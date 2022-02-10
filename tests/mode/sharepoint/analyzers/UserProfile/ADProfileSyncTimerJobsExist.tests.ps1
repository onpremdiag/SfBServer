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
# Filename: ADProfileSyncTimerJobsExist.tests.ps1
# Description: TODO
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 6/18/2019 3:27 PM
#
# Last Modified On: 6/18/2019 3:27 PM
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

. "$srcRoot\common\Globals.ps1"
. "$srcRoot\common\Utils.ps1"
. "$srcRoot\mode\$mode\common\Globals.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$testRoot\mocks\SharePointMocks.ps1"

$classes   = Get-ChildItem -Path "$srcRoot\classes"              -Recurse -Filter *.ps1
$rules     = Get-ChildItem -Path "$srcRoot\mode\$mode\rules"     -Recurse -Filter RD*.ps1 | Where-Object { $_.FullName -notlike "*\samples\*"}
$insights  = Get-ChildItem -Path "$srcRoot\mode\$mode\insights"  -Recurse -Filter ID*.ps1 | Where-Object { $_.FullName -notlike "*\samples\*"}

foreach ($group in $classes, $insights, $rules)
{
    foreach ($file in $group)
    {
        . $file.FullName
    }
}

. $sut

Describe -Tag 'SharePoint' "ADProfileSyncTimerJobsExist" {
    Context "RDUPSProfSyncJobExists" {
        $true | Should -BeTrue
    }

    Context "RDUPSProfSyncAlertJobExists" {
        $true | Should -BeTrue
    }
}