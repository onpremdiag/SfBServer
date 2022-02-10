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
# Filename: Invoke-ScriptAnalyzer.ps1
# Description: Run PSScriptAnalyzer on the source code
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 5/1/2019 12:42 PM
#
# Last Modified On: 5/1/2019 12:42 PM
#################################################################################
[cmdletbinding()]
param
(
    [Parameter(Mandatory = $false)]
    [string] $Product,

    [Parameter(Mandatory = $false)]
    [string] $SourceDirectory = $pwd
)

# Load helper functions for the build process
. "$SourceDirectory\buildhelpers\build_utils.ps1"

 # Let's install Script Analyzer (if not already there)
#Install-BuildModule -Name PSScriptAnalyzer -Version "1.18.3"
Install-BuildModule -Name PSScriptAnalyzer -Version "1.19.1"

$saResults = Invoke-ScriptAnalyzer -Path "$SourceDirectory\src\classes" `
    -Profile "$($SourceDirectory)\buildhelpers\PSScriptAnalyzerSettings.psd1" `
    -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}

$saResults += Invoke-ScriptAnalyzer -Path "$SourceDirectory\src\common" `
    -Profile "$($SourceDirectory)\buildhelpers\PSScriptAnalyzerSettings.psd1" `
    -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}

$saResults += Invoke-ScriptAnalyzer -Path "$SourceDirectory\src\OPD-console.ps1" `
    -Profile "$($SourceDirectory)\buildhelpers\PSScriptAnalyzerSettings.psd1" `
    -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}

if ([string]::IsNullOrEmpty($Product))
{
    $saResults += Invoke-ScriptAnalyzer -Path "$SourceDirectory\src\mode" `
    -Profile "$($SourceDirectory)\buildhelpers\PSScriptAnalyzerSettings.psd1" `
    -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}
}
else
{
    $saResults += Invoke-ScriptAnalyzer -Path "$SourceDirectory\src\mode\$Product" `
        -Profile "$($SourceDirectory)\buildhelpers\PSScriptAnalyzerSettings.psd1" `
        -Recurse | Where-Object {$_.RuleName -ne 'TypeNotFound'}
}

if ($saResults)
{
    Write-Host "##vso[task.logissue type=error;]One or more Script Analyzer errors/warnings where found. Build cannot continue" `
        -ForegroundColor Red -BackgroundColor Black

    $saResults | `
        Sort-Object -Property @{Expression="ScriptName"}, @{Expression="Severity"}, @{Expression="RuleName"} | `
        Format-Table

    $saResults | Out-File -FilePath "$SourceDirectory\PSSA-output.txt" -Force -Encoding utf8
    Write-Host "##vso[task.complete result=Failed;] Build failed" -ForegroundColor Red -BackgroundColor Black
}
else
{
    "{0}: No PSScriptAnalyzer warnings" -f (Get-Date -Format o) | Out-file -FilePath "$SourceDirectory\PSSA-output.txt" -Force -Encoding utf8
}