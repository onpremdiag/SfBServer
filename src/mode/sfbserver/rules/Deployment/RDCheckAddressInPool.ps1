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
# Filename: RDCheckAddressInPool.ps1
# Description: Determine the IP address of the current FE is included in the
# list of IP addresses for the pool
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/28/2021 11:33 AM
#
# Last Modified On: 1/28/2021 11:33 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckAddressInPool : RuleDefinition
{
    RDCheckAddressInPool([object] $Insight)
    {
        $this.Name        ='RDCheckAddressInPool'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('C7018F30-BD7A-4C07-A702-1ACD971C42DA')
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

            $ServerFqdn = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($ServerFqdn))
            {
                $PoolFqdn = Get-CsComputer -Identity $ServerFqdn.Name -ErrorAction SilentlyContinue

                if (-not [string]::IsNullOrEmpty($PoolFqdn))
                {
                    $PoolIPAddressList = @(Resolve-DnsName -Name $PoolFqdn.Pool -Type A -ErrorAction SilentlyContinue)

                    if (-not [string]::IsNullOrEmpty($PoolIPAddressList))
                    {
                        if ($PoolIPAddressList.IPAddress -notcontains $ServerFqdn.IPAddress)
                        {
                            throw 'IDIPAddressNotInPool'
                        }
                    }
                    else
                    {
                        throw 'IDNoPoolIPAddresses'
                    }
                }
                else
                {
                    throw 'IDUnableToGetServiceInfo'
                }
            }
            else
            {
                throw 'IDUnableToResolveDNSName'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDIPAddressNotInPool
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_) -f $ServerFqdn.IPAddress, ($PoolIPAddressList -join ', ')
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                    $this.Insight.Status    = 'WARNING'
                }

                IDNoPoolIPAddresses
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }
                IDUnableToGetServiceInfo
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
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