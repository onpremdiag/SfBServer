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
# Filename: RDServerSocketCoreRatio.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/1/2022 10:43:38 AM
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\performance\IDInsufficientSQLCores.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)
    . (Join-Path -Path $testRoot -ChildPath mocks\MicrosoftTeamsMocks.ps1)

    . $sut
}


Describe -Tag 'SfBServer' "RDServerSocketCoreRatio" {
    Context "Checking CPU Cores assigned to SQL Server Express" {
        BeforeEach {
            Mock Write-OPDEventLog {}

            $rule = [RDServerSocketCoreRatio]::new([IDInsufficientSQLCores]::new())
        }

        It "Has 4 cores allocated (SUCCESS)" {
            Mock Invoke-SQLCmd {@{cpu_count=4}}

            $rule.Execute($null)

            $rule.Success           | Should -BeTrue
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDInsufficientSQLCores'
            $rule.Insight.Action    | Should -Be $global:InsightActions.'IDInsufficientSQLCores'

        }

        It "Has less than 4 cores allocated (IDInsufficientSQLCores)" {
            Mock Invoke-SQLCmd {@{cpu_count=3}}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDInsufficientSQLCores'
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDInsufficientSQLCores' -f 4, 3)

        }

        It "Invoke-SQLCmd returned empty (IDInsufficientSQLCores)" {
            Mock Invoke-SQLCmd {@{cpu_count=$null}}

            $rule.Execute($null)

            $rule.Success           | Should -BeFalse
            $rule.EventId           | Should -Be $global:EventIds.($rule.Name)
            $rule.Insight.Detection | Should -Be $global:InsightDetections.'IDInsufficientSQLCores'
            $rule.Insight.Action    | Should -Be ($global:InsightActions.'IDInsufficientSQLCores' -f 4, 0)

        }
    }
}