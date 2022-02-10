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
# Filename: Invoke-TestCases.ps1
# Description: Run Pester test cases for a specific language (or all languages)
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 5/1/2019 12:19 PM
#
# Last Modified On: 5/1/2019 12:19 PM
#################################################################################
[cmdletbinding()]
param
(
    [Parameter(Mandatory = $false)]
    [string[]] $Languages = "English",

    [Parameter(Mandatory = $false)]
    [string] $Product,

    [Parameter(Mandatory = $false)]
    [string] $SourceDirectory = $pwd
)

Set-StrictMode -Version Latest

# Load helper functions for the build process
. "$SourceDirectory\buildhelpers\build_utils.ps1"

 # Let's install Pester (if not already there)
Install-BuildModule -Name Pester -Version "5.3.1"

$Locales = @{"English"="en-us";"French"="fr-fr";"German"="de-de"}

foreach ($language in $Languages)
{
    Write-Host "Running tests for $language" -ForegroundColor Yellow -BackgroundColor Black
    $locale = $Locales.$language

    if ([string]::IsNullOrEmpty($Product))
    {
        $testResults = Using-Culture -Culture $locale `
            -ScriptBlock { `
                Invoke-Pester -Path $SourceDirectory\tests `
                -OutputFile $SourceDirectory\Test-Pester.$locale.XML `
                -OutputFormat NUnitXml `
                -PassThru
            }
    }
    else
    {
        $testResults = Using-Culture -Culture $locale `
            -ScriptBlock { `
                Invoke-Pester -Path $SourceDirectory\tests `
                -Tag 'Core', $Product `
                -OutputFile $SourceDirectory\Test-Pester.$locale.XML `
                -OutputFormat NUnitXml `
                -PassThru
        }
    }

    # A summary would be nice :-)
    $testResults.TestResult | `
        Group-Object -Property Result | `
        Format-Table -Property Name, Count

    # Show all passing tests
    Write-Host "Successful Pester tests" -ForegroundColor Green -BackgroundColor Black
    $testResults.TestResult | `
        Where-Object {$_.Result -eq 'Passed'} | `
        Sort-Object -Property Name | `
        Format-Table -Property Name, Result

    # Do we have any pending/inconclusive test results? If so, let's show them and issue a warning
    if ($testResults.PendingCount -gt -0)
    {
        Write-Host "##vso[task.logissue type=error;] Inconclusive Pester tests. Please modify and re-submit" `
            -ForegroundColor Yellow -BackgroundColor Black

        $testResults.TestResult | `
            Where-Object {$_.Result -eq 'Pending'} | `
            Sort-Object -Property Name | `
            Format-Table -Property Name, Result

        Write-Host "##vso[task.complete result=Failed;] Build failed" `
            -ForegroundColor Yellow -BackgroundColor Black
    }

    # If we have any failures, let's show them
    if ($testResults.FailedCount -gt 0)
    {
        Write-Host "##vso[task.logissue type=error;] Failing Pester tests" `
            -ForegroundColor Red -BackgroundColor Black

        $testResults.TestResult | Where-Object {$_.Result -eq 'Failed'} | `
            Sort-Object -Property Name | `
            Format-Table -Wrap -Property Name, StackTrace

        Write-Host "##vso[task.complete result=Failed;] Build failed" -ForegroundColor Red -BackgroundColor Black
    }

    # Any warning/failures, bail
    if ($testResults.FailedCount -gt 0 -or $testResults.PendingCount -gt 0)
    {
        break
    }
}
