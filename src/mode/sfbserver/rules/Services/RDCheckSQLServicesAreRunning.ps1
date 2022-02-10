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
# Filename: RDCheckSQLServicesAreRunning.ps1
# Description: Check if RTCLOCAL and LYNCLOCAL SQL Server instances are running
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckSQLServicesAreRunning : RuleDefinition
{
    RDCheckSQLServicesAreRunning([object] $Insight)
    {
        $this.Name        ='RDCheckSQLServicesAreRunning'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('366ea6db-d372-4c20-a267-e44a9a7a4f22')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $sqlInstanceServices = Get-Service -DisplayName "SQL Server (*)"

            if(-not [string]::IsNullOrEmpty($sqlInstanceServices))
            {
                foreach ($sqlInstance in $sqlInstanceServices)
                {
                    if ($sqlInstance.Status -ne 'Running')
                    {
                        $this.Success = $false
                        break
                    }
                }
            }
            else
            {
                # No SQL services found
                $this.Insight.Detection = $global:InsightDetections.'IDNoSQLServiceInstancesFound'
                $this.Insight.Action    = $global:InsightActions.'IDNoSQLServiceInstancesFound'
                $this.Success           = $false
            }
        }
        catch [System.Management.Automation.PropertyNotFoundException]
        {
            $this.Insight.Detection = $global:InsightDetections.'IDPropertyNotFoundException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDPropertyNotFoundException'
            $this.Success           = $false
        }
        catch [System.Management.Automation.CommandNotFoundException]
        {
            $this.Insight.Detection = $global:InsightDetections.'IDCommandNotFoundException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDCommandNotFoundException'
            $this.Success           = $false
        }
        catch
        {
            $this.Insight.Detection = $global:InsightDetections.'IDException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDException'
            $this.Success           = $false
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}

