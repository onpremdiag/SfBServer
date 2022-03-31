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
# Filename: OPD-console.ps1
# Description: Console driver for OPD %MODE%
# Owner: Mike McIntyre <opd-support@microsoft.com>
# Created On: 9/17/2018 4:36 PM
#
# Last Modified On: 9/17/2018 4:36 PM
#################################################################################

<#
.SYNOPSIS
    OnPrem Diagnostic Support for %MODE%

.DESCRIPTION
    Console driver for OPD %MODE%.
        Run OPD-console.ps1 to check various aspects of on premise %MODE%.
        Framework designed with WMF v5.1 as a pre-req

.PARAMETER Mode
    Mode allows for the selection of a product diagnostic suite. By default, it
    will be set to '%MODE%

.EXAMPLE
        OPD-console.ps1 -mode %MODE%
        Start OPD in the %MODE% mode. This is the default behavior and it will cause
        OPD to run %MODE% specific diagnostic scenarios.

.PARAMETER AcceptEula
    Specify this switch to AcceptEula to run the OPD tool.
    Failure to specify this parameter will provide menu prompt waiting for user response to Accept
    Yes - explicitly accept EULA and proceed
    No - terminates execution immediately

.EXAMPLE
        OPD-console.ps1 -mode %MODE% -AcceptEula Yes
        Explicitly accept the End User License Agreement (EULA) and proceed. The default is to not
        accept the EULA.

.PARAMETER CheckForUpdate
    Specify whether to check for an update or not. The default behavior is to always check for
    an update. If an update is found, the user is given the option of performing an in-place upgrade.

.EXAMPLE
        OPD-console.ps1 -mode %MODE% -CheckForUpdate No
        This will cause OPD to skip the check for an updated version on GitHub. The default is to check
        and see if there is a newer version available and provide the option to do an in-place upgrade

.PARAMETER ProxyAccessType
    Specify which type of proxy access to use.
        AutoDetect - force autodetection of proxy
        IEConfig - use the Internet Explorer proxy configuration for the current user. Internet
        Explorer proxy settings for the current active network connection
        None - ProxyAccessType is not specified
        NoProxyServer - Do not use a proxy server - resolves all host names locally (DEFAULT)
        WinHttpConfig - proxy settings configured for WinHTTP, using the ProxyCfg.exe utility

.EXAMPLE
    OPD-console.ps1 -ProxyAccessType IEConfig
#>

[cmdletbinding()]
param
(
    [Parameter(Mandatory = $false)]
    [String] $Mode = "%MODE%", ## Debug ## "%MODE%",

    [Parameter(Mandatory = $false)]
    [Switch] $AcceptEula,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Yes","No")]
    [string] $CheckForUpdate = "Yes",

    [Parameter(Mandatory = $false)]
    [Switch] $DiagnosticData,

    [Parameter(Mandatory = $false)]
    [Switch] $Debugxx,

    [Parameter(Mandatory = $false)]
    [ValidateSet("AutoDetect","IEConfig","None","NoProxyServer","WinHttpConfig")]
    [string] $ProxyAccessType = "NoProxyServer",

    [Parameter(Mandatory = $false)]
    [ValidateSet("AzureChinaCloud",
                 "AzureCloud",
                 "AzureGermanyCloud",
                 "AzureOneBox",
                 "AzurePPE",
                 "AzureUSGovernmantCloud",
                 "AzureUSGovernmantCloud2",
                 "AzureUSGovernmantCloud3",
                 "USGovernmantCloud")]
    [string] $AzureEnvironment = "AzureCloud"
)

$Global:OPDOutputResults = @()

$global:OPDOptions  = @{
    AcceptEula       = $AcceptEula.IsPresent
    AzureEnvironment = $AzureEnvironment
    CheckForUpdate   = $CheckForUpdate
    Debugxx          = $Debugxx.IsPresent
    DiagnosticData   = $DiagnosticData.IsPresent
    Mode             = $Mode
    OriginalCulture  = ([System.Threading.Thread]::CurrentThread.CurrentCulture).Name
    ProxyAccessType  = $ProxyAccessType
    WindowsTitle     = $Host.UI.RawUI.WindowTitle
}

if (([System.Version]$PSVersionTable.PSVersion).Major -gt 5)
{
    Set-Variable -Name AccessChkCompiled -Scope 'Global' -Value $true -Force
}

