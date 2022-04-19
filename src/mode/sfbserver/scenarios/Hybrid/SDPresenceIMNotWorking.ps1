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
# Filename: SDPresenceIMNotWorking.ps1
# Description: Presence and messaging between On-Premises and Online homed
# users is not working. This scenario checks if Skype for BUsiness Server
# hybrid deployment is properly configured
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/10/2020 11:44 AM
#
# Last Modified On: 1/10/2020 11:44 AM
#################################################################################
Set-StrictMode -Version Latest

class SDPresenceIMNotWorking : ScenarioDefinition
{
    SDPresenceIMNotWorking([guid] $ExecutionId)
    {
        $this.Name         = 'SDPresenceIMNotWorking'
        $this.Description  = $global:ScenarioDescriptions.($this.Name)
        $this.ExecutionId  = $ExecutionId
        $this.Id           = [guid]::new('EB85AC7C-6D6E-45FF-B59A-E5961CA876E0')
        $this.Success      = $true
        $this.EventId      = Get-EventId($this.Name)

        # Analyzers
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADEdgeServerAvailable]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckSecurityGroupMembership]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADIsSfbServerAdminAccount]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckSIPHostingProvider]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckEdgeConfiguration]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckEdgePoolConfiguration]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCompareOnPremToOnline]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCertificateCheck]::new())
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckEdgeInternalDNS]::new())

        # Keywords for searching
        Add-Keyword -Scenario $this -Keyword 'Hybrid'
        Add-Keyword -Scenario $this -Keyword 'IM'
        Add-Keyword -Scenario $this -Keyword 'Presence'

        # Parameters needed by the analyzer/rules
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDEdgeUserID]::new())
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDEdgePassword]::new())
        #Add-ParameterDefinition -Object $this -ParameterDefinition ([PDO365Domain]::new())
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDPromptforTeamsCreds]::new())

        # Areas
        Add-Area -Scenario $this -Area ($global:AreaTitles.'Hybrid')
    }

    [void] Execute()
    {
        $global:CurrentScenario = $this.Id
        $id                     = Get-ProgressId
        $analyzerCount          = 0

        try
        {
            # Verify that Teams Module is loaded
            if (-not (Test-MicrosoftTeamsModule))
            {
                throw 'IDMicrosoftTeamsModuleCheckFailed'
            }

            # Establish a session
            Get-UserInput -ParameterDefinitions $this.ParameterDefinitions

            Disconnect-MicrosoftTeams
            Connect-MicrosoftTeams

            foreach ($analyzer in $this.AnalyzerDefinitions)
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
            switch ($_.ToString())
            {
                IDMicrosoftTeamsModuleCheckFailed
                {
                    $LogArguments = @{
                        LogName   = $global:EventLogName
                        Source    = "Scenarios"
                        EntryType = "Error"
                        Message   = ("{0}" -f $global:InsightDetections.$_)
                        EventId   = 999
                    }

                    Write-EventLog  @LogArguments

                    $this.Success  = $false
                }

                default
                {
                    $LogArguments = @{
                        LogName   = $global:EventLogName
                        Source    = "Scenarios"
                        EntryType = "Error"
                        Message   = ("{0}`r`n{1}" -f $_.Exception, $_.ScriptStackTrace)
                        EventId   = 999
                    }

                    Write-EventLog  @LogArguments

                    $this.Success  = $false
                }
            }
        }
        finally
        {
            Disconnect-MicrosoftTeams
            Write-Progress -Activity $global:OPDStrings.'RunningAnalyzers' -Id $id -Status "Ready" -Completed
            Get-PSSession -ErrorAction SilentlyContinue | Remove-PSSession -ErrorAction SilentlyContinue
            Write-OPDEventLog -Scenario $this
        }
    }
}
