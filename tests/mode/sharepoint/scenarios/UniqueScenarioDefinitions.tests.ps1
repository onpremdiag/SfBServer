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
# Filename: UniqueScenarioDefinitions.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 6/13/2019 1:59 PM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\OnPremDiagTests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

# Load resource files needed for tests
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. "$srcRoot\common\utils.ps1"
. "$srcRoot\classes\RuleDefinition.ps1"
. "$srcRoot\classes\InsightDefinition.ps1"
. "$srcRoot\classes\AnalyzerDefinition.ps1"
. "$srcRoot\classes\ScenarioDefinition.ps1"
. "$testRoot\mocks\SharePointMocks.ps1"
. "$testRoot\mocks\IISMocks.ps1"

Describe -Tag 'SharePoint' "UniqueScenarioDefinitions" {
    BeforeAll {
        $testCases = @()
        $scenarioIds = [Collections.Generic.SortedDictionary[string, int]] @{}
        $scenarioEventIds = [Collections.Generic.SortedDictionary[uint16, int]] @{}

        $rules     = Get-ChildItem $srcRoot\mode\$mode\rules     -Recurse -Filter RD*.ps1 | ForEach-Object {. $_.FullName}
        $insights  = Get-ChildItem $srcRoot\mode\$mode\insights  -Recurse -Filter ID*.ps1 | ForEach-Object {. $_.FullName}
        $analyzers = Get-ChildItem $srcRoot\mode\$mode\analyzers -Recurse -Filter AD*.ps1 | ForEach-Object {. $_.FullName}
        $scenarios = Get-ChildItem $srcRoot\mode\$mode\scenarios -Recurse -Filter SD*.ps1 | Where-Object { $_.FullName -notlike '*sample*'}

        $scenarios | ForEach-Object {$testCases += @{ClassName = $_.BaseName; FullName = $_.FullName}}
        $scenarios | ForEach-Object {. $_.FullName}
    }

    Context "There should be no TODO" {
        It "Scenario <ClassName> should have no TODO" -TestCases $testCases {
            param($FullName)

            $contents = Get-Content -Path $FullName
            foreach($line in $contents)
            {
                if ($line.contains("TODO"))
                {
                    $foundIt = $true
                    break
                }
                else
                {
                    $foundIt = $false
                }
            }

            $foundIt | Should -BeTrue
        }
    }

    Context "Check for ID assignment" {
        It "Scenario <ClassName> should have an ID assigned" -TestCases $testCases {
            param($ClassName)
            $scenarioDefinition = New-Object -TypeName $ClassName -ArgumentList ([guid]::NewGuid())
            $scenarioDefinition.Id | Should Not BeNullOrEmpty
        }
    }

    Context "Check for EventID" {
        It "Scenario <ClassName> should have an EventID assigned" -TestCases $testCases {
            param($ClassName)
            $scenarioDefinition = New-Object -TypeName $ClassName -ArgumentList ([guid]::NewGuid())
            $scenarioDefinition.EventId | Should -BeGreaterThan 0
        }
    }

    Context "Check for description" {
        It "Scenario <ClassName> should have a description" -TestCases $testCases {
            param($ClassName)
            $scenarioDefinition = New-Object -TypeName $ClassName -ArgumentList ([guid]::NewGuid())
            $scenarioDefinition.Description | Should Not BeNullOrEmpty
        }
    }

    Context "All Scenarios should be initialized to true" {
        It "Scenario <ClassName> success Should -BeTrue" -TestCases $testCases {
            param($ClassName)
            $scenarioDefinition = New-Object -TypeName $ClassName -ArgumentList ([guid]::NewGuid())
            $scenarioDefinition.Success | Should -BeTrue
        }
    }

    Context "Class names should match the basename of the file" {
        It "Scenario <ClassName> should match script base name" -TestCases $testCases {
            param($ClassName)
            $scenarioDefinition = New-Object -TypeName $ClassName -ArgumentList ([guid]::NewGuid())
            $scenarioDefinition.Name | Should -Be $ClassName
        }
    }

    Context "Scenarios should have a unique ID" {
        It "Scenario IDs should be unique" {
            foreach($scenario in $scenarios)
            {
                # Source in the analyzer definition
                . $scenario.FullName

                $a =  New-Object -TypeName $scenario.BaseName -ArgumentList ([guid]::NewGuid())

                # Is the id already present?
                if ($scenarioIds.ContainsKey($a.Id))
                {
                    $scenarioIds[$a.Id] += 1
                }
                else
                {
                    $scenarioIds.Add($a.Id, 1)
                }
            }

            $scenarioIds.Values | ForEach-Object {$_ | Should -Be 1}
        }
    }

    Context "Check to make sure event id in the correct range" {
        It "Scenario EventIDs need to be unique and valid" {
            foreach($scenario in $scenarios)
            {
                # Source in the analyzer definition
                . $scenario.FullName

                $a =  New-Object -TypeName $scenario.BaseName -ArgumentList ([guid]::NewGuid())

                # we do not enforce an event ID right now
                if ($a.EventId -gt 0)
                {
                    # Is the id already present?
                    if ($scenarioEventIds.ContainsKey($a.EventId))
                    {
                        $scenarioEventIds[$a.EventId] += 1
                    }
                    else
                    {
                        $scenarioEventIds.Add($a.EventId, 1)
                    }
                }
            }

            foreach ($key in $scenarioEventIds.Keys)
            {
                $key | Should -BeGreaterOrEqual 9800
                $key | Should -BeLessThan 9900
                $scenarioEventIds[$key] | Should -Be 1 -Because "$key is not a unique EventID"
            }
        }
    }
}