. (Join-Path -Path $PSScriptRoot -ChildPath common\Globals.ps1)
. (Join-Path -Path $PSScriptRoot -ChildPath common\Utils.ps1)

Initialize-CommonResourceStrings -Root $PSScriptRoot

# Do we have a valid product specified?
$products = Get-ChildItem -Path $PSScriptRoot\mode -Directory

if ($Mode -like '?MODE?' -or $products.Name -notcontains $Mode)
{
    $global:CommonStrings.'InvalidProduct' -f $Mode, ($products.Name -join ',') | Write-Host

    exit
}

$global:AreaTypes   = $global:Parameters = $global:Rules = $global:Insights = $global:Analyzers = $global:Scenarios = $null
$global:scriptName  = ($MyInvocation.MyCommand.Name).Split('.')[0]
$global:scriptPath  = $MyInvocation.MyCommand.Path
$global:ExecutionId = [System.Guid]::NewGuid()

function Confirm-ShareResults
{
    $yes      = New-Object System.Management.Automation.Host.ChoiceDescription "&$($global:OPDStrings.'Yes')", $global:OPDStrings.'OptIn'
    $no       = New-Object System.Management.Automation.Host.ChoiceDescription "&$($global:OPDStrings.'No')", $global:OPDStrings.'OptOut'
    $options  = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $accepted = $host.ui.PromptForChoice("", $global:OPDStrings.'OptIn', $options, 0)

    return !$accepted
}

function Get-Area
{
    param
    (
        $Scenarios
    )

    $chosenArea     = @()
    $validChoice    = $false
    $potentialAreas = @()

    if ($null -ne $Scenarios)
    {
        $potentialAreas += $Scenarios | ForEach-Object {$_.Areas} | `
            Where-Object { $_ -in $global:AreaTypes.Keys } | `
            Sort-Object -Unique
    }

    if ($potentialAreas.Count -gt 0)
    {
        Clear-Host
        while (!$validChoice)
        {
            New-Banner -Delay 0

            for ($i = 0; $i -lt $potentialAreas.Count; $i++)
            {
                $global:OPDStrings.'KeyValuePair' -f ($i+1), $global:AreaTypes[$potentialAreas[$i]] | Write-Host
            }
            $global:OPDStrings.'Exit' | Write-Host

            $choice = Read-Host -Prompt $global:OPDStrings.'Area'

            switch($choice)
            {
                {[string]::IsNullOrEmpty($_)}
                {
                    Write-Yellow -Message ($global:OPDStrings.'SelectFromList' -f $_ )
                    break
                }

                $global:OPDStrings.'ExitKey'
                {
                    $validChoice = $true
                    $chosenArea  = $_
                    break
                }

                {1..($potentialAreas.Count) -contains $_}
                {
                    $global:OPDStrings.'Choice' -f $_ | Write-Host
                    $chosenArea += $potentialAreas[$_ -1]
                    $validChoice = $true
                    $global:BreadCrumb = $global:AreaDescriptions.($chosenArea[0].ToString())
                    break
                }

                default
                {
                    $global:OPDStrings.'InvalidChoice' -f $_ | Write-OPD -Status WARNING -NoNewline:$true
                }
            }

            if (!$validChoice)
            {
                Read-Host | Out-Null
            }
            else
            {
                break
            }
        }
    }

    return $chosenArea
}

function New-Banner
{
    param
    (
        [int] $Delay = 2
    )

    Clear-Host

    $bannerStrings = @($global:OPDTitle, $global:OPDVersion, $global:BreadCrumb)

    $banner =  New-AsciiBanner -BannerStrings $bannerStrings

    $banner | Write-Host
    Start-Sleep -Seconds $Delay
}

