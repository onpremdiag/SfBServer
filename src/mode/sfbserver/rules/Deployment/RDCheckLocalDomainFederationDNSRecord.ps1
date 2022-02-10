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
# Filename: RDCheckLocalDomainFederationDNSRecord.ps1
# Description: Determine if local domain federation DNS SRV record is correct
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckLocalDomainFederationDNSRecord : RuleDefinition
{
    RDCheckLocalDomainFederationDNSRecord([object] $Insight)
    {
        $this.Name        ='RDCheckLocalDomainFederationDNSRecord'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('0a260a16-2dd2-4f79-801e-263e85dfa8e1')
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

            $SipDomains = Get-CsSipDomain | Where-Object {$_.IsDefault}

            if ([string]::IsNullOrEmpty($SipDomains))
            {
                throw 'IDNoDefaultSipDomainFound'
            }

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
                            foreach ($sipDomain in $SipDomains)
                            {
                                $Session = New-PSSession -ComputerName $edgeServer `
                                                         -Credential $obj.Credential `
                                                         -Port $global:WinRMHTTPPort `
                                                         -ErrorAction SilentlyContinue

                                $scriptBlock =
                                {
                                    param($Server)
                                    Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force;
                                    Resolve-DnsName -Name $Server -Type SRV -DnsOnly | Where-Object {$_.Type -eq 'SRV'}
                                }

                                $dnsRecords = Invoke-RemoteCommand -Session $Session `
                                                -ScriptBlock $scriptBlock `
                                                -ArgumentList ("{0}.{1}" -f $global:SIPFederationTLS, $sipDomain.Identity)

                                $errorRecords = $Error | Where-Object {$_.ToString() -like "*$($global:SIPFederationTLS).$($sipDomain.Identity)"}

                                if(-not [string]::IsNullOrEmpty($dnsRecords))
                                {
                                    foreach($dnsRecord in $dnsRecords)
                                    {
                                        $NameTarget  = $dnsRecord.NameTarget

                                        if ($NameTarget.EndsWith($sipDomain.Identity))
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
                                                throw 'IDUnableToResolveDNSName'
                                            }
                                        }
                                        else
                                        {
                                            $this.Success        = $false
                                            $this.Insight.Action = $this.Insight.Action -f $sipDomain.Identity
                                            break
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
                IDDNSNameDoesNotExist
                {
                    $this.Insight.Name      = 'IDDNSNameDoesNotExist'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name) -f ("{0}.{1}" -f $global:SIPFederationTLS, $sipDomain.Identity))
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name) -f ("{0}.{1}" -f $global:SIPFederationTLS, $sipDomain.Identity))
                    $this.Success           = $false
                }

                IDEdgeServerNotReachable
                {
                    $this.Insight.Name      = 'IDEdgeServerNotReachable'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $edgeServer
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

                IDNoDefaultSipDomainFound
                {
                    $this.Insight.Name      = 'IDNoDefaultSipDomainFound'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
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
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f ("{0}.{1}" -f $global:SIPFederationTLS, $sipDomain.Identity)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name) -f ("{0}.{1}" -f $global:SIPFederationTLS, $sipDomain.Identity)
                    $this.Success           = $false
                }

                IDUnableToResolveDNSName
                {
                    $this.Insight.Name      = 'IDUnableToResolveDNSName'
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

