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
# Filename: RDCheckProxyConfiguration.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/20/2021 11:17 AM
#
# Last Modified On: 4/21/2021 1:28 PM
#################################################################################
Set-StrictMode -Version Latest

$sut                   = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root                  = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$srcRoot               = "$root\src"
$testRoot              = "$root\tests"
$testMode              = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode                  = $Matches.Mode
$webConfigWithProxy    = Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'WithProxy.web.config'
$webConfigWithoutProxy = Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'WithoutProxy.web.config'

Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

# Load resource files needed for tests
. (Join-Path $testRoot -ChildPath "testhelpers\LoadResourceFiles.ps1")

Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path $srcRoot  -ChildPath "common\Globals.ps1")
. (Join-Path $srcRoot  -ChildPath "common\Utils.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\Globals.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\$mode.ps1")
. (Join-Path $srcRoot  -ChildPath "classes\RuleDefinition.ps1")
. (Join-Path $srcRoot  -ChildPath "classes\InsightDefinition.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDProxyMismatch.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDGetCsServerVersionFailed.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDUnableToGetVersion.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDFileDoesNotExist.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDFileIsEmpty.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDRegistryKeyNotFound.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Global\IDPropertyNotFoundException.ps1")
. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

. $sut

Describe "RDCheckProxyConfiguration" {
	Context "RDCheckProxyConfiguration" {
		BeforeAll {
			Mock Write-OPDEventLog {}

            Copy-Item -Path $webConfigWithProxy -Destination (Join-Path -Path 'TestDrive:' -ChildPath (Split-Path -Path $webConfigWithProxy -Leaf)) -Force
			Copy-Item -Path $webConfigWithOutProxy -Destination (Join-Path -Path 'TestDrive:' -ChildPath (Split-Path -Path $webConfigWithOutProxy -Leaf)) -Force
		}

		BeforeEach {
			$rule = [RDCheckProxyConfiguration]::new([IDRegistryKeyNotFound]::new())
            $global:WebConfigInternal = $global:WebConfigExternal = 'TestDrive:\WithProxy.web.config'

			Mock Get-CsServerVersion { "Skype for Business Server 2019 (7.0.2046.0): Volume license key installed." }
			Mock Test-Path { $true }
			Mock Get-ItemProperty {
				@(
					@{
						EnableNegotiate    = 1
						MigrateProxy       = 1
						ProxyEnable        = 1
						WarnonZoneCrossing = 0
					}
				)
			}
		}

		It "Proxy setting matches web.config files (SUCCESS)" {

			$rule.Execute($null)

			$rule.Success           | Should -BeTrue
			$rule.EventId           | Should -Be $global:EventIds.($rule.Name)
			$rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
			$rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Unable to find registry key (IDRegistryKeyNotFound)" {
			Mock Test-Path { $false }

			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
			$rule.EventId           | Should -Be $global:EventIds.($rule.Name)
			$rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDRegistryKeyNotFound' -f $global:ProxyEnabled)
			$rule.Insight.Action    | Should -Be $global:InsightActions.'IDRegistryKeyNotFound'
		}

		It "Unable to get current product information (IDGetCsServerVersionFailed)" {
			Mock Get-CsServerVersion { $null }

			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
			$rule.EventId           | Should -Be $global:EventIds.($rule.Name)
			$rule.Insight.Detection | Should -Be $global:InsightDetections.'IDGetCsServerVersionFailed'
			$rule.Insight.Action    | Should -Be $global:InsightActions.'IDGetCsServerVersionFailed'
		}

		It "Product version is not valid for Skype for Business (IDUnableToGetVersion)" {
			Mock Get-CsServerVersion { "this is a test string" }

			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
			$rule.EventId           | Should -Be $global:EventIds.($rule.Name)
			$rule.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToGetVersion'
			$rule.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToGetVersion'
		}

		It "Proxy mismatch - no proxy in web.config file (IDPropertyNotFoundException)" {
            $global:WebConfigInternal = (Join-Path -Path 'TestDrive:' -ChildPath (Split-Path -Path $webConfigWithOutProxy -Leaf))

			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
			$rule.EventId           | Should -Be $global:EventIds.($rule.Name)
			$rule.Insight.Action    | Should -Be $global:InsightActions.'IDPropertyNotFoundException'
		}

		It "Proxy mismatch - no proxy in registry  (IDProxyMismatch)" {
			$global:WebConfigInternal = (Join-Path -Path 'TestDrive:' -ChildPath (Split-Path -Path $webConfigWithProxy -Leaf))

			Mock Get-ItemProperty {
				@(
					@{
						EnableNegotiate    = 1
						MigrateProxy       = 1
						ProxyEnable        = 0
						WarnonZoneCrossing = 0
					}
				)
			}

			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
			$rule.EventId           | Should -Be $global:EventIds.($rule.Name)
			$rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDProxyMismatch' -f $global:WebConfigInternal)
			$rule.Insight.Action    | Should -Be $global:InsightActions.'IDProxyMismatch'
		}
	}

	Context "Empty files" {
		BeforeAll {
			Mock Write-OPDEventLog {}

            Copy-Item -Path $webConfigWithProxy -Destination (Join-Path -Path 'TestDrive:' -ChildPath (Split-Path -Path $webConfigWithProxy -Leaf)) -Force
			Copy-Item -Path $webConfigWithOutProxy -Destination (Join-Path -Path 'TestDrive:' -ChildPath (Split-Path -Path $webConfigWithOutProxy -Leaf)) -Force
		}

		BeforeEach {
			$rule = [RDCheckProxyConfiguration]::new([IDRegistryKeyNotFound]::new())
            $global:WebConfigInternal = $global:WebConfigExternal = 'TestDrive:\WithProxy.web.config'

			Mock Get-CsServerVersion { "Skype for Business Server 2019 (7.0.2046.0): Volume license key installed." }
			Mock Test-Path { $true }
			Mock Get-ItemProperty {
				@(
					@{
						EnableNegotiate    = 1
						MigrateProxy       = 1
						ProxyEnable        = 1
						WarnonZoneCrossing = 0
					}
				)
			}
		}

		It "Web.config file is empty (IDFileIsEmpty)" {
            Mock Get-Content { [string]::Empty }

			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
			$rule.EventId           | Should -Be $global:EventIds.($rule.Name)
			$rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDFileIsEmpty' -f $global:WebConfigInternal)
			$rule.Insight.Action    | Should -Be $global:InsightActions.'IDFileIsEmpty'
		}
	}
}