function New-AsciiBanner
{
    param
    (
        [string[]] $BannerStrings
    )

    $upperLeftCorner  = "╔"
    $upperRightCorner = "╗"
    $lowerLeftCorner  = "╚"
    $lowerRightCorner = "╝"
    $horizontalLine   = "═"
    $verticalLine     = "║"
    $longest          = 0

    foreach ($string in $BannerStrings)
    {
        if ($string.Length -gt $longest)
        {
            $longest = $string.Length
        }
    }

    $width      = $longest + 4
    #$height     = $BannerStrings.Count

    $topLine    = $upperLeftCorner + ($horizontalLine*$width) + $upperRightCorner
    $bottomLine = $lowerLeftCorner + ($horizontalLine*$width) + $lowerRightCorner
    $banner     = New-Object -TypeName System.Text.StringBuilder

    $banner.AppendLine($topLine) | Out-Null

    foreach ($line in ($BannerStrings | Where-Object {-not [string]::IsNullOrEmpty($_)}))
    {
        $offset    = [Math]::Round(($topLine.Length - $line.Length) / 2) - 1
        $leftSide  = $offset + $line.Length
        $rightSide = $width - $leftSide

        $banner.AppendLine($verticalLine + (" " * $offset) + $line + (" " * $rightSide) + $verticalLine) | Out-Null
    }

    $banner.AppendLine($BottomLine) | Out-Null

    return $banner.ToString()
}

