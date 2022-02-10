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
# Filename: Utils.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/5/2018 10:23 AM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
    $srcRoot  = "$root\src"
    $testRoot = "$root\OnPremDiagTests"

    . (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
    . (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
}

Describe -Tag 'Core' "Common utility functions" {
    Context "Get current OPD Version" {
        It "Should return default when not defined" {
            Remove-Variable -Scope Global -Name OPDVersion -ErrorAction Ignore

            Get-OPDVersion | Should -Be ([System.Version]"0.0.0.0")
        }

        It "Should return 1.2.3.4" {
            Remove-Variable -Name OPDVersion -Scope Global -ErrorAction Ignore
            New-Variable -Name OPDVersion -Value "1.2.3.4" -Scope Global -Force

            Get-OPDVersion | Should -Be ([System.Version]"1.2.3.4")

            Remove-Variable -Name OPDVer -Scope Global -ErrorAction Ignore
        }
    }

    Context "Get-RegistryKeyValue Tests" {
        BeforeEach {
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name BuildVersion -Value $null
        }

        It "Retrieving a registry key value" {
            $object.BuildVersion = "15.0.1234.1000"

            Mock Invoke-RegistryGetValue {
                return $object.BuildVersion
            }

            Invoke-RegistryGetValue -RegistryHive LocalMachine -SubKey "SOFTWARE\Microsoft\Office Server\16.0" -GetValue 'BuildVersion' | Should -Be $object.BuildVersion
        }

        It "If registry path does not exist" {
            Mock Invoke-RegistryGetValue { return $null }
            Invoke-RegistryGetValue -RegistryHive LocalMachine -SubKey "SOFTWARE\Microsoft\Office Server\16.0" -GetValue 'BuildVersion' | Should -Be $null
        }

        It "If registry key does not exist" {
            Mock Invoke-RegistryGetValue { return $null }
            Invoke-RegistryGetValue -RegistryHive LocalMachine -SubKey "SOFTWARE\Microsoft\Office Server\16.0" -GetValue 'KeyNotThere' | Should -Be $null
        }
    }

    Context "New-TemporaryFile" {
        It "Should create a temporary file" {
            $tempFile = New-TemporaryFile

            Test-Path -Path $tempFile | Should -BeTrue

            Remove-Item -Path $tempFile -Force

            Test-Path -Path $tempFile | Should -BeFalse
        }
    }

    Context "Get-ProgressID" {
        It "Should generate a random ID between MinInt and MaxInt" {
            $progressId = Get-ProgressId

            $progressID | Should -BeLessOrEqual ([int32]::MaxValue)
        }
    }

    Context "OPD Pre-requisites" {
        It "Should find minimum PowerShell version" {
            Mock Test-MinimumPowershellVersion {
                @(
                    @{
                        Description                = "Minimum PowerShell Version"
                        "Minimum Required Version" = $global:MinimumPowershellVersion
                        "Installed Version"        = [System.Version]"5.1.19041.1023"
                        Passed                     = $true
                    }
                )
            }

            (Test-MinimumPowershellVersion).Passed | Should -BeTrue
        }

        It "Need to upgrade PowerShell version" {
            Mock Test-MinimumPowershellVersion {
                @(
                    @{
                        Description                = "Minimum PowerShell Version"
                        "Minimum Required Version" = $global:MinimumPowershellVersion
                        "Installed Version"        = [System.Version]"4.1.19041.1023"
                        Passed                     = $false
                    }
                )
            }

            (Test-MinimumPowershellVersion).Passed | Should -BeFalse
        }

        It "Minimum version of .NET framework found" {
            Mock Test-MinimumNETFramework {
                @(
                    @{
                        Description                = "Minimum .NET Framework"
                        "Minimum Required Version" = $global:MinimumNetFramework
                        "Installed Version"        = [System.Version]"4.7.2"
                        Passed                     = $true
                    }
                )
            }

            (Test-MinimumNETFramework -MinimumVersion "4.7.2").Passed | Should -BeTrue
        }

        It "Need to upgrade version of .NET framework" {
            Mock Test-MinimumNETFramework {
                @(
                    @{
                        Description                = "Minimum .NET Framework"
                        "Minimum Required Version" = $global:MinimumNetFramework
                        "Installed Version"        = [System.Version]"4.6"
                        Passed                     = $false
                    }
                )
            }

            (Test-MinimumNETFramework -MinimumVersion "4.7.2").Passed | Should -BeFalse
        }
    }
}

