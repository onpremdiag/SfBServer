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
# Filename: StampOwners.ps1
# Description: Stamps the console with the build version
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 04/03/2019 1:39 PM
#################################################################################

# Enable -Verbose option
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [String] $OwnerName,

    [Parameter(Mandatory = $true)]
    [String] $OwnerEmail,

    [Parameter(Mandatory = $false)]
    [string] $Product
)

# Regular expression pattern to find the version in the build number
# and then apply it to the assemblies
$OwnerRegex = "^\#\s+Owner.*:\s+(?<Owner>.*)$"

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
Write-Verbose "BUILD_SOURCESDIRECTORY: $Env:BUILD_SOURCESDIRECTORY"

# Apply correct ownership to all of the files
# Let's grab the core files first
$files  = Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY\src\classes -Recurse -Include *.ps*
$files += Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY\src\common -Recurse -Include *.ps*
$files += Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY\src\locale -Recurse -Include *.ps*
$files += Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY\src -File

if ([string]::IsNullOrEmpty($Product))
{
    $files += Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY\src\mode -Recurse -Include *.ps*
}
else
{
    $files += Get-ChildItem -Path $Env:BUILD_SOURCESDIRECTORY\src\mode\$Product -Recurse -Include *.ps*
}

if ($files)
{
    Write-Host "Will apply $OwnerName <$OwnerEmail> to $($files.Count) files."

    $newOwner = "# Owner: $OwnerName <$OwnerEmail>"
    $i = 0

    foreach ($file in $files)
    {
        $i++
        $fileContent = Get-Content -Path $file.FullName
        $file.IsReadOnly = $false
        $fileContent = $fileContent -replace $OwnerRegex, $newOwner
        $fileContent | Out-File -FilePath $file.FullName
        "{0:000} : Ownership set on {1}" -f $i, $file.FullName | Write-Host
    }
}
else
{
    Write-Warning "Found no files"
}
