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
# Filename: RDNoOnlineUsers.tests.ps1
# Description: <TODO>
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 7/14/2021 3:32 PM
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
. (Join-Path $testRoot -ChildPath "testhelpers\LoadResourceFiles.ps1")

Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path $srcRoot  -ChildPath "common\Globals.ps1")
. (Join-Path $srcRoot  -ChildPath "common\Utils.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\Globals.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\common\$mode.ps1")
. (Join-Path $srcRoot  -ChildPath "classes\RuleDefinition.ps1")
. (Join-Path $srcRoot  -ChildPath "classes\InsightDefinition.ps1")
. (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDOnPremiseUsersFound.ps1")
. (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")
. (Join-Path $testRoot -ChildPath "mocks\MicrosoftTeamsMocks.ps1")
. $sut

Describe -Tag 'SfbServer','Rules' "RDNoOnPremiseUsers" {
	Context "Testing for Online Users" {
		BeforeAll {
			Mock Write-OPDEventLog {}
		}

		BeforeEach {
			$rule = [RDNoOnPremiseUsers]::new([IDOnPremiseUsersFound]::new())
		}

		It "Should not have any online users" {
			Mock Get-CsOnlineUser {}

            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.Insight.Name      | Should -Be 'IDOnPremiseUsersFound'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDOnPremiseUsersFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDOnPremiseUsersFound'

		}

		It "Found on premise users - Failure (IDOnPremiseUsersFound)" {
			Mock Get-CsOnlineUser {
				$users = @()

				$user = New-Object PSObject
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'SipAddress' -Value 'sip:userd@contoso.com'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'InterpretedUserType' -Value 'HybridOnpremSfBUserWithTeamsLicense'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'OnPremHostingProvider' -Value $null
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'MCOValidationError' -Value {}
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'ProvisioningStamp' -Value [string]::Empty
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'SubProvisioningStamp' -Value [string]::Empty
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'Enabled' -Value $true

				$users += $user

				$user = New-Object PSObject
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'SipAddress' -Value 'sip:usera@contoso.com'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'InterpretedUserType' -Value 'HybridOnpremSfBUserWithTeamsLicense'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'OnPremHostingProvider' -Value 'SRV:'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'MCOValidationError' -Value {}
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'ProvisioningStamp' -Value [string]::Empty
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'SubProvisioningStamp' -Value [string]::Empty
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'Enabled' -Value $true

				$users += $user

				return $users
			}


			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDOnPremiseUsersFound'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDOnPremiseUsersFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDOnPremiseUsersFound'
		}

		It "Found on premise users - Failure (IDUsersValidationErrorFound)" {
			Mock Get-CsOnlineUser {
				$users = @()

				$user = New-Object PSObject
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'SipAddress' -Value 'sip:userd@contoso.com'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'InterpretedUserType' -Value 'HybridOnpremSfBUserWithTeamsLicense'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'OnPremHostingProvider' -Value $null
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'MCOValidationError' -Value 'HybridOnlineSfBUser: A user created on-premises and migrated to SfBO'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'ProvisioningStamp' -Value ([string]::Empty)
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'SubProvisioningStamp' -Value ([string]::Empty)
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'Enabled' -Value $true

				$users += $user

				$user = New-Object PSObject
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'SipAddress' -Value 'sip:usera@contoso.com'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'InterpretedUserType' -Value 'HybridOnpremSfBUserWithTeamsLicense'
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'OnPremHostingProvider' -Value $null
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'MCOValidationError' -Value {}
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'ProvisioningStamp' -Value ([string]::Empty)
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'SubProvisioningStamp' -Value ([string]::Empty)
				Add-Member -InputObject $user -MemberType NoteProperty -Name 'Enabled' -Value $true

				$users += $user

				return $users
			}

			$rule.Execute($null)

			$rule.Success           | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDUsersValidationErrorFound'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDUsersValidationErrorFound'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDUsersValidationErrorFound'
		}
	}
}