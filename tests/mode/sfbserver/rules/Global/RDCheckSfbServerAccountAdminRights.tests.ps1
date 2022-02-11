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
# Filename: RDIsSfbServerFrontend.tests.ps1
# Description: Determine if current account has Skype for Business Server
# Frontend administrative privileges
# Owner: João Loureiro <joaol@microsoft.com>
# Created On: 10/31/2019 2:14 PM
#
# Last Modified On: 10/31/2019 2:14 PM
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
. "$srcRoot\mode\$mode\insights\global\IDAccountMissingSfbServerAdminRights.ps1"
. "$testRoot\mocks\SfbServerMock.ps1"

. $sut

Describe -Tag 'SfbServer' "RDCheckSfbServerAccountAdminRights" {
	Context "Verify if current account has Skype for Business Server administrative privileges" {

		BeforeEach {
			Mock Write-OPDEventLog {}
			$rd = [RDCheckSfbServerAccountAdminRights]::new([IDAccountMissingSfbServerAdminRights]::new())
		}

		It "Current account does not have Skype for Business administrative privileges" {
			Mock Test-IsADGroupMember { return $false }

			$rd.Execute($null)

			$rd.Success | Should -BeFalse
		}

		It "Current account has Skype for Business administrative privileges" {
				Mock Test-IsADGroupMember { return $true }

				$rd.Execute($null)

				$rd.Success | Should -BeTrue
		}
	}
}
