################################################################################
# MIT License
#
# Copyright (c) 2019 Microsoft and Contributors
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
# Filename: build.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 5/3/2019 1:34 PM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
[cmdletbinding()]
param (
    [string] $SourceDirectory = $pwd,

    [Parameter(Mandatory = $true)]
    [string] $Product,

    [Parameter(Mandatory = $false)]
    [string[]] $Languages = 'English'
)

Set-StrictMode -Version Latest

# Load helper functions for the build process
. "$SourceDirectory\buildhelpers\build_utils.ps1"

#
# Let's start the pipeline...
#

# Step 1 - Run script analyzer (Lint) against the code
. "$SourceDirectory\buildhelpers\Invoke-ScriptAnalyzer.ps1" -Product $Product -SourceDirectory $SourceDirectory

# Step 2 - Run test cases for product and core
. "$SourceDirectory\buildhelpers\Invoke-TestCases.ps1" -Product $Product -SourceDirectory $SourceDirectory -Languages $Languages

# Step 3 - Generate BI tables for reporting
. "$SourceDirectory\buildhelpers\GenerateBITables.ps1" -Product $Product -SourceDirectory $SourceDirectory

