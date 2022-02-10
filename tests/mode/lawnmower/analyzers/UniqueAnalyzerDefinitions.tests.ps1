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
# Filename: UniqueAnalyzerDefinitions.tests.ps1
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

#. "$srcRoot\common\SharePoint.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$srcRoot\common\utils.ps1"
. "$srcRoot\classes\RuleDefinition.ps1"
. "$srcRoot\classes\InsightDefinition.ps1"
. "$srcRoot\classes\AnalyzerDefinition.ps1"
#. "$testRoot\mocks\SharePointMocks.ps1"
. "$testRoot\mocks\IISMocks.ps1"

Describe -Tag 'Lawnmower','Sample','Demo' "UniqueAnalyzerDefinitions" {
    BeforeAll {
        $testCases        = @()
        $analyzerIds      = [Collections.Generic.SortedDictionary[string, int]] @{}
        $analyzerEventIds = [Collections.Generic.SortedDictionary[uint16, int]] @{}

        $rules     = Get-ChildItem -Path "$srcRoot\mode\$mode\rules" -Recurse -Filter RD*.ps1
        $insights  = Get-ChildItem -Path "$srcRoot\mode\$mode\insights" -Recurse -Filter ID*.ps1
        $analyzers = Get-ChildItem -Path "$srcRoot\mode\$mode\analyzers" -Recurse -Filter AD*.ps1

        $analyzers | ForEach-Object {$testCases += @{ClassName = $_.BaseName; FullName = $_.FullName}}

        $rules     | ForEach-Object {. $_.FullName}
        $insights  | ForEach-Object {. $_.FullName}
        $analyzers | ForEach-Object {. $_.FullName}
    }

    Context "There should be no TODO" {
        It "Analyzer <ClassName> should have no TODO" -TestCases $testCases {
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

    Context "All analyzers should have an ID assigned" {
        It "Analyzer <ClassName> should have an ID assigned" -TestCases $testCases {
            param($ClassName)
            $analyzerDefinition = New-Object -TypeName $ClassName
            $analyzerDefinition.Id | Should Not BeNullOrEmpty
        }
    }

    Context "All analyzers should have an EventID assigned" {
        It "Analyzer <ClassName> should have an EventID assigned" -TestCases $testCases {
            param($ClassName)
            $analyzerDefinition = New-Object -TypeName $ClassName
            $analyzerDefinition.EventId | Should -BeGreaterThan 0
        }
    }

    Context "All analyzers should have a description" {
        It "Analyzer <ClassName> should have a description" -TestCases $testCases {
            param($ClassName)
            $analyzerDefinition = New-Object -TypeName $ClassName
            $analyzerDefinition.Description | Should Not BeNullOrEmpty
        }
    }

    Context "All analyzers should be initialized to passing" {
        It "Analyzer <ClassName> success Should -BeTrue" -TestCases $testCases {
            param($ClassName)
            $analyzerDefinition = New-Object -TypeName $ClassName
            $analyzerDefinition.Success | Should -BeTrue
        }
    }

    Context "Class name should match the basename of the file" {
        It "Analyzer <ClassName> should match script base name" -TestCases $testCases {
            param($ClassName)
            $analyzerDefinition = New-Object -TypeName $ClassName
            $analyzerDefinition.Name | Should -Be $ClassName
        }
    }

    Context "All analyzers should have a unique ID" {
        It "Analyzer IDs should be unique" {
            foreach($analyzer in $analyzers)
            {
                # Source in the analyzer definition
                . $analyzer.FullName

                $a = New-Object -TypeName $analyzer.BaseName

                # Is the id already present?
                if ($analyzerIds.ContainsKey($a.Id))
                {
                    $analyzerIds[$a.Id] += 1
                }
                else
                {
                    $analyzerIds.Add($a.Id, 1)
                }
            }

            $analyzerIds.Values | ForEach-Object {$_ | Should -Be 1}
        }
    }

    Context "All analyzers ID should be in the correct range" {
        It "Analyzer IDs need to be unique and valid" {
            foreach($analyzer in $analyzers)
            {
                # Source in the analyzer definition
                . $analyzer.FullName

                $a =  New-Object -TypeName $analyzer.BaseName

                # we do not enforce an event ID right now
                if ($a.EventId -gt 0)
                {
                    # Is the id already present?
                    if ($analyzerEventIds.ContainsKey($a.EventId))
                    {
                        $analyzerEventIds[$a.EventId] += 1
                    }
                    else
                    {
                        $analyzerEventIds.Add($a.EventId, 1)
                    }
                }
            }

            foreach ($key in $analyzerEventIds.Keys)
            {
                $key | Should -BeGreaterOrEqual 9700
                $key | Should -BeLessThan 9800
                $analyzerEventIds[$key] | Should -Be 1 -Because "$key is not a unique EventID"
            }
        }
    }
}