function Get-MyScenarios
{
    param
    (
        [String] $ScenarioIDs   = $null,
        [String] $ScenarioNames = $null,
        [String] $PlayList      = $null
    )

    $customScenarios = 0
    $scenarioList = @()

    # We will only allow one option to be used
    foreach ($validScenario in $ScenarioIDs, $ScenarioNames, $PlayList)
    {
        if (![String]::IsNullOrEmpty($validScenario))
        {
            $customScenarios += 1
        }
    }

    # IFF we get a single input for scenario selection
    if ($customScenarios -eq 1)
    {
        if (![String]::IsNullOrEmpty($ScenarioIDs))
        {
            # We have at least one scenario ID being passed in
            if ($ScenarioIDs.Contains(";"))
            {
                foreach ($scenarioID in $ScenarioIDs.Split(";"))
                {
                    $scenarioList += $scenarioID
                }
            }
            else
            {
                $scenarioList += $ScenarioIDs
            }
        }
        elseif (![String]::IsNullOrEmpty($ScenarioNames))
        {
            # We have at least one scenario Name being passed in
            if ($ScenarioNames.Contains(";"))
            {
                foreach($scenarioName in $ScenarioNames.Split(";"))
                {
                    $scenarioList += $scenarioName
                }
            }
            else
            {
                $scenarioList += $ScenarioNames
            }
        }
        elseif (![String]::IsNullOrEmpty($PlayList))
        {
            # We have a playlist. Let's go get it
            $scenarioList = Get-Playlist -Source $PlayList
        }
    }
    elseif ($customScenarios -gt 1)
    {
        Write-Yellow -Message ($global:OPDStrings.'KeyValuePair' -f $global:OPDStrings.'MessageWarning', `
            $global:OPDStrings.'ChooseOne') `
            -BackgroundColor Black
    }

    return $scenarioList
}

function Get-Playlist
{
    param
    (
        [String] $Source
    )

    $scenarioList = @()

    # Ensure that the file actually exists
    if (Test-Path -Path $Source)
    {
        try
        {
            $myPlaylist = (Get-Content -Path $Source) | ConvertFrom-Json

            # There should be at least one scenario in the play list
            if ($myPlayList.Playlist.Count -gt 0)
            {
                $scenarioList = $myPlayList.Playlist.Scenario
            }
            else
            {
                Write-Yellow -Message ($global:OPDStrings.'KeyValuePair' -f $global:OPDStrings.'MessageWarning', `
                ($global:OPDStrings.'MinPlayList' -f $Source)) `
                             -BackgroundColor Black
            }
        }
        catch
        {
            Write-Red -Message ($global:OPDStrings.'KeyValuePair' -f $global:OPDStrings.'MessageCritical', `
            ($global:OPDStrings.'InvalidPlayList' -f $Source)) `
                      -BackgroundColor Black
        }
    }
    else
    {
        Write-Yellow -Message ($global:OPDStrings.'KeyValuePair' -f $global:OPDStrings.'MessageWarning', `
        ($global:OPDStrings.'PlayListNotFound' -f $Source)) `
                     -BackgroundColor Black
    }

    return $scenarioList
}

function Get-Scenario
{
    param
    (
        $ScenarioList,
        $Area
    )

    $chosenScenario       = @()
    $validChoice          = $false
    $potentialScenarios   = @()

    if ($null -ne $ScenarioList)
    {
        $potentialScenarios += $ScenarioList | Where-Object {$_.Areas -contains $Area} | Sort-Object -Unique
    }

    if ($potentialScenarios.Count -gt 0)
    {
        while (!$validChoice)
        {
            Clear-Host
            New-Banner -Delay 0

            for ($i = 0; $i -lt $potentialScenarios.Count; $i++)
            {
                $global:OPDStrings.'KeyValuePair' -f ($i+1), $potentialScenarios[$i].Description | Write-Host
            }

            $global:OPDStrings.'BackALevel' -f $global:OPDStrings.'Area' | Write-Host

            $choice = Read-Host -Prompt $global:OPDStrings.'Scenario'

            switch ($choice)
            {
                {[string]::IsNullOrEmpty($_)}
                {
                    Write-Yellow -Message ($global:OPDStrings.'SelectFromList' -f $_)
                    break
                }

                $global:OPDStrings.'BackKey'
                {
                    $validChoice       = $true
                    $chosenScenario    = $global:OPDStrings.'ExitKey'
                    $global:BreadCrumb = [String]::Empty
                    break
                }

                {1..($potentialScenarios.Count) -contains $_}
                {
                    $global:OPDStrings.'Choice' -f $_ | Write-Host
                    $chosenScenario += $potentialScenarios[$_ -1]
                    $validChoice = $true
                    break
                }

                default
                {
                    $global:OPDStrings.'InvalidChoice' -f $_ | Write-OPD -Status WARNING -NoNewline:$true
                }
            }

            if (!$validChoice)
            {
                Read-Host | Out-Null
            }
            else
            {
                break
            }
        }
    }
    return $chosenScenario
}

function Initialize-Mode
{
    param
    (
        [String] $Mode
    )

    try
    {
        # Load the resource strings for this mode
        Initialize-ModeResourceStrings -MyMode $Mode -Root $PSScriptRoot

        $global:Rules      = Get-ChildItem -Path "$PSScriptRoot\mode\$Mode\rules"     -Recurse -Filter RD*.ps1 -File
        $global:Insights   = Get-ChildItem -Path "$PSScriptRoot\mode\$Mode\insights"  -Recurse -Filter ID*.ps1 -File
        $global:Analyzers  = Get-ChildItem -Path "$PSScriptRoot\mode\$Mode\analyzers" -Recurse -Filter AD*.ps1 -File
        $global:Scenarios  = Get-ChildItem -Path "$PSScriptRoot\mode\$Mode\scenarios" -Recurse -Filter SD*.ps1 -File
        $global:Parameters = Get-ChildItem -Path "$PSScriptRoot\mode\$Mode\parameters" -Recurse -Filter PD*.ps1 -File

        if($global:OPDTitle -match '%PRODUCT%')
        {
            Set-Variable -Name OPDTitle -Scope 'Global' -Value ($global:OPDTitle -replace '%PRODUCT%', $Mode) -Force
        }

        # Do we have any local rule data that needs to be pre-loaded?
        if (Test-Path -Path "$PSScriptRoot\mode\$Mode\rules\$Mode-Data.json")
        {
            #Loading this for our sample scenarios
            New-Variable -Name ("{0}Data" -f $Mode) `
                         -Value (Get-Content -Path "$PSScriptRoot\mode\$Mode\rules\$Mode-Data.json" -Raw | ConvertFrom-Json) `
                         -Scope 'Global' `
                         -Option ReadOnly `
                         -Force
        }

        # Load the configuration file for this mode. As a minimum, it should contain a list
        # of the areas for this mode
        if (Test-Path -Path "$PSScriptRoot\mode\$Mode\config.json")
        {
            New-Variable -Name "AreaTypes" `
                         -Value @{} `
                         -Scope 'Global' `
                         -Force

            Import-ScriptConfigFile -ScriptConfigFileLocation "$PSScriptRoot\mode\$Mode\config.json" -ErrorAction SilentlyContinue

            # Loop through the areas and grab their title/description for display in the UX
            foreach ($area in $areas.Split(','))
            {
                $global:AreaTypes += @{$global:AreaTitles.$area=$global:AreaDescriptions.$area}
            }
        }
    }
    catch
    {
        throw "Unable to initialize the requested mode: {0}" -f $_
    }
}

function Initialize-OPD
{
    # restart OPD elevated in case it was not launched from an administrator PowerShell window
    if ($false -eq (Test-IsLocalAdministrator))
    {
        ## need to execute as encoded command in case the path contains spaces
        $arguments       = [string]::Empty

        foreach($flag in ($PSCmdlet.MyInvocation.BoundParameters.Keys))
        {
            $arguments += "-{0} " -f $flag
        }

        $command        = "& '$($global:scriptPath)' $arguments"
        $bytes          = [Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList "-NoExit", ("-EncodedCommand $encodedCommand")
        exit
    }
    else
    {
        # Let's customize the PowerShell UI
        $UpgradeAvailable = Test-UpgradeAvailable -Product $Mode
        if ($UpgradeAvailable)
        {
            $WindowsTitle = "*{0} - {1} [{2}\{3}]" -f $global:OPDTitle, $global:OPDVersion, $env:USERDOMAIN, $env:USERNAME
        }
        else
        {
            $WindowsTitle = "{0} - {1} [{2}\{3}]" -f $global:OPDTitle, $global:OPDVersion, $env:USERDOMAIN, $env:USERNAME
        }

        $Host.UI.RawUI.WindowTitle = $WindowsTitle

        if (Test-ApproveEula -Product $Mode)
        {
            if ($global:OPDOptions.CheckForUpdate -eq "Yes")
            {
                Approve-Upgrade -Product $Mode
            }

            Clear-Host

            $sb = New-Object -TypeName System.Text.StringBuilder
            $sb.AppendFormat($global:OPDStrings.'ExecutionMarker', $global:OPDStrings.'Starting', $Mode) | Out-Null
            $sb.AppendFormat(" : {0}", $global:ExecutionId) | Out-Null

            Write-EventLog -LogName OPDLog -Source $global:scriptName -EntryType Information `
                -Message $sb.ToString() `
                -EventId (Get-EventId -Event "OPDStart")
        }
        else
        {
            Exit-OPD
        }
    }
}

function Start-Console
{
    $myScenarios = $null #Get-MyScenarios -PlayList $Playlist -ScenarioIDs $ScenarioID -ScenarioNames $ScenarioName

    $scenarioList = @()

    if ($null -ne $global:Scenarios)
    {
        foreach ($scenario in $global:Scenarios.BaseName)
        {
            $sd = New-Object -TypeName $scenario -ArgumentList $global:ExecutionId

            #Set-Expiration -Scenario $sd

            # Has the scenario expired?
            if ($sd.Expiry -ge (Get-Date))
            {
                if (![String]::IsNullOrEmpty($myScenarios))
                {
                    foreach ($myScenario in $myScenarios)
                    {
                        if ($myScenario -eq $sd.Name -or $myScenario -eq $sd.ID)
                        {
                            $scenarioList += $sd
                            break
                        }
                    }
                }
                else
                {
                    $scenarioList += $sd
                }
            }
        }

        New-Banner

        # Perform any pre-checks, if required. The command, if defined, will be defined in
        # $Mode\common\$Mode.ps1
        if($null -ne (Get-Command -Name Invoke-SupportabilityPreChecks -ErrorAction SilentlyContinue))
        {
            if ($false -eq (Invoke-SupportabilityPreChecks))
            {
                Read-Host -Prompt $global:OPDStrings.'Continue'
                New-Banner -Delay 0
                Write-Red -Message "Minimum requirements were not met"
                $global:OPDPreRequisites | Sort-Object -Property Passed | Format-Table

                Exit-OPD
            }
        }

        $area = (Get-Area -Scenarios $scenarioList) | Where-Object {[string]::IsNullOrEmpty($_) -eq $false}

        while ($true)
        {
            $global:CurrentRule = $global:CurrentAnalyzer = $global:CurrentScenario = [System.Guid]::Empty

            if ($area -ne $global:OPDStrings.'ExitKey')
            {
                $scenarioChoice = (Get-Scenario -ScenarioList $scenarioList -Area $area) | Where-Object {[string]::IsNullOrEmpty($_) -eq $false}
                if ($scenarioChoice -ne $global:OPDStrings.'ExitKey')
                {
                    foreach ($scenario in $scenarioChoice)
                    {
                        $global:OPDStrings.'KeyValuePair' -f $global:OPDStrings.'ExecScenario', `
                                ($scenario.Description + (Get-Title -Name $scenario.Name)) | Write-Host
                        $scenario.AnalyzerDefinitions | ForEach-Object {$_.Success = $true; $_.Results = $null}

                        Invoke-Scenario -Scenario $scenario

                        $failures = $scenario.AnalyzerDefinitions | Where-Object {$_.Success -eq $false}
                        $success  = $scenario.AnalyzerDefinitions | Where-Object {$_.Success -eq $true -and $_.Executed -eq $true}

                        # Let's show all results: Error, Warning, and then Success
                        if ($null -ne $failures)
                        {
                            $warnings = $failures | Where-Object {$_.Status -eq [OPDSTATUS]::WARNING}
                            $errors   = $failures | Where-Object {$_.Status -eq [OPDSTATUS]::ERROR}

                            $sb = New-Object -TypeName System.Text.StringBuilder

                            foreach($analyzer in $errors)
                            {
                                $analyzer.Description + (Get-Title -Name $analyzer.Name) | Write-OPD -Status $analyzer.Status
                                foreach($rule in ($analyzer.RuleDefinitions | Where-Object {!$_.Success}))
                                {
                                    $rule.Description + (Get-Title -Name $rule.Name) | Write-OPD -Status $rule.Status -IndentLevel 1
                                    $global:OPDStrings.'Detection' -f $rule.Insight.Detection + (Get-Title -Name $rule.Insight.Name) | Write-OPD -Status $rule.Status -IndentLevel 2
                                    $global:OPDStrings.'Action' -f $rule.Insight.Action + (Get-Title -Name $rule.Insight.Name) | Write-OPD -Status $rule.Status -IndentLevel 2
                                }
                            }

                            foreach($analyzer in $warnings)
                            {
                                $analyzer.Description + (Get-Title -Name $analyzer.Name) | Write-OPD -Status $analyzer.Status
                                foreach($rule in ($analyzer.RuleDefinitions | Where-Object {!$_.Success}))
                                {
                                    $rule.Description + (Get-Title -Name $rule.Name) | Write-OPD -Status $rule.Status -IndentLevel 1
                                    $global:OPDStrings.'Detection' -f $rule.Insight.Detection + (Get-Title -Name $rule.Insight.Name) | Write-OPD -Status $rule.Status -IndentLevel 2
                                    $global:OPDStrings.'Action' -f $rule.Insight.Action + (Get-Title -Name $rule.Insight.Name) | Write-OPD -Status $rule.Status -IndentLevel 2
                                }
                            }
                        }

                        # Now, the successes...
                        if ($null -ne $success)
                        {
                            $sb = New-Object -TypeName System.Text.StringBuilder

                            foreach ($analyzer in $success)
                            {
                                $analyzer.Description + (Get-Title -Name $analyzer.Name) | Write-OPD -Status SUCCESS

                                foreach($rule in $analyzer.RuleDefinitions)
                                {
                                    $rule.Description + (Get-Title -Name $rule.Name) | Write-OPD -Status SUCCESS -IndentLevel 1
                                }

                                $infos = $analyzer.RuleDefinitions | Where-Object {$_.Success -ne $true }
                                foreach ($info in $infos)
                                {
                                    $info.Insight.Detection + (Get-Title -Name $rule.Insight.Name) | Write-OPD -Status ERROR
                                    $info.Insight.Action + (Get-Title -Name $rule.Insight.Name) | Write-OPD -Status ERROR
                                }
                            }
                        }

                        Read-Host -Prompt $global:OPDStrings.'EnterToContinue'
                    }
                }
                else
                {
                    $area = (Get-Area -Scenarios $scenarioList) | Where-Object {[string]::IsNullOrEmpty($_) -eq $false}
                }
            }
            else
            {
                break
            }
        }

        Clear-Host
    }
}

function Start-OPD
{
    Initialize-OPD

    foreach ($group in $global:Parameters, $global:Insights, $global:Rules, $global:Analyzers, $global:Scenarios)
    {
        $i = 0

        if ($group -isnot [system.array])
        {
            $numberOfFiles = 1
        }
        else
        {
            $numberOfFiles = $group.Count
        }

        foreach ($file in $group)
        {
            $i++
            Write-Progress -Activity $global:OPDStrings.'LoadingFiles' -Status $file.FullName -PercentComplete ($i/$numberOfFiles*100)
            . $file.FullName
        }
    }

    Write-Progress -Activity $global:OPDStrings.'LoadingFiles' -Status $global:OPDStrings.'Ready' -Completed

    Start-Console
}

function Exit-OPD
{

    # Task 33803: Prompt end user for up/down on diagnosing problem
    Send-YesNoDataToMicrosoft (Get-UserFeedback)

    # Perform any logging/cleanup required upon exiting OPD

    # Task 33536: Pre-requisite diagnostics information to event log

    $sb = New-Object -TypeName System.Text.StringBuilder
    $sb.AppendFormat($global:OPDStrings.'ExecutionMarker', $global:OPDStrings.'Ending', $Mode) | Out-Null
    $sb.AppendFormat(" : {0}`n`n", $global:ExecutionId) | Out-Null

    $sb.AppendLine("OPD + Product Specific Pre-requisites check") | Out-Null
    $sb.AppendLine("-----------------------------------------------") | Out-Null

    # Log all of the pre-req checks (OPD + product specific)
    foreach ($prereq in $global:OPDPreRequisites)
    {
        foreach($key in $prereq.PSObject.Properties | Where-Object {$_.MemberType -eq 'NoteProperty'})
        {
            $sb.AppendFormat(("{0}: {1}`n" -f $key.Name, $key.Value)) | Out-Null
        }
        $sb.AppendLine() | Out-Null
    }

    $sb.AppendLine("General Diagnostic Information") | Out-Null
    $sb.AppendLine("----------------------------------") | Out-Null

    # Log general diagnostic information
    $sb.AppendLine((Get-DiagnosticInformation)) | Out-Null

    $sb.AppendLine("OPD Options") | Out-Null
    $sb.AppendLine("----------------") | Out-Null
    foreach($key in $global:OPDOptions.Keys)
    {
        $sb.AppendFormat(("{0}: {1}`n" -f $key, $global:OPDOptions.$key)) | Out-Null
    }
    $sb.AppendLine() | Out-Null

    # Dump summary of results
    $sb.AppendLine("Output Results") | Out-Null
    $sb.AppendLine("------------------") | Out-Null

    foreach($result in $global:OPDOutputResults)
    {
        $sb.AppendLine($result) | Out-Null
    }

    Write-VerboseWriter("Diagnostic summary")
    Write-VerboseWriter($sb.ToString())

    # Dump all of this into the event log so we have a record
    Write-EventLog -LogName OPDLog -Source $global:scriptName -EntryType Information `
        -Message $sb.ToString() `
        -EventId (Get-EventId -Event "OPDFinish")

    $Host.UI.RawUI.WindowTitle = $global:OPDOptions.WindowsTitle

    Exit
}

########
# Main #
########
$Error.Clear() #Always clear out the errors

# Create event log, if it does not already exist
foreach ($source in ($global:scriptName, "Analyzers", "Insights", "Rules", "Scenarios"))
{
    New-EventLog -Source $source -LogName $global:EventLogName -ErrorAction SilentlyContinue
}

if($DiagnosticData.IsPresent)
{
    Get-DiagnosticInformation
}
else
{
    if (Test-OPDPreRequisites)
    {
        # Instantiate class definitions
        Get-ChildItem $PSScriptRoot\classes\*.ps1 -Recurse -File | ForEach-Object {. $_.FullName}

        # Load common libraries
        . (Join-Path -Path $PSScriptRoot -ChildPath common\SQL.ps1)
        . (Join-Path -Path $PSScriptRoot -ChildPath common\IIS.ps1)
        . (Join-Path -Path $PSScriptRoot -ChildPath common\PowershellRemoting.ps1)

        # Load product specific libraries
        . (Join-Path -Path $PSScriptRoot -ChildPath mode\$Mode\common\$Mode.ps1)
        . (Join-Path -Path $PSScriptRoot -ChildPath mode\$Mode\common\Globals.ps1)

        Import-Module (Join-Path -Path $PSScriptRoot -ChildPath common\AI.psm1)

        Initialize-Mode -Mode $Mode
        Start-OPD

        Exit-OPD
    }
    else
    {
        Write-Red -Message "Minimum requirements were not met"
        $global:OPDPreRequisites | Sort-Object -Property Passed | Format-Table
        Exit-OPD
    }
}
