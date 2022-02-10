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
# Filename: RuleResourcesDefined.tests.ps1
# Description: <TODO>
# Owner: João Loureiro <joaol@microsoft.com>
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
    $myPath   = $PSCommandPath
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
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\insights\Global\IDException.ps1)
}

Describe -Tag 'sfbserver' "Check rule resources" {
    BeforeAll {
        $rules   = Get-ChildItem $srcRoot\mode\$mode\rules -Recurse -Filter RD*.ps1 -File | Sort-Object -Property BaseName
        $insight = New-Object -TypeName "IDException" -ArgumentList $null
    }

    Context "1.0 Filenames/Class Names" {
        It "Class name for rule should match internal name" {
            $index = 0

            foreach($rule in $rules)
            {
                $index++
                #"`t1.$($index) Class name for $($rule.BaseName) should match internal name" | Write-Host
                    . $rule.FullName

                    $obj = New-Object -TypeName $rule.BaseName -ArgumentList $insight

                    $rule.BaseName | Should -BeExactly $obj.GetType().Name
            }
        }
    }

    Context "2.0 Resources" {
        It "Rule should have a resources in RuleDescriptions" {
            $index = 0

            foreach($rule in $rules)
            {
                $index++
                #"`t2.$($index) Rule $($rule.BaseName) should have resource in RuleDescriptions: $($Global:RuleDescriptions.($rule.BaseName))" | Write-Host
                $Global:RuleDescriptions.($rule.BaseName) | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "3.0 Event IDs" {
        It "Rule should have an event ID" {
            $index = 0
            foreach($rule in $rules)
            {
                $index++
                #"`t3.$($index) Rule $($rule.BaseName) should have an event ID: $($Global:EventIDs.$($rule.BaseName))" | Write-Host
                $Global:EventIDs.$($rule.BaseName) | Should -Not -BeNullOrEmpty
            }
        }
    }
}
