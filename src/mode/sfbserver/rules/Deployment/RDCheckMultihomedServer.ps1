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
# Filename: RDCheckMultihomedServer.ps1
# Description: Check frontend servers to ensure they are not multi-homed
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/20/2021 11:12 AM
#
# Last Modified On: 1/20/2021 11:12 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckMultihomedServer : RuleDefinition
{
    RDCheckMultihomedServer([object] $Insight)
    {
        $this.Name        ='RDCheckMultihomedServer'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('18048221-D9F9-4046-8586-B4D204318567')
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
                $ServerFqdnName = $ServerFqdn.Name

                if (-not [string]::IsNullOrEmpty($ServerFqdnName))
                {
                    $IPAddress = (Resolve-DnsName -Name $ServerFqdnName -Type A).IPAddress

                    if (-not [string]::IsNullOrEmpty($IPAddress))
                    {
                        $count = @(Get-NetIPAddress -IPAddress $IPAddress -AddressFamily IPv4 -Type Unicast |
                                                Where-Object {$_.PrefixOrigin -ne 'WellKnown'}).Count

                        if ($count -gt 1)
                        {
                            # What is the WARNING/ERROR condition??
                            # 1 is good, >1 => WARNING
                            # ID: multi-homed detected machine. Not supported configuration
                            # IA: Point them to KB article
                            throw 'IDMultiHomePossible'
                        }
                    }
                    else
                    {
                        throw 'IDUnableToResolveDNSName'
                    }
                }
                else
                {
                    throw 'IDUnableToResolveServerFQDN'
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
                IDUnableToResolveDNSName
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDMultiHomePossible
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Status    = 'WARNING'
                    $this.Insight.Detection = $global:InsightDetections.($_) -f $count
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