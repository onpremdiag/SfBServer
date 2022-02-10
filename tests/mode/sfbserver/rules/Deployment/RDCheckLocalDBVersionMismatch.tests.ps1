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
# Filename: RDCheckLocalDBVersionMismatch.tests.ps1
# Description: <TODO>
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On:
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDCommandNotFoundException.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDPropertyNotFoundException.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDTestCsDatabaseNoResults.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Services\IDLocalSQLServerSchemaVersionMismatch.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

    . $sut
}



Describe  -Tag 'SfBServer' "RDCheckLocalDBVersionMismatch" {
    Context "Determine if local databases version match expected version" {
        BeforeAll {
            Mock Write-OPDEventLog {}
        }

        BeforeEach {
            Mock Test-CsDatabase {
                @(
                    @{

                        DatabaseName     = "rtcxds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "15.13.22"
                        InstalledVersion = "15.13.22"
                    },
                    @{
                        DatabaseName     = "rtcab"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "62.42.13"
                        InstalledVersion = "62.42.13"
                    },
                    @{
                        DatabaseName     = "rgsconfig"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "5.5.2"
                        InstalledVersion = "5.5.2"
                    },
                    @{
                        DatabaseName     = "rgsdyn"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "2.2.1"
                        InstalledVersion = "2.2.1"
                    },
                    @{
                        DatabaseName     = "cpsdyn"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "1.1.2"
                        InstalledVersion = "1.1.2"
                    },
                    @{
                        DatabaseName     = "xds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "10.16.7"
                        InstalledVersion = "10.16.7"
                    },
                    @{
                        DatabaseName     = "lis"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "3.1.1"
                        InstalledVersion = "3.1.1"
                    },
                    @{
                        DatabaseName     = "rtc"
                        SqlInstanceName  = "rtclocal"
                        ExpectedVersion  = "125.74.89"
                        InstalledVersion = "125.74.89"
                    },
                    @{
                        DatabaseName     = "lyss"
                        SqlInstanceName  = "lynclocal"
                        ExpectedVersion  = "12.44.13"
                        InstalledVersion = "12.44.13"
                    },
                    @{
                        DatabaseName     = "xds"
                        SqlInstanceName  = "rtclocal"
                        ExpectedVersion  = "10.16.7"
                        InstalledVersion = "10.16.7"
                    }
                )
            }

            $rule = [RDCheckLocalDBVersionMismatch]::new([IDLocalSQLServerSchemaVersionMismatch]::new())
        }

        It "Installed databases match expected databases (default pass)" {
            $rule.Execute($null)

            $rule.Success | Should -BeTrue
        }

        It "Installed databases does not match expected databases (IDLocalSQLServerSchemaVersionMismatch)" {
            Mock Test-CsDatabase {
                @(
                    @{

                        DatabaseName     = "rtcxds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "15.13.22"
                        InstalledVersion = "15.13.22"
                    },
                    @{
                        DatabaseName     = "rtcab"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "62.42.13"
                        InstalledVersion = "62.42.13"
                    },
                    @{
                        DatabaseName     = "rgsconfig"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "5.5.2"
                        InstalledVersion = "5.5.2"
                    },
                    @{
                        DatabaseName     = "rgsdyn"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "2.2.2"
                        InstalledVersion = "2.2.1"
                    },
                    @{
                        DatabaseName     = "cpsdyn"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "1.1.2"
                        InstalledVersion = "1.1.2"
                    },
                    @{
                        DatabaseName     = "xds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "10.16.7"
                        InstalledVersion = "10.16.7"
                    },
                    @{
                        DatabaseName     = "lis"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "3.1.1"
                        InstalledVersion = "3.1.1"
                    },
                    @{
                        DatabaseName     = "rtc"
                        SqlInstanceName  = "rtclocal"
                        ExpectedVersion  = "125.74.89"
                        InstalledVersion = "125.74.89"
                    },
                    @{
                        DatabaseName     = "lyss"
                        SqlInstanceName  = "lynclocal"
                        ExpectedVersion  = "12.44.13"
                        InstalledVersion = "12.44.13"
                    },
                    @{
                        DatabaseName     = "xds"
                        SqlInstanceName  = "rtclocal"
                        ExpectedVersion  = "10.16.7"
                        InstalledVersion = "10.16.7"
                    }
                )
            }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse

            $rule.Insight.Name      | Should -Be 'IDLocalSQLServerSchemaVersionMismatch'
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDLocalSQLServerSchemaVersionMismatch' -f 'rgsdyn', '2.2.1', '2.2.2')
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDLocalSQLServerSchemaVersionMismatch'
        }

        It "No databases found (IDTestCsDatabaseNoResults)" {
            Mock Test-CsDatabase {}

            $rule.Execute($null)

            $rule.Success | Should -BeFalse
            $rule.Insight.Name      | Should -Be 'IDTestCsDatabaseNoResults'
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDTestCsDatabaseNoResults'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDTestCsDatabaseNoResults'
        }
    }
}