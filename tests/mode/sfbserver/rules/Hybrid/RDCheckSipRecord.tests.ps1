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
# Filename: RDCheckSipRecord.tests.ps1
# Description: <TODO>
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 8/16/2021 12:55 PM
#
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
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
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDDNSARecord.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDDNSSRVRecord.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDDNSNameDoesNotExist.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDDNSTXTRecord.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDDNSTypeOther.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDGetCsOnlineSipDomainFails.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Hybrid\IDDNSOnPremises.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\MicrosoftTeamsMocks.ps1)

. $sut

Describe -Tag 'SfBserver' "RDCheckSipRecord" {
	Context "Checks if SIP records have correct DNS CNAME entries" {
		BeforeEach {
			Mock Write-OPDEventLog {}
			$rule = [RDCheckSipRecord]::new([IDDNSNameDoesNotExist]::new())

            Mock Get-CsOnlineSipDomain {
                @(
                    @{
                        Name   = 'lyncmx.mail.onmicrosoft.com'
                        Status = 'Enabled'
                    },
                    @{
                        Name   = 'lyncmx.onmicrosoft.com'
                        Status = 'Enabled'
                    },
                    @{
                        Name   = 'contoso.com'
                        Status = 'Enabled'
                    }
                )
            }

            Mock Resolve-DnsName {
                @(
                    @{
                        QueryType  = 'CNAME'
                        Type       = 'CNAME'
                        NameHost   = $global:SIPDir
                        Name       = "sip.contoso.com"
                        Section    = 'Answer'
                    }
                )
            }
		}

		It "1. Should pass - no errors" {
            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDDNSNameDoesNotExist'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDDNSNameDoesNotExist'
		}

        It "2. Should fail because we can't find any domains (IDGetCsOnlineSipDomainFails)" {
            Mock Get-CsOnlineSipDomain {}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDGetCsOnlineSipDomainFails'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDGetCsOnlineSipDomainFails'
        }

        It "3. DNS Name does not exist (IDDNSNameDoesNotExist)" {
            Mock Get-CsOnlineSipDomain {
                @(
                    @{
                        Name   = 'contoso.com'
                        Status = 'Enabled'
                    }
                )
            }

            Mock Resolve-DnsName { throw 'Resolve-DnsName : contoso.com : DNS name does not exist'}

            $domain = Get-CsOnlineSipDomain

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDDNSNameDoesNotExist' -f "sip.$($domain.Name)")
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDDNSNameDoesNotExist'-f "sip.$($domain.Name)")
        }

        It "4. DNS points to On Premise entry (IDDNSOnPremises)" {
            Mock Resolve-DnsName {
                @(
                    @{
                        QueryType  = 'CNAME'
                        Type       = 'CNAME'
                        NameHost   = 'contoso.com'
                        Name       = "sip.contoso.com"
                        Section    = 'Answer'
                    }
                )
            }

            $Domain = Resolve-DnsName -Name contoso.com

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDDNSOnPremises' -f $domain.Name, $global:SIPDir, $Domain.NameHost.ToString())
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDDNSOnPremises'
        }
	}
}
