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
# Filename: Set-ProductMode.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/5/2019 4:37 PM
#
# Last Modified On: 5/3/2019 12:59 PM
#################################################################################
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [String] $Product,

    [Parameter(Mandatory = $false)]
    [String] $SourceDirectory
)

# Regular expression pattern to find the Product mode
# and then apply it for this ruleset/mode
$ProductRegex = "\%MODE\%" #"^\s+Initialize-Mode\s+-Product\s+""\w+"".*$"

# If this script is not running on a build server, remind user to
# set environment variables so that this script can be debugged
if (-not ($Env:BUILD_SOURCESDIRECTORY -and $Env:BUILD_BUILDNUMBER))
{
    Write-Error "You must set the following environment variables"
    Write-Error "to test this script interactively."
    Write-Host '$Env:BUILD_SOURCESDIRECTORY - For example, enter something like:'
    Write-Host '$Env:BUILD_SOURCESDIRECTORY = "C:\code\FabrikamTFVC\HelloWorld"'
    Write-Host '$Env:BUILD_BUILDNUMBER - For example, enter something like:'
    Write-Host '$Env:BUILD_BUILDNUMBER = "Build HelloWorld_0000.00.00.0"'
    exit 1
}

if ([string]::IsNullOrEmpty($SourceDirectory) -or (-not (Test-Path -Path $SourceDirectory)))
{
    # Make sure path to source code directory is available
    if (-not $Env:BUILD_SOURCESDIRECTORY)
    {
        Write-Error ("BUILD_SOURCESDIRECTORY environment variable is missing.")
        exit 1
    }
    elseif (-not (Test-Path $Env:BUILD_SOURCESDIRECTORY))
    {
        Write-Error "BUILD_SOURCESDIRECTORY does not exist: $Env:BUILD_SOURCESDIRECTORY"
        exit 1
    }
    else
    {
        $SourceDirectory = "{0}" -f $env:BUILD_SOURCESDIRECTORY
    }
}

Write-Verbose "Source directory: $SourceDirectory"

# Apply correct product rule set to main console
$files = Get-ChildItem -Path $SourceDirectory -Recurse -Include "OPD-Console.ps1"

if ($files)
{
    foreach ($file in $files)
    {
        $fileContent = Get-Content -Path $file.FullName
        attrib $file -r
        $fileContent = $fileContent -replace $ProductRegex, $Product
        $fileContent | Out-File -FilePath $file.FullName
        Write-Host "$($file.FullName) - Product Mode, $($Product), applied"
    }
}
else
{
    Write-Warning "No file found"
}
