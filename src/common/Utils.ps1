################################################################################
# MIT License
#
# Copyright (c) Microsoft Corporation. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Filename: Utils.ps1
# Description: Common/shared utility function
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 8/16/2018 9:59 AM
#
# Last Modified On: 9/17/2018 10:54 AM (UTC+2)
#################################################################################
Set-StrictMode -Version Latest

# Include helper files/functions
. (Join-Path -Path $PSScriptRoot -ChildPath Files.ps1)
. (Join-Path -Path $PSScriptRoot -ChildPath Registry.ps1)
. (Join-Path -Path $PSScriptRoot -ChildPath Security.ps1)
. (Join-Path -Path $PSScriptRoot -ChildPath Writers.ps1)

# setup some useful values
$ComputerName = $Env:COMPUTERNAME

Add-Type -ErrorAction SilentlyContinue -TypeDefinition @"
    public enum OPDStatus
    {
        ERROR = 1,
        WARNING = 2,
        INFO = 4,
        SUCCESS = 8
    }
"@

Add-Type -ErrorAction SilentlyContinue -TypeDefinition @"
    public enum OPDLogLevel { SILENT, ERROR, WARNING, INFO, VERBOSE, DEBUG }
"@

Filter FormatBytes
{
    param ($bytes,$precision='0')
    trap [Exception]
    {
        Write-ToErrorDebugReport -ErrorRecord $_ -ScriptErrorText "[FormatBytes] - Bytes: $bytes / Precision: $precision" -InvokeInfo $MyInvocation
        continue
    }

    if ($null -eq $bytes)
    {
        $bytes = $_
    }

    if ($null -ne $bytes)
    {
        $bytes = [double] $bytes
        foreach ($i in ("Bytes","KB","MB","GB","TB"))
        {
            if (($bytes -lt 1000) -or ($i -eq "TB"))
            {
                $bytes = ($bytes).tostring("F0" + "$precision")
                return $bytes + " $i"
            }
            else
            {
                $bytes /= 1KB
            }
        }
    }
}

function Get-Count()
{
    Begin
    {
        $n = 0
    }
    Process
    {
        if($null -ne $input)
        {
            $n += 1
        }
    }
    End
    {
        return $n
    }
}

function Get-OPDTemp()
{
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    param
    (
        [Parameter(Mandatory = $false)]
        [String] $LogFolder,

        [Parameter(Mandatory = $false)]
        [String] $Extension,

        [Parameter(Mandatory = $false)]
        [String] $Filename
    )

    if([String]::IsNullOrEmpty($LogFolder)) { $LogFolder = $env:TEMP+"\OPD"}
    if([String]::IsNullOrEmpty($Extension)) { $Extension = ".txt"}

    if ([String]::IsNullOrEmpty($Filename))
    {
        $tempFileName = (Get-Date -Format o).Replace(':', '-').Replace('.', '-')
        $tempFileName = $tempFileName + $Extension
    }
    else
    {
        $tempFileName = $Filename + $Extension
    }

    # Does the folder exist? If not, create it
    if($false -eq (Test-Path -Path $LogFolder))
    {
        New-Item -ItemType Directory -Path $LogFolder | Out-Null
    }

    return($LogFolder + "\" + $tempFileName)
}

function Invoke-Scenario
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [object] $Scenario
    )

    $global:CommonStrings.'ExecutingScenario' -f $Scenario.Name, $Scenario.Description | Write-ToStdOut
    $OriginalProgressPreference = $global:ProgressPreference

    try
    {
        Set-Variable -Name ProgressPreference -Scope 'Global' -Value "Continue" -Force

        if ($Scenario.Expiry -ge (Get-Date))
        {
            Write-VerboseWriter("Invoking scenario {0}" -f $Scenario.Name)

            # Prior to invoking the scenario, let's make sure that we have
            # cleared any prior invocations (same session) of this scenario and any cached
            # analyzer results (#29186)
            $Scenario.AnalyzerDefinitions | ForEach-Object { $_.Executed = $false }
            $Scenario.Success = $true
            $Scenario.Results = $null

            $elapsedTime      = Measure-Command {$Scenario.Execute()}
            $Scenario.Metrics = "ET={0}" -f $elapsedTime.Milliseconds

            Write-OPDEventLog -Scenario $Scenario
        }
    }
    catch
    {
        # we can write this exception to the event log but we do not have a defined method to bubble it up to the UI of the user
        Get-ExceptionInsight -ErrorMessage "An Exception has occurred while executing the scenario $($Scenario.Name): " `
                             -ErrorObject $_
        $Scenario.Success = $false
    }
    finally
    {
        Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
    }
}

function Invoke-Analyzer
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [object] $Analyzer,

        [Parameter(Mandatory=$false)]
        [object] $Obj,

        [Parameter(Mandatory=$false)]
        [object[]] $ParameterDefinitions = $null
    )

    $OriginalProgressPreference = $global:ProgressPreference

    try
    {
        if ($Analyzer.Expiry -ge (Get-Date))
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "Continue" -Force

            Write-VerboseWriter("Invoking analyzer {0}" -f $Analyzer.Name)

            # Prior to invoking the analyzer, let's make sure that we have
            # cleared any prior invocations (same session) of this analyzer
            $Analyzer.Success  = $true
            $Analyzer.Executed = $false

            $elapsedTime       = Measure-Command {$Analyzer.Execute($Obj)}
            $Analyzer.Metrics  = "ET={0}" -f $elapsedTime.Milliseconds

            if ($Analyzer.Executed)
            {
                # What is the lowest status from the rules
                $status = ($Analyzer.RuleDefinitions.Status | Measure-Object -Minimum).Minimum

                $Analyzer.Status = $status
            }

            Write-OPDEventLog -Analyzer $Analyzer
        }
    }
    catch
    {
        # we can write this exception to the event log but we do not have a defined method to bubble it up to the UI of the user
        Get-ExceptionInsight -ErrorMessage "An Exception has occurred while executing the analyzer $($Analyzer.Name): " `
                             -ErrorObject $_.ScriptStackTrace #$_
        $Analyzer.Success = $false
    }
    finally
    {
        Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
    }

    if ($false -eq $Analyzer.Success)
    {
        Write-VerboseWriter("Analyzer {0} failed" -f $Analyzer.Name)
        $global:CommonStrings.'AnalyzerFailure' -f  $Analyzer.Name | Write-ToStdOut
    }
    else
    {
        Write-VerboseWriter("Analyzer {0} succeeded" -f $Analyzer.Name)
        $global:CommonStrings.'AnalyzerSuccess' -f $Analyzer.ExecutionId, `
            $Analyzer.Description, `
            $Analyzer.Success | Write-ToStdOut

        $global:CommonStrings.'AnalyzerCompleted' -f $Analyzer.Name | Write-ToStdOut
    }
}

