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
# Filename: SDResponseGroupUsageReport.ps1
# Description: Check if response group usage report is working properly
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 10/18/2021 10:58 AM
#
#################################################################################
Set-StrictMode -Version Latest

class SDResponseGroupUsageReport : ScenarioDefinition
{
    SDResponseGroupUsageReport([guid] $ExecutionId)
    {
        $this.Name         = 'SDResponseGroupUsageReport'
        $this.Description  = $global:ScenarioDescriptions.($this.Name)
        $this.ExecutionId  = $ExecutionId
        $this.Id           = [guid]::new('D452DAD9-486F-40C9-A6EA-DC775C568909')
        $this.Success      = $true
        $this.EventId      = Get-EventId($this.Name)

        # Analyzers
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADRGSUsageTrend]::new())

        # Keywords for searching
        Add-Keyword -Scenario $this -Keyword 'Performance'
        Add-Keyword -Scenario $this -Keyword 'SQL'

        # Areas
        Add-Area -Scenario $this -Area ($global:AreaTitles.'Performance')
        Add-Area -Scenario $this -Area ($global:AreaTitles.'ResponseGroups')

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