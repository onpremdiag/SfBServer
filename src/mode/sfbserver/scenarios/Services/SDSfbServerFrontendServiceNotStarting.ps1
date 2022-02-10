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
# Filename: SDSfbServerFrontendServiceNotStarting.ps1
# Description: Skype for Business Server Frontend service not starting
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class SDSfbServerFrontendServiceNotStarting : ScenarioDefinition
{
    SDSfbServerFrontendServiceNotStarting([guid] $ExecutionId)
    {
        $this.Name         = 'SDSfbServerFrontendServiceNotStarting'
        $this.Description  = $global:ScenarioDescriptions.($this.Name)
        $this.ExecutionId  = $ExecutionId
        $this.Id           = [guid]::new('9e3fe3d9-220d-459c-ba52-cfcbc0a75fe0')
        $this.Success      = $true
        $this.EventId      = Get-EventId($this.Name)

        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckLocalSQLServerInstanceAndDBs]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADIsSfbServerCertificateValid]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckRootCACertificates]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADIsSQLBackendConnectionAvailable]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckQuorumLoss]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckSChannelRegistryKeys]::new())

        Add-Keyword -Scenario $this -Keyword 'Services'
        Add-Keyword -Scenario $this -Keyword 'Certificate'
        Add-Keyword -Scenario $this -Keyword 'Starting'
        Add-Keyword -Scenario $this -Keyword 'Frontend'

        Add-Area -Scenario $this -Area ($global:AreaTitles.'Services')
    }

    [void] Execute()
    {
        $global:CurrentScenario = $this.Id
        $id                     = Get-ProgressId
        $analyzerCount          = 0

        try
        {
            foreach($analyzer in $this.AnalyzerDefinitions)
            {
                $analyzerCount++
                $analyzer.ExecutionId          = $this.ExecutionId

                Write-Progress -Activity $global:OPDStrings.'RunningAnalyzers' -Id $id `
                               -Status $analyzer.Description `
                               -PercentComplete($analyzerCount/$this.AnalyzerDefinitions.Count*100)

                Invoke-Analyzer -analyzer $analyzer

                $this.Success = $this.Success -band $analyzer.Success
                if ($false -eq $analyzer.Success)
                {
                    $this.Results += $analyzer
                    break
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
            Write-Progress -Activity $global:OPDStrings.'RunningAnalyzers' -Id $id -Status "Ready" -Completed
            Write-OPDEventLog -Scenario $this
        }
    }
}
