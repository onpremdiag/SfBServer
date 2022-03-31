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
# Filename: SDServerPerfCheck.ps1
# Description: <TODO>
# Task 25831: Diagnostic Investment - Presence subscription and instant messaging delays - Performance
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/8/2022 3:16:26 PM
#
#################################################################################
Set-StrictMode -Version Latest

class SDServerPerfCheck : ScenarioDefinition
{
    SDServerPerfCheck([guid] $ExecutionId)
    {
        $this.Name         = 'SDServerPerfCheck'
        $this.Description  = $global:ScenarioDescriptions.($this.Name)
        $this.ExecutionId  = $ExecutionId
        $this.Id           = [guid]::new('C0CE85AD-3228-425C-9407-387EB9D57655')
        $this.Success      = $true
        $this.EventId      = Get-EventId($this.Name)

        # Analyzers
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADServerPerfCheck]::new())

        $this.Keywords = @()

        # Areas
        Add-Area -Scenario $this -Area ($global:AreaTitles.'Performance')

    }

    [void] Execute()
    {
        $global:CurrentScenario = $this.Id

        try
        {
            foreach($analyzer in $this.AnalyzerDefinitions)
            {
                $analyzer.ExecutionId = $this.ExecutionId

                Invoke-Analyzer -analyzer $analyzer

                $this.Success = $this.Success -band $analyzer.Success
                if ($false -eq $analyzer.Success)
                {
                    $this.Results += $analyzer
                }
            }
        }
        catch
        {
            Write-EventLog  -LogName $global:EventLogName `
                            -source "Scenarios" `
                            -EntryType Error `
                            -Message ("{0}`r`n{1}" -f $_.Exception, $_.ScriptStackTrace) `
                            -EventId 999
            $this.Success  = $false
        }
        finally
        {
            Write-OPDEventLog -Scenario $this
        }
    }
}

#
# SDServerPerfCheck.ps1
#
