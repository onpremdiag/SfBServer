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
# Filename: SDOnPremFederation.ps1
# Description: Checks if federation for On-Premise deployments is properly configured
# and functional
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class SDOnPremFederation : ScenarioDefinition
{
    SDOnPremFederation([guid] $ExecutionId)
    {
        $this.Name         = 'SDOnPremFederation'
        $this.Description  = $global:ScenarioDescriptions.($this.Name)
        $this.ExecutionId  = $ExecutionId
        $this.Id           = [guid]::new('1f1ea7f2-4819-42fe-9c70-c253459f6283')
        $this.Success      = $true
        $this.EventId      = Get-EventId($this.Name)

        # Analyzers
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADEdgeServerAvailable]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADIsSfbServerAdminAccount]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckSIPHostingProviderForOnPrem]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckEdgeOnPremConfiguration]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckEdgePoolConfiguration]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckFederatedDomain]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckFederationDNSRecords]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCertificateCheck]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckEdgeInternalDNS]::new())

        # Parameters needed by the analyzer/rules
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDEdgeUserID]::new())
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDEdgePassword]::new())
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDRemoteFqdnDomain]::new())

        # Keywords for searching
        Add-Keyword -Scenario $this -Keyword 'OnPrem'
        Add-Keyword -Scenario $this -Keyword 'Federation'

        # Areas
        Add-Area -Scenario $this -Area ($global:AreaTitles.'Federation')
    }

    [void] Execute()
    {
        $global:CurrentScenario = $this.Id
        $id                     = Get-ProgressId
        $analyzerCount          = 0

        Get-UserInput -ParameterDefinitions $this.ParameterDefinitions

        try
        {
            # Step 1 - Purge all existing sessions - forces re-authentication in some cases
            Get-PSSession -ErrorAction SilentlyContinue | Remove-PSSession -ErrorAction SilentlyContinue

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
