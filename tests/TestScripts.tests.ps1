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
# Filename: TestScripts.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 6/17/2019 12:18 PM
#
# Last Modified On: 6/20/2019 10:10 AM
#################################################################################
Set-StrictMode -Version Latest

BeforeDiscovery {
    $sut      = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
    $srcRoot  = "$root\src"
    $testRoot = "$root\tests"

    $srcFiles  = Get-ChildItem -Path $srcRoot -Recurse -Include *.ps? -File `
        | Where-Object {$_.BaseName -notlike 'ID*'} `
        | Where-Object {$_.BaseName -notlike 'PD*'} `
        | Where-Object {$_.BaseName -notlike 'AD*'} `
        | Where-Object {$_.BaseName -notlike 'SD*'} | Sort-Object -Property BaseName

}

Describe -Tag 'Core' "Test Scripts" -ForEach $srcFiles {
    It "Checking to see if test script for $($_.FullName) exists" {
        $testScript = $_.FullName -replace '^(.*)\\src\\(.*?)\\(.*?)\.*.ps1', '$1\tests\$2\$3.tests.ps1'
        $testScript | Should -Exist
    }
}
