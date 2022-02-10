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
# Filename: RDCheckFederatedDomainDNSRecords.ps1
# Description: Determine if federated domain DNS SRV is correct
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckFederatedDomainDNSRecords : RuleDefinition
{
    RDCheckFederatedDomainDNSRecords([object] $Insight)
    {
        $this.Name        ='RDCheckFederatedDomainDNSRecords'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('d3f2b45c-d3a0-4b08-b1e9-692e13bc93ce')
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

            $RemoteDomainFqdn  = Get-ParameterDefinition -Object $this -ParameterName 'PDRemoteFqdnDomain'
            $EdgePools         = @(Get-CsService -EdgeServer | Where-Object {$_.AccessEdgeExternalSipPort -eq $global:SIPSecurePort})

            if (-not [string]::IsNullOrEmpty($EdgePools))
            {
                foreach ($edgePool in $EdgePools)
                {
                    $csPool = Get-CsPool -Identity $edgePool.PoolFqdn
                    if ([String]::IsNullOrEmpty($csPool))
                    {
                        throw "IDNoEdgeServersFound"
                    }
                    else
                    {
                        $edgeServers = $csPool.Computers
                    }

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
                                    param($Server)
                                    Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force;
                                    Resolve-DnsName -Name $Server -Type SRV -DnsOnly | Where-Object {$_.Type -eq 'SRV'}
                                }

                                $dnsRecords = Invoke-RemoteCommand -Session $Session `
                                                                   -ScriptBlock $scriptBlock `
                                                                   -ArgumentList ("{0}.{1}" -f $global:SIPFederationTLS, $RemoteDomainFqdn)

                                $errorRecords = $Error | Where-Object {$_.ToString() -like "*$($RemoteDomainFqdn)*"}

                                if(-not [string]::IsNullOrEmpty($dnsRecords))
                                {
                                    foreach($dnsRecord in $dnsRecords)
                                    {
                                        $NameTarget  = $dnsRecord.NameTarget

                                        if ($NameTarget.EndsWith($RemoteDomainFqdn))
                                        {
                                            $scriptBlock =
                                            {
                                                param($Server)
                                                Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force;
                                                (Resolve-DnsName -Name $Server -DnsOnly | Where-Object {$_.Section -eq 'Answer'}).Name
                                            }

                                            $dnsRecordName = Invoke-RemoteCommand -Session $Session `
                                                                                  -ScriptBlock $scriptBlock `
                                                                                  -ArgumentList $NameTarget

                                            if(-not [string]::IsNullOrEmpty($dnsRecordName))
                                            {
                                                $this.Success = $true
                                            }
                                            else
                                            {
                                                $this.Success = $false
                                                $this.Insight.Action = $this.Insight.Action -f $RemoteDomainFqdn
                                                break
                                            }
                                        }
                                        else
                                        {
                                            $this.Success = $false
                                        }
                                    }
                                }
                                elseif (-not [string]::IsNullOrEmpty($errorRecords))
                                {
                                    if ($errorRecords.Exception.ToString().Contains("DNS name does not exist"))
                                    {
                                        throw 'IDDNSNameDoesNotExist'
                                    }
                                }
                                else
                                {
                                    throw 'IDUnableToConnectToSipServer'
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
                throw "IDNoEdgeServersFound"
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDNoEdgeServersFound
                {
                    # No edge pools found; hence, no edge server(s)
                    $this.Insight.Name      = 'IDNoEdgeServersFound'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDEdgeServerNotReachable
                {
                    $this.Insight.Name      = 'IDEdgeServerNotReachable'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $edgeServer
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDDNSNameDoesNotExist
                {
                    $this.Insight.Name      = 'IDDNSNameDoesNotExist'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name) -f $RemoteDomainFqdn)
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name) -f $RemoteDomainFqdn)
                    $this.Success           = $false
                }

                IDUnableToConnectToEdgeServer
                {
                    $this.Insight.Name      = 'IDUnableToConnect'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name) -f $edgeServer)
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name) -f $edgeServer)
                    $this.Success           = $false
                }

                IDUnableToConnectToSipServer
                {
                    $this.Insight.Name      = 'IDUnableToConnect'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name) -f ("{0}.{1}" -f $global:SIPFederationTLS, $RemoteDomainFqdn))
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name) -f ("{0}.{1}" -f $global:SIPFederationTLS, $RemoteDomainFqdn))
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

