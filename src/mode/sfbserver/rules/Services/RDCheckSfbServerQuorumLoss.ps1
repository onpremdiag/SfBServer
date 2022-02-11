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
# Filename: RDCheckSfbServerQuorumLoss.ps1
# Description: Check if minimum number of servers required to start pool are up and running
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckSfbServerQuorumLoss : RuleDefinition
{
    RDCheckSfbServerQuorumLoss([object] $Insight)
    {
        $this.Name        ='RDCheckSfbServerQuorumLoss'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('043a5275-5073-4749-b283-4e2e1c794bbb')
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
                            $Connection = Test-NetConnection -ComputerName $FE.Fqdn -Port 5090 -WarningAction SilentlyContinue
                            if(-not [string]::IsNullOrEmpty($Connection))
                            {
                                if($Connection.TcpTestSucceeded)
                                {
                                    $FEAvailable++
                                }
                            }
                            else
                            {
                                # Unable to resolve DNS name
                                # Network connection fails
                                throw 'IDTestNetworkConnectionFails'
                            }
                         }

                        Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force

                        if ($FECount -ne $FEAvailable)
                        {
                            $this.Success           = $false
                            $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f $FEAvailable, $FECount
                            $this.Insight.Action    = $global:InsightActions.($this.Insight.Name) -f $PoolFqdn
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
                IDNullOrEmptyPoolFQDN
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($_) -f $ServerFqdn.Name)
                    $this.Insight.Action    = ($global:InsightActions.($_) -f $ServerFqdn.Name)
                    $this.Success           = $false
                }

                IDTestNetworkConnectionFails
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_) -f $FE.Fqdn
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDUnableToResolveDNSName
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDUnableToResolveServerFQDN
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
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
