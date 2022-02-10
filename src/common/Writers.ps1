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
# Filename: Writers.ps1
# Description: https://github.com/dpaulson45/PublicPowerShellFunctions/tree/master/src
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 10/19/2021 3:03 PM
#
#################################################################################
Set-StrictMode -Version Latest

$HostFunctionCaller    = $null
$VerboseFunctionCaller = $null

Function Write-Break
{
    Write-Host ([string]::Empty)
}

Function Write-Red
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,

        [Parameter(Mandatory = $false)]
        [System.ConsoleColor] $BackgroundColor = $Host.UI.RawUI.BackgroundColor
    )

    if ([string]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host $message -ForegroundColor Red
    }
    else
    {
        Write-Host $message -ForegroundColor Red -BackgroundColor $BackgroundColor
    }
}

Function Write-Green
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,

        [Parameter(Mandatory = $false)]
        [System.ConsoleColor] $BackgroundColor
    )

    if ([string]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host $message -ForegroundColor Green
    }
    else
    {
        Write-Host $message -ForegroundColor Green -BackgroundColor $BackgroundColor
    }
}

Function Write-Yellow
{
    param
    (

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,

        [Parameter(Mandatory = $false)]
        [System.ConsoleColor] $BackgroundColor
    )

    if ([string]::IsNullOrEmpty($BackgroundColor))
    {
        Write-Host $message -ForegroundColor Yellow
    }
    else
    {
        Write-Host $message -ForegroundColor Yellow -BackgroundColor $BackgroundColor
    }
}

Function Write-VerboseWriter
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$WriteString
    )

    if ($null -eq $VerboseFunctionCaller)
    {
        Write-Verbose $WriteString
    }
    else
    {
        &$VerboseFunctionCaller $WriteString
    }
}

Function Write-HostWriter
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Need to use Write Host')]

    param
    (
        [Parameter(Mandatory = $true)]
        [string]$WriteString
    )

    if ($null -eq $HostFunctionCaller)
    {
        Write-Host $WriteString
    }
    else
    {
        &$HostFunctionCaller $WriteString
    }
}

