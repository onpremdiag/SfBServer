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
# Filename: RDServerCore.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/25/2022 4:27:49 PM
#
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
    . (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)

    Import-ResourceFiles -Root $srcRoot -MyMode $mode

    . (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)
    . (Join-Path -Path $srcRoot -ChildPath classes\RuleDefinition.ps1)
    . (Join-Path -Path $srcRoot -ChildPath classes\InsightDefinition.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\performance\IDInsufficientCores.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\performance\IDInsufficientCores2015.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\performance\IDInsufficientCores2019.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\MicrosoftTeamsMocks.ps1)

    . $sut
}

Describe -Tag 'SfBServer' "RDServerCores" {
    Context "Checking number of cores" {
        BeforeEach {
            Mock Write-OPDEventLog {}

            $rule = [RDServerCores]::new([IDInsufficientCores]::new())
        }

        It "6 (or more) cores (SUCCESS)" {
            Mock Get-WmiObjectHandler {
                @(
                    @{
                        NumberOfCores             = 6
                        NumberOfLogicalProcessors = 2
                    }
                )
            } -ParameterFilter {$Class -eq 'Win32_Processor'}

            Mock Get-CsServerVersion {"Skype for Business Server 2019 (7.0.2046.0): Volume license key installed."}

            $rule.Execute($null)
            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDInsufficientCores'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientCores'
        }

        It "Less than 6 cores - 2019 (IDInsufficientCores2019)" {
            Mock Get-WmiObjectHandler {
                @(
                    @{
                        NumberOfCores             = 4
                        NumberOfLogicalProcessors = 2
                    }
                )
            } -ParameterFilter {$Class -eq 'Win32_Processor'}

            Mock Get-CsServerVersion {"Skype for Business Server 2019 (7.0.2046.0): Volume license key installed."}

            $rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDInsufficientCores2019' -f 4, 6)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientCores2019'
        }

        It "Less than 6 cores - 2015 (IDInsufficientCores2015)" {
            Mock Get-WmiObjectHandler {
                @(
                    @{
                        NumberOfCores             = 4
                        NumberOfLogicalProcessors = 2
                    }
                )
            } -ParameterFilter {$Class -eq 'Win32_Processor'}

            Mock Get-CsServerVersion {"Skype for Business Server 2015 (7.0.2046.0): Volume license key installed."}

            $rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be ($global:InsightDetections.'IDInsufficientCores2015' -f 4, 6)
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientCores2015'
        }

        It "Less than 6 cores - another version (IDInsufficientCores)" {
            Mock Get-WmiObjectHandler {
                @(
                    @{
                        NumberOfCores             = 4
                        NumberOfLogicalProcessors = 2
                    }
                )
            } -ParameterFilter {$Class -eq 'Win32_Processor'}

            Mock Get-CsServerVersion {"Skype for Business Server 2016 (7.0.2046.0): Volume license key installed."}

            $rule.Execute($null)
            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDInsufficientCores'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientCores'
        }
    }
}