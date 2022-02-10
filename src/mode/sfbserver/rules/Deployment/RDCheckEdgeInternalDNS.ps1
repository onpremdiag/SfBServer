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
# Filename: RDCheckEdgeInternalDNS.ps1
# Description: Determine if edge server can resolve next hop pool FQDN for
# each frontend server
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/16/2020 12:57 PM
#
# Last Modified On: 9/16/2020 1:31 PM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckEdgeInternalDNS : RuleDefinition
{
    RDCheckEdgeInternalDNS([object] $Insight)
    {
        $this.Name        ='RDCheckEdgeInternalDNS'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('16EAEB48-4A8E-49C4-A8EC-FD615CE3A65F')
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
                    $registrar = ($edgePool.Registrar).Split(':')[1]
                    $edgeServer = ($edgePool.Identity).Split(':')[1]

                    if ((-not [string]::IsNullOrEmpty($registrar)) -and (-not [string]::IsNullOrEmpty($edgeServer)))
                    {
                        $pool = Get-CsComputer -Pool $registrar

                        $Session = New-PSSession -ComputerName $edgeServer `
                                                 -Credential $obj.Credential `
                                                 -Port $global:WinRMHTTPPort `
                                                 -ErrorAction SilentlyContinue

                        if (-not [string]::IsNullOrEmpty($Session))
                        {
                            foreach ($frontEndServer in $pool)
                            {
                                $scriptBlock =
                                {
                                    Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force;
                                    Resolve-DnsName -Name $Using:frontEndServer.Fqdn -Type A -DnsOnly |
                                        Where-Object {$_.Section -eq 'Answer'} | Select-Object -Property IPAddress
                                }

                                $dnsRecord = Invoke-RemoteCommand -Session $Session `
                                                            -ScriptBlock $scriptBlock

                                if (-not [string]::IsNullOrEmpty($dnsRecord))
                                {
                                    $IPAddress = $dnsRecord.IPAddress

                                    if (-not [string]::IsNullOrEmpty($IPAddress))
                                    {
                                        # Let's check to see if that IPAddress resolves to server Fqdn
                                        $scriptBlock =
                                        {
                                            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force;
                                            ([System.Net.Dns]::GetHostEntry($Using:IPAddress)).HostName
                                        }

                                        $serverName = Invoke-RemoteCommand -Session $Session `
                                                            -ScriptBlock $scriptBlock

                                        # Server name returned should match the frontend server name from earlier
                                        if ($frontEndServer.Fqdn -ne $serverName)
                                        {
                                            throw 'IDIPv4DoesNotMatchReverseLookup'
                                        }
                                    }
                                    else
                                    {
                                        # Record found but no IP address associated with it
                                        throw 'IDNoIPAddressForHostName'
                                    }
                                }
                                else
                                {
                                    #no dns record found
                                    throw 'IDNoDNSRecordFound'
                                }
                            }
                        }
                        else
                        {
                            throw 'IDUnableToConnect'
                        }
                    }
                    else
                    {
                        #no registrar server found
                        throw 'IDNoRegistrarServerFound'
                    }
                }
            }
            else
            {
                # no edge pools found
                throw 'IDNoEdgePoolsFound'
            }
        }

        catch [System.Management.Automation.PropertyNotFoundException]
        {
            $this.Insight.Name      = 'IDPropertyNotFoundException'
            $this.Insight.Detection = $global:InsightDetections.'IDPropertyNotFoundException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDPropertyNotFoundException'
            $this.Success           = $false
        }

        catch
        {
            switch($_.ToString())
            {
                IDIPv4DoesNotMatchReverseLookup
                {
                    $this.Insight.Name      = 'IDIPv4DoesNotMatchReverseLookup'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $IPAddress, $registrar, $serverName
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDNoIPAddressForHostName
                {
                    $this.Insight.Name      = 'IDNoIPAddressForHostName'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $frontEndServer.Fqdn
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name)) -f $frontEndServer.Fqdn
                    $this.Success           = $false
                }

                IDNoDNSRecordFound
                {
                    $this.Insight.Name      = 'IDNoDNSRecordFound'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name))
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                IDNoRegistrarServerFound
                {
                    $this.Insight.Name      = 'IDNoRegistrarServerFound'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $edgePool.PoolFqdn
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name)) -f $edgePool.PoolFqdn
                    $this.Success           = $false
                }

                IDNoEdgePoolsFound
                {
                    $this.Insight.Name      = 'IDNoEdgePoolsFound'
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name))
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