Function Write-ToStdOut
{
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER ObjectToAdd
    Parameter description

    .PARAMETER ShortFormat
    Parameter description

    .PARAMETER IsError
    Parameter description

    .PARAMETER Color
    Parameter description

    .PARAMETER DebugOnly
    Parameter description

    .PARAMETER PassThru
    Parameter description

    .PARAMETER InvokeInfo
    Parameter description

    .PARAMETER AdditionalFileName
    Parameter description

    .PARAMETER noHeader
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    param
    (
        $ObjectToAdd,
        [switch]$ShortFormat,
        [switch]$IsError,
        $Color,
        [switch]$DebugOnly,
        [switch]$PassThru,
        [System.Management.Automation.InvocationInfo] $InvokeInfo = $MyInvocation,
        [string]$AdditionalFileName = $null,
        [switch]$noHeader
    )

    BEGIN
    {
        $WhatToWrite = @()
        if ($null -ne $ObjectToAdd)
        {
            $WhatToWrite  += $ObjectToAdd
        }

        if(($DebugOnly) -and ($Host.Name -ne "Default Host") -and ($Host.Name -ne "Default MSH Host"))
        {
            if($null -eq $Color)
            {
                $Color = $Host.UI.RawUI.ForegroundColor
            }
            elseif($Color -isnot [ConsoleColor])
            {
                $Color = [Enum]::Parse([ConsoleColor],$Color)
            }
            $scriptName = [System.IO.Path]::GetFileName($InvokeInfo.ScriptName)
        }

        $ShortFormat = $ShortFormat #-or $global:ForceShortFormat
    }
    PROCESS
    {
        if ($null -ne $_ )
        {
            if ($_.GetType().Name -ne "FormatEndData")
            {
                $WhatToWrite += $_ | Out-String
            }
            else
            {
                $WhatToWrite = "Object not correctly formatted. The object of type Microsoft.PowerShell.Commands.Internal.Format.FormatEntryData is not valid or not in the correct sequence."
            }
        }
    }
    END
    {
        if($ShortFormat)
        {
            $separator = " "
        }
        else
        {
            $separator = "`r`n"
        }
        $WhatToWrite = [string]::Join($separator,$WhatToWrite)
        while($WhatToWrite.EndsWith("`r`n"))
        {
            $WhatToWrite = $WhatToWrite.Substring(0,$WhatToWrite.Length-2)
        }
        if(($DebugOnly) -and ($Host.Name -ne "Default Host") -and ($Host.Name -ne "Default MSH Host"))
        {
            $output = "[$([DateTime]::Now.ToString(`"s`"))] [$($scriptName):$($MyInvocation.ScriptLineNumber)]: $WhatToWrite"

            if($IsError.Ispresent)
            {
                $Host.UI.WriteErrorLine($output)
            }
            else
            {
                if($null -eq $Color){$Color = $Host.UI.RawUI.ForegroundColor}
                $output | Write-Host -ForegroundColor $Color
            }

            if($null -eq (Get-Variable DebugOutLog -Scope Global -ErrorAction SilentlyContinue))
            {
                $global:DebugOutLog = Join-Path $Env:TEMP "$([Guid]::NewGuid().ToString(`"n`")).txt"
            }

            $output | Out-File -FilePath $global:DebugOutLog -Append -Force
        }
        elseif(-not $DebugOnly)
        {
            [System.Threading.Monitor]::Enter($global:m_WriteCriticalSection)

            trap [Exception]
            {
                Write-ToErrorDebugReport -ErrorRecord $_ -ScriptErrorText "[Write-ToStdout]: $WhatToWrite" -InvokeInfo $MyInvocation -SkipWriteToStdout
                continue
            }
            Trap [System.IO.IOException]
            {
                # An exception in this location indicates either that the file
                # is in-use or user do not have permissions. Wait .5 seconds. Try again
                Start-Sleep -Milliseconds 500
                Write-ToErrorDebugReport -ErrorRecord $_ -ScriptErrorText "[Write-ToStdout]: $WhatToWrite" -InvokeInfo $MyInvocation -SkipWriteToStdout
                continue
            }

            if($ShortFormat)
            {
                if ($NoHeader.IsPresent)
                {
                    $WhatToWrite | Out-File -FilePath $StdOutFileName -append -ErrorAction SilentlyContinue
                    if ($AdditionalFileName.Length -gt 0)
                    {
                        $WhatToWrite | Out-File -FilePath $AdditionalFileName -append -ErrorAction SilentlyContinue
                    }
                }
                else
                {
                    "[" + (Get-Date -Format "T") + " " + $ComputerName + " - " + [System.IO.Path]::GetFileName($InvokeInfo.ScriptName) + " - " + $InvokeInfo.ScriptLineNumber.ToString().PadLeft(4) + "] $WhatToWrite" | Out-File -FilePath $StdOutFileName -append -ErrorAction SilentlyContinue
                    if ($AdditionalFileName.Length -gt 0)
                    {
                        "[" + (Get-Date -Format "T") + " " + $ComputerName + " - " + [System.IO.Path]::GetFileName($InvokeInfo.ScriptName) + " - " + $InvokeInfo.ScriptLineNumber.ToString().PadLeft(4) + "] $WhatToWrite" | Out-File -FilePath $AdditionalFileName -append -ErrorAction SilentlyContinue
                    }
                }
            }
            else
            {
                if ($NoHeader.IsPresent)
                {
                    "`r`n" + $WhatToWrite | Out-File -FilePath $StdOutFileName -append -ErrorAction SilentlyContinue
                    if ($AdditionalFileName.Length -gt 0)
                    {
                        "`r`n" + $WhatToWrite | Out-File -FilePath $AdditionalFileName -append -ErrorAction SilentlyContinue
                    }
                    if ($Host.Name -eq "Windows PowerShell ISE Host")
                    {
                        "`r`n" + $WhatToWrite | Write-Host
                    }
                }
                else
                {
                    "`r`n[" + (Get-Date) + " " + $ComputerName + " - From " + [System.IO.Path]::GetFileName($InvokeInfo.ScriptName) + " Line: " + $InvokeInfo.ScriptLineNumber + "]`r`n" + $WhatToWrite | Out-File -FilePath $StdOutFileName -append -ErrorAction SilentlyContinue
                    if ($AdditionalFileName.Length -gt 0)
                    {
                        "`r`n[" + (Get-Date) + " " + $ComputerName + " - From " + [System.IO.Path]::GetFileName($InvokeInfo.ScriptName) + " Line: " + $InvokeInfo.ScriptLineNumber + "]`r`n" + $WhatToWrite | Out-File -FilePath $AdditionalFileName -append -ErrorAction SilentlyContinue
                    }
                    if ($Host.Name -eq "Windows PowerShell ISE Host")
                    {
                        "`r`n" + $WhatToWrite | Write-Host
                    }
                }
            }
            [System.Threading.Monitor]::Exit($global:m_WriteCriticalSection)

        }
        if($PassThru)
        {
            return $WhatToWrite
        }
    }
}

