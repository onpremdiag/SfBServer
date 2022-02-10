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
# Filename: RDCheckUserUCSConnectivity.tests.ps1
# Description: <TODO>
#
# Owner: João Loureiro <joaol@microsoft.com>
# Created On: 12/19/2019 11:31 AM
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
    . "$testRoot\testhelpers\LoadResourceFiles.ps1"
    Import-ResourceFiles -Root $srcRoot -MyMode $mode

    . "$srcRoot\common\Globals.ps1"
    . "$srcRoot\common\Utils.ps1"
    . "$srcRoot\mode\$mode\common\Globals.ps1"
    . "$srcRoot\mode\$mode\common\$mode.ps1"
    . "$srcRoot\classes\RuleDefinition.ps1"
    . "$srcRoot\classes\InsightDefinition.ps1"
    . "$srcRoot\mode\$mode\insights\ContactList\IDUCSConnectivityNotAvailable.ps1"
    . "$testRoot\mocks\SfbServerMock.ps1"

    . $sut
}

Describe -Tag 'SfBServer' "RDCheckUserUCSConnectivity" {
    Context "Determine if server-to-server Skype for Business and Exchange connectivity is working" {
        BeforeAll {
            Mock Write-OPDEventLog {}

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

            Mock Test-CsUnifiedContactStore {
                @(
                    @{
                        Result = "Success"
                        }
                )
            }
        }

        BeforeEach {
            $rd = [RDCheckUserUCSConnectivity]::new([IDUCSConnectivityNotAvailable]::new())
        }

        It "Exchange connection available" {

            $rd.ParameterDefinitions = @{
                Name  = "PDSipAddress";
                Value = "user@contoso.com"
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Exchange connection not available" {
            Mock Test-CsUnifiedContactStore {
                @(
                    @{
                        Result = "Failure"
                    }
                )
            }

            $rd.ParameterDefinitions = @{
                Name  = "PDSipAddress";
                Value = "user@contoso.com"
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
        }

        It "Unable to resolve DNS name for server (Resolve-DnsName fails)" {
            Mock Resolve-DnsName { }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToResolveDNSName'
        }

        It "Unable to get information on PoolFqdn (Get-CsComputer fails)" {
            Mock Get-CsComputer {
                @(
                    @{
                        Identity = [string]::Empty
                        Pool     = [string]::Empty
                        Fqdn     = [string]::Empty
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToResolveServerFQDN'
        }

        It "Server FQDN Name is missing" {
            Mock Resolve-DnsName {
                @(
                    @{
                        Address    = [ipaddress]"127.0.0.1"
                        IPAddress  = [ipaddress]"127.0.0.1"
                        QueryType  = "A"
                        IP4Address = [ipaddress]"127.0.0.1"
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDPropertyNotFoundException'
        }

        It "Server FQDN Name is empty" {
            Mock Resolve-DnsName {
                @(
                    @{
                        Address    = [ipaddress]"127.0.0.1"
                        IPAddress  = [ipaddress]"127.0.0.1"
                        QueryType  = "A"
                        IP4Address = [ipaddress]"127.0.0.1"
                        Name       = [string]::Empty
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToResolveServerFQDN'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToResolveServerFQDN'
        }
     }
}