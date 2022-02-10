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
# Filename: AI.psm1
# Description: Application Insight Integration
# Owner: Stefan Goﬂner <stefang@microsoft.com>
# Created On: 8/24/2018 11:44 PM (UTC+2)
#
# Exported Functions: AI_Log
#
# Last Modified On: 8/24/2018 11:44 PM (UTC+2)
#################################################################################
Set-StrictMode -Version Latest

$AI_InstrumentationKey = "cdac67b1-7fa6-421d-8b59-1223591836cb"
$AI_module             = "$PSScriptRoot\..\resources\Microsoft.ApplicationInsights.dll"

function Write-Telemetry($Scenario, $Operation, $Properties)
{
    Write-Verbose("Entering Write-Telemetry now...")

    try
    {
        Write-Verbose("Instrumentation Key: {0}" -f $AI_InstrumentationKey)

        if ($null -eq $global:AppInsightsTelemetryClient)
        {
            $loadedFile = [Reflection.Assembly]::LoadFile($AI_module)

            if ($null -ne $loadedFile)
            {
                $global:AppInsightsTelemetryClient = New-Object Microsoft.ApplicationInsights.TelemetryClient
                $global:AppInsightsTelemetryClient.InstrumentationKey = $AI_InstrumentationKey
            }
        }

        $d = New-Object 'system.collections.generic.dictionary[string,string]'

        $Properties.Keys | ForEach-Object { $d[$_] = $Properties[$_] }

        $global:AppInsightsTelemetryClient.Context.Operation.Name = $Scenario
        $global:AppInsightsTelemetryClient.TrackEvent($Operation, $d)
    }
    catch
    {
        Write-EventLog -LogName $global:EventLogName -Source $global:scriptName -EntryType Error `
            -Message ($global:OPDStrings.'UnableToLoadAI') `
            -EventId (Get-EventID -Event "UnableToLoadAI")
    }
}

function Update-Telemetry()
{
    try
    {
        if ($null -ne $global:AppInsightsTelemetryClient)
        {
            Write-Verbose "Flushing Application Insight cache..."
            $global:AppInsightsTelemetryClient.Flush()
        }
    }
    catch
    {
        Write-EventLog -LogName $global:EventLogName -Source $global:scriptName -EntryType Error `
            -Message ($global:OPDStrings.GetString('UnableToWriteAI')) `
            -EventId (Get-EventID -Event "UnableToWriteAI")
    }
}

Export-ModuleMember -Function '*'