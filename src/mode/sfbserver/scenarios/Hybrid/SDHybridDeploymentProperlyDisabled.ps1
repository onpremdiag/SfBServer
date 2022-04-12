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
# Filename: SDHybridDeploymentProperlyDisabled.ps1
# Description:  validate if Skype for Business hybrid deployment was properly
# disabled as per Disable hybrid to complete migration to the cloud
#
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 7/13/2021 1:14 PM
#
#################################################################################
Set-StrictMode -Version Latest

class SDHybridDeploymentProperlyDisabled : ScenarioDefinition
{
    SDHybridDeploymentProperlyDisabled([guid] $ExecutionId)
    {
        $this.Name         = 'SDHybridDeploymentProperlyDisabled'
        $this.Description  = $global:ScenarioDescriptions.($this.Name)
        $this.ExecutionId  = $ExecutionId
        $this.Id           = [guid]::new('B0A5C9B8-F67A-4E66-B214-A3CBCB5A4C07')
        $this.Success      = $true
        $this.EventId      = Get-EventId($this.Name)

        # Analyzers
        Add-AnalyzerDefinition -Scenario $this -AnalyzerDefinition ([ADCheckHybridDeployment]::new())

        # Keywords for searching
        Add-Keyword -Scenario $this -Keyword 'Hybrid'

        # Parameters needed by the analyzer/rules
        Add-ParameterDefinition -Object $this -ParameterDefinition ([PDPromptforTeamsCreds]::new())

        # Areas
        Add-Area -Scenario $this -Area ($global:AreaTitles.'Hybrid')
    }

    [void] Execute()
    {
        $global:CurrentScenario = $this.Id
        $id                     = Get-ProgressId
        $analyzerCount          = 0

        Get-UserInput -ParameterDefinitions $this.ParameterDefinitions

        try
        {
            # Verify that Teams Module is loaded
            if (Test-MicrosoftTeamsModule -eq $false)
            {
                throw 'IDMicrosoftTeamsModuleCheckFailed'
            }

            # Establish a session
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
                    $this.Insight.Name      = $_
                    $this.Insight.Action    = $global:InsightActions.$_
                    $this.Insight.Detection = $global:InsightDetections.$_
                    $this.Success           = $false
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
