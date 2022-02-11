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
# Filename: RDOAuthCertificateValid.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/15/2020 4:20 PM
#
# Last Modified On: 10/15/2020 4:20 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
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
	. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDOAuthCertficateNoThumbprint.ps1)
	. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDOAuthCertficateExpired.ps1)
	. (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Exchange\IDMissingOAuthCertificate.ps1)
	. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

	. $sut
}

Describe -Tag 'SfBServer' "RDOAuthCertificateValid" {
	Context "RDOAuthCertificateValid" {
		BeforeAll {
			Mock Write-OPDEventLog {}
		}

		BeforeEach {
			Mock Get-CsCertificate {
				@(
					@{
						Issuer             = "CN=ucstaff-DC-CA, DC=ucstaff, DC=com"
						NotAfter           = (Get-Date).AddYears(1)
						NotBefore          = (Get-Date).AddYears(-1)
						SerialNumber       = "2300000005C96B5B0E58E81568000000000005"
						Subject            = "CN=ucstaff.com"
						AlternativeNames   = {}
						Thumbprint         = "4AA3C098CC06277EB2B4A51EE6B955FEA6FD9A71"
						EffectiveDate      = (Get-date).AddYears(-1).AddMinutes(10)
						PreviousThumbprint = [string]::Empty
						UpdateTime         = [string]::Empty
						Use                = "OAuthTokenIssuer"
						SourceScope        = "Global"
					}
				)
			}

			$rule = [RDOAuthCertificateValid]::new([IDMissingOAuthCertificate]::new())
		}

		It "Runs with no issues (Success)" {
			$rule.Execute($null)

            $rule.Success           | Should -BeTrue
			$rule.Insight.Name      | Should -Be 'IDMissingOAuthCertificate'
			$rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
			$rule.Insight.Action    | Should -Be $global:InsightActions.( $rule.Insight.Name)
		}

		It "Unable to locate OAuthCertificate (IDMissingOAuthCertificate)" {
			Mock Get-CsCertificate { $null }

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
			$rule.Insight.Name      | Should -Be 'IDMissingOAuthCertificate'
			$rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
			$rule.Insight.Action    | Should -Be $global:InsightActions.( $rule.Insight.Name)
		}

		It "OAuthCertificate has expired (IDOAuthCertficateExpired)" {
			Mock Get-CsCertificate {
				@(
					@{
						Issuer             = "CN=ucstaff-DC-CA, DC=ucstaff, DC=com"
						NotAfter           = (Get-Date).AddMinutes(-30)
						NotBefore          = (Get-Date).AddYears(-1)
						SerialNumber       = "2300000005C96B5B0E58E81568000000000005"
						Subject            = "CN=ucstaff.com"
						AlternativeNames   = {}
						Thumbprint         = "4AA3C098CC06277EB2B4A51EE6B955FEA6FD9A71"
						EffectiveDate      = (Get-date).AddYears(-1).AddMinutes(10)
						PreviousThumbprint = [string]::Empty
						UpdateTime         = [string]::Empty
						Use                = "OAuthTokenIssuer"
						SourceScope        = "Global"
					}
				)
			}

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
			$rule.Insight.Name      | Should -Be 'IDOAuthCertficateExpired'
			$rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
			$rule.Insight.Action    | Should -Be $global:InsightActions.( $rule.Insight.Name)
		}

		It "OAuthCertificate has no thumbprint (IDOAuthCertficateNoThumbprint)" {
			Mock Get-CsCertificate {
				@(
					@{
						Issuer             = "CN=ucstaff-DC-CA, DC=ucstaff, DC=com"
						NotAfter           = (Get-Date).AddYears(1)
						NotBefore          = (Get-Date).AddYears(-1)
						SerialNumber       = "2300000005C96B5B0E58E81568000000000005"
						Subject            = "CN=ucstaff.com"
						AlternativeNames   = {}
						Thumbprint         = [string]::Empty
						EffectiveDate      = (Get-date).AddYears(-1).AddMinutes(10)
						PreviousThumbprint = [string]::Empty
						UpdateTime         = [string]::Empty
						Use                = "OAuthTokenIssuer"
						SourceScope        = "Global"
					}
				)
			}

			$rule.Execute($null)

            $rule.Success           | Should -BeFalse
			$rule.Insight.Name      | Should -Be 'IDOAuthCertficateNoThumbprint'
			$rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
			$rule.Insight.Action    | Should -Be $global:InsightActions.( $rule.Insight.Name)
		}
	}
}