function Invoke-Rule
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [object] $Rule,

        [Parameter(Mandatory=$false)]
        [object] $Obj
    )

    $global:CommonStrings.'ExecutingRule' -f $Rule.ExecutionId, `
        "Rule", `
        $Rule.Name, `
        "Starting" | Write-ToStdOut

    $OriginalProgressPreference = $global:ProgressPreference

    try
    {
        Set-Variable -Name ProgressPreference -Scope 'Global' -Value "Continue" -Force

        if ($Rule.Expiry -ge (Get-Date))
        {
            Write-VerboseWriter("Invoking rule {0}" -f $Rule.Name)

            # Prior to invoking the rule, let's make sure that we have
            # cleared any prior invocations (same session) of this rule
            $Rule.Success = $true

            $elapsedTime  = Measure-Command {$Rule.Execute($Obj)}
            $Rule.Metrics = "ET={0}" -f $elapsedTime.Milliseconds

            if ($Rule.Success -ne $true)
            {
                $Rule.Status = $Rule.Insight.Status
            }

            if ($Rule.Success)
            {
                Write-VerboseWriter("Rule {0} passed" -f $Rule.Name)
            }
            else
            {
                Write-VerboseWriter("Rule {0} failed" -f $Rule.Name)
            }

            Write-OPDEventLog -Rule $Rule
        }
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        $Rule.Insight.Detection = $global:InsightDetections.'IDCommandNotFoundException' -f $_.Exception.Message
        $Rule.Insight.Action    = $global:InsightActions.'IDCommandNotFoundException'
        $Rule.Status            = [OPDStatus]::ERROR
        $Rule.Success           = $false
    }
    catch [System.Management.Automation.PropertyNotFoundException]
    {
        $this.Insight.Detection = $global:InsightDetections.'IDPropertyNotFoundException' -f $_.Exception.Message
        $this.Insight.Action    = $global:InsightActions.'IDPropertyNotFoundException'
        $Rule.Status            = [OPDStatus]::ERROR
        $this.Success           = $false
    }
    catch
    {
        $Rule.Insight = Get-ExceptionInsight "An Exception has occurred while executing the rule $($Rule.Name): " $_.ScriptStackTrace #Exception.Message
        $Rule.Status  = [OPDStatus]::ERROR
        $Rule.Success = $false
    }
    finally
    {
        Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
    }

    if ($false -eq $Rule.Success)
    {
        $insight = $Rule.Insight

        if ($null -eq $insight)
        {
            $global:CommonStrings.'RuleNoInsight' -f $Rule.Name | Write-ToStdOut
        }
        else
        {
            $global:CommonStrings.'RuleHasInsight' | Write-ToStdOut
            $global:CommonStrings.'InsightDetection' -f $insight.Detection | Write-ToStdOut
            $global:CommonStrings.'InsightAction' -f $insight.Action | Write-ToStdOut
        }
    }
    else
    {

        $global:CommonStrings.'RuleCompleted' -f $Rule.ExecutionId, `
            "Rule", `
            $Rule.Name, `
            "Ending", `
            $Rule.Success | Write-ToStdOut
    }
}

$StdOutFileName = Get-OPDTemp


function Test-WindowsFirewallEnabled
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName
    )

    $windowsFirewallEnabled = $false
    $regPath = "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile"
    $regName = "EnableFirewall"

    [bool]$windowsFirewallEnabled = Invoke-RegistryGetValue -MachineName $ComputerName `
                                        -Subkey "System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" `
                                        -GetValue "EnableFirewall"

    return $windowsFirewallEnabled
}

function Get-EventID
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Event
    )

    $eventID = $global:EventIDs.$Event

    return [Uint16]$eventID
}

function Get-FirewallRules
{
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName
    )

    $firewallRules = @()

    if ($ComputerName -eq $Env:COMPUTERNAME)
    {
        # Process local machine registry
        $keys = (Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules').PSObject.Members
    }
    else
    {
        # Process remote machine registry
        $keys = Invoke-Command -ComputerName $ComputerName {(Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules').PSObject.Members}
    }

    foreach ($key in $keys.Value)
    {
        if ($key -match "^(?:.*)\|Action=(?<Action>\w+)\|Active=(?<Active>\w+)\|Dir=(?<Direction>\w+)\|.*(LPort=(?<LPort>\w+)|RPort=(?<RPort>\w+))(?:.*)$")
        {
            $firewallRule = New-Object PSObject

            Add-Member -InputObject $firewallRule -MemberType NoteProperty -Name "Action" -Value $Matches.Action
            Add-Member -InputObject $firewallRule -MemberType NoteProperty -Name "Direction" -Value $Matches.Direction
            Add-Member -InputObject $firewallRule -MemberType NoteProperty -Name "Active" -Value $Matches.Active
            Add-Member -InputObject $firewallRule -MemberType NoteProperty -Name "LPort" -Value $null
            Add-Member -InputObject $firewallRule -MemberType NoteProperty -Name "RPort" -Value $null

            if ($Matches.ContainsKey('LPort'))
            {
                $firewallRule.LPort = $Matches.LPort
            }

            if ($Matches.ContainsKey('RPort'))
            {
                $firewallRule.RPort = $Matches.RPort
            }

            $firewallRules += $firewallRule
        }
    }

    return $firewallRules
}

############################################################
## public function to create an Exception Insight
##
## Owner: Stefan Goßner <stefang@microsoft.com>
## Last Modified On: 10/30/2018 14:13 (UTC+2)
############################################################

function Get-ExceptionInsight
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $ErrorMessage,

        [Parameter(Mandatory=$true)]
        [object] $ErrorObject
    )
    $ResourceStrings = DATA
    {
        ConvertFrom-StringData @'
            idExecution    = Execution Id
'@
    }

    $insight = [IDException]::new()

    # keep track of the Id of the Exception insight to ensure that we send exception and
    # call stack to application insights for further investigation
    $global:ExceptionInsightId = $insight.Id

    $ExceptionObject = @( $ErrorObject.Exception.InnerException, $ErrorObject.Exception )[($null -eq $ErrorObject.Exception.InnerException)]

    $ExceptionRecord = New-Object PSObject -property @{
        Exception  = $ExceptionObject.GetType().FullName
        StackTrace = $ErrorObject.ScriptStackTrace
    }

    $ExceptionText = $ExceptionRecord | Format-List Exception, StackTrace | Out-String

    $insight.Detection = ($ErrorMessage + $ExceptionText).Trim() + [Environment]::NewLine

    $message = "{0}`r`n`r`n{1}" -f $ResourceStrings.idExecution, $insight.Detection

    Write-EventLog -LogName $global:EventLogName -Source $global:scriptName -EntryType Error `
        -Message $message -EventId 9002

    return $Insight
}

#region Telemetry
############################################################
## function to upload telemetry data to Microsoft
##
## Owner: Stefan Goßner <stefang@microsoft.com>
## Last Modified On: 11/02/2018 09:12 (CET)
############################################################

$global:InsightCache = @{}
$global:ExceptionInsightId = [Guid]::Empty

function Initialize-InsightCache
{
    if ($global:InsightCache.Count -eq 0)
    {
        # populate InsightCache
        $insights = Get-ChildItem -Path (Join-Path -Path (Split-Path -Path $Global:scriptPath) -ChildPath "mode\$Mode\insights") -Recurse -Filter ID*.ps1

        foreach ($insight in $insights)
        {
            try
            {
                $insightDef                          = New-Object -TypeName $insight.BaseName
                $global:InsightCache[$insightDef.Id] = $insightDef
            }
            catch
            {
                # we ignore insights we have not instantiated. Nothing to worry about here
                Write-VerboseWriter("Expected exception caught - nothing to worry about.")
            }
        }
    }
}

#region Task 33803: Prompt end user for up/down on diagnosing problem
function Get-UserFeedback
{
    try
    {
        $Failure = New-Object System.Management.Automation.Host.ChoiceDescription "&$($global:OPDStrings.'No')"
        $Success = New-Object System.Management.Automation.Host.ChoiceDescription "&$($global:OPDStrings.'Yes')"
        $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Failure, $Success)

        $Transmit  = $host.UI.PromptForChoice(
                        "",
                        $global:OPDStrings.'IssueDiagnosed',
                        $Options,
                        1
                    )

        Write-VerboseWriter("{0} {1}" -f $global:OPDStrings.'IssueDiagnosed', ($options[$Transmit].Label))
    }
    catch
    {
        throw $_
    }

    return $Transmit
}

function Send-YesNoDataToMicrosoft
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $ResolvedIssue
    )

    try
    {
        $YesAction = New-Object System.Management.Automation.Host.ChoiceDescription "&$($global:OPDStrings.'Yes')"
        $NoAction  = New-Object System.Management.Automation.Host.ChoiceDescription "&$($global:OPDStrings.'No')"
        $Options   = [System.Management.Automation.Host.ChoiceDescription[]]($NoAction, $YesAction)
        $Transmit  = $host.UI.PromptForChoice(
                        "",
                        $global:OPDStrings.'ShareResults',
                        $Options,
                        1
                    )

        if ($true -eq $Transmit)
        {
            $AIInfo = @{
                Culture   = ([System.Threading.Thread]::CurrentThread.CurrentCulture).Name
                EventDate = (Get-Date).ToString("u")
                Product   = $global:OPDTitle
                Version   = $global:OPDVersion
                Resolved  = $ResolvedIssue
            }

            Write-VerboseWriter("Sending success/failure results to Microsoft")
            Write-Telemetry -Scenario $global:ExecutionId -Operation "IssueResolution" -Properties $AIInfo
        }
    }
    finally
    {
        if ($true -eq $Transmit)
        {
            Update-Telemetry
        }
    }
}
#endregion

