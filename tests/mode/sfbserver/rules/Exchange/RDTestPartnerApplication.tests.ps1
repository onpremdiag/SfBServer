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
# Filename: RDTestPartnerApplication.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/1/2020 3:04 PM
#
# Last Modified On: 10/1/2020 3:05 PM
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
	. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDPartnerApplicationDisabled.ps1)
	. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDNoPartnerApplication.ps1)
	. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDWrongPartnerApplication.ps1)
	. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

	. $sut
}

Describe -Tag 'SfBServer' "RDTestPartnerApplication" {
	Context "RDTestPartnerApplication" {
		BeforeAll {
			Mock Write-OPDEventLog {}
		}

		BeforeEach {
			Mock Get-CsPartnerApplication {
				@(
					@{
						Identity                             = "microsoft.exchange"
						Name                                 = "microsoft.exchange"
						ApplicationIdentifier                = "00000002-0000-0ff1-ce00-000000000000"
						Realm                                = [string]::Empty
						ApplicationTrustLevel                = "Full"
						AcceptSecurityIdentifierInformation  = $false
						Enabled                              = $true
					}
				)
			}

			$rule = [RDTestPartnerApplication]::new([IDNoPartnerApplication]::new())
		}

        It "No issues (Success)" {
            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDNoPartnerApplication'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

        It "Partner application is not enabled (IDPartnerApplicationDisabled)" {
			Mock Get-CsPartnerApplication {
				@(
					@{
						Identity                             = "microsoft.exchange"
						Name                                 = "microsoft.exchange"
						ApplicationIdentifier                = "00000002-0000-0ff1-ce00-000000000000"
						Realm                                = [string]::Empty
						ApplicationTrustLevel                = "Full"
						AcceptSecurityIdentifierInformation  = $false
						Enabled                              = $false
					}
				)
			}
            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDPartnerApplicationDisabled'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

        It "Partner application does not match service name (IDWrongPartnerApplication)" {
			Mock Get-CsPartnerApplication {
				@(
					@{
						Identity                             = "microsoft.exchange"
						Name                                 = "microsoft.exchange"
						ApplicationIdentifier                = "00000001-0000-0ff1-ce00-000000000000"
						Realm                                = [string]::Empty
						ApplicationTrustLevel                = "Full"
						AcceptSecurityIdentifierInformation  = $false
						Enabled                              = $true
					}
				)
			}
            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDWrongPartnerApplication'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

        It "No partner application found (IDNoPartnerApplication)" {
			Mock Get-CsPartnerApplication {}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDNoPartnerApplication'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

	}
}