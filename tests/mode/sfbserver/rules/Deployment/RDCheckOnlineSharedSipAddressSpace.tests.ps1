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
# Filename: RDCheckOnlineSharedSipAddressSpace.tests.ps1
# Description: <TODO>
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 9/27/2021 2:25 PM
#
#################################################################################

Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\tests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

# Load resource files needed for tests
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. "$srcRoot\common\Globals.ps1"
. "$srcRoot\common\Utils.ps1"
. "$srcRoot\mode\$mode\common\Globals.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$srcRoot\classes\RuleDefinition.ps1"
. "$srcRoot\classes\InsightDefinition.ps1"
. "$srcRoot\mode\$mode\insights\Deployment\IDSIPHostingProviderSharedAddressSpaceEnabled.ps1"
. "$srcRoot\mode\$mode\insights\Deployment\IDSIPSharedAddressSpaceEnabled.ps1"
. "$testRoot\mocks\SfbServerMock.ps1"
. "$testRoot\mocks\LyncOnlineConnectorMocks.ps1"

. $sut

Describe -Tag 'SfBServer' "RDCheckOnlineSharedSipAddressSpace" {
	Context "Checks if the online settings for ShareSipAddressSpace are disabled" {
        BeforeEach {
            Mock Write-OPDEventLog
            $rule = [RDCheckOnlineSharedSipAddressSpace]::new([IDSIPHostingProviderSharedAddressSpaceEnabled]::new())
        }

		It "AllowSipAddressSpace is false (success)" {
            Mock Get-CsTenantFederationConfiguration {
                @(
                    @{
                        AllowedDomains         = "Microsoft.Rtc.Management.WritableConfig.Settings.Edge.AllowAllKnownDomains"
                        SharedSipAddressSpace  = $false
                    }
                )
            }

            $rule.Execute(@{Object=$null;Session="any value"})

            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
		}

		It "AllowSipAddressSpace is true (failure)" {
            Mock Get-CsTenantFederationConfiguration {
                @(
                    @{
                        AllowedDomains         = "Microsoft.Rtc.Management.WritableConfig.Settings.Edge.AllowAllKnownDomains"
                        SharedSipAddressSpace  = $true
                    }
                )
            }

            $rule.Execute(@{Object=$null;Session="any value"})

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDSIPHostingProviderSharedAddressSpaceEnabled'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDSIPSharedAddressSpaceEnabled'
		}

        It "AllowSipAddressSpace is missing" {
            Mock Get-CsTenantFederationConfiguration {
                @(
                    @{
                        AllowedDomains         = "Microsoft.Rtc.Management.WritableConfig.Settings.Edge.AllowAllKnownDomains"
                    }
                )
            }

            $rule.Execute(@{Object=$null;Session="any value"})

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDSIPHostingProviderSharedAddressSpaceEnabled'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDSIPSharedAddressSpaceEnabled'
        }
	}
}