function Send-TelemetryDataToMicrosoft
{
    $ResourceStrings = DATA
    {
        ConvertFrom-StringData @'
            idAction           = Action
            idAnalyzer         = Analyzer Id
            idDescription      = Description
            idDetection        = Detection
            idExceptionInsight = idException
            idExecution        = Execution Id
            idID               = ID
            idInsight          = Insight Id
            idMessage          = Message
            idMetrics          = Metrics
            idName             = Name
            idNoIssues         = No Issues Detected
            idRule             = Rule Id
            idScenario         = Scenario Id
            idStatus           = Status
            msgError           = Error
            msgInformation     = Information
            msgWarning         = Warning
'@
    }

    # get event log data from last hour (a scenario should never run for longer than an hour
    $EventLogData = Get-EventLog -LogName OPDLog -After (get-date).AddHours(-1) |
        Where-Object {$_.Message.Contains($global:ExecutionId)}

    # loop over all event log entries for current scenario
    for ($i = 0; $i -lt $EventLogData.Count; $i++)
    {
        $analyzerId   = $null
        $description  = $null
        $executionId  = $null
        $id           = $null
        $insightId    = $null
        $insightName  = $null
        $message      = $null
        $messageLines = [System.Collections.ArrayList] @()
        $metrics      = $null
        $name         = $null
        $ruleId       = $null
        $scenarioId   = $null
        $status       = $null

        $entryType    = $EventLogData[$i].EntryType.ToString()
        $eventDate    = $EventLogData[$i].TimeGenerated.ToString("u")
        $eventId      = $EventLogData[$i].EventID
        $index        = $EventLogData[$i].Index
        $source       = $EventLogData[$i].Source

        $lines = $EventLogData[$i].Message -split [Environment]::NewLine

        $percentComplete = [math]::Round(($i/$EventLogData.Count)*100, 2)

        Write-Progress -Activity $global:OPDStrings.'TelemetryUploading' `
                       -Status ($global:OPDStrings.'PercentComplete' -f $percentComplete) `
                       -PercentComplete $percentComplete

        foreach ($line in $lines)
        {
            switch -Regex ($line)
            {
                "^(?:$($ResourceStrings.idName)\s*:\s*)(?<Name>.*)$"
                {
                    $name = $Matches.Name
                }

                "^(?:$($ResourceStrings.idDescription)\s*:\s*)(?<Description>.*)$"
                {
                    $description = $Matches.Description
                }

                "^(?:$($ResourceStrings.idID)\s*:\s*)(?<ID>[0-9A-Fa-f]{8}[-]?([0-9A-Fa-f]{4}[-]){3}[0-9A-Fa-f]{12})$"
                {
                    $id = $Matches.Id
                }

                "^(?:$($ResourceStrings.idExecution)\s*:\s*)(?<ExecutionId>[0-9A-Fa-f]{8}[-]?([0-9A-Fa-f]{4}[-]){3}[0-9A-Fa-f]{12})$"
                {
                    $executionId = $Matches.ExecutionId
                }

                "^(?:$($ResourceStrings.idInsight)\s*:\s*)(?<InsightId>[0-9A-Fa-f]{8}[-]?([0-9A-Fa-f]{4}[-]){3}[0-9A-Fa-f]{12})$"
                {
                    $insightId = $Matches.InsightId
                }

                "^(?:$($ResourceStrings.idStatus)\s*:\s*)(?<Status>.*)$"
                {
                    $status = $Matches.Status
                }

                "^(?:$($ResourceStrings.idScenario)\s*:\s*)(?<ScenarioId>.*)$"
                {
                    $scenarioId = $Matches.ScenarioId
                }

                "^(?:$($ResourceStrings.idAnalyzer)\s*:\s*)(?<AnalyzerId>.*)$"
                {
                    $analyzerId = $Matches.AnalyzerId
                }

                "^(?:$($ResourceStrings.idRule)\s*:\s*)(?<RuleId>.*)$"
                {
                    $ruleId = $Matches.RuleId
                }

                "^(?:$($ResourceStrings.idMetrics)\s*:\s*)(?<Metrics>.*)$"
                {
                    $metrics = $Matches.Metrics
                }

                default
                {
                    if (![string]::IsNullOrEmpty($line) -or $messageLines.Count -gt 0)
                    {
                        $messageLines += $line
                    }
                }
            }
        }

        if ($null -eq $insightId -or $insightId -eq $global:ExceptionInsightId)
        {
            # for exceptions and messages without insights we can take the complete text as it does not include EUII
            $message = $messageLines -join [Environment]::NewLine
        }
        else
        {
            # for everything else we well replace Detection and Action with the default values
            Initialize-InsightCache

            $insight     = $global:InsightCache[[Guid]::new($insightId)]
            $insightName = $insight.Name
            $message     = $ResourceStrings.idDetection + " : " + $insight.Detection + [Environment]::NewLine + $ResourceStrings.idAction + " : " + $insight.Action
        }

        $aiInfo = @{
            AnalyzerId  = $analyzerId
            Culture     = ([System.Threading.Thread]::CurrentThread.CurrentCulture).Name
            Description = $description
            EntryType   = $entryType
            EventDate   = $eventDate
            EventId     = $eventId
            ExecutionId = $global:ExecutionId
            Id          = $id
            Index       = $index
            Insight     = $insightName
            InsightId   = $insightId
            Message     = $message
            Metrics     = $metrics
            Name        = $name
            Product     = $global:OPDTitle
            RuleId      = $ruleId
            ScenarioId  = $scenarioId
            Source      = $source
            Status      = $status
            Version     = $global:OPDVersion
        }

        # write telemetry data record
        Write-Telemetry -Scenario $global:ExecutionId -Operation $name $aiInfo
    }

    Write-Progress -Activity $global:OPDStrings.'TelemetryUploading' `
                   -Complete
    # flush data
    Update-Telemetry
}

#endregion

#region EULA
function Approve-EULA
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [String] $Eula,

        [Switch] $AcceptEula,

        [Parameter(Mandatory = $true)]
        [string] $Product
    )

    $eulaInformation    = Get-EULAInformation -Product $Product

    $installedVersion   = $eulaInformation.Version
    $timeStamp          = $eulaInformation.InstallationDate
    $eulaAcceptance     = [bool]$eulaInformation.EULA
    $installationFolder = $eulaInformation.Location
    $accepted           = $null
    $eventID            = $null
    $result             = @{}

    if (($false -eq [bool]$eulaInformation.EULA) -or ([System.Version]$global:OPDVersion).CompareTo($installedVersion) -ne 0)
    {
        if (!$AcceptEula)
        {
            Clear-Host
            $yes      = New-Object System.Management.Automation.Host.ChoiceDescription "&Accept", "Accept the EULA"
            $no       = New-Object System.Management.Automation.Host.ChoiceDescription "&Decline", "Do not accept the EULA"
            $options  = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
            $accepted = $host.ui.PromptForChoice("", $Eula, $options, 1)

        }
        else
        {
            $accepted = 0
        }

        if ($accepted -eq 0)
        {
            $eulaAcceptance     = $true
            $installedVersion   = [System.Version]$global:OPDVersion
            $timeStamp          = (Get-Date).ToUniversalTime()
            $installationFolder = Split-Path ((Get-Variable MyInvocation -Scope 1).Value).PSCommandPath

            $registryKey = Join-Path -Path $global:OPD_REGKEY -ChildPath $Product

            New-Item -Path $registryKey -Force                                                  | Out-Null
            New-ItemProperty -Path $registryKey -Name Version -Value $installedVersion -Force   | Out-Null
            New-ItemProperty -Path $registryKey -Name EULA -Value ([int]$eulaAcceptance) -Force | Out-Null
            New-ItemProperty -Path $registryKey -Name InstallationDate -Value $timeStamp        | Out-Null
            New-ItemProperty -Path $registryKey -Name Location -Value $installationFolder       | Out-Null
        }
        else
        {
            $eulaAcceptance = $false
        }
    }

    $result = @{
        Version          = $installedVersion
        EULA             = $eulaAcceptance
        InstallationDate = $timeStamp
        Location         = $installationFolder
    }

    return $result
}

Function Get-EULAInformation
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $Product
    )

    $eulaInformation    = @{}
    $installedVersion   = [System.Version]"0.0.0.0"
    $timeStamp          = [System.DateTime]::MinValue
    $eulaAccepted       = $false
    $installationFolder = Get-ScriptDirectory

    # Check to see if the registry value is there
    $registryKey = Join-Path -Path $global:OPD_REGKEY -ChildPath $Product

    if (Test-Path -Path $registryKey)
    {
        if ($null -ne (Get-ItemProperty -Path $registryKey).Version -and ![String]::IsNullOrEmpty((Get-ItemProperty -Path $registryKey).Version))
        {
            $installedVersion   = [System.Version](Get-ItemProperty -Path $registryKey).Version
        }

        if ($null -ne (Get-ItemProperty -Path $registryKey).EULA -and ![String]::IsNullOrEmpty((Get-ItemProperty -Path $registryKey).EULA))
        {
            $eulaAccepted       = [bool](Get-ItemProperty -Path $registryKey).EULA
        }

        if ($null -ne (Get-ItemProperty -Path $registryKey).InstallationDate -and ![String]::IsNullOrEmpty((Get-ItemProperty -Path $registryKey).InstallationDate))
        {
            $timeStamp          = [System.DateTime]::Parse((Get-ItemProperty -Path $registryKey).InstallationDate)
        }

        if ($null -ne (Get-ItemProperty -Path $registryKey).Location -and ![String]::IsNullOrEmpty((Get-ItemProperty -Path $registryKey).Location))
        {
            $installationFolder = [System.IO.FileInfo](Get-ItemProperty -Path $registryKey).Location
        }
    }

    $eulaInformation = @{
        Version          = $installedVersion
        EULA             = [bool]$eulaAccepted
        InstallatioNDate = $timeStamp
        Location         = $installationFolder
    }

    return $eulaInformation
}
#endregion

function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value

    return (Split-Path $Invocation.PSCommandPath)
}

function Get-PowershellVersion
{
    return [System.Version]$PSVersionTable.PSVersion
}

function Test-MinimumPowershellVersion
{
    $prereq = New-Object PSObject
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Description" -Value "Windows PowerShell Version"
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Minimum Required Version" -Value $global:MinimumPowershellVersion
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Installed Version" -Value ((Get-PowershellVersion).ToString())
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Passed" -Value ((Get-PowershellVersion).CompareTo($global:MinimumPowershellVersion) -ge 0)
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Help" -Value $global:UpgradeExistingWindowsPowerShell

    return $prereq
}

function Test-MinimumNETFramework
{
    param
    (
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Range',
            Position = 0)]
        [String]$MinimumVersion,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'Range',
            Position = 1)]
        [String]$MaximumVersion,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'Exact')]
        [string]$ExactVersion
    )

    $dotNetFramework = Get-NETFrameworkVersion

    $prereq = New-Object PSObject
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Description" -Value ".NET Framework"
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Installed Version" -Value ($dotNetFramework.ToString())
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Help" -Value $global:InstallDotNetFramework

    if (-not [string]::IsNullOrEmpty($ExactVersion))
    {
        $Passed          = ($dotNetFramework.CompareTo([System.Version]$ExactVersion) -eq 0)
        $RequiredVersion = "{0} == {1}" -f $dotNetFramework.ToString(), $ExactVersion

        Write-VerboseWriter("{0} == {1}" -f $dotNetFramework.ToString(), $ExactVersion )
    }
    elseif ([string]::IsNullOrEmpty($MinimumVersion) -and -not [string]::IsNullOrEmpty($MaximumVersion))
    {
        $Passed          = ($dotNetFramework.CompareTo([System.Version]$MaximumVersion) -le 0)
        $RequiredVersion = "<= {0}" -f $MaximumVersion

        Write-VerboseWriter("{0} <= {1}" -f $dotNetFramework.ToString(), $MaximumVersion)
    }
    elseif (-not [string]::IsNullOrEmpty($MinimumVersion) -and [string]::IsNullOrEmpty($MaximumVersion))
    {
        $Passed          = ($dotNetFramework.CompareTo([System.Version]$MinimumVersion) -ge 0)
        $RequiredVersion = ">= {0}" -f $MinimumVersion

        Write-VerboseWriter("{0} >= {1}" -f $dotNetFramework.ToString(), $MinimumVersion)
    }
    elseif (-not ([string]::IsNullOrEmpty($MinimumVersion) -and [string]::IsNullOrEmpty($MaximumVersion)))
    {
        $Passed          = ($dotNetFramework.CompareTo([System.Version]$MinimumVersion) -ge 0) -and  ($dotNetFramework.CompareTo([System.Version]$MaximumVersion) -le 0)
        $RequiredVersion = "{0} <= {1} <= {2}" -f $MinimumVersion, $dotNetFramework.ToString(), $MaximumVersion

        Write-VerboseWriter($RequiredVersion)
    }

    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Minimum Required Version" -Value $RequiredVersion
    Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Passed" -Value $Passed

    return $prereq
}

function Test-OPDPreRequisites
{
    $passed = $true

    $global:OPDPreRequisites += Test-MinimumPowershellVersion

    $global:OPDPreRequisites += Test-MinimumNETFramework -MinimumVersion $global:MinimumNetFramework

    foreach($prereq in $global:OPDPreRequisites)
    {
        Write-VerboseWriter("Description: {0}" -f $prereq.Description)
        Write-VerboseWriter("   Expected: {0}" -f ($prereq.'Minimum Required Version').ToString())
        Write-VerboseWriter("     Actual: {0}" -f ($prereq.'Installed Version').ToString())
        Write-VerboseWriter("     Passed: {0}" -f $prereq.Passed.ToString())

        if (-not $prereq.Passed)
        {
            $passed = $false
        }
    }

    return $passed
}

function Test-ApproveEula
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $Product
    )

    $eula = Approve-EULA -Eula $global:EULA -AcceptEula:$AcceptEula -Product $Product

    return ($eula.Count -ne 0 -and $eula.EULA -eq $true)
}

#region Resource Strings
function Initialize-ModeResourceStrings
{
    param
    (
        [Parameter(Mandatory = $false)]
        [string] $Root = $PSScriptRoot,

        [Parameter(Mandatory = $true)]
        [String] $MyMode
    )

    try
    {
        Add-Type -AssemblyName System.Windows.Forms

        # Let's load the event id resource file
        $eventIDs = "$Root\mode\$MyMode\common\EventIDs.psd1"

        if (Test-Path -Path $eventIDs)
        {
            New-Variable -Name "ProductEventIDs" `
                -Description 'ProductEventIDs Event ID resources' `
                -Scope Global `
                -Force `
                -Value (Import-PowerShellDataFile -Path $eventIDs)
        }

        # Resource string files that should be loaded
        $resourceFiles  = @('AnalyzerDescriptions','InsightActions', 'InsightDetections' )
        $resourceFiles += @('RuleDescriptions','ScenarioDescriptions')
        $resourceFiles += @('AreaTitles','AreaDescriptions')
        $resourceFiles += @('ParameterDescriptions', 'ParameterExampleText', 'ParameterPrompts')
        $resourceFiles += @('MiscStrings')

        if(-not (Get-Variable -Name OPDOptions -ErrorAction SilentlyContinue))
        {
            $culture = "en-US"
        }
        else
        {
            $culture = $global:OPDOptions.OriginalCulture
        }

        foreach ($resourceFile in $resourceFiles)
        {
            # Target resource file
            $resourceStrings = Join-Path -Path "$Root\Mode\$MyMode\locale\$culture" -ChildPath "$resourceFile.psd1"

            # Check to see if we have a resource file for this locale. If not, default to en-US
            if ($false -eq (Test-Path -Path $resourceStrings))
            {
                $culture = [System.Globalization.CultureInfo]"en-US"
                $stringsFile = Join-Path -Path "$Root\Mode\$MyMode\locale\$culture" -ChildPath "$resourceFile.psd1"

                #Write-EventLog -LogName $global:EventLogName -Source $global:scriptName -EntryType Warning `
                #    -Message ("Missing resource file: '{0}'. Default to: '{1}'" -f (Split-Path -Path $resourceStrings -Leaf), `
                #                                                                   (Split-Path -Path $stringsFile -Leaf)) `
                #    -EventId 9818
            }

            New-Variable -Name $resourceFile `
                -Description 'Resource file' `
                -Scope Global `
                -Force `
                -Value (
                    Import-LocalizedData -BaseDirectory  "$Root\Mode\$MyMode\locale\$culture" `
                                         -UICulture $culture `
                                         -FileName $resourceFile
                )
        }

        Join-EventIDs
    }
    catch
    {
        throw "Unable to load resource files: {0}" -f $_
    }
}

