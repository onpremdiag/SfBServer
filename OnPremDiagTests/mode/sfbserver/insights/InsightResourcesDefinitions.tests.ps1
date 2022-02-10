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
}

Describe -Tag 'sfbserver' "Check insight resources" {
    BeforeAll {
        $insights  = Get-ChildItem $srcRoot\mode\$mode\insights -Recurse -Filter ID*.ps1 -File | Sort-Object -Property BaseName
    }

    Context "Class names" {
        It "Class name should match internal name" {
            foreach($insight in $insights)
            {
                . $insight.FullName

                $id1 = New-Object -TypeName $insight.BaseName -ArgumentList $null
                $id2 = New-Object -TypeName $insight.BaseName -ArgumentList "WARNING"

                $insight.BaseName | Should -BeExactly $id1.GetType().Name
                $insight.BaseName | Should -BeExactly $id2.GetType().Name
            }
        }
    }

    Context "Constructor names" {
        It "Class name should not be null or empty" {
            foreach($insight in $insights)
            {
                . $insight.FullName

                $id1 = New-Object -TypeName $insight.BaseName -ArgumentList $null
                $id2 = New-Object -TypeName $insight.BaseName -ArgumentList "WARNING"

                $id1.Name | Should -Not -BeNullOrEmpty
                $id2.Name | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context "Constructors should be in sync" {
        It "Constructors should be in sync" {
            foreach($insight in $insights)
            {
                . $insight.FullName

                $id1 = New-Object -TypeName $insight.BaseName -ArgumentList $null
                $id2 = New-Object -TypeName $insight.BaseName -ArgumentList "WARNING"

                $id1 | Should -Not -BeNullOrEmpty
                $id2 | Should -Not -BeNullOrEmpty

                $id1.Name      | Should -BeExactly $id2.Name
                $id1.Action    | Should -BeExactly $id2.Action
                $id1.Detection | Should -BeExactly $id2.Detection
                $id1.Id        | Should -BeExactly $id2.Id
            }
        }
    }

    Context "Resources" {
        It "Insight should have a resource in InsightDetections" {
            foreach($insight in $insights)
            {
                $global:InsightDetections.($insight.BaseName) | Should -Not -BeNullOrEmpty
            }
        }

        It "Insight should have a resource in InsightActions" {
            foreach($insight in $insights)
            {
                $global:InsightActions.($insight.BaseName) | Should -Not -BeNullOrEmpty
            }
        }
    }
}
