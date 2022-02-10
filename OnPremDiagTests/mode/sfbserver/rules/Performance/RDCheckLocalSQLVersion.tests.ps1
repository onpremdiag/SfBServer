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
# Filename: RDCheckLocalSQLVersion.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/31/2022 3:23:20 PM
#
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
    . (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)

    Import-ResourceFiles -Root $srcRoot -MyMode $mode

    . (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)
    . (Join-Path -Path $srcRoot -ChildPath classes\RuleDefinition.ps1)
    . (Join-Path -Path $srcRoot -ChildPath classes\InsightDefinition.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDCheckSQLVersion.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDUnableToGetVersion.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Deployment\IDUnableToResolveServerFQDN.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Performance\IDUpgradeSQLExpress.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\global\IDTestCsDatabaseNoResults.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\global\IDUnableToGetServiceInfo.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\global\IDUnableToResolveDNSName.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

    . $sut
}

Describe -Tag 'SfBServer', 'Rule' "RDCheckLocalSQLVersion" {
    Context "RDCheckLocalSQLVersion" {
        BeforeAll {
            Mock Write-OPDEventLog {}
            $OriginalComputerName = $env:COMPUTERNAME
            $OriginalDNSDomain    = $env:USERDNSDOMAIN
        }

        BeforeEach {
            Mock Resolve-DnsName {
                @(
                    @{
                        Address      = "127.0.0.1"
                        IPAddress    = "127.0.0.1"
                        QueryType    = "A"
                        IP4Address   = "127.0.0.1"
                        Name         = "sfbserver.contoso.com"
                        Type         = "A"
                        CharacterSet = "Unicode"
                        Section      = "Answer"
                        DataLength   = 4
                        TTL          = 1200
                    }
                )
            }
            Mock Get-CsComputer {
                @(
                    @{
                        Identity = "sfbserver.contoso.com"
                        Pool     = "sfbserver.contoso.com"
                        Fqdn     = "sfbserver.contoso.com"
                    }
                )
            }
            Mock Test-CsDatabase {
                @(
                    @{

                        DatabaseName     = "rtcxds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "15.13.22"
                        InstalledVersion = "15.13.22"
                        SQLServerVersion = @{
                            ProductVersion = [System.Version]"15.0.4198.2";
                            ProductLevel   = 'CU15';
                            Edition        = "Express Edition 2019"
                        }
                    },
                    @{
                        DatabaseName     = "rtcab"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "62.42.13"
                        InstalledVersion = "62.42.13"
                        SQLServerVersion = "13.0.4259 SP1 Express Edition (64-bit)"
                    }
                )
            }
            Mock Get-CsService {
                @(
                    @{
                        Role         = "UserServer"
                        Identity     = "UserServer:sfbserver.contoso.com"
                        UserDatabase = "UserDatabase:sfbserver.contoso.com"
                    }
                )
            }

            $rule              = [RDCheckLocalSQLVersion]::new([IDUpgradeSQLExpress]::new())
            $env:ComputerName  = "sfbserver"
            $env:USERDNSDOMAIN = "CONTOSO.COM"
        }

        AfterAll {
            $env:COMPUTERNAME  = $OriginalComputerName
            $env:USERDNSDOMAIN = $OriginalDNSDomain
        }

        It "Correct server version (SUCCESS)" {

            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)
        }

        It "Upgrade SQL Server Express 2019 (IDUpgradeSQLExpress)" {
            Mock Test-CsDatabase {
                @(
                    @{

                        DatabaseName     = "rtcxds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "15.13.22"
                        InstalledVersion = "15.13.22"
                        SQLServerVersion = @{
                            ProductVersion = [System.Version]"15.0.1234.2";
                            ProductLevel   = 'CU15';
                            Edition        = "Express Edition 2019"
                        }
                    },
                    @{
                        DatabaseName     = "rtcab"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "62.42.13"
                        InstalledVersion = "62.42.13"
                        SQLServerVersion = "13.0.4259 SP1 Express Edition (64-bit)"
                    }
                )
            }

            $SQLVersion = ($global:SQLExpressVersions | Where-Object {$_.Edition -eq 'Express Edition 2019'})

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $SQLExpress2019.ProductVersion.ToString(),"15.0.1234.2")
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f $SQLVersion.Description, $SQLVersion.URL)
        }

        It "Upgrade SQL Server Express 2017 (IDUpgradeSQLExpress)" {
            Mock Test-CsDatabase {
                @(
                    @{

                        DatabaseName     = "rtcxds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "15.13.22"
                        InstalledVersion = "15.13.22"
                        SQLServerVersion = @{
                            ProductVersion = [System.Version]"14.0.1000.1";
                            ProductLevel   = 'CU15';
                            Edition        = "Express Edition 2017"
                        }
                    },
                    @{
                        DatabaseName     = "rtcab"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "62.42.13"
                        InstalledVersion = "62.42.13"
                        SQLServerVersion = "13.0.4259 SP1 Express Edition (64-bit)"
                    }
                )
            }

            $SQLVersion = ($global:SQLExpressVersions | Where-Object {$_.Edition -eq 'Express Edition 2017'})

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $SQLExpress2017.ProductVersion.ToString(),"14.0.1000.1")
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f $SQLVersion.Description, $SQLVersion.Url)
        }

        It "Upgrade SQL Server Express 2016 (IDUpgradeSQLExpress)" {
            Mock Test-CsDatabase {
                @(
                    @{

                        DatabaseName     = "rtcxds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "15.13.22"
                        InstalledVersion = "15.13.22"
                        SQLServerVersion = @{
                            ProductVersion = [System.Version]"13.0.1000.0";
                            ProductLevel   = 'CU15';
                            Edition        = "Express Edition 2016"
                        }
                    },
                    @{
                        DatabaseName     = "rtcab"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "62.42.13"
                        InstalledVersion = "62.42.13"
                        SQLServerVersion = "13.0.4259 SP1 Express Edition (64-bit)"
                    }
                )
            }

            $SQLVersion = ($global:SQLExpressVersions | Where-Object {$_.Edition -eq 'Express Edition 2016'})

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $SQLExpress2016.ProductVersion.ToString(),"13.0.1000.0")
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f $SQLVersion.Description, $SQLVersion.Url)
        }

        It "Upgrade SQL Server Express 2014 (IDUpgradeSQLExpress)" {
            Mock Test-CsDatabase {
                @(
                    @{

                        DatabaseName     = "rtcxds"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "15.13.22"
                        InstalledVersion = "15.13.22"
                        SQLServerVersion = @{
                            ProductVersion = [System.Version]"12.0.1000.0";
                            ProductLevel   = 'CU15';
                            Edition        = "Express Edition 2014"
                        }
                    },
                    @{
                        DatabaseName     = "rtcab"
                        SqlInstanceName  = "rtc"
                        ExpectedVersion  = "62.42.13"
                        InstalledVersion = "62.42.13"
                        SQLServerVersion = "13.0.4259 SP1 Express Edition (64-bit)"
                    }
                )
            }

            $SQLVersion = ($global:SQLExpressVersions | Where-Object {$_.Edition -eq 'Express Edition 2014'})
            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f $SQLExpress2014.ProductVersion.ToString(),"12.0.1000.0")
            $rule.Insight.Action    | Should -Be ($global:InsightActions.($rule.Insight.Name) -f $SQLVersion.Description, $SQLVersion.Url)
        }
    }
}