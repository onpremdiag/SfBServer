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
# Filename: SfBServer.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/5/2018 5:41 PM
#
# Last Modified On: 6/13/2019 1:59 PM
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

    . (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfBServerMock.ps1)
}

Describe -Tag 'SfBServer' "Test-SfbServerPSModuleIsLoaded" {
    Context "SfBServer PowerShell Modules" {
        BeforeEach {
            $global:SfbServerPowerShellModuleLoaded = $false
        }

        AfterEach {
            $global:SfbServerPowerShellModuleLoaded = $false
        }

        It "SfBServer PowerShell Module is loaded" {
            Mock Get-Module { return @{Name = $global:SfBServerModule} }

            Test-SfbServerPSModuleIsLoaded | Should -BeTrue
        }

        It "SfBServer PowerShell Module is NOT loaded" {
            Mock Get-Module { return @{Name = [string]::Empty} }

            Test-SfbServerPSModuleIsLoaded | Should -BeFalse
        }

        It "SfBServer PowerShell Module is already loaded (global)" {
            $global:SfbServerPowerShellModuleLoaded = $true

            Test-SfbServerPSModuleIsLoaded | Should -BeTrue
        }
    }
}

Describe -Tag 'SfBServer' "Test-IsSkypeForBusinessFrontend" {
    It "Server is a SfBServer Front End Server" {
        Mock Invoke-RegistryGetValue { return $true }

        Test-IsSkypeForBusinessFrontend | Should -BeTrue
    }

    It "Server is NOT a SfBServer Front End Server" {
        Mock Invoke-RegistryGetValue { return $false }

        Test-IsSkypeForBusinessFrontend | Should -BeFalse
    }
}

Describe -Tag 'SfBServer' "Test-IsSkypeForBusinessServerAdminAccount" {
    It "Current account has Skype for Business Administrative privileges" {
        Mock Test-IsADGroupMember { return $true }

        Test-IsSkypeForBusinessServerAdminAccount | Should -BeTrue
    }

    It "Current account does NOT have Skype for Business Administrative privileges" {
        Mock Test-IsADGroupMember { return $false}

        Test-IsSkypeForBusinessServerAdminAccount | Should -BeFalse
    }
}

Describe -Tag 'SfBServer' "Test-IsEnableSessionTicketOn" {
    It "Schannel session ticket TLS optimization is turned on" {
        Mock Invoke-RegistryGetValue { return $true }

        Test-IsEnableSessionTicketOn | Should -BeTrue
    }

    It "Schannel session ticket TLS optimization is NOT turned on" {
        Mock Invoke-RegistryGetValue { return $false }

        Test-IsEnableSessionTicketOn | Should -BeFalse
    }
}

Describe -Tag 'SfBServer' "Test-IsClientAuthTrustModeSetToTrustCA"{
    It "Test if Schannel trust mode is set to 'Exclusive CA Trust'" {
        Mock Invoke-RegistryGetValue { return $true }

        Test-IsClientAuthTrustModeSetToTrustCA | Should -BeTrue
    }

    It "Test if Schannel trust mode is NOT set to 'Exclusive CA Trust'" {
        Mock Invoke-RegistryGetValue { return $false }

        Test-IsClientAuthTrustModeSetToTrustCA | Should -BeFalse
    }

}

Describe -Tag 'SfBServer' "Test-SanOnCert"{
    It "Checking parameter values/types" {
        Get-Command "Test-SanOnCert" | Should -HaveParameter SAN -Type [System.Object]
        Get-Command "Test-SanOnCert" | Should -HaveParameter Certificate -Type [System.Object]
        Get-Command "Test-SanOnCert" | Should -HaveParameter SAN -Mandatory
        Get-Command "Test-SanOnCert" | Should -HaveParameter Certificate -Mandatory
    }
}