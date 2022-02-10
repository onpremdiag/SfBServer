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
# Filename: RDCheckLyncdiscoverRecord.ps1
# Description: Determine if lyncdiscover.<domain> DNS CNAME record points to webdir.online.lync.com
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 8/16/2021 12:02 PM
#
#################################################################################
Set-StrictMode -Version Latest

class RDCheckLyncdiscoverRecord : RuleDefinition
{
    RDCheckLyncdiscoverRecord([object] $Insight)
    {
        $this.Name        ='RDCheckLyncdiscoverRecord'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('E19014B6-FB15-475D-B919-541652F56B90')
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
            $Domains = Get-CsOnlineSipDomain

            if ([string]::IsNullOrEmpty($Domains))
            {
                throw 'IDGetCsOnlineSipDomainFails'
            }
            else
            {
                foreach($OnlineSipDomainBase in ($Domains | Where-Object {$_.Name -notlike '*onmicrosoft.com'}))
                {
                    # Let's look for CNAME lyncdiscover -> webdir.online.lync.com
                    $DNSSrvSipFed  = "$($global:LyncDiscover)." + $OnlineSipDomainBase.Name.ToString()
                    $resolution    = $null

                    # Bug 33940: Update stale DNS records rules logic
                    $resolution = Resolve-DnsName -Name $DNSSrvSipFed `
                                                  -Type CNAME `
                                                  -Server $global:DNSServer `
                                                  -ErrorAction Stop `
                                                  -DnsOnly | Where-Object {$_.Section -eq 'Answer'}

                    foreach($domain in $resolution)
                    {
                        if ($domain.NameHost.ToString() -ne $global:WebDir)
                        {
                            throw 'IDDNSOnPremises'
                        }
                    }
                }
            }
        }
        catch
        {
            if ($_.Exception.Message.Contains($global:MiscStrings.'DNSDoesNotExist'))
            {
                $this.Insight.Name      = 'IDDNSNameDoesNotExist'
                $this.Insight.Detection = ($global:InsightDetections.'IDDNSNameDoesNotExist' -f $DNSSrvSipFed)
                $this.Insight.Action    = ($global:InsightActions.'IDDNSNameDoesNotExist' -f $DNSSrvSipFed)
                $this.Success           = $false
            }
            else
            {
                switch($_.ToString())
                {
                    IDGetCsOnlineSipDomainFails
                    {
                        $this.Insight.Name      = $_
                        $this.Insight.Detection = $global:InsightDetections.($_)
                        $this.Insight.Action    = $global:InsightActions.($_)
                        $this.Success           = $false
                        $this.Status            = [OPDStatus]::ERROR
                    }

                    IDDNSOnPremises
                    {
                        $this.Insight.Name      = $_
                        $this.Insight.Detection = ($global:InsightDetections.($_) -f $DNSSrvSipFed, $global:WebDir, $domain.NameHost.ToString())
                        $this.Insight.Action    = $global:InsightActions.($_)
                        $this.Success           = $false
                        $this.Status            = [OPDStatus]::ERROR
                    }

                    #IDDNSARecord
                    #{
                    #    $this.Insight.Name      = $_
                    #    $this.Insight.Detection = ($global:InsightDetections.($_) -f $domain.NameHost)
                    #    $this.Insight.Action    = $global:InsightActions.($_)
                    #    $this.Success           = $false
                    #    $this.Status            = [OPDStatus]::ERROR
                    #}

                    #IDDNSSRVRecord
                    #{
                    #    $this.Insight.Name      = $_
                    #    $this.Insight.Detection = ($global:InsightDetections.($_) -f $domain.NameHost, $domain.Name)
                    #    $this.Insight.Action    = $global:InsightActions.($_)
                    #    $this.Success           = $false
                    #    $this.Status            = [OPDStatus]::ERROR
                    #}

                    #IDDNSTXTRecord
                    #{
                    #    $this.Insight.Name      = $_
                    #    $this.Insight.Detection = ($global:InsightDetections.($_) -f $domain.NameHost)
                    #    $this.Insight.Action    = $global:InsightActions.($_)
                    #    $this.Success           = $false
                    #    $this.Status            = [OPDStatus]::ERROR
                    #}

                    #IDDNSTypeOther
                    #{
                    #    $this.Insight.Name      = $_
                    #    $this.Insight.Detection = ($global:InsightDetections.($_) -f $domain.NameHost, $domain.Type)
                    #    $this.Insight.Action    = $global:InsightActions.($_)
                    #    $this.Success           = $false
                    #    $this.Status            = [OPDStatus]::ERROR
                    #}

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
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}
