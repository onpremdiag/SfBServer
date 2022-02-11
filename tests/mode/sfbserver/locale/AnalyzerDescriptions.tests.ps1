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
# Filename: AnalyzerDescriptions.tests.ps1
# Description: Checking that all analyzer descriptions have a value and that
# they all begin with 'Verifies...'
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 5/6/2021 12:57 PM
#
# Last Modified On: 5/6/2021 12:57 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
	$sut      = $PSCommandPath -replace '^(.*)\\tests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
	$root     = $PSCommandPath -replace '^(.*)\\tests\\(.*)', '$1'
	$myPath   = $PSCommandPath
	$srcRoot  = "$root\src"
	$testRoot = "$root\tests"
	$testMode = $PSCommandPath -match "^(.*)\\tests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"

	Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

	$global:OPDOptions  = @{
		OriginalCulture  = ([System.Threading.Thread]::CurrentThread.CurrentCulture).Name
	}

	# Load resource files needed for tests
	. (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)
	. (Join-Path -Path $srcRoot  -ChildPath common\Globals.ps1)
	. (Join-Path -Path $srcRoot  -ChildPath common\Utils.ps1)

	Initialize-ResourceString -Root $srcRoot -MyMode 'SfBServer'
}

Describe -Tag 'SfBServer' "AnalyzerDescriptions" {
	Context "Checking for TODO" {
		It "Analyzer Descriptions should not have a TODO marker" {
			foreach($AnalyzerDescription in $global:AnalyzerDescriptions.Keys)
			{
				#"Analyzer Description for $AnalyzerDescription should not be a TODO marker" | Write-Host
				$global:AnalyzerDescriptions.$AnalyzerDescription | Should -Not -Match 'TODO'
			}
		}
	}

	Context "Uniformity" {
		It "Analyzer Description should begin with Verifies..." {
			foreach($AnalyzerDescription in $global:AnalyzerDescriptions.Keys)
			{
				#"Analyzer Description for $AnalyzerDescription should begin with Verifies..." | Write-Host
				$global:AnalyzerDescriptions.$AnalyzerDescription | Should -BeLike "Verifies*"
			}
		}
	}
}