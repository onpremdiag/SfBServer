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
# Filename: RDTestAutoDiscover.ps1
# Description: Determine if the DNS name for the Autodiscover is resolvable
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/23/2020 1:23 PM
#
# Last Modified On: 9/23/2020 1:29 PM
#################################################################################
Set-StrictMode -Version Latest

class RDTestAutoDiscover : RuleDefinition
{
    RDTestAutoDiscover([object] $Insight)
    {
        $this.Name        ='RDTestAutoDiscover'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('707B4353-05F0-4E58-B2E7-7FB5A857024E')
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
            $domainName               = $env:USERDNSDOMAIN
            $expectedAutoDiscoverName = "autodiscover.$domainName"
            $actualServerName         = $expectedAutoDiscoverName

            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            if (-not [string]::IsNullOrEmpty($domainName))
            {

                $autoDiscoverCNAMERecord = Resolve-DnsName -Name $expectedAutoDiscoverName -Server 8.8.8.8 -Type CNAME -ErrorAction SilentlyContinue
                $autoDiscoverARecord     = Resolve-DnsName -Name $actualServerName -Server 8.8.8.8 -Type A -ErrorAction SilentlyContinue |
                                            Where-Object {$_.Type -eq 'A'}

                if (-not [string]::IsNullOrEmpty($autoDiscoverCNAMERecord))
                {
                    $actualServerName = $autoDiscoverCNAMERecord.NameHost

                    if (-not $actualServerName.EndsWith($domainName,'CurrentCultureIgnoreCase'))
                    {
                        # CNAME record does not respect strict name matching
                        throw 'IDAutoDiscoverNameDoNotMatch'
                    }
                }
                elseif ([string]::IsNullOrEmpty($autoDiscoverARecord))
                {
                    # Possible missing DNS record
                    throw 'IDDNSNameDoesNotExist'
                }
            }
            else
            {
                # unable to determine domain name from the environment variable
                throw 'IDUnknownDomain'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDDNSNameDoesNotExist
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $expectedAutoDiscoverName
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDAutoDiscoverNameDoNotMatch
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $expectedAutoDiscoverName, $actualServerName
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name)) -f $expectedAutoDiscoverName
                }

                IDUnknownDomain
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name))
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
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