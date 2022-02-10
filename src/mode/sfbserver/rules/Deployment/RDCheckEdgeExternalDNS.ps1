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
# Filename: RDCheckEdgeExternalDNS.ps1
# Description: Determine if edge pool allows external DNS resolution
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckEdgeExternalDNS : RuleDefinition
{
    RDCheckEdgeExternalDNS([object] $Insight)
    {
        $this.Name        ='RDCheckEdgeExternalDNS'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('84a0ed4d-e2a9-40b5-bee2-baaaefe0ac2f')
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

                    if (-not [string]::IsNullOrEmpty($edgeServers))
                    {
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
                                        Resolve-DnsName -Name sipfed.online.lync.com -Type A -DnsOnly | Where-Object {$_.Section -eq 'Answer'}
                                    }

                                    $dnsRecords = Invoke-RemoteCommand -Session $Session `
                                                                       -ScriptBlock $scriptBlock

                                    if(-not [string]::IsNullOrEmpty($dnsRecords))
                                    {
                                        $this.Success = $true
                                    }
                                    else
                                    {
                                        throw 'IDExternalDNSResolutionFailed'
                                    }
                                }
                                else
                                {
                                    # Bug 33702: RDCheckEdgeExternalDNS - New-PSSession fails connecting to edge when edge is not domain joined
                                    throw 'IDUnableToConnectToEdgeServer'
                                }
                            }
                        }
                    }
                    else
                    {
                        throw 'IDNoEdgeServersFound'
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
                IDEdgeServerNotReachable
                {
                    $this.Insight.Name      = 'IDEdgeServerNotReachable'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $edgeServer
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDExternalDNSResolutionFailed
                {
                    $this.Insight.Name      = 'IDExternalDNSResolutionFailed'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDGetCsServiceFails
                {
                    $this.Insight.Name      = 'IDGetCsServiceFails'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDNoEdgeServersFound
                {
                    # No edge pools found; hence, no edge server(s)
                    $this.Insight.Name      = 'IDNoEdgeServersFound'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDUnableToConnectToEdgeServer
                {
                    $this.Insight.Name      = 'IDUnableToConnectToEdgeServer'
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

