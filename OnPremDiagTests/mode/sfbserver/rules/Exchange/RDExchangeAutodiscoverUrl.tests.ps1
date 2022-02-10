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
# Filename: RDExchangeAutodiscoverUrl.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/24/2020 4:02 PM
#
# Last Modified On: 9/24/2020 4:03 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
    $myPath   = $PSCommandPath
    $srcRoot  = "$root\src"
    $testRoot = "$root\OnPremDiagTests"
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDExchangeAutodiscoverUrlNotConfigured.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDNoOauthConfigurationFound.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

    . $sut
}

Describe -Tag 'SfBServer' "RDExchangeAutodiscoverUrl" {
    Context "RDExchangeAutodiscoverUrl" {
        BeforeAll {
            Mock Write-OPDEventLog {}
            $expectedAutoDiscoverName = "autodiscover.CONTOSO.COM"
        }

        BeforeEach {
            $rule = [RDExchangeAutodiscoverUrl]::new([IDNoOauthConfigurationFound]::new())
        }

        It "Runs with no issues (Success)" {
            Mock Get-CsOAuthConfiguration {
                @(
                    @{
                        Identity                                    = "Global"
                        PartnerApplications                         = @(
                            @{
                                AuthToken                           = "Microsoft.Rtc.Management.WritableConfig.Settings.SSAuth.UseOAuthServer"
                                Name                                = "microsoft.exchange"
                                ApplicationIdentifier               = "00000002-0000-0ff1-ce00-000000000000"
                                Realm                               = [string]::Empty
                                ApplicationTrustLevel               = "Full"
                                AcceptSecurityIdentifierInformation = $false
                                Enabled                             = $true
                            },
                            @{
                                AuthToken                           = "https://autodiscover.ucstaff.com/autodiscover/metadata/json/1"
                                Name                                = "Exchange"
                                ApplicationIdentifier               = "00000002-0000-0ff1-ce00-000000000000"
                                Realm                               = [string]::Empty
                                ApplicationTrustLevel               = "Full"
                                AcceptSecurityIdentifierInformation = $false
                                Enabled                             = $true
                            },
                            @{
                                AuthToken                           = "Microsoft.Rtc.Management.WritableConfig.Settings.SSAuth.UseOAuthServer"
                                Name                                = "ole"
                                ApplicationIdentifier               = "11000002-0000-0ff1-ce00-000000000000"
                                Realm                               = [string]::Empty
                                ApplicationTrustLevel               = "Full"
                                AcceptSecurityIdentifierInformation = $false
                                Enabled                             = $true
                            }
                        )
                        ServiceName                                 = "00000004-0000-0ff1-ce00-000000000000"
                        ExchangeAutodiscoverUrl                     = "https://exchange.contoso.com/Autodiscover/Autodiscover.svc"
                    }
                )
            }

            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDNoOauthConfigurationFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.( $rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.( $rule.Insight.Name)
        }

        It "Not well configured for exchange on-premises (IDExchangeAutodiscoverUrlNotConfigured)" {
            Mock Get-CsOAuthConfiguration {
                @(
                    @{
                        Identity                                    = "Global"
                        PartnerApplications                         = @(
                            @{
                                AuthToken                           = "Microsoft.Rtc.Management.WritableConfig.Settings.SSAuth.UseOAuthServer"
                                Name                                = "microsoft.exchange"
                                ApplicationIdentifier               = "00000002-0000-0ff1-ce00-000000000000"
                                Realm                               = [string]::Empty
                                ApplicationTrustLevel               = "Full"
                                AcceptSecurityIdentifierInformation = $false
                                Enabled                             = $true
                            },
                            @{
                                AuthToken                           = "https://autodiscover.ucstaff.com/autodiscover/metadata/json/1"
                                Name                                = "Exchange"
                                ApplicationIdentifier               = "00000002-0000-0ff1-ce00-000000000000"
                                Realm                               = [string]::Empty
                                ApplicationTrustLevel               = "Full"
                                AcceptSecurityIdentifierInformation = $false
                                Enabled                             = $true
                            },
                            @{
                                AuthToken                           = "Microsoft.Rtc.Management.WritableConfig.Settings.SSAuth.UseOAuthServer"
                                Name                                = "ole"
                                ApplicationIdentifier               = "11000002-0000-0ff1-ce00-000000000000"
                                Realm                               = [string]::Empty
                                ApplicationTrustLevel               = "Full"
                                AcceptSecurityIdentifierInformation = $false
                                Enabled                             = $true
                            }
                        )
                        ServiceName                                 = "00000004-0000-0ff1-ce00-000000000000"
                        ExchangeAutodiscoverUrl                     = "https://exchange.contoso.com/Autodiscover/Autodiscover1.svc"
                    }
                )
            }

            $expectedValue = "*/autodiscover/autodiscover.svc*"
            $actualValue = (Get-CsOAuthConfiguration).ExchangeAutodiscoverUrl

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDExchangeAutodiscoverUrlNotConfigured'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $expectedValue, $actualValue)
            $rule.Insight.Action    | Should -Be $global:InsightActions.( $rule.Insight.Name)
        }

        It "No oAuth configuration information returned (IDNoOauthConfigurationFound)" {
            Mock Get-CsOAuthConfiguration { }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoOauthConfigurationFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.( $rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.( $rule.Insight.Name)        }

    }
}