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
# Filename: SDModernAuthenticationNotWorking.ps1
# Description: Check if Sfb Server modern authentication topology is supported
# and functional
#
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class SDModernAuthenticationNotWorking : ScenarioDefinition
{
    SDModernAuthenticationNotWorking([guid] $ExecutionId)
    {
        $this.Name         = 'SDModernAuthenticationNotWorking'
        $this.Description  = $global:ScenarioDescriptions.($this.Name)
        $this.ExecutionId  = $ExecutionId
        $this.Id           = [guid]::new('2195fe01-1ce2-4e96-ad81-0ce956bf9c84')
        $this.Success      = $true
        $this.EventId      = Get-EventId($this.Name)

        # Analyzers
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckAllServersSkype]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckRegistrarVersions]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckO365Connectivity]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckDomainIsKnown]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckAADConfigured]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckModernAuthentication]::new())

        # Do we need any parameters for this scenario?
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDSipAddress]::new())
        #Add-ParameterDefinition -Object $this -ParameterDefinition ([PDO365Domain]::new())
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDPromptforTeamsCreds]::new())

        # Areas
        Add-Area -Scenario $this -Area ($global:AreaTitles.'Deployment')

        # Keywords for searching
        Add-Keyword -Scenario $this -Keyword 'Authentication'
    }

    [void] Execute()
    {
        $global:CurrentScenario = $this.Id
        $id                     = Get-ProgressId
        $analyzerCount          = 0

        Get-UserInput -ParameterDefinitions $this.ParameterDefinitions

        try
        {
            # Establish a session
            Disconnect-MicrosoftTeams
            Connect-MicrosoftTeams

            foreach($analyzer in $this.AnalyzerDefinitions)
            {
                $analyzerCount++
                $analyzer.ExecutionId          = $this.ExecutionId
                $analyzer.ParameterDefinitions = $this.ParameterDefinitions

                Write-Progress -Activity $global:OPDStrings.'RunningAnalyzers' -Id $id `
                               -Status $analyzer.Description `
                               -PercentComplete($analyzerCount/$this.AnalyzerDefinitions.Count*100)

                Invoke-Analyzer -Analyzer $analyzer -Obj $null

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
            Disconnect-MicrosoftTeams
            Write-Progress -Activity $global:OPDStrings.'RunningAnalyzers' -Id $id -Status "Ready" -Completed
        }
    }
}
