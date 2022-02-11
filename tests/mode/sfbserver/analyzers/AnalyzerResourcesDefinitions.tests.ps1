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
# Filename: AnalyzerResourcesDefined.tests.ps1
# Description: <TODO>
# Owner: Jo�o Loureiro <joaol@microsoft.com>
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$myPath   = $PSCommandPath
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\tests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

$classes    = Get-ChildItem -Path "$srcRoot\classes"               -Recurse -Filter *.ps1
$rules      = Get-ChildItem -Path "$srcRoot\mode\$mode\rules"      -Recurse -Filter RD*.ps1
$insights   = Get-ChildItem -Path "$srcRoot\mode\$mode\insights"   -Recurse -Filter ID*.ps1
$analyzers  = Get-ChildItem -Path "$srcRoot\mode\$mode\analyzers"  -Recurse -Filter AD*.ps1
$parameters = Get-ChildItem -Path "$srcRoot\mode\$mode\parameters" -Recurse -Filter PD*.ps1

foreach ($group in $classes, $insights, $rules, $analyzers, $parameters)
{
    foreach ($file in $group)
    {
        . $file.FullName
    }
}

# Load resource files needed for tests
. (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)

Import-ResourceFiles -Root $srcRoot -MyMode $mode

. (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
. (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)

Describe -Tag 'sfbserver' "Check analyzer resources" {
    BeforeAll {
        $analyzers  = Get-ChildItem $srcRoot\mode\$mode\analyzers -Recurse -Filter AD*.ps1 -File | Sort-Object -Property BaseName
    }

    Context "Class name matches file name" {
        foreach($analyzer in $analyzers)
        {
            It "Class Name for $($analyzer.BaseName) should match internal name" {
                . $analyzer.FullName

                $parameters = @{
                    TypeName     = $analyzer.BaseName
                    ArgumentList = $null
                }

                $obj = New-Object @parameters

                $obj.Name | Should -Not -BeNullOrEmpty
                $analyzer.BaseName | Should -BeExactly $obj.GetType().Name
            }
        }
    }

    Context "Resources" {
        foreach($analyzer in $analyzers)
        {
            It "Analyzer $($analyzer.BaseName) should have a resource in AnalyzerDescriptions" {
                $global:AnalyzerDescriptions.($analyzer.BaseName) | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Event IDs" {
        foreach($analyzer in $analyzers)
        {
            It "Analyzer $($analyzer.BaseName) should have an event id" {
                $global:EventIDs.($analyzer.BaseName) | Should -Not -BeNullOrEmpty
            }
        }

    }
}
