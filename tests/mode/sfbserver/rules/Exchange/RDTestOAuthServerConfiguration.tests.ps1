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
# Filename: RDTestOAuthServerConfiguration.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/19/2020 10:46 AM
#
# Last Modified On: 10/19/2020 10:46 AM
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$myPath   = $PSCommandPath
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\tests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
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
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDWrongOnlineMetadataUrlConfiguration.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDNoTenantIDFound.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDNoOAuthServer.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

. $sut

Describe -Tag 'SfBServer' "RDTestOAuthServerConfiguration" {
	Context "RDTestOAuthServerConfiguration" {
		BeforeAll {
            Mock Write-OPDEventLog {}

			Mock Get-CsOAuthServer {
				@(
					@{
						Identity                            = "microsoft.sts"
						Name                                = "microsoft.sts"
						IssuerIdentifier                    = "00000001-0000-0000-c000-000000000000"
						Realm                               = "5588B4FD-F26D-475C-824F-9911277AB13E"
						MetadataUrl                         = "https://accounts.accesscontrol.windows.net/5588B4FD-F26D-475C-824F-9911277AB13E/metadata/json/1"
						AuthorizationUriOverride            = ([string]::Empty)
						Type                                = "Acs"
						AcceptSecurityIdentifierInformation = $false
					}
				)

			}
		}

		BeforeEach {
			$rule = [RDTestOAuthServerConfiguration]::new([IDWrongOnlineMetadataUrlConfiguration]::new())
		}

		It "No issuess (Success)" {
            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDWrongOnlineMetadataUrlConfiguration'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Get-CsOAuthServer returns no/missing value (IDNoOAuthServer)" {
			Mock Get-CsOauthServer {}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoOAuthServer'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Unable to find value for Tenant/Realm (IDNoOAuthServer)" {
			Mock Get-CsOAuthServer {
				@(
					@{
						Identity                            = "microsoft.sts"
						Name                                = "microsoft.sts"
						IssuerIdentifier                    = "00000001-0000-0000-c000-000000000000"
						Realm                               = [string]::Empty
						MetadataUrl                         = "https://accounts.accesscontrol.windows.net/5588B4FD-F26D-475C-824F-9911277AB13E/metadata/json/1"
						AuthorizationUriOverride            = ([string]::Empty)
						Type                                = "Acs"
						AcceptSecurityIdentifierInformation = $false
					}
				)
			}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoTenantIDFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}

		It "Wrong value for Metadata URL (IDWrongOnlineMetadataUrlConfiguration)" {
			Mock Get-CsOAuthServer {
				@(
					@{
						Identity                            = "microsoft.sts"
						Name                                = "microsoft.sts"
						IssuerIdentifier                    = "00000001-0000-0000-c000-000000000000"
						Realm                               = "5DECB8B8-EEA0-43EF-9DC2-718CF7163FFD"
						MetadataUrl                         = "https://accounts.accesscontrol.windows.net/5588B4FD-F26D-475C-824F-9911277AB13E/metadata/json/1"
						AuthorizationUriOverride            = ([string]::Empty)
						Type                                = "Acs"
						AcceptSecurityIdentifierInformation = $false
					}
				)
			}

			$expectedValue = "https://accounts.accesscontrol.windows.net/5DECB8B8-EEA0-43EF-9DC2-718CF7163FFD/metadata/json/1"
			$actualValue = (Get-CsOAuthServer).MetadataUrl

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDWrongOnlineMetadataUrlConfiguration'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $expectedValue, $actualValue)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
		}
	}
}