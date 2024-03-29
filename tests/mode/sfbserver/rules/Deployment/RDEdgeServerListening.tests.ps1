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
# Filename: RDEdgeServerListening.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/4/2020 1:20 PM
#
# Last Modified On: 2/4/2020 1:20 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
    $srcRoot  = "$root\src"
    $testRoot = "$root\tests"
    $testMode = $PSCommandPath -match "^(.*)\\tests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
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
    . (Join-Path $srcRoot  -ChildPath "mode\$mode\insights\Deployment\IDEdgeServerNotListening.ps1")
    . (Join-Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")

    . $sut
}

Describe -Tag 'SfBServer', 'Rules' "RDEdgeServerListening" {
    Context "Check if Edge Server is available for remote commands" {
        BeforeEach {
            Mock Write-OPDEventLog {}

            $rule = [RDEdgeServerListening]::new([IDEdgeServerNotListening]::new())

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
                        AccessEdgeExternalSipPort    = 5061
                    }
                )
            }

            Mock Get-CsPool {
                @(
                    @{
                        Identity = "sfb2019.contoso.com"
                        Computers = @(
                            'sfb2019.contoso.com'
                        )
                    }
                )
            }

            Mock Test-NetConnection {
                @(
                    @{
                        ComputerName     = "edge.contoso.com"
                        RemoteAddress    = [ipaddress]"192.168.2.62"
                        RemotePort       = 5985
                        InterfaceAlias   = "NIC1"
                        SourceAddress    = [ipaddress]"192.168.2.54"
                        TcpTestSucceeded = $true
                    }
                )
            }
        }

        It "Constructor worked" {
            $rule.Name        | Should -Be 'RDEdgeServerListening'
            $rule.Description | Should -Not -BeNullOrEmpty
            $rule.ExecutionId | Should -Be ([guid]::Empty)
            $rule.Success     | Should -BeTrue
            $rule.Insight     | Should -Not -BeNullOrEmpty
            $rule.EventId     | Should -Not -BeNullOrEmpty
        }

        It "Passes with single edge server" {
            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.($rule.Insight.Name)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)

        }

        It "Cannot connect to edge server" {
            Mock Test-NetConnection {
                @(
                    @{
                        ComputerName     = "edge.contoso.com"
                        RemoteAddress    = [ipaddress]"192.168.2.62"
                        RemotePort       = 5985
                        InterfaceAlias   = "NIC1"
                        SourceAddress    = [ipaddress]"192.168.2.54"
                        TcpTestSucceeded = $false
                    }
                )
            }

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.($rule.Insight.Name) -f (Get-CsPool).Computers)
            $rule.Insight.Action    | Should -Be $global:InsightActions.($rule.Insight.Name)

        }
    }
}