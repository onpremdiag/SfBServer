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
# Filename: SharePoint.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/5/2018 5:41 PM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\OnPremDiagTests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

. "$srcRoot\common\Globals.ps1"
. "$srcRoot\common\Utils.ps1"
. "$srcRoot\mode\$mode\common\Globals.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$testRoot\mocks\SharePointMocks.ps1"

Describe -Tag 'SharePoint' "SharePoint" {
    Context "Test-SharePointSnapinsAreLoaded" {
        It "SharePoint Snapin is loaded" {
            Mock Get-PSSnapin { return @{Name="Microsoft.SharePoint.PowerShell"}}
            $global:SharePointSnappinLoaded = $true

            Test-SharePointSnapinsAreLoaded | Should -BeTrue
        }

        It "SharePoint Snapin is not loaded" {
            Mock Get-PSSnapin { return @{Name="Somethingelse.Powershell"}}
            $global:SharePointSnappinLoaded = $false

            Test-SharePointSnapinsAreLoaded | Should -BeTrue
        }
    }
}

# Test Get-SharePointVersion function
# Owner: Stefan Goßner <stefang@microsoft.com>
# Created On: 9/06/2018 12:19 PM (UTC+2)

Describe -Tag 'SharePoint' "Test Get-SharePointVersion function" {

    Context "Test all SharePoint Versions" {

        It "No SharePoint installed" {
            Mock Get-RegistryKeyValue { return $null }
            Get-SharePointVersion | should be $null
        }

        It "SharePoint 2013 installed" {
            Mock Get-RegistryKeyValue { return "15.0.1234.1000" } -ParameterFilter { $Path -eq $OfficeServerHive15 }
            Mock Get-RegistryKeyValue { return $null } -ParameterFilter { $Path -eq $OfficeServerHive16 }

            Get-SharePointVersion | should be $SharePoint2013
        }

        It "SharePoint 2016 installed" {
            Mock Get-RegistryKeyValue { return $null } -ParameterFilter { $Path -eq $OfficeServerHive15 }
            Mock Get-RegistryKeyValue { return "16.0.1234.1000" } -ParameterFilter { $Path -eq $OfficeServerHive16 }

            Get-SharePointVersion | should be $SharePoint2016
        }

        It "SharePoint 2019 installed" {
            Mock Get-RegistryKeyValue { return $null } -ParameterFilter { $Path -eq $OfficeServerHive15 }
            Mock Get-RegistryKeyValue { return "16.0.12345.10000" } -ParameterFilter { $Path -eq $OfficeServerHive16 }

            Get-SharePointVersion | should be $SharePoint2019
        }

    }

}

# Test Get-SharePointVersion function
# Owner: Stefan Goßner <stefang@microsoft.com>
# Created On: 9/06/2018 12:19 PM (UTC+2)

Describe -Tag 'SharePoint' "Get-ListOfServersInTheFarmWithSharePointInstalled" {
    Context "Get-ListOfServersInTheFarmWithSharePointInstalled" {

        Function Get-SPProduct {}

        BeforeEach {
            Mock Confirm-SharePointSnapinsAreLoaded { return $true }
        }

        It "Single Server Farm" {
            Mock Get-SPProduct {
                return @{
                    Servers = @(
                        @{ ServerName = "WFE" ; InstallStatus = "NoActionRequired"; RequiredButMissingPatches = $null }
                    )
                }
            }

            Get-ListOfServersInTheFarmWithSharePointInstalled | Should -Be @( 'WFE' )
        }

        It "Farm with 2 servers" {
            Mock Get-SPProduct {
                return @{
                    Servers = @(
                        @{ ServerName = "WFE" ; InstallStatus = "NoActionRequired"; RequiredButMissingPatches = $null };
                        @{ ServerName = "APP"; InstallStatus = "InstallRequired"; RequiredButMissingPatches = $null }
                    )
                }
            }

            Get-ListOfServersInTheFarmWithSharePointInstalled | Should -Be @( 'WFE' ; 'APP')
        }

    }
}

# Test Get-SharePointVersion function
# Owner: Stefan Goßner <stefang@microsoft.com>
# Created On: 9/06/2018 12:19 PM (UTC+2)

Describe -Tag 'SharePoint' "FarmAdministrator and FarmAccount" {
    Context "Test-IsFarmAdministrator" {

        BeforeEach {
            Mock Confirm-SharePointSnapinsAreLoaded { return $true }

            Mock Get-SPWebApplication {
                return @( @{
                    IsAdministrationWebApplication = $true
                    Url = "http://centraladmin"
                } )
            }

            Mock Get-SPWeb {
                return @{
                    AssociatedOwnerGroup = @{
                        users = @{ Name = "mydomain\farmadmin" }
                    }
                }
            }
        }

        It "Is Farm Admin" {
            Mock Get-CurrentUserName { return "mydomain\farmadmin"}

            Test-IsFarmAdministrator | Should -BeTrue
        }

        It "Is not Farm Admin" {
            Mock Get-CurrentUserName { return "mydomain\anotheruser"}

            Test-IsFarmAdministrator | Should -BeTrue
        }

    }

    Context "Get-SharePointFarmAccount" {

        BeforeEach {
            Mock Confirm-SharePointSnapinsAreLoaded { return $true }
        }

        It "retrieve Farm account" {
            Mock Get-SPFarm {
                return @{
                    DefaultServiceAccount = @{
                        Name = "mydomain\farmaccount"
                    }
                }
            }

            Get-SharePointFarmAccount | Should -Be "mydomain\farmaccount"
        }

    }
}
