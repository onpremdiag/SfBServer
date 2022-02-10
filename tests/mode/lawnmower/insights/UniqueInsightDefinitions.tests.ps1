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
# Filename: UniqueInsightDefinitions.tests.ps1
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
. "$srcRoot\classes\InsightDefinition.ps1"

Describe -Tag 'Lawnmower','Sample','Demo' "UniqueInsightDefinitions" {
    BeforeAll {
        $testCases = @()
        $insightIds = [Collections.Generic.SortedDictionary[string, int]] @{}

        $insights = Get-ChildItem -Path "$srcRoot\mode\$mode\insights" -Recurse -Filter ID*.ps1
        $insights | ForEach-Object {$testCases += @{ClassName = $_.Basename; FullName = $_.FullName}}
        $insights | ForEach-Object {. $_.FullName}
    }

    Context "There should be no TODO" {
        It "Insight <ClassName> should have no TODO" -TestCases $testCases {
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

    Context "Should have constructors" {
        It "Default constructor for <ClassName>" -TestCases $testCases {
            param($ClassName, $FullName)

            $fc = Get-Content -Path $FullName

            $fc | Select-String -Pattern "^\s+$ClassName\(\)$" | Should Not BeNullOrEmpty
        }

        It "Overloaded constructor for <ClassName> with Status" -TestCases $testCases {
            param($ClassName, $FullName)

            $fc = Get-Content -Path $FullName

            $fc | Select-String -Pattern ('^\s+{0}\(\[OPDStatus\]\s+\$Status\)$' -f $ClassName) | Should Not BeNullOrEmpty
        }
    }

    Context "Insight status should be initialized to Failure/Error state" {
        It "Insight <ClassName> status should be initialized to Failure/Error state" -TestCases $testCases {
            param($ClassName)
            $insightDefinition = New-Object -TypeName $ClassName
            $insightDefinition.Status | Should -Be ERROR
        }
    }

    Context "Insights should have an ID assigned to them" {
        It "Insight <ClassName> should have an ID assigned" -TestCases $testCases {
            param($ClassName)
            $insightDefinition = New-Object -TypeName $ClassName
            $insightDefinition.Id | Should Not BeNullOrEmpty
        }
    }

    Context "Insights should have a detection defined" {
        It "Insight <ClassName> should have a detection" -TestCases $testCases {
            param($ClassName)
            $insightDefinition = New-Object -TypeName $ClassName
            $insightDefinition.Detection | Should Not BeNullOrEmpty
        }
    }

    Context "Insights should have an action defined" {
        It "Insight <ClassName> should have an action" -TestCases $testCases {
            param($ClassName)
            $insightDefinition = New-Object -TypeName $ClassName
            $insightDefinition.Action | Should Not BeNullOrEmpty
        }
    }

    Context "Class names should match the basename of the script" {
        It "Insight <ClassName> should match script base name" -TestCases $testCases {
            param($ClassName)
            $insightDefinition = New-Object -TypeName $ClassName
            $insightDefinition.Name | Should -Be $ClassName
        }
    }

    Context "Insight IDs should be unique" {
        It "Insight Id should be unique" {
            foreach($insight in $insights)
            {
                . $insight.FullName

                $i = New-Object -TypeName $insight.Basename

                # Is the id already present?
                If ($insightIds.ContainsKey($i.Id))
                {
                    $insightIds[$i.Id] += 1
                }
                else
                {
                    $insightIds.Add($i.Id, 1)
                }
            }

            $insightIds.Values | ForEach-Object {$_ | Should -Be 1}
        }
    }
}