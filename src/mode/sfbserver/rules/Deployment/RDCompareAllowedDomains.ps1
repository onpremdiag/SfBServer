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
# Filename: RDCompareAllowedDomains.ps1
# Description: Determine if the On-Prem and Online Allowed Domains is the same
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/21/2020 12:48 PM
#
# Last Modified On: 1/21/2020 12:49 PM
#################################################################################
Set-StrictMode -Version Latest

class RDCompareAllowedDomains : RuleDefinition
{
    RDCompareAllowedDomains([object] $Insight)
    {
        $this.Name        ='RDCompareAllowedDomains'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('9EF62019-7F4A-4BD7-8B9E-67DD153A8DBB')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        $OL_allowedDomains          = $null
        $OP_allowedDomains          = $null

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            #ONLINE Get Tenant Federation Configuration
            $OL_TenantFedConf = Get-CsTenantFederationConfiguration

            #ONLINE Get Tenant Allowed Domains (minus preconfigured domains)
            try
            {
                if (-not [string]::IsNullOrEmpty($OL_TenantFedConf.AllowedDomains.AllowedDomain))
                {
                    $OL_allowedDomains = (($OL_TenantFedConf.AllowedDomains.AllowedDomain).Domain) |
                                            Where-Object {
                                                ($_ -notmatch "hotmail") -and
                                                ($_ -notmatch "Live") -and
                                                ($_ -notmatch "messenger") -and
                                                ($_ -notmatch "msn") -and
                                                ($_ -notmatch "passport") -and
                                                ($_ -notmatch "Live") -and
                                                ($_ -notmatch "sympatico") -and
                                                ($_ -notmatch "webtv") -and
                                                ($_ -notmatch "outlook.com")
                                            }
                    if ($null -eq $OL_allowedDomains)
                    {
                        $OL_allowedDomains = $global:MiscStrings.'None'
                    }
                }
                else
                {
                    $OL_allowedDomains = $global:MiscStrings.'None'
                }
            }
            catch [System.Management.Automation.PropertyNotFoundException]
            {
                if ($_.Exception.Message.Contains('AllowedDomains'))
                {
                    $OL_allowedDomains = $global:MiscStrings.'None'
                }
            }

            #ONPREM Get Allowed Domains
            try
            {
                $OP_allowedDomains = (Get-CsAllowedDomain).Domain | Where-Object {$_ -notmatch "push.lync.com"}

                if ($null -eq $OP_allowedDomains)
                {
                    $OP_allowedDomains = $global:MiscStrings.'None'
                }

            }
            catch [System.Management.Automation.PropertyNotFoundException]
            {
                if ($_.Exception.Message.Contains('Domain'))
                {
                    $OP_allowedDomains = $global:MiscStrings.'None'
                }
            }

            # Let's compare the two
            $DomainCompare  = Compare-Object -ReferenceObject $OP_allowedDomains -DifferenceObject $OL_allowedDomains -IncludeEqual
            $AllowedDomains = @()

            foreach($domain in $DomainCompare)
            {
                if($domain.SideIndicator -eq "==")
                {
                    $AllowedDomains += New-Object PSObject -Property @{"Success"=$true;"OnPrem"=$($domain.InputObject);"OnLine"=$($domain.InputObject)}
                }
                elseif ($domain.SideIndicator -eq "<=")
                {
                    $AllowedDomains += New-Object PSObject -Property @{"Success"=$false;"OnPrem"=$($domain.InputObject);"OnLine"="[$($global:MiscStrings.'DomainNotFound')]"}
                }
                else
                {
                    $AllowedDomains += New-Object PSObject -Property @{"Success"=$false;"OnPrem"="[$($global:MiscStrings.'DomainNotFound')]";"OnLine"=$($domain.InputObject)}
                }
            }

            if ([string]::IsNullOrEmpty(($AllowedDomains | Where-Object {$_.Success})))
            {
                $domainNotFound         = @($AllowedDomains | Where-Object {-not $_.Success})
                $this.Insight.Detection = ($this.Insight.Detection -f $domainNotFound[0].OnPrem, $domainNotFound[0].OnLine)

                # Bug 30136: Blocked domains (on-line vs. on prem)
                $this.Success = $false
            }
        }
        catch
        {
            $this.Success = $false
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}