function Initialize-CommonResourceStrings
{
    param
    (
        [Parameter(Mandatory = $false)]
        [String] $Root = $PSScriptRoot
    )

    try
    {
        Add-Type -AssemblyName System.Windows.Forms

        ## Let's load the event id resource file
        $resourceFile = Join-Path -Path "$Root\common" -ChildPath EventIDs.psd1

        New-Variable -Name "OPDEventIDs" `
            -Description 'OPD Event ID resources' `
            -Scope Global `
            -Force `
            -Value (Import-PowerShellDataFile -Path $resourceFile)

        # Resource string files that should be loaded
        $resourceFiles  = @('CommonStrings', 'OPDStrings')

        if(-not (Get-Variable -Name OPDOptions -ErrorAction SilentlyContinue))
        {
            $culture = "en-US"
        }
        else
        {
            $culture = $global:OPDOptions.OriginalCulture
        }

        foreach ($resourceFile in $resourceFiles)
        {
            # Target resource file
            $resourceStrings  = Join-Path -Path "$Root\locale\$culture" -ChildPath "$resourceFile.psd1"

            # Check to see if we have a resource file for this locale. If not, default to en-US
            if ($false -eq (Test-Path -Path $resourceStrings))
            {
                $culture = [System.Globalization.CultureInfo]"en-US"
                $stringsFile = Join-Path -Path "$Root\local\$culture" -ChildPath "$resourceFile.psd1"

                #Write-EventLog -LogName $global:EventLogName -Source $global:scriptName -EntryType Warning `
                #    -Message ("Missing resource file: '{0}'. Default to: '{1}'" -f (Split-Path -Path $resourceStrings -Leaf), `
                #                                                                   (Split-Path -Path $stringsFile -Leaf)) `
                #    -EventId 9818
            }

            New-Variable -Name $resourceFile `
                -Description 'Resource file' `
                -Scope Global `
                -Force `
                -Value (Import-LocalizedData -BaseDirectory "$Root\locale\$culture" -UICulture $culture -FileName $resourceFile)
        }
    }
    catch
    {
        throw "Unable to load resource files: {0}" -f $_
    }
}

