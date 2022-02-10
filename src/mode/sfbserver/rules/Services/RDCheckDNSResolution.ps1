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
# Filename: RDCheckDNSResolution.ps1
# Description: Check to see if DNS IPv4 IP can be resolved and that the reverse
# lookup matches the fqdn
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 7/20/2020 11:42 AM
#
# Last Modified On: 7/20/2020 11:42 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckDNSResolution : RuleDefinition
{
    RDCheckDNSResolution([object] $Insight)
    {
        $this.Name        ='RDCheckDNSResolution'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('D038B7C9-B5F8-491B-A9D7-DE75F3844597')
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

            $FECount = 1

            $ServerFqdn = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($ServerFqdn))
            {
                $ServerFqdnName = $ServerFqdn.Name

                if (-not [string]::IsNullOrEmpty($ServerFqdnName))
                {
                    $PoolFqdn = Get-CsComputer -Identity $ServerFqdn.Name -ErrorAction SilentlyContinue
                    if (-not [string]::IsNullOrEmpty($PoolFqdn.Pool))
                    {
                        $FrontEnds  = Get-CsComputer -Pool $PoolFqdn.Pool

                        if ($PoolFqdn.Fqdn -ne $FrontEnds.Fqdn)
                        {
                            $FECount = $FrontEnds.Count
                        }

                        $FEAvailable = 0

                        # Test-NetConnection displays a progress bar. We're going to temporarily turn it off
                        $OriginalProgressPreference = $global:ProgressPreference
                        Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

                        foreach($FE in $FrontEnds)
                        {
                            $Connection = Resolve-DnsName -Name $FE.Fqdn -Type A -DnsOnly |
                                            Where-Object {$_.Section -eq 'Answer'}

                            if(-not [string]::IsNullOrEmpty($Connection))
                            {
                                # Able to resolve DNS name. Let's lookup by IP address & see if the names match
                                $ReverseLookup = Get-HostEntry -IPAddress $Connection.Ip4Address

                                if ($ReverseLookup -ne $FE.FQDN)
                                {
                                    # Rule failure
                                    throw 'IDIPv4DoesNotMatchReverseLookup'
                                }
                            }
                            else
                            {
                                # Unable to resolve DNS name
                                # Network connection fails
                                throw 'IDTestNetworkConnectionFails'
                            }
                         }
                    }
                    else
                    {
                        # Unable to resolve Pool name
                        throw 'IDNullOrEmptyPoolFQDN'
                    }
                }
                else
                {
                    # Unable to resolve ServerFqdnName
                    throw 'IDUnableToResolveServerFQDN'
                }
            }
            else
            {
                # Unable to Resolve-DnsName
                throw 'IDUnableToResolveDNSName'
            }
        }
        catch [System.Management.Automation.PropertyNotFoundException]
        {
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
                    $this.Insight.Name      = $_.ToString()
                    $this.Insight.Detection = $global:InsightDetections.'IDIPv4DoesNotMatchReverseLookup' `
                                                -f $Connection.Ip4Address, $Connection.Name, $ReverseLookup
                    $this.Insight.Action    = $global:InsightActions.'IDIPv4DoesNotMatchReverseLookup'
                    $this.Success           = $false
                }

                IDNullOrEmptyPoolFQDN
                {
                    $this.Insight.Name      = $_.ToString()
                    $this.Insight.Detection = $global:InsightDetections.'IDNullOrEmptyPoolFQDN' -f $PoolFqdn.Fqdn
                    $this.Insight.Action    = $global:InsightActions.'IDNullOrEmptyPoolFQDN' -f $ServerFqdn.Name
                    $this.Success           = $false
                }

                IDTestNetworkConnectionFails
                {
                    $this.Insight.Name      = $_.ToString()
                    $this.Insight.Detection = $global:InsightDetections.'IDTestNetworkConnectionFails' -f $FE.Fqdn
                    $this.Insight.Action    = $global:InsightActions.'IDTestNetworkConnectionFails'
                    $this.Success           = $false
                }

                IDUnableToResolveDNSName
                {
                    $this.Insight.Name      = $_.ToString()
                    $this.Insight.Detection = $global:InsightDetections.'IDUnableToResolveDNSName'
                    $this.Insight.Action    = $global:InsightActions.'IDUnableToResolveDNSName'
                    $this.Success           = $false
                }

                IDUnableToResolveServerFQDN
                {
                    $this.Insight.Name      = $_.ToString()
                    $this.Insight.Detection = $global:InsightDetections.'IDUnableToResolveServerFQDN'
                    $this.Insight.Action    = $global:InsightActions.'IDUnableToResolveServerFQDN'
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