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
# Filename: RDCheckSQLServerBackendConnection.tests.ps1
# Description: <TODO>
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 12/02/2019 12:59 PM
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
. "$srcRoot\mode\$mode\insights\Services\IDSQLServerBackendConnectionIsDown.ps1"
. "$testRoot\mocks\SfbServerMock.ps1"

. $sut

Describe  -Tag 'SfBServer' "RDCheckSQLServerBackendConnection" {
    BeforeAll {
        Mock Write-EventLog{}
    }

    BeforeEach {

        Mock Resolve-DnsName {
            @(
                @{
                    Address    = [ipaddress]"127.0.0.1"
                    IPAddress  = [ipaddress]"127.0.0.1"
                    QueryType  = "A"
                    IP4Address = [ipaddress]"127.0.0.1"
                    Name       = "sfb2019.contoso.com"
                }
            )
        }

        Mock Get-CsComputer {
            @(
                @{
                    Identity = "sfb2019.contoso.com"
                    Pool     = "sfb2019.contoso.com"
                    Fqdn     = "sfb2019.contoso.com"
                }
            )
        }

        Mock Get-CsService {
            @(
                @{
                    Identity                     = "UserServer:sfb2019.contoso.com"
                    UserDatabase                 = "UserDatabase:sfb2019.contoso.com"
                    McuFactorySipPort            = [uint16]444
                    UserPinManagementWcfHttpPort = [uint16]443
                    SiteId                       = "Site:contoso"
                    PoolFqdn                     = "sfb2019.contoso.com"
                    Role                         = "UserServer"
                }
            )
        }

        Mock Test-CsDatabase {
            @(
                @{
                    SqlServerFqdn            = "sfb2019.contoso.com"
                    SqlInstanceName          = "rtc"
                    DatabaseName             = "rtcxds"
                    DatabaseHighAvailability = "None"
                    DataSource               = "sfb2019.contoso.com\rtc"
                    SQLServerVersion         = "13.0.4259 SP1 Express Edition (64-bit)"
                    ExpectedVersion          = "15.13.21"
                    InstalledVersion         = "15.13.21"
                    Succeed                  = $true
                },
                @{
                    SqlServerFqdn            = "sfb2019.ucstaff.com"
                    SqlInstanceName          = "rtc"
                    DatabaseName             = "rtcab"
                    DatabaseHighAvailability = "None"
                    DataSource               = "sfb2019.ucstaff.com\rtc"
                    SQLServerVersion         = "13.0.4259 SP1 Express Edition (64-bit)"
                    ExpectedVersion          = "62.42.13"
                    InstalledVersion         = "62.42.13"
                    Succeed                  = $true
                }
            )
        }

        $rd = [RDCheckSQLServerBackendConnection]::new([IDSQLServerBackendConnectionIsDown]::new())
    }

    Context "Check if SQL Server back-end connectivity is operational (SUCCESS)" {
        It "SQL back-end is reachable" {

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        }

        It "Unable to resolve DNS name for server (Resolve-DnsName fails) - IDUnableToResolveDNSName" {
            Mock Resolve-DnsName { }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToResolveDNSName'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToResolveDNSName'
        }

        It "Unable to get information on PoolFqdn (Get-CsComputer fails) - IDPropertyNotFoundException" {
            Mock Get-CsComputer { }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDPropertyNotFoundException'
        }

        It "Unable to get access back-end service (Get-CsService fails) - IDUnableToGetServiceInfo" {
            Mock Get-CsService { }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToGetServiceInfo'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToGetServiceInfo'
        }

        It "No UserDatabase found (Service.UserDatabase does not exist) - IDUnableToGetServiceInfo" {
            Mock Get-CsService {
                @(
                    @{
                        Identity                     = "UserServer:sfb2019.contoso.com"
                        UserDatabase                 = [string]::Empty
                        McuFactorySipPort            = [uint16]444
                        UserPinManagementWcfHttpPort = [uint16]443
                        SiteId                       = "Site:contoso"
                        PoolFqdn                     = "sfb2019.contoso.com"
                        Role                         = "UserServer"
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToGetServiceInfo'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToGetServiceInfo'

        }

        It "Unable to verify connectivity to one or more Skype for Business Server databases (Test-CsDatabase returns null) - IDTestCsDatabaseNoResults" {
            Mock Test-CsDatabase {}

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDTestCsDatabaseNoResults'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDTestCsDatabaseNoResults'
        }

        It "Property not found - IDPropertyNotFoundException" {
            Mock Get-CsService { throw [System.Management.Automation.PropertyNotFoundException]::new() }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDPropertyNotFoundException'
        }
    }
}