function Initialize-ResourceString
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Root,

        [Parameter(Mandatory = $true)]
        [String] $MyMode

    )
        Initialize-CommonResourceStrings -Root $Root
        Initialize-ModeResourceStrings -Root $Root -MyMode $MyMode
}

function Join-EventIDs
{
    try
    {
        Add-Type -AssemblyName System.Windows.Forms

        $eventIDs = $global:OPDEventIds + $global:ProductEventIDs

        New-Variable -Name 'EventIDs' `
                     -Description 'OPD/Product Event ID resources' `
                     -Scope Global `
                     -Force `
                     -Value $eventIDs
    }
    catch
    {
        throw "Unable to combine EventID resource files: {0}" -f $_
    }
}

#endregion

#region UpgradeOPD
function Get-OPDVersion
{
    $currentVersion = $null
    $defaultVersion = "0.0.0.0"

    if (Get-Variable -Scope Global OPDVersion -ErrorAction Ignore)
    {
        $currentVersion = $global:OPDVersion
    }
    else
    {
        $currentVersion = $defaultVersion
    }

    return [System.Version]$currentVersion
}

function Test-UpgradeAvailable
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $Product
    )

    # Let's get the currently running version
    return Get-LatestOPDRelease -CurrentVersionNumber (Get-OPDVersion) -Product $Product
}

function Get-LatestOPDRelease
{
    param
    (
        [String] $CurrentVersionNumber,

        [Parameter(Mandatory = $true)]
        [string] $Product
    )

    $releaseParams = @{
        Uri    = "https://api.github.com/repos/$global:GitHubUserName/$Product/releases";
        Method = 'GET';
    }

    try
    {
        $releases =  Invoke-RestMethod @releaseParams

        $availableReleases = @()

        foreach($tag in ($releases | ForEach-Object {$_.tag_name}))
        {
            $assets = ($releases | Where-Object {$_.tag_name -eq $tag}).assets
            if ($assets.Length -ne 0)
            {
                $obj = New-Object PSObject
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "Type" -Value $tag.Split('.')[1]
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "Version" -Value ([System.Version]$tag)
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "URL" -Value $assets.browser_download_url
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "CurrentVersion" -Value  ([System.Version]$CurrentVersionNumber)

                $availableReleases += $obj
            }
        }

        $latestRelease = $availableReleases | `
                            Where-Object {$_.Type -eq $CurrentVersionNumber.Split('.')[1]} | `
                            Sort-Object -Property Version -Descending | `
                            Select-Object -First 1

        if ($latestRelease.CurrentVersion -ge $latestRelease.Version)
        {
            $latestRelease = $null
        }
    }
    catch
    {
        $latestRelease = $null
    }

    return $latestRelease
}


function Approve-Upgrade
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $Product
    )

    $upgrade          = [string]::Empty
    $UpgradeAvailable = Test-UpgradeAvailable -Product $Product

    if ($UpgradeAvailable)
    {
        $yes     = New-Object System.Management.Automation.Host.ChoiceDescription "&$($global:OPDStrings.'Yes')", $global:OPDStrings'UpgradeOPD'
        $no      = New-Object System.Management.Automation.Host.ChoiceDescription "&$($global:OPDStrings.'No')", $global:OPDStrings.'KeepCurrentOPD'
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $upgrade = $host.ui.PromptForChoice(
                        "", `
                        ($global:OPDStrings.'UpgradeAvailable' -f $UpgradeAvailable.Version.ToString(), $global:OPDTitle), `
                        $options, `
                        1)
    }

    if ($upgrade -eq 0)
    {
        $currentInstallInformation = Get-EULAInformation -Product $Product

        $tempFile = ([System.IO.Path]::GetTempFileName()) -replace '\.tmp', '.ps1'

        $startupFolder = Get-ScriptDirectory
        $upgradeScript = Join-Path -Path "$($startupFolder)\common" -ChildPath Update-OPD.ps1

        Copy-Item -Path $upgradeScript -Destination $tempFile -Force

        $command        = "& '$($tempFile)' -CurrentVersion $($currentInstallInformation.Version.ToString()) -InstallationFolder $($currentInstallInformation.Location.Fullname) -Product $Mode"
        $bytes          = [Text.Encoding]::UniCode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)

        Start-Process "$psHome\PowerShell.exe" -Verb Runas -ArgumentList "-NoExit", ("-EncodedCommand $encodedCommand")

        Stop-Process -Id $PID
    }
}
#endregion

