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
# Filename: RDIsUniversalServerAdmin.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/10/2020 12:45 PM
#
# Last Modified On: 1/10/2020 12:45 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
	$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
	$root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
	$srcRoot  = "$root\src"
	$testRoot = "$root\OnPremDiagTests"
	$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
	$mode     = $Matches.Mode

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
	. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\global\IDNotAMemberOfSecurityGroup.ps1")
	. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

	. $sut
}

Describe -Tag 'SfbServer', 'Rule' "RDIsUniversalServerAdmin" {
	Context "Determine if the current user has access to the required cmdlets" {
		BeforeAll {
			Mock Write-OPDEventLog {}

			Mock Test-IsUSAMember { $true } -ParameterFilter {$SAMAccountName -eq 'RTCUniversalServerAdmins'}

			Mock Test-IsUSAMember { $true } -ParameterFilter {$SAMAccountName -eq 'CsServerAdministrator'}

			Mock Test-IsUSAMember { $true } -ParameterFilter {$SAMAccountName -eq 'CsHelpdesk'}

			Mock Initialize-Module { $true }
		}

		BeforeEach {
			$rule = [RDIsUniversalServerAdmin]::new([IDNotAMemberOfSecurityGroup]::new())
		}

		It "User belongs to at least one of the required groups" {
			$rule.Execute($null)

			$rule.Success | Should -BeTrue
		}

		It "User does not belong to any of the required groups" {
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'RTCUniversalServerAdmins'}
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'CsServerAdministrator'}
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'CsHelpdesk'}

			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
			$rule.Insight.Name      | Should -Be 'IDNotAMemberOfSecurityGroup'
			$rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDNotAMemberOfSecurityGroup' -f ("{0}@{1}" -f $env:USERNAME, $env:USERDOMAIN))
			$rule.Insight.Action    | Should -Be $global:InsightActions.'IDNotAMemberOfSecurityGroup'
		}

		It "User belongs to RTCUniversalServerAdmins group" {
			Mock Test-IsUSAMember { $true } -ParameterFilter {$SAMAccountName -eq 'RTCUniversalServerAdmins'}
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'CsServerAdministrator'}
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'CsHelpdesk'}

			$rule.Success | Should -BeTrue
		}

		It "User belongs to CsServerAdministrator group" {
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'RTCUniversalServerAdmins'}
			Mock Test-IsUSAMember { $true } -ParameterFilter {$SAMAccountName -eq 'CsServerAdministrator'}
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'CsHelpdesk'}

			$rule.Success | Should -BeTrue
		}

		It "User belongs to CsHelpdesk group" {
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'RTCUniversalServerAdmins'}
			Mock Test-IsUSAMember { $false } -ParameterFilter {$SAMAccountName -eq 'CsServerAdministrator'}
			Mock Test-IsUSAMember { $true } -ParameterFilter {$SAMAccountName -eq 'CsHelpdesk'}

			$rule.Success | Should -BeTrue
		}
	}
}