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
# Filename: SDExchangeOnPremiseIntegrationNotWorking.ps1
# Description: Checks the integration between Skype for Business Server
# On-Premises and Exchange On-Premises, Online or Hybrid
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/16/2020 9:48 AM
#
# Last Modified On: 10/16/2020 9:48 AM
#################################################################################
Set-StrictMode -Version Latest

class SDExchangeOnPremiseIntegrationNotWorking : ScenarioDefinition
{
    SDExchangeOnPremiseIntegrationNotWorking([guid] $ExecutionId)
    {
        $this.Name         = 'SDExchangeOnPremiseIntegrationNotWorking'
        $this.Description  = $global:ScenarioDescriptions.($this.Name)
        $this.ExecutionId  = $ExecutionId
        $this.Id           = [guid]::new('EA4911BC-5286-4F98-BEF5-2F8954FCA413')
        $this.Success      = $true
        $this.EventId      = Get-EventId($this.Name)

        # Analyzers
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADExchangeOnPremise]::new())

        # Parameters needed by the analyzer/rules
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDSipAddress]::new())
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDExchangeServer]::new())

        # Keywords for searching
        Add-Keyword -Scenario $this -Keyword 'OnPrem'
        Add-Keyword -Scenario $this -Keyword 'Exchange'

        # Areas
        Add-Area -Scenario $this -Area ($global:AreaTitles.'Exchange')
    }

    [void] Execute()
    {
        $global:CurrentScenario = $this.Id
        $id                     = Get-ProgressId
        $analyzerCount          = 0

        Get-UserInput -ParameterDefinitions $this.ParameterDefinitions

        try
        {
            foreach($analyzer in $this.AnalyzerDefinitions)
            {
                $analyzerCount++
                $analyzer.ExecutionId          = $this.ExecutionId
                $analyzer.ParameterDefinitions = $this.ParameterDefinitions

                Write-Progress -Activity $global:OPDStrings.'RunningAnalyzers' -Id $id `
                                -Status $analyzer.Description `
                                -PercentComplete($analyzerCount/$this.AnalyzerDefinitions.Count*100)

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
            Get-PSSession -ErrorAction SilentlyContinue | Remove-PSSession -ErrorAction SilentlyContinue
            Write-Progress -Activity $global:OPDStrings.'RunningAnalyzers' -Id $id -Status "Ready" -Completed
            Write-OPDEventLog -Scenario $this
        }
    }
}