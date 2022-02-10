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
# Filename: RDServerMemory.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/26/2022 12:36:27 PM
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\performance\IDInsufficientMemory.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\performance\IDInsufficientMemory2015.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\performance\IDInsufficientMemory2019.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\MicrosoftTeamsMocks.ps1)

    . $sut
}

Describe -Tag 'SfBServer' "RDServerMemory" {
    Context "Checking memory requirements" {
        BeforeEach {
            Mock Write-OPDEventLog {}

            $rule = [RDServerMemory]::new([IDInsufficientMemory]::new())
        }

        It "Skype For Business Server 2015 - 32GB Minimum" {
            Mock Get-CimInstance {
                @(
                    @{
                        TotalPhysicalMemory       = 32GB
                        NumberOfProcessors        = 1
                        NumberOfLogicalProcessors = 8
                    }
                )
            } -ParameterFilter {$ClassName -eq 'Win32_ComputerSystem'}

            Mock Get-CsServerVersion {"Skype for Business Server 2015 (7.0.2046.0): Volume license key installed."}

            $rule.Execute($null)
            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDInsufficientMemory'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientMemory'
        }

        It "Skype For Business Server 2019 - 64GB Minimum" {
            Mock Get-CimInstance {
                @(
                    @{
                        TotalPhysicalMemory       = 64GB
                        NumberOfProcessors        = 1
                        NumberOfLogicalProcessors = 8
                    }
                )
            } -ParameterFilter {$ClassName -eq 'Win32_ComputerSystem'}

            Mock Get-CsServerVersion {"Skype for Business Server 2019 (7.0.2046.0): Volume license key installed."}

            $rule.Execute($null)
            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDInsufficientMemory'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientMemory'
        }

        It "Skype For Business Server 2015 - 16GB (IDInsufficientMemory2015)" {
            Mock Get-CimInstance {
                @(
                    @{
                        TotalPhysicalMemory       = 16GB
                        NumberOfProcessors        = 1
                        NumberOfLogicalProcessors = 8
                    }
                )
            } -ParameterFilter {$ClassName -eq 'Win32_ComputerSystem'}

            Mock Get-CsServerVersion {"Skype for Business Server 2015 (7.0.2046.0): Volume license key installed."}

            $rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDInsufficientMemory2015' -f '32', '16')
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientMemory2015'
        }

        It "Skype For Business Server 2019 - 32GB (IDInsufficientMemory2019)" {
            Mock Get-CimInstance {
                @(
                    @{
                        TotalPhysicalMemory       = 32GB
                        NumberOfProcessors        = 1
                        NumberOfLogicalProcessors = 8
                    }
                )
            } -ParameterFilter {$ClassName -eq 'Win32_ComputerSystem'}

            Mock Get-CsServerVersion {"Skype for Business Server 2019 (7.0.2046.0): Volume license key installed."}

            $rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDInsufficientMemory2019' -f '64', '32')
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientMemory2019'
        }
    }
}