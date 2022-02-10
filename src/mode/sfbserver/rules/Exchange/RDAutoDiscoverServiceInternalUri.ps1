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
# Filename: RDAutoDiscoverServiceInternalUri.ps1
# Description: Determine if the AutoDiscoverServiceInternalUri value contains
# a valid configuration
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/24/2020 12:04 PM
#
# Last Modified On: 9/24/2020 12:04 PM
#################################################################################
Set-StrictMode -Version Latest

class RDAutoDiscoverServiceInternalUri : RuleDefinition
{
    RDAutoDiscoverServiceInternalUri([object] $Insight)
    {
        $this.Name        ='RDAutoDiscoverServiceInternalUri'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('A8E1A42E-880E-4C9C-9DC8-4781926BB883')
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
            $expectedValue = '/Autodiscover/Autodiscover.xml'

            $ClientAccessService = Get-ClientAccessService -Identity EXCHANGE

            if (-not [string]::IsNullOrEmpty($ClientAccessService))
            {
                if ($ClientAccessService.AutoDiscoverServiceInternalUri -notlike "*$($expectedValue)*")
                {
                    # Wrong AutoDiscoverServiceInternalUri configuration
                    throw 'IDBadAutoDiscoverServiceInternalUri'
                }
            }
            else
            {
                # No value returned for client access server role
                throw 'IDNoClientAccessServerRole'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDNoClientAccessServerRole
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDBadAutoDiscoverServiceInternalUri
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f "*$($expectedValue)*", $ClientAccessService.AutoDiscoverServiceInternalUri
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                default
                {
                    $LogArguments = @{
                        LogName   = $global:EventLogName
                        Source    = "Rules"
                        EntryType = "Error"
                        Message   = $_
                        EventId   = 9002
                    }

                    Write-EventLog @LogArguments

                    $this.Success = $false
                }
            }
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}