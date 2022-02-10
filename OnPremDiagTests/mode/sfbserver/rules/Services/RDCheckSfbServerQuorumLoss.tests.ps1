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
# Filename: RDCheckSfbServerQuorumLoss.tests.ps1
# Description: <TODO>
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 12/02/2019 12:59 PM
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
    . "$srcRoot\mode\$mode\insights\Services\IDSfbServerNoQuorum.ps1"
    . "$testRoot\mocks\SfbServerMock.ps1"

    . $sut
}

Describe  -Tag 'SfBServer' "RDCheckSfbServerQuorumLoss" {
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

        Mock Test-NetConnection {
            @(
                @{
                    ComputerName     = "sfb2019.contoso.com"
                    RemoteAddress    = [ipaddress]"127.0.0.1"
                    RemotePort       = [uint32]"5090"
                    InterfaceAlias   = "NIC1"
                    SourceAddress    = [ipaddress]"127.0.0.1"
                    TcpTestSucceeded = $true
                }
            )
        }
    }

    BeforeEach {
        $rd = [RDCheckSfbServerQuorumLoss]::new([IDSfbServerNoQuorum]::new())
    }

    Context "Check if minimum number of servers required to start pool are up and running" {
        It "All required servers are up and running" {

            $rd.Execute($null)

            $rd.Success           | Should -BeTrue
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.($rd.Insight.Name)
            $rd.Insight.Detection | Should -Be $global:InsightDetections.($rd.Insight.Name)
        }

        It "Unable to resolve DNS name for server (Resolve-DnsName fails-IDUnableToResolveDNSName)" {
            Mock Resolve-DnsName { }

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDUnableToResolveDNSName'
            $rd.Insight.Detection | Should -Be $global:InsightDetections.'IDUnableToResolveDNSName'
        }

        It "Unable to get information on PoolFqdn (Get-CsComputer fails-IDNullOrEmptyPoolFQDN)" {
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
            $rd.Insight.Action    | Should -Be ($global:InsightActions.'IDNullOrEmptyPoolFQDN' -f 'sfb2019.contoso.com')
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.'IDNullOrEmptyPoolFQDN' -f 'sfb2019.contoso.com')
        }

        It "Unable to validate network connection (Test-NetConnection fails-IDTestNetworkConnectionFails)" {
            Mock Test-NetConnection { }
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

            $Computer = Get-CsComputer

            $rd.Execute($null)

            $rd.Success           | Should -BeFalse
            $rd.EventId           | Should -Be $global:EventIds.($rd.Name)
            $rd.Insight.Action    | Should -Be $global:InsightActions.'IDTestNetworkConnectionFails'
            $rd.Insight.Detection | Should -Be ($global:InsightDetections.'IDTestNetworkConnectionFails' -f $Computer.Fqdn)
        }

        It "Port not available" {
            Mock Test-NetConnection {
                @(
                    @{
                        ComputerName     = "sfb2019.contoso.com"
                        RemoteAddress    = [ipaddress]"127.0.0.1"
                        RemotePort       = [uint32]"5090"
                        InterfaceAlias   = "NIC1"
                        SourceAddress    = [ipaddress]"127.0.0.1"
                        TcpTestSucceeded = $false
                    }
                )
            }

            $rd.Execute($null)

            $rd.Success | Should -BeFalse
            $rd.EventId | Should -Be $global:EventIds.($rd.Name)
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