Filter Write-ToErrorDebugReport
(
    [string] $ScriptErrorText,
    [System.Management.Automation.ErrorRecord] $ErrorRecord = $null,
    [System.Management.Automation.InvocationInfo] $InvokeInfo = $null,
    [switch] $SkipWriteToStdout
)
{
    trap [Exception]
    {
        $ExInvokeInfo = $_.Exception.ErrorRecord.InvocationInfo
        if ($null -ne $ExInvokeInfo)
        {
            $line = ($_.Exception.ErrorRecord.InvocationInfo.Line).Trim()
        }
        else
        {
            $Line = ($_.InvocationInfo.Line).Trim()
        }

        if (-not ($SkipWriteToStdout.IsPresent))
        {
            "[Write-ToErrorDebugReport] Error: " + $_.Exception.Message + " [" + $Line + "].`r`n" + $_.StackTrace | Write-ToStdout
        }
        continue
    }

    if (($ScriptErrorText.Length -eq 0) -and ($ErrorRecord -eq $null)) {$ScriptErrorText=$_}

    if (($ErrorRecord -ne $null) -and ($InvokeInfo -eq $null))
    {
        if ($null -ne $ErrorRecord.InvocationInfo)
        {
            $InvokeInfo = $ErrorRecord.InvocationInfo
        }
        elseif ($null -ne $ErrorRecord.Exception.ErrorRecord.InvocationInfo)
        {
            $InvokeInfo = $ErrorRecord.Exception.ErrorRecord.InvocationInfo
        }
        if ($null -eq $InvokeInfo)
        {
            $InvokeInfo = $MyInvocation
        }
    }
    elseif ($InvokeInfo -eq $null)
    {
        $InvokeInfo = $MyInvocation
    }

    $Error_Summary = New-Object PSObject

    if (($null -ne $InvokeInfo.ScriptName) -and ($InvokeInfo.ScriptName.Length -gt 0))
    {
        $ScriptName = [System.IO.Path]::GetFileName($InvokeInfo.ScriptName)
    }
    elseif (($null -ne $InvokeInfo.InvocationName) -and ($InvokeInfo.InvocationName.Length -gt 1))
    {
        $ScriptName = $InvokeInfo.InvocationName
    }
    elseif ($null -ne $MyInvocation.ScriptName)
    {
        $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    }

    $Error_Summary_TXT = @()
    if (-not ([string]::IsNullOrEmpty($ScriptName)))
    {
        $Error_Summary | Add-Member -MemberType NoteProperty -Name "Script" -Value $ScriptName
    }

    if ($null -ne $InvokeInfo.Line)
    {
        $Error_Summary | Add-Member -MemberType NoteProperty -Name "Command" -Value ($InvokeInfo.Line).Trim()
        $Error_Summary_TXT += "Command: [" + ($InvokeInfo.Line).Trim() + "]"
    }
    elseif ($null -ne $InvokeInfo.MyCommand)
    {
        $Error_Summary | Add-Member -MemberType NoteProperty -Name "Command" -Value $InvokeInfo.MyCommand.Name
        $Error_Summary_TXT += "Command: [" + $InvokeInfo.MyCommand.Name + "]"
    }

    if ($null -ne $InvokeInfo.ScriptLineNumber)
    {
        $Error_Summary | Add-Member -MemberType NoteProperty -Name "Line Number" -Value $InvokeInfo.ScriptLineNumber
    }

    if ($null -ne $InvokeInfo.OffsetInLine)
    {
        $Error_Summary | Add-Member -MemberType NoteProperty -Name "Column  Number" -Value $InvokeInfo.OffsetInLine
    }

    if (-not ([string]::IsNullOrEmpty($ScriptErrorText)))
    {
        $Error_Summary | Add-Member -MemberType NoteProperty -Name "Additional Info" -Value $ScriptErrorText
    }

    if ($null -ne $ErrorRecord.Exception.Message)
    {
        $Error_Summary | Add-Member -MemberType NoteProperty -Name "Error Text" -Value $ErrorRecord.Exception.Message
        $Error_Summary_TXT += "Error Text: " + $ErrorRecord.Exception.Message
    }
    if($null -ne $ErrorRecord.ScriptStackTrace)
    {
        $Error_Summary | Add-Member -MemberType NoteProperty -Name "Stack Trace" -Value $ErrorRecord.ScriptStackTrace
    }

    $Error_Summary | Add-Member -MemberType NoteProperty -Name "Custom Error" -Value "Yes"

    if ($ScriptName.Length -gt 0)
    {
        $ScriptDisplay = "[$ScriptName]"
    }

    $Error_Summary | ConvertTo-Xml | update-diagreport -id ("ScriptError_" + (Get-Random)) -name "Script Error $ScriptDisplay" -verbosity "Debug"
    if (-not ($SkipWriteToStdout.IsPresent))
    {
        "[Write-ToErrorDebugReport] An error was logged to Debug Report: " + [string]::Join(" / ", $Error_Summary_TXT) | Write-ToStdout -InvokeInfo $InvokeInfo -ShortFormat -IsError
    }
    $Error_Summary | Format-List * | Out-String | Write-ToStdout -DebugOnly -IsError
}