#region Helper functions
function Get-UserInput([object] $ParameterDefinitions)
{
    $validInput = $null

    if ($null -ne $ParameterDefinitions)
    {
        foreach ($pd in $ParameterDefinitions)
        {
            $validInput = $false

            if ($null -eq $pd.Value -or `
                $pd.LastModified -eq [System.DateTime]::MinValue -or `
                $pd.LastModified -lt [System.DateTime]::Now)
            {
                while ($false -eq $validInput)
                {
                    $title = Get-Title -Name $pd.Name

                    if($pd.ValueType -eq 'Secure')
                    {
                        $pd.Value = Read-Host -Prompt "`t$($title) $($pd.Prompt)" -AsSecureString
                    }
                    elseif($pd.ValueType -eq 'Prompt')
                    {
                        $pd.Value = Read-Host -Prompt "`t$($title) $($pd.Prompt)"
                    }
                    else
                    {
                        $pd.Value = Read-Host -Prompt "`t$($title) $($pd.Prompt)"
                    }

                    if (![string]::IsNullOrEmpty($pd.Value) -and $pd.ValueType -ne 'Prompt')
                    {
                        if ([string]::IsNullOrEmpty($pd.InputValidationRegex))
                        {
                            $validInput      = $true
                            $pd.LastModified = [System.DateTime]::Now
                            break
                        }
                        else
                        {
                            if ($pd.Value -match $pd.InputValidationRegex)
                            {
                                $validInput      = $true
                                $pd.LastModified = [System.DateTime]::Now
                                break
                            }
                            else
                            {
                                Write-OPD -Status ERROR `
                                    -Message ("Invalid response '{0}'. Example input: {1}" -f $pd.Value, $pd.ExampleInputText)
                            }
                        }
                    }
                    elseif($pd.ValueType -eq 'Prompt' -and [string]::IsNullOrEmpty($pd.Value))
                    {
                        $validInput = $true
                        $pd.LastModified = [System.DateTime]::Now
                        break
                    }
                }
            }
        }
    }

    return $validInput
}

function Get-DiagnosticInformation
{
    $sb = New-Object -TypeName System.Text.StringBuilder

    $OS = Get-WmiObjectHandler -Class Win32_OperatingSystem

    $sb.AppendLine("Timestamp: {0} UTC" -f (Get-Date).ToUniversalTime())                                | Out-Null
    $sb.AppendLine("OPDVersion: {0}" -f $global:OPDVersion)                                             | Out-Null
    $sb.AppendLine("Product: {0}" -f $Mode.ToUpper())                                                   | Out-Null
    $sb.AppendLine("Language: {0}" -f (([System.Threading.Thread]::CurrentThread.CurrentCulture).Name)) | Out-Null
    $sb.AppendLine("PSVersion: {0}" -f ($PSVersionTable.PsVersion).ToString())                          | Out-Null
    $sb.AppendLine("OSVersion: {0}" -f ($OS.Version))                                                   | Out-Null
    $sb.AppendLine("OSCaptionn: {0}" -f ($OS.Caption))                                                  | Out-Null
    $sb.ToString()                                                                                      | Set-Clipboard

    return $sb.ToString()
}

function Test-IsFlagSet
{
    param
    (
        [Parameter(Mandatory=$true)]
        [uint16]
        $Bitmask,

        [Parameter(Mandatory=$true)]
        [uint16]
        $Flag
    )

    return (($Bitmask -band $Flag) -eq $Flag)
}

function Set-Flag
{
    param
    (
        [Parameter(Mandatory=$true)]
        [uint16]
        $Bitmask,

        [Parameter(Mandatory=$true)]
        [uint16]
        $Flag
    )

    return ($Bitmask -bor $Flag)
}

#endregion

#region Module helpers
function Test-ModuleLoaded
{
    param
    (
        [string] $ModuleName
    )

    $ModuleLoaded = @(Get-Module -ListAvailable | Where-Object {$_.Name -like $ModuleName}).Count -gt 0

    return [bool]$ModuleLoaded
}

function Test-IsModuleInstalled
{
    param
    (
        [string] $DisplayName
    )
    $ModuleIsInstalled = $null

    try
    {
        if (-not [string]::IsNullOrEmpty($DisplayName))
        {
            $ModuleIsInstalled = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' |
                                    ForEach-Object {Get-ItemProperty -Path $_.PsPath} |
                                    Where-Object {$_.DisplayName -match $DisplayName} |
                                    Select-Object -ExpandProperty DisplayName
        }
    }
    catch [System.Management.Automation.PropertyNotFoundException]
    {
        # One of the items did not have the DisplayName property - that's OK
        # Keeping going
        Write-VerboseWriter("One of the items did not have the DisplayName property - that's OK")
        continue
    }
    catch
    {
        $ModuleIsInstalled = $false
    }

    return $ModuleIsInstalled
}

function Initialize-Module
{
    param
    (
        [string] $ModuleName
    )

    $ModuleInitialized = $false

    try
    {
        # Check to see if the module is already loaded
        if (Test-ModuleLoaded -ModuleName $ModuleName)
        {
            $ModuleInitialized = $true
        }
        else
        {
            Import-Module -Name $ModuleName

            $ModuleInitialized = Test-ModuleLoaded -ModuleName $ModuleName
        }
    }
    catch
    {
            throw $_
    }

    return $ModuleInitialized
}
#endregion

#region Class helpers
function Add-AnalyzerDefinition()
{
    param
    (
        [object] $Scenario,
        [object] $AnalyzerDefinition,
        [uint16] $Order = 0
    )

    try
    {
        if ($null -eq $Scenario.AnalyzerDefinitions -or `
            $Scenario.AnalyzerDefinitions.Name -inotcontains $AnalyzerDefinition.Name)
        {
            if ($Order -eq 0)
            {
                # Auto-assign next available value
                if ($null -eq $Scenario.AnalyzerDefinitions)
                {
                    $AnalyzerDefinition.Order = 1
                }
                else
                {
                    $AnalyzerDefinition.Order = ($Scenario.AnalyzerDefinitions.Order | Measure-Object -Maximum).Maximum + 1
                }
            }
            $Scenario.AnalyzerDefinitions += $AnalyzerDefinition
        }
    }
    catch
    {
        throw $_
    }
}

function Add-Area()
{
    param
    (
        [object] $Scenario,
        [object] $Area
    )

    try
    {
        if ($null -eq $Scenario.Areas -or $Scenario.Areas -inotcontains $Area)
        {
            $Scenario.Areas += $Area
        }
    }
    catch
    {
        throw $_
    }
}

function Add-Keyword()
{
    param
    (
        [object] $Scenario,
        [object] $Keyword
    )

    try
    {
        if ($null -eq $Scenario.Keywords -or $Scenario.Keywords -inotcontains $Keyword)
        {
            $Scenario.Keywords += $Keyword
        }
    }
    catch
    {
        throw $_
    }
}

function Add-ParameterDefinition()
{
    param
    (
        [object] $Object,
        [object] $ParameterDefinition
    )

    try
    {
        if ($null -eq $Object.ParameterDefinitions -or `
             $Object.ParameterDefinitions.Name -inotcontains $ParameterDefinition.Name)
        {
            $Object.ParameterDefinitions += $ParameterDefinition
        }
    }
    catch
    {
        throw $_
    }
}

function Add-RuleDefinition()
{
    param
    (
        [object] $Analyzer,
        [object] $RuleDefinition,
        [uint16] $Order = 0
    )

    try
    {
        if ($null -eq $Analyzer.RuleDefinitions -or `
             $Analyzer.RuleDefinitions.Name -inotcontains $RuleDefinition.Name)
        {
            if ($Order -eq 0)
            {
                # Auto-assign next available value
                if ($null -eq $Analyzer.RuleDefinitions)
                {
                    $RuleDefinition.Order = 1
                }
                else
                {
                    $RuleDefinition.Order = ($Analyzer.RuleDefinitions.Order | Measure-Object -Maximum).Maximum + 1
                }
            }
            $Analyzer.RuleDefinitions += $RuleDefinition
        }
    }
    catch
    {
        throw $_
    }
}

function Get-ParameterDefinition
{
    param
    (
        [object] $Object,
        [string] $ParameterName
    )

    $value = $null

    try
    {
        if($null -ne $Object.ParameterDefinitions)
        {
            $parm = $Object.ParameterDefinitions | Where-Object {$_.Name -eq $ParameterName}

            if($null -ne $parm)
            {
                $value = $parm.Value
            }
        }
    }
    catch
    {
        throw $_
    }

    return $value
}
#endregion

#region Misc functions
function Get-ProgressId
{
    return ([math]::Abs((Get-Random -Minimum ([int32]::MinValue) -Maximum ([int32]::MaxValue))))
}

function Get-Title
{
    param
    (
        [string] $Name
    )

    $title = [string]::Empty

    if (Test-Verbose -or $global:OPDOptions.Debugxx)
    {
        $title = " [{0}]" -f $Name
    }

    return $title
}

<#
    .SYNOPSIS
        Overrides the New-TemporaryFile function from the module Microsoft.PowerShell.Utility
        This function is not available in the related Snappin Microsoft.PowerShell.Utility which
        is loaded by default in Azure Stack's JEA endpoint
    .NOTES
        See WI 27564 for more information
#>
function New-TemporaryFile
{
    [CmdletBinding(
        HelpURI='https://go.microsoft.com/fwlink/?LinkId=526726',
        SupportsShouldProcess=$true)]
    [OutputType([System.IO.FileInfo])]
    Param()

    Begin
    {
        try
        {
            if($PSCmdlet.ShouldProcess($env:TEMP))
            {
                $tempFilePath = [System.IO.Path]::GetTempFileName()
            }
        }
        catch
        {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new($_.Exception,"NewTemporaryFileWriteError","WriteError", $env:TEMP)
            Write-Error -ErrorRecord $errorRecord
            return
        }

        if($tempFilePath)
        {
            Get-Item $tempFilePath
        }
    }
}

function Test-ConnectionLocalSubnet
{
    param
    (
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Name',
            Position = 0)]
        [string] $ComputerName,

        [Parameter(Mandatory = $true,
            ParameterSetName = 'IPAddress',
            Position = 0)]
        [string]$IPAddress
    )

    # Let's start by deleting all of the hosts
    $arpOutput = arp -d 2>&1

    if (-not [string]::IsNullOrEmpty($ComputerName))
    {
        $ping = Test-Connection -ComputerName $ComputerName -Count 3 -Quiet
    }
    else
    {
        $ping = Test-Connection -IPAddress $IPAddress -Count 3 -Quiet
        $arp  = (arp -a | Select-String "$IPAddress")
    }

    # Bug 33514: Exception due $arp not initialized in Test-ConnectionLocalSubnet function
    if ($ping -or ((Test-Path -Path variable:arp) -and (-not [string]::IsNullOrEmpty($arp))))
    {
        return $true
    }
    else
    {
        return $false
    }
}

function Test-TcpConnect
{
    param
    (
        [string] $Server,
        [int32] $Port
    )

    $result = $true

    try
    {
        $tcpClient = New-object -TypeName System.Net.Sockets.TcpClient

        $tcpClient.Connect($Server, $Port)

        $result = $tcpClient.Connected
    }
    catch
    {
        $result = $false
    }
    finally
    {
        if($tcpClient)
        {
            $tcpClient.Dispose()
        }
    }

    return $result
}

function Test-TcpPort
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [int]$Port
    )

    try
    {
        $Socket = New-Object Net.Sockets.TcpClient
        $Socket.Connect($ComputerName, $Port)
        $Status = "Open"

        $Socket.Close()
    }
    catch
    {
        $Status = 'Closed/Filtered'
    }
    finally
    {
        $obj = [PSCustomObject]@{
            ComputerName = $ComputerName
            TcpPort      = $Port
            Status       = $Status
        }
        $obj
    }
}


function Test-Verbose
{

    [System.Management.Automation.ActionPreference]::SilentlyContinue -ne $VerbosePreference
}

#endregion

#region Connection Manager

function Clear-ConnectionCache
{
    if (-not [string]::IsNullOrEmpty($global:Connections.Container))
    {
        $global:Connections.Container = $global:Connections.Container | Where-Object {$_.Item3.State -eq 'Opened'}
    }
}

function Find-RemoteConnection
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $ComputerName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credentials
    )

    $remoteConnection = $potentialConnections = $null

    # Let's get a list for this computer, if there are any
    Clear-ConnectionCache

    if ($null -ne $global:Connections.Container)
    {
        $potentialConnections = $global:Connections.Container | Where-Object {$_.Item1 -eq $ComputerName}
    }

    if ($null -ne $potentialConnections)
    {
        # OK, we found some potential connections already for this computer. Let's see if any of them
        # have the same credential block. If so, we don't need to create a new connection; otherwise,
        # we'll go ahead and spin up a new one with these creds
        foreach ($connection in $potentialConnections)
        {
            if ((Compare-SecureString -ReferenceObject $connection.Item2.Password -DifferenceObject $Credentials.Password) -and `
                ($connection.Item2.UserName -eq $Credentials.UserName))
            {
                # We've already got a connection object for these credentials
                $remoteConnection = $connection
                break
            }
        }
    }

    return $remoteConnection
}

function Get-RemoteConnection
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $ComputerName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential] $Credentials,

        [Parameter(Mandatory = $true)]
        [int32] $Port
    )

    $remoteSession    = $null
    $remoteConnection = Find-RemoteConnection -ComputerName $ComputerName -Credentials $Credentials

    if ($null -eq $remoteConnection)
    {
        $remoteSession = Get-RemoteSession -ComputerName $ComputerName -Credentials $Credentials -Port $Port
        if ($null -ne $remoteSession)
        {
            $remoteConnection = [System.Tuple]::Create($ComputerName, $Credentials, $remoteSession)
            $global:Connections.Container += $remoteConnection
        }
    }
    else
    {
        $remoteSession = $remoteConnection.Item3
    }

    return $remoteSession
}

function Get-RemoteSession
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $ComputerName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential] $Credentials,

        [Parameter(Mandatory = $true)]
        [int32] $Port
    )

    New-PSSession -ComputerName $ComputerName -Credential $Credentials -Port $Port -ErrorAction SilentlyContinue
}

function Test-CertificateSubject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $Url,

        [Parameter(Mandatory=$false)]
        [uint16] $Timeout = 10000
    )

    $result = $null

    try
    {
        #disabling the cert validation check. This is what makes this whole thing work with invalid certs...
        # Bug 33256: RDCheckSipDomainIsFederated rule shouldn’t fail
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

        $request         = [Net.HttpWebRequest]::Create([Uri]$Url)
        $request.Timeout = $Timeout

        $request.GetResponse() | Out-Null

    }
    catch
    {
        Write-VerboseWriter("{0}: {1}" -f $Url, $_)
    }
    finally
    {
        $result = -not [string]::IsNullOrEmpty($request.ServicePoint.Certificate.Subject)
    }

    return $result
}

function Get-RemoteSSLCertificate
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName,

        [int]
        $Port = 443
    )

    $Certificate = $null

    $TcpClient   = New-Object -TypeName System.Net.Sockets.TcpClient
    try
    {
        $TcpClient.Connect($ComputerName, $Port)
        $TcpStream = $TcpClient.GetStream()

        $Callback =
        {
            param($sender, $cert, $chain, $errors)
            return $true
        }

        $SslStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList @($TcpStream, $true, $Callback)

        try
        {
            $SslStream.AuthenticateAsClient('')
            $Certificate = $SslStream.RemoteCertificate
        }
        finally
        {
            $SslStream.Dispose()
        }
    }
    finally
    {
        $TcpClient.Dispose()
    }

    if ($Certificate)
    {
        if ($Certificate -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2])
        {
            $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate
        }
    }

    return $Certificate
}

function Import-RemoteSession
{
    param
    (
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Session',
            Position=0)]
        [System.Object] $Session
    )

    $results = $null

    try
    {
        if (-not [string]::IsNullOrEmpty($Session))
        {
            $results = Import-PSSession -Session $Session `
                                        -DisableNameChecking `
                                        -AllowClobber
        }
    }
    catch
    {
        throw $_
    }

    return $results
}

function Invoke-RemoteCommand
{
    [CmdletBinding(DefaultParameterSetName='Computer')]
    param
    (
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Computer',
            Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName,

        [Parameter(Mandatory = $true,
            ParameterSetName = 'Computer',
            Position=1)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Credentials,

        [Parameter(Mandatory = $true,
            ParameterSetName = 'Session',
            Position=0)]
        [System.Object] $Session,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Scriptblock] $ScriptBlock,

        [Parameter(Mandatory = $false)]
        [System.Object[]] $ArgumentList
    )

    $results = $null

    try
    {
        if (-not [string]::IsNullOrEmpty($ComputerName))
        {
            $results = Invoke-Command -ComputerName $ComputerName `
                                      -Credential $Credentials `
                                      -ScriptBlock $ScriptBlock `
                                      -ArgumentList $ArgumentList `
                                      -ErrorAction SilentlyContinue
        }
        elseif (-not [string]::IsNullOrEmpty($Session))
        {
            $results = Invoke-Command -Session $Session `
                                      -ScriptBlock $ScriptBlock `
                                      -ArgumentList $ArgumentList `
                                      -ErrorAction SilentlyContinue
        }
    }
    catch
    {
        throw $_
    }

    return $results
}
#endregion Connection Manager

