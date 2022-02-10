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
# Filename: ADCheckEdgeConfiguration.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/13/2020 11:15 AM
#
# Last Modified On: 1/13/2020 11:15 AM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
    $srcRoot  = "$root\src"
    $testRoot = "$root\OnPremDiagTests"
    $testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
    $mode     = $Matches.Mode


    $global:OPDOptions  = @{
        OriginalCulture  = ([System.Threading.Thread]::CurrentThread.CurrentCulture).Name
    }

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
    . (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)

    Import-ResourceFiles -Root $srcRoot -MyMode $mode

    . (Join-Path -Path $srcRoot -ChildPath "common\Globals.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "common\Utils.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "mode\$mode\common\Globals.ps1")
    . (Join-Path -Path $srcRoot -ChildPath "mode\$mode\common\$mode.ps1")

    . (Join-Path -Path $testRoot -ChildPath "mocks\SfbServerMock.ps1")
    . (Join-Path -Path $testRoot -ChildPath "mocks\ActiveDirectoryMocks.ps1")
    . (Join-Path -Path $testRoot -ChildPath "mocks\LyncOnlineConnectorMocks.ps1")

    . $sut
}

Describe -Tag 'SfBserver' "ADCheckEdgeConfiguration" {
    Context "Verifies that edge configuration is properly configured" {
        BeforeAll {
            Mock Write-OPDEventLog {}
        }

        BeforeEach {
            Mock Initialize-Module { return $true }
            $analyzer = [ADCheckEdgeConfiguration]::new()
        }

        It "Analyzer should complete with no errors" {
            Mock Get-CsAccessEdgeConfiguration {
                @(
                    @{
                        AllowOutsideUsers   = $true
                        RoutingMethod       = "UseDnsSrvRouting"
                        AllowFederatedUsers = $true
                    }
                )
            }

            $analyzer.Execute($null)

            $analyzer.Success | Should -BeTrue
        }

        It "Get-CsAccessEdgeConfiguration fails" {
            Mock Get-CsAccessEdgeConfiguration { $null }

            $analyzer.Execute($null)

            $analyzer.Success              | Should -BeFalse
        }

        It "Outside users are allowed" {
            Mock Get-CsAccessEdgeConfiguration {
                @(
                    @{
                        AllowOutsideUsers   = $true
                        RoutingMethod       = "UseDnsSrvRouting"
                        AllowFederatedUsers = $true
                    }
                )
            }

            $analyzer.Execute($null)

            $analyzer.Success              | Should -BeTrue
        }

        It "Outside users not allowed" {
            Mock Get-CsAccessEdgeConfiguration {
                @(
                    @{
                        AllowOutsideUsers   = $false
                        RoutingMethod       = "UseDnsSrvRouting"
                        AllowFederatedUsers = $true
                    }
                )
            }

            $analyzer.Execute($null)

            $analyzer.Success              | Should -BeFalse
            $analyzer.Results.Insight.Name | Should -Be 'IDEdgeConfigDoNotAllowOutsideUsers'
        }

        It "Federated users are allowed" {
            Mock Get-CsAccessEdgeConfiguration {
                @(
                    @{
                        AllowOutsideUsers   = $true
                        RoutingMethod       = "UseDnsSrvRouting"
                        AllowFederatedUsers = $true
                    }
                )
            }

            $analyzer.Execute($null)

            $analyzer.Success              | Should -BeTrue
        }

        It "Federated users not allowed" {
            Mock Get-CsAccessEdgeConfiguration {
                @(
                    @{
                        AllowOutsideUsers   = $true
                        RoutingMethod       = "UseDnsSrvRouting"
                        AllowFederatedUsers = $false
                    }
                )
            }

            $analyzer.Execute($null)

            $analyzer.Success              | Should -BeFalse
            $analyzer.Results.Insight.Name | Should -Be 'IDEdgeConfigDoNotAllowFederatedUsers'
        }

        It "DNS Server Routing is being used" {
            Mock Get-CsAccessEdgeConfiguration {
                @(
                    @{
                        AllowOutsideUsers   = $true
                        RoutingMethod       = "UseDnsSrvRouting"
                        AllowFederatedUsers = $true
                    }
                )
            }

            $analyzer.Execute($null)

            $analyzer.Success              | Should -BeTrue
        }

        It "DNS Server Routing not being used" {
            Mock Get-CsAccessEdgeConfiguration {
                @(
                    @{
                        AllowOutsideUsers   = $true
                        RoutingMethod       = "DoNotUseDnsSrvRouting"
                        AllowFederatedUsers = $true
                    }
                )
            }

            $analyzer.Execute($null)

            $analyzer.Success              | Should -BeFalse
            $analyzer.Results.Insight.Name | Should -Be 'IDEdgeConfigDoNotAllowDnsSrvRouting'
        }
    }
}