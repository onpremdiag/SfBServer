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
# Filename: RDCheckSfbServerCertificateValid.ps1
# Description: Checks if the FrontEnd/Pool server has a valid certificate
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/6/2021 10:29 AM
#
# Last Modified On: 4/6/2021 10:29 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckSfbServerCertificateValid : RuleDefinition
{
    RDCheckSfbServerCertificateValid([object] $Insight)
    {
        $this.Name        ='RDCheckSfbServerCertificateValid'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('F5827EBE-4BF0-4289-A2A4-4EEC32879C84')
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

            $validCertificates = @(Get-CsCertificate -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {$_.NotAfter -ge (Get-Date) -and $_.Use -eq "Default"})

            if ($validCertificates.Count -gt 0)
            {
                $ServerFQDN = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue
                if (-not [string]::IsNullOrEmpty($ServerFQDN))
                {
                    $ServerName = $ServerFQDN.Name
                    if (-not [string]::IsNullOrEmpty($ServerName))
                    {
                        $PoolFQDN = Get-CsComputer -Identity $ServerName -ErrorAction SilentlyContinue

                        if (-not [string]::IsNullOrEmpty($PoolFQDN.Pool))
                        {
                            $SANOnCert = Test-SanOnCert -SAN $ServerName -Certificate $validCertificates
                            if ($SANOnCert)
                            {
                                $SANOnCert = Test-SanOnCert -SAN $PoolFQDN.Fqdn -Certificate $validCertificates
                                if (-not $SANOnCert)
                                {
                                    throw 'IDPoolFqdnCertNotOnSan'
                                }
                                else
                                {
                                    $this.Success = $true
                                }
                            }
                            else
                            {
                                throw 'IDFrontendFqdnCertNotOnSan'
                            }
                        }
                        else
                        {
                            throw 'IDNullOrEmptyPoolFQDN'
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
            else
            {
                throw 'IDNoValidCertificates'
            }

        }
        catch
        {
            switch($_.ToString())
            {
                IDNoValidCertificates
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDFrontendFqdnCertNotOnSan
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDPoolFqdnCertNotOnSan
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

                IDUnableToResolveServerFQDN
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDNullOrEmptyPoolFQDN
                {
                    $this.Insight.Name      = $_.ToString()
                    $this.Insight.Detection = $global:InsightDetections.'IDNullOrEmptyPoolFQDN' -f $PoolFqdn.Fqdn
                    $this.Insight.Action    = $global:InsightActions.'IDNullOrEmptyPoolFQDN' -f $ServerName
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
