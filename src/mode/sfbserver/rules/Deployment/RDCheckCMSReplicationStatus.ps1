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
# Filename: RDCheckCMSReplicationStatus.ps1
# Description: Verifies CMS replication status
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/14/2020 10:35 AM
#
# Last Modified On: 1/14/2020 10:35 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckCMSReplicationStatus : RuleDefinition
{
    RDCheckCMSReplicationStatus([object] $Insight)
    {
        $this.Name        ='RDCheckCMSReplicationStatus'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('AE0AB89E-8BB0-4692-8414-FA551C13E8C4')
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

            $CMSReplicationStatus = Get-CsManagementStoreReplicationStatus
            $EdgePools            = Get-CsService -EdgeServer | Where-Object {$_.AccessEdgeExternalSipPort -eq $global:SIPSecurePort}
            $EdgeServers          = @()

            if ($null -ne $EdgePools)
            {
                foreach ($EdgePool in $EdgePools)
                {
                    $computer = Get-CsComputer | Where-Object {$_.Pool -eq $EdgePools.PoolFqdn}

                    if ($null -ne $computer)
                    {
                        $EdgeServers += $computer.Fqdn
                    }
                }

                if (-not [String]::IsNullOrEmpty($EdgeServers))
                {
                    if (-not [String]::IsNullOrEmpty($CMSReplicationStatus))
                    {
                        foreach ($EdgeServer in $EdgeServers)
                        {
                            $replicationStatus = ($CMSReplicationStatus | Where-Object {$_.ReplicaFqdn -eq $EdgeServer}).UpToDate
                            $replicationDate   = ($CMSReplicationStatus | Where-Object {$_.ReplicaFqdn -eq $EdgeServer}).LastStatusReport

                            if (-not $replicationStatus)
                            {
                                $this.Insight.Name      = 'IDCMSReplicationNotSuccessful'
                                $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name) -f $EdgeServer)
                                $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name) -f $replicationDate)
                                $this.Success           = $false
                                break
                            }
                        }
                    }
                    else
                    {
                        # No information returned from Get-CsManagementStoreReplicationStatus
                        throw 'IDNoReplicationStatus'
                    }
                }
                else
                {
                    throw 'IDNoEdgeServersFound'
                }
            }
            else
            {
                throw 'IDEdgeServerWrongExternalSipPort'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDEdgeServerWrongExternalSipPort
                {
                    $this.Insight.Name      = 'IDEdgeServerWrongExternalSipPort'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDNoEdgeServersFound
                {
                    # No edge servers were found
                    $this.Insight.Name      = 'IDNoEdgeServersFound'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDNoReplicationStatus
                {
                    $this.Insight.Name      = 'IDNoReplicationStatus'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
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