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
# Filename: ADCompareOnPremToOnline.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/21/2020 1:34 PM
#
# Last Modified On: 1/21/2020 1:34 PM
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\tests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

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

. (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
. (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
. (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\SfbServerMock.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\ActiveDirectoryMocks.ps1)
. (Join-Path -Path $testRoot -ChildPath mocks\LyncOnlineConnectorMocks.ps1)

. $sut

Describe -Tag 'SfBServer' "ADCompareOnPremToOnline" {
    BeforeAll {
        Mock Write-OPDEventLog {}
    }

    BeforeEach {
        Mock Initialize-Module { return $true }
        $analyzer = [ADCompareOnPremToOnline]::new()
    }

    Context "Exception Handling" {
        It "TODO" {
            $true | Should -BeTrue
        }
    }
}