if($null -eq (Get-Variable m_WriteCriticalSection -Scope Global -ErrorAction SilentlyContinue))
{
    $global:m_WriteCriticalSection = New-Object System.Object
}

Function Write-OPD
{
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory = $false)]
        [OPDStatus] $Status = [OPDStatus]::INFO,

        [Parameter(Mandatory = $false, ValueFromPipeline=$true)]
        [string] $Message,

        [Parameter(Mandatory = $false)]
        [System.ConsoleColor] $ForegroundColor = (Get-Host).ui.rawui.ForegroundColor,
        [System.ConsoleColor] $BackgroundColor = (Get-Host).ui.rawui.BackgroundColor,

        [Switch] $NoNewline = $false,
        [int] $IndentLevel = 0
    )

    BEGIN
    {
        if ($ForegroundColor -lt 0)
        {
            $ForegroundColor = [System.ConsoleColor]::White
        }

        if ($BackgroundColor -lt 0)
        {
            $BackgroundColor = [System.ConsoleColor]::DarkBlue
        }
    }

    PROCESS
    {
        foreach($msg in $Message)
        {
            switch($Status)
            {
                SUCCESS
                {
                    $msg = ("`t"*$IndentLevel) + ("[+] $msg")
                    Write-Green -Message $msg
                    $global:OPDOutputResults += $msg
                }

                WARNING
                {
                    $msg = ("`t"*$IndentLevel) + ("[!] $msg")
                    Write-Yellow -Message $msg
                    $global:OPDOutputResults += $msg
                }

                ERROR
                {
                    $msg = ("`t"*$IndentLevel) + ("[-] $msg")
                    Write-Red -Message $msg
                    $global:OPDOutputResults += $msg
                }

                INFO
                {
                    $msg = ("`t"*$IndentLevel) + ("[?] $msg")
                    Write-Host $msg -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor -NoNewline:$NoNewline
                    $global:OPDOutputResults += $msg
                }

                Default
                {
                    return
                }
            }
        }
    }

    END
    {

    }
}

