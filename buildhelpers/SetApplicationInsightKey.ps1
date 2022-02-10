################################################################################
# MIT License
#
# Copyright (c) 2018 Microsoft and Contributors
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
# Filename: SetApplicationInsightKey.ps1
# Description: Helper script to stamp the Application Insight key at build time
# Owner: Mike McIntyre <opd-support@microsoft.com>
# Created On: 3/6/2019 9:17 AM
#
# Last Modified On: 3/6/2019 9:17 AM
#################################################################################

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateSet (
        "Development",
        "Release"
    )]
    [String] $Stage = "Release",

    [Parameter(Mandatory = $false)]
    [String] $SourceDirectory
)

$GUIDRegex = "[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?"

switch ($Stage)
{
    'Development' { $AIGuid = "cdac67b1-7fa6-421d-8b59-1223591836cb" }
    'Release'     { $AIGuid = "0d9bae91-21a0-495c-a92d-2d97ed21bc6c" }
    default       { $AIGuid = [System.Guid]::Empty}
}

# If this script is not running on a build server, remind user to
# set environment variables so that this script can be debugged
if (-not $Env:BUILD_SOURCESDIRECTORY -and ([string]::IsNullOrEmpty($SourceDirectory)))
{
    Write-Error "You must set the following environment variables"
    Write-Error "to test this script interactively."
    Write-Host '$Env:BUILD_SOURCESDIRECTORY - For example, enter something like:'
    Write-Host '$Env:BUILD_SOURCESDIRECTORY = "C:\code\FabrikamTFVC\HelloWorld"'
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
        $SourceDirectory = "{0}\src" -f $env:BUILD_SOURCESDIRECTORY
    }
}

Write-Verbose "BUILD_SOURCESDIRECTORY: $SourceDirectory"

$file = Get-ChildItem -Path (Join-Path $SourceDirectory -ChildPath "common") -Recurse -Include "AI.psm1"

if ($file)
{
    Write-Verbose "Will apply $AIGuid"

    $fileContent = Get-Content -Path $file.FullName
    attrib $file -r
    $fileContent = $fileContent -replace $GUIDRegex, $AIGuid
    $fileContent | Out-File -FilePath $file.FullName
}
else
{
    Write-Warning "No file found"
}
