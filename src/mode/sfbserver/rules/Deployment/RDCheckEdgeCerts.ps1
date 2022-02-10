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
# Filename: RDCheckEdgeCerts.ps1
# Description: Determine if there are certificates on the edge server
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/6/2020 3:55 PM
#
# Last Modified On: 2/6/2020 3:55 PM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckEdgeCerts : RuleDefinition
{
    RDCheckEdgeCerts([object] $Insight)
    {
        $this.Name        ='RDCheckEdgeCerts'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('53228A74-B002-4566-88B8-D08F7C0AA45A')
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

            $EdgePools = @(Get-CsService -EdgeServer | Where-Object {$_.AccessEdgeExternalSipPort -eq $global:SIPSecurePort})

            if (-not [string]::IsNullOrEmpty($EdgePools))
            {
                foreach ($edgePool in $EdgePools)
                {
                    $edgeServers = (Get-CsPool -Identity $edgePool.PoolFqdn).Computers

                    foreach ($edgeServer in $edgeServers)
                    {
                        if(-not (Test-NetConnection -ComputerName $edgeServer -Port $global:WinRMHTTPPort).TcpTestSucceeded)
                        {
                            throw 'IDEdgeServerNotReachable'
                        }
                        else
                        {
                            $Session = New-PSSession -ComputerName $edgeServer `
                                                     -Credential $obj.Credential `
                                                     -Port $global:WinRMHTTPPort `
                                                     -ErrorAction SilentlyContinue

                            if (-not [string]::IsNullOrEmpty($Session))
                            {
                                $scriptBlock =
                                {
                                    Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force;
                                    Get-CsCertificate -Type AccessEdgeExternal | `
                                    Select-Object -Property PsComputerName, AlternativeNames, Thumbprint, Use
                                }

                                $edgeCerts = Invoke-RemoteCommand -Session $Session `
                                                                  -ScriptBlock $scriptBlock

                                if(-not [string]::IsNullOrEmpty($edgeCerts))
                                {
                                    foreach($edgeCert in $edgeCerts)
                                    {
                                        $Identity  = $edgeCert.PsComputerName
                                        $PoolFQDN  = (Get-CsComputer -Identity $Identity).Pool
                                        $FQDN      = (Get-CsService -EdgeServer -PoolFqdn $PoolFQDN).AccessEdgeExternalFqdn
                                        $SANOnCert = Test-SanOnCert -SAN $FQDN -Certificate $edgeCert

                                        if(-not $SANOnCert)
                                        {
                                            throw 'IDEdgeCertsNotOnSan'
                                        }
                                        else
                                        {
                                            $this.Success = $true
                                        }
                                    }
                                    $this.Results += @{EdgeCerts=$edgeCerts}
                                }
                                else
                                {
                                    throw 'IDUnableToConnect'
                                }
                            }
                            else
                            {
                                throw 'IDUnableToConnect'
                            }
                        }
                    }
                }
            }
            else
            {
                throw 'IDGetCsServiceFails'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDEdgeCertsNotOnSan
                {
                    $this.Success           = $false
                    $this.Insight.Name      = 'IDEdgeCertsNotOnSan'
                    $this.Insight.Detection = ($this.Insight.Detection -f $Identity, $FQDN, "TopologyFqdn")
                }

                IDEdgeServerNotReachable
                {
                    $this.Success           = $false
                    $this.Insight.Name      = 'IDEdgeServerNotReachable'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $edgeServer
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDGetCsServiceFails
                {
                    $this.Insight.Name      = 'IDGetCsServiceFails'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDUnableToConnect
                {
                    $this.Insight.Name      = 'IDUnableToConnect'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name) -f $edgeServer)
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name) -f $edgeServer)
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