Function Write-OPDEventLog
{
    param
    (
        [Parameter(Mandatory=$false, ParameterSetName="Analyzer")]
        [object] $Analyzer,

        [Parameter(Mandatory=$false, ParameterSetName="Rule")]
        [object] $Rule,

        [Parameter(Mandatory=$false ,ParameterSetName="Scenario")]
        [object] $Scenario,

        [Parameter(Mandatory=$false, ParameterSetName="Rule")]
        [bool] $RuleFailureIsJustAWarning = $false
    )

    $ResourceStrings = DATA
    {
        ConvertFrom-StringData @'
            idAction              = Action
            idAnalyzer            = Analyzer Id
            idAnalyzerDescription = AnalyzerDescription
            idAnalyzerName        = AnalyzerName
            idAnalyzerStatus      = AnalyzerStatus
            idDescription         = Description
            idDetection           = Detection
            idExecution           = Execution Id
            idID                  = ID
            idInsight             = Insight Id
            idInsightAction       = InsightAction
            idInsightDetection    = InsightDetection
            idInsightStatus       = InsightStatus
            idMessage             = Message
            idMetrics             = Metrics
            idName                = Name
            idNoIssues            = No Issues Detected
            idRule                = Rule Id
            idRuleDescription     = RuleDescription
            idRuleName            = RuleName
            idRuleStatus          = RuleStatus
            idScenario            = Scenario Id
            idStatus              = Status
            KeyValuePair          = {0} : {1}
            msgError              = Error
            msgInformation        = Information
            msgWarning            = Warning
'@
    }

    $sb = New-Object -TypeName System.Text.StringBuilder
    $source = $status = $eventId =  $null

    if ($null -ne $Analyzer)
    {
        $source = "Analyzers"
        $eventId = $Analyzer.EventId
        $status = [System.Diagnostics.EventLogEntryType]::Information

        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idName, $Analyzer.Name)) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idDescription, $Analyzer.Description)) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idID, $Analyzer.Id.ToString())) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idExecution, $Analyzer.ExecutionId.ToString())) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idMetrics, $Analyzer.Metrics)) | Out-Null

        if ($null -eq $Analyzer.Results)
        {
            $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idStatus, $ResourceStrings.msgInformation)) | Out-Null
        }
        else
        {
            if ($true -eq $Analyzer.Success)
            {
                $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idStatus, $ResourceStrings.msgInformation)) | Out-Null
            }
            else
            {
                $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idStatus, $ResourceStrings.msgError)) | Out-Null
                $failures = $Analyzer | ForEach-Object {$_.RuleDefinitions} | Where-Object {$_.Success -eq $false}
                foreach($failure in $failures)
                {
                    $sb.AppendLine() | Out-Null
                    $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idRuleName, $failure.Name)) | Out-Null
                    $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idRuleDescription, $failure.Description)) | Out-Null
                    $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idRuleStatus, $failure.Success)) | Out-Null
                }
                $status = [System.Diagnostics.EventLogEntryType]::Error
            }
            $status = ($Analyzer.RuleDefinitions.Status | Measure-Object -Minimum).Minimum
        }
    }

    if ($null -ne $Rule)
    {
        $source = "Rules"
        $eventId = $Rule.EventId
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idName, $Rule.Name)) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idDescription, $Rule.Description)) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idID, $Rule.Id.ToString())) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idExecution, $Rule.ExecutionId.ToString())) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idMetrics, $Rule.Metrics)) | Out-Null

        if ($true -eq $Rule.Success)
        {
            $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idStatus, $ResourceStrings.msgInformation)) | Out-Null
            $status = [System.Diagnostics.EventLogEntryType]::Information
        }
        else
        {
            # Dump the insight associated with this rule
            $sb.AppendLine() | Out-Null
            $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idInsightStatus, $ResourceStrings.msgError)) | Out-Null
            $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idInsightDetection, $Rule.Insight.Detection.ToString())) | Out-Null
            $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idInsightAction, $Rule.Insight.Action.ToString())) | Out-Null
            $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idInsight, $Rule.Insight.Id.ToString())) | Out-Null

            if ($true -eq $RuleFailureIsJustAWarning)
            {
                $status = [System.Diagnostics.EventLogEntryType]::Warning
                $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idStatus, $ResourceStrings.msgWarning)) | Out-Null
            }
            else
            {
                $status = [System.Diagnostics.EventLogEntryType]::Error
                $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idStatus, $ResourceStrings.msgError)) | Out-Null
            }
        }
    }

    if ($null -ne $Scenario)
    {
        $source = "Scenarios"
        $eventId = $Scenario.EventId

        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idName, $Scenario.Name)) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idDescription, $Scenario.Description)) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idID, $Scenario.Id.ToString())) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idExecution, $Scenario.ExecutionId.ToString())) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idMetrics, $Scenario.Metrics)) | Out-Null

        if ($true -eq $Scenario.Success)
        {
            $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idStatus, $ResourceStrings.msgInformation)) | Out-Null
            $status = [System.Diagnostics.EventLogEntryType]::Information
        }
        else
        {
            $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idStatus, $ResourceStrings.msgError)) | Out-Null
            $failures = $Scenario | ForEach-Object {$_.AnalyzerDefinitions} | Where-Object {$_.Success -eq $false}
            foreach($failure in $failures)
            {
                $sb.AppendLine() | Out-Null
                $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idAnalyzerName, $failure.Name)) | Out-Null
                $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idAnalyzerDescription, $failure.Description)) | Out-Null
                $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idAnalyzerStatus, $failure.Success)) | Out-Null
            }

            $status = [System.Diagnostics.EventLogEntryType]::Error
        }
    }

    if($Scenario -or $Analyzer -or $Rule)
    {
        $sb.AppendLine() | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idScenario, $global:CurrentScenario.ToString())) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idAnalyzer, $global:CurrentAnalyzer.ToString())) | Out-Null
        $sb.AppendLine(($ResourceStrings.KeyValuePair -f $ResourceStrings.idRule, $global:CurrentRule.ToString())) | Out-Null
    }

    Write-EventLog -LogName $global:EventLogName -Source $source -EntryType $status `
        -Message $sb.ToString() `
        -EventId $eventId
}