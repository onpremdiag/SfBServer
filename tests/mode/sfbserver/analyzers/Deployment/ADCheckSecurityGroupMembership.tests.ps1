﻿################################################################################
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
# Filename: ADCheckSecurityGroupMembership.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/15/2020 1:19 PM
#
# Last Modified On: 1/15/2020 1:20 PM
#################################################################################
Set-StrictMode -Version Latest
$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

$classes   = Get-ChildItem -Path "$srcRoot\classes"              -Recurse -Filter *.ps1
$rules     = Get-ChildItem -Path "$srcRoot\mode\$mode\rules"     -Recurse -Filter RD*.ps1 | Where-Object { $_.FullName -notlike "*\samples\*"}
$insights  = Get-ChildItem -Path "$srcRoot\mode\$mode\insights"  -Recurse -Filter ID*.ps1 | Where-Object { $_.FullName -notlike "*\samples\*"}
$analyzers = Get-ChildItem -Path "$srcRoot\mode\$mode\analyzers" -Recurse -Filter AD*.ps1 | Where-Object { $_.FullName -notlike "*\samples\*"}

foreach ($group in $classes, $insights, $rules, $analyzers)
{
    foreach ($file in $group)
    {
        . $file.FullName
    }
}

# Load resource files needed for tests
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. "$srcRoot\common\Globals.ps1"
. "$srcRoot\common\Utils.ps1"
. "$srcRoot\mode\$mode\common\Globals.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$testRoot\mocks\SfbServerMock.ps1"
. "$testRoot\mocks\ActiveDirectoryMocks.ps1"

. $sut

Describe -Tag 'SfbServer' "ADCheckSecurityGroupMembership" {
    BeforeAll {
        Mock Write-OPDEventLog {}
    }

    BeforeEach {
        Mock Initialize-Module { return $true }
        $ad = [ADCheckSecurityGroupMembership]::new()
    }

    Context "Current acount has Skype for Business Server administrative privileges" {
        It "User is a member of RTCUniversalServerAdmins security group" {
            Mock Test-IsADGroupMember { return $true }
            Mock Get-ADAccountAuthorizationGroup {
                @(
                    @{
                        distinguishedName = "CN=RTCUniversalServerAdmins,CN=Users,DC=ucstaff,DC=com"
                        GroupCategory     = "Security"
                        GroupScope        = "Universal"
                        name              = "RTCUniversalServerAdmins"
                        objectClass       = "group"
                        objectGUID        = [guid]::new('7dc32d02-6fba-4282-bd45-86e18417de8c')
                        SamAccountName    = "RTCUniversalServerAdmins"
                        SID               = "S-1-5-21-1472933442-3739916588-3898627659-1117"
                    }
                )
            }

            $ad.Execute($null)

            $ad.Success | Should -BeTrue
        }

        It "User is a member of CsServerAdministrator security group" {
            Mock Test-IsADGroupMember { return $true }
            Mock Get-ADAccountAuthorizationGroup {
                @(
                    @{
                        distinguishedName = "CN=CsServerAdministrator,CN=Users,DC=ucstaff,DC=com"
                        GroupCategory     = "Security"
                        GroupScope        = "Universal"
                        name              = "CsServerAdministrator"
                        objectClass       = "group"
                        objectGUID        = [guid]::new('7dc32d02-6fba-4282-bd45-86e18417de8c')
                        SamAccountName    = "CsServerAdministrator"
                        SID               = "S-1-5-21-1472933442-3739916588-3898627659-1117"
                    }
                )
            }

            $ad.Execute($null)

            $ad.Success | Should -BeTrue
        }

        It "User is a member of CsHelpdesk security group" {
            Mock Test-IsADGroupMember { return $true }
            Mock Get-ADAccountAuthorizationGroup {
                @(
                    @{
                        distinguishedName = "CN=CsHelpdesk,CN=Users,DC=ucstaff,DC=com"
                        GroupCategory     = "Security"
                        GroupScope        = "Universal"
                        name              = "CsHelpdesk"
                        objectClass       = "group"
                        objectGUID        = [guid]::new('7dc32d02-6fba-4282-bd45-86e18417de8c')
                        SamAccountName    = "CsHelpdesk"
                        SID               = "S-1-5-21-1472933442-3739916588-3898627659-1117"
                    }
                )
            }

            $ad.Execute($null)

            $ad.Success | Should -BeTrue
        }

        It "User is not a member of required security groups" {
            Mock Test-IsADGroupMember { return $false }
            Mock Get-ADAccountAuthorizationGroup {
                @(
                    @{
                        distinguishedName = "CN=Bozo,CN=Users,DC=ucstaff,DC=com"
                        GroupCategory     = "Security"
                        GroupScope        = "Universal"
                        name              = "Bozo"
                        objectClass       = "group"
                        objectGUID        = [guid]::new('7dc32d02-6fba-4282-bd45-86e18417de8c')
                        SamAccountName    = "Bozo"
                        SID               = "S-1-5-21-1472933442-3739916588-3898627659-1117"
                    }
                )
            }

            $ad.Execute($null)

            $ad.Success | Should -BeFalse
        }
    }
}