function Set-Expiration
{
    param
    (
        [Parameter(Mandatory = $true,
            Position=0)]
        [System.Object] $Scenario
    )

    $analyzers = $Scenario.AnalyzerDefinitions.Name
    $rules = $Scenario.AnalyzerDefinitions.RuleDefinitions.Name

    # Does the scenario have an expiration? If so, no need to process analyzers/rules
    $ScenarioExpiration = $global:ConfigData.Expirations.Scenarios | Where-Object {$_.Name -eq $Scenario}

    if ([string]::IsNullOrEmpty($ScenarioExpiration))
    {
        foreach($analyzer in $analyzers)
        {
            $AnalyzerExpiration = $global:ConfigData.Expirations.Analyzers | Where-Object {$_.Name -eq $analyzer}

            if (-not [string]::IsNullOrEmpty($AnalyzerExpiration))
            {
                $analyzer.Expiry = [System.DateTime]$AnalyzerExpiration.Expiration
            }
        }

        foreach($rule in $rules)
        {
            $RuleExpiration = $global:ConfigData.Expirations.Rules | Where-Object {$_.Name -eq $rule}
            if (-not [string]::IsNullOrEmpty($RuleExpiration))
            {
                $rule.Expiry = [System.DateTime]$RuleExpiration.Expiration
            }
        }
    }
    else
    {
        $Scenario.Expiry = [System.DateTime]$ScenarioExpiration.Expiration
    }
}

Function Get-NETFrameworkVersion
{
    [CmdletBinding()]
    param
    (
        [string]$MachineName = $env:COMPUTERNAME,
        [int]$NetVersionKey  = -1
    )

    if ($NetVersionKey -eq -1)
    {
        [int]$NetVersionKey = Invoke-RegistryGetValue -RegistryHive "LocalMachine" `
                                -SubKey "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" `
                                -GetValue "Release" -MachineName $MachineName
    }

    # https://docs.microsoft.com/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed?source=docs

    if ($NetVersionKey -lt 378389)
    {
        $friendlyName = "Unknown"
        $minValue     = -1
    }
    elseif ($NetVersionKey -lt 378675)
    {
        $friendlyName = "4.5"
        $minValue     = 378389
    }
    elseif ($NetVersionKey -lt 379893)
    {
        $friendlyName = "4.5.1"
        $minValue     = 378675
    }
    elseif ($NetVersionKey -lt 393295)
    {
        $friendlyName = "4.5.2"
        $minValue     = 379893
    }
    elseif ($NetVersionKey -lt 394254)
    {
        $friendlyName = "4.6"
        $minValue     = 393295
    }
    elseif ($NetVersionKey -lt 394802)
    {
        $friendlyName = "4.6.1"
        $minValue     = 394254
    }
    elseif ($NetVersionKey -lt 460798)
    {
        $friendlyName = "4.6.2"
        $minValue     = 394802
    }
    elseif ($NetVersionKey -lt 461308)
    {
        $friendlyName = "4.7"
        $minValue     = 460798
    }
    elseif ($NetVersionKey -lt 461808)
    {
        $friendlyName = "4.7.1"
        $minValue     = 461308
    }
    elseif ($NetVersionKey -lt 528040)
    {
        $friendlyName = "4.7.2"
        $minValue     = 461808
    }
    elseif ($NetVersionKey -ge 528040)
    {
        $friendlyName = "4.8"
        $minValue     = 528040
    }

    Write-VerboseWriter(".NET Version Key = {0}" -f $NetVersionKey)
    Write-VerboseWriter(".NET friendly Name = {0}" -f $friendlyName)

    return [System.Version]$friendlyName
}

Function Get-WmiObjectHandler
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWMICmdlet', '', Justification = 'This is what this function is for')]
    param
    (
        [Parameter(Mandatory = $false)][string]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory = $true)][string]$Class,
        [Parameter(Mandatory = $false)][string]$Filter,
        [Parameter(Mandatory = $false)][string]$Namespace,
        [Parameter(Mandatory = $false)][scriptblock]$CatchActionFunction
    )

    Write-VerboseWriter("Calling: Get-WmiObjectHandler")
    Write-VerboseWriter("Passed: [string]ComputerName: {0} | [string]Class: {1} | [string]Filter: {2} | [string]Namespace: {3}" -f $ComputerName, $Class, $Filter, $Namespace)

    $execute = @{
        ComputerName = $ComputerName
        Class        = $Class
    }

    if (![string]::IsNullOrEmpty($Filter))
    {
        $execute.Add("Filter", $Filter)
    }

    if (![string]::IsNullOrEmpty($Namespace))
    {
        $execute.Add("Namespace", $Namespace)
    }

    try
    {
        $wmi = Get-WmiObject @execute -ErrorAction Stop
        return $wmi
    }
    catch
    {
        Write-VerboseWriter("Failed to run Get-WmiObject object on class '{0}'" -f $Class)
        if ($null -ne $CatchActionFunction)
        {
            & $CatchActionFunction
        }
    }
}

Function Invoke-ScriptBlockHandler
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [string]$ScriptBlockDescription,

        [Parameter(Mandatory = $false)]
        [object]$ArgumentList,

        [Parameter(Mandatory = $false)]
        [bool]$IncludeNoProxyServerOption,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Default",
            "Basic",
            "Credssp",
            "Digest",
            "Kerberos",
            "Negotiate",
            "NegotiateWithImplicitCredential")]
        [string]$Authentication = "Default",

        [Parameter(Mandatory = $false)]
        [scriptblock]$CatchActionFunction
    )

    Write-VerboseWriter("Calling: Invoke-ScriptBlockHandler")

    if (![string]::IsNullOrEmpty($ScriptBlockDescription))
    {
        Write-VerboseWriter($ScriptBlockDescription)
    }

    try
    {
        if (($ComputerName).Split(".")[0] -ne $env:COMPUTERNAME)
        {
            $params = @{
                ComputerName   = $ComputerName
                ScriptBlock    = $ScriptBlock
                ErrorAction    = "Stop"
                Authentication = $Authentication
            }

            if ($IncludeNoProxyServerOption)
            {
                Write-VerboseWriter("Including SessionOption")
                $params.Add("SessionOption", (New-PSSessionOption -ProxyAccessType NoProxyServer))
            }

            if ($null -ne $ArgumentList)
            {
                $params.Add("ArgumentList", $ArgumentList)
                Write-VerboseWriter("Running Invoke-Command with argument list.")
            }
            else
            {
                Write-VerboseWriter("Running Invoke-Command without argument list.")
            }

            $invokeReturn = Invoke-Command @params

            return $invokeReturn
        }
        else
        {
            if ($null -ne $ArgumentList)
            {
                Write-VerboseWriter("Running Script Block locally with argument list.")
                $localReturn = & $ScriptBlock $ArgumentList
            }
            else
            {
                Write-VerboseWriter("Running Script Block locally without argument list.")
                $localReturn = & $ScriptBlock
            }

            return $localReturn
        }
    }
    catch
    {
        Write-VerboseWriter("Failed to Invoke-ScriptBlockHandler")

        if ($null -ne $CatchActionFunction)
        {
            & $CatchActionFunction
        }
    }
}

Function Get-WmiObjectHandler
{
    param
    (
        [Parameter(Mandatory = $false)][string]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory = $true)][string]$Class,
        [Parameter(Mandatory = $false)][string]$Filter,
        [Parameter(Mandatory = $false)][string]$Namespace,
        [Parameter(Mandatory = $false)][scriptblock]$CatchActionFunction
    )

    Write-VerboseWriter("Calling: Get-WmiObjectHandler")
    Write-VerboseWriter("Passed: [string]ComputerName: {0} | [string]Class: {1} | [string]Filter: {2} | [string]Namespace: {3}" -f $ComputerName, $Class, $Filter, $Namespace)

    $execute = @{
        ComputerName = $ComputerName
        ClassName    = $Class
    }

    if (![string]::IsNullOrEmpty($Filter))
    {
        $execute.Add("Filter", $Filter)
    }

    if (![string]::IsNullOrEmpty($Namespace))
    {
        $execute.Add("Namespace", $Namespace)
    }

    try
    {
        $wmi = Get-CimInstance @execute -ErrorAction SilentlyContinue
        return $wmi
    }
    catch
    {
        Write-VerboseWriter("Failed to run Get-WmiObject object on class '{0}'" -f $Class)
        if ($null -ne $CatchActionFunction)
        {
            & $CatchActionFunction
        }
    }
}

function Get-CPUs
{
    param
    (
        [string]$MachineName = $env:COMPUTERNAME
    )

    [int] $cores   = 0
    [int] $sockets = 0
    [string] $test = $null

    $Processors = Get-WmiObjectHandler -Class Win32_Processor -ComputerName $MachineName

    foreach ($processor in $Processors)
    {
        if ($null -eq $processor.NumberOfCores)
        {
            if (-not $test.Contains($processor.SocketDesignation))
            {
                $test += $processor.SocketDesignation
                $sockets++
            }
            $cores++
        }
        else
        {
            $sockets++
            $cores += $processor.NumberOfCores
        }
    }

    return @{Server=$MachineName;Cores=$cores;Sockets=$sockets }

}