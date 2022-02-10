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
# Filename: RDCheckDomainApprovedForFederation.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/7/2020 10:31 AM
#
# Last Modified On: 4/21/2020 3:10 PM
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$myPath   = $PSCommandPath
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

# Load resource files needed for tests
. (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)

Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
. (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)
. (Join-Path -Path $srcRoot -ChildPath classes\RuleDefinition.ps1)
. (Join-Path -Path $srcRoot -ChildPath classes\InsightDefinition.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDDomainNotApprovedForFederation.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

. $sut

Describe -Tag 'SfBServer','Rule' "RDCheckDomainApprovedForFederation" {
    Context "RDCheckDomainApprovedForFederation" {
        BeforeAll {
            Mock Get-ParameterDefinition {return "fabrikam.com"} -ParameterFilter {$ParameterName -eq "PDRemoteFqdnDomain"}

            Mock Get-CsAllowedDomain {
                @(
                    @{
                        Domain = "fabrikam.com"
                    }
                )
            }
        }

        BeforeEach {
            Mock Get-CsAccessEdgeConfiguration {
                @(
                    @{
                        AllowAnonymousUsers                    = $true
                        AllowFederatedUsers                    = $true
                        AllowOutsideUsers                      = $true
                        BeClearingHouse                        = $false
                        EnablePartnerDiscovery                 = $true
                        DiscoveredPartnerVerificationLevel     = "UseSourceVerification"
                        EnableArchivingDisclaimer              = $false
                        EnableUserReplicator                   = $false
                        KeepCrlsUpToDateForPeers               = $true
                        MarkSourceVerifiableOnOutgoingMessages = $true
                        OutgoingTlsCountForFederatedPartners   = 4
                        DnsSrvCacheRecordCount                 = 131072
                        DiscoveredPartnerStandardRate          = 20
                        EnableDiscoveredPartnerContactsLimit   = $true
                        MaxContactsPerDiscoveredPartner        = 1000
                        DiscoveredPartnerReportPeriodMinutes   = 60
                        EnablePartnerMonitoringCosmosOutput    = $false
                        EnablePartnerMonitoringIfxLog          = $false
                        MaxAcceptedCertificatesStored          = 1000
                        MaxRejectedCertificatesStored          = 500
                        CertificatesDeletedPercentage          = 20
                        SkypeSearchUrl                         = "https://skypegraph.skype.com/search/v1.0"
                        RoutingMethod                          = "UseDnsSrvRouting"
                    }
                )
            }

            Mock Get-CsBlockedDomain {
                @(
                    @{
                        Identity = [string]::Empty
                        Domain   = [string]::Empty
                        Comment  = [string]::Empty
                    }
                )
            }

            Mock Write-OPDEventLog {}

            $rule = [RDCheckDomainApprovedForFederation]::new([IDDomainNotApprovedForFederation]::new())
        }

        It "No issues found" {
            $rule.Execute($null)

            $rule.Success | Should -BeTrue
        }

        It "Get-CsAllowedDomain returns null or empty (IDDomainNotApprovedForFederation)" {
            Mock Get-CsAllowedDomain {}

            Mock Get-CsBlockedDomain {
                @(
                    @{
                        Identity = "fabrikam.com"
                        Domain   = "fabrikam.com"
                        Comment  = [string]::Empty
                    }
                )
            }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Detection | Should -Be (($global:InsightDetections.($rule.Insight.Name) -f 'fabrikam.com'))
            $rule.Insight.Action    | Should -Be (($global:InsightActions.($rule.Insight.Name) -f 'fabrikam.com'))
        }
    }
}