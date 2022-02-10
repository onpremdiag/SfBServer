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
# Filename: ApplyVersionToConsole.ps1
# Description: Stamps the console with the build version
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/21/2018 11:38 AM
#
# Last Modified On: 9/21/2018 11:39 AM
#################################################################################

# Enable -Verbose option
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet(
        "Development",
        "Testing",
        "Release"
    )]
    [String] $Stage = "Development",

    [Parameter(Mandatory = $false)]
    [System.Version] $Version,

    [Parameter(Mandatory = $false)]
    [String] $SourceDirectory
)

# Regular expression pattern to find the version in the build number
# and then apply it to the assemblies
#$VersionRegex = "(?<Major>\d+)\.(?<Minor>\d+)\.(?<Build>\d+)\.(?<Revision>\d+)"
$VersionRegex = '^\s+-Value\s+\"(?<Major>\d+)\.(?<Minor>\d+)\.(?<Build>\d+)\.(?<Revision>.*)\"'

# If this script is not running on a build server, remind user to
# set environment variables so that this script can be debugged
if(-not ($Env:BUILD_SOURCESDIRECTORY -and $Env:BUILD_BUILDNUMBER) `
   -and ([string]::IsNullOrEmpty($SourceDirectory) -and [string]::IsNullOrEmpty($Version)))
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
        $SourceDirectory = "{0}\src" -f $env:BUILD_SOURCESDIRECTORY
    }
}

Write-Verbose "BUILD_SOURCESDIRECTORY: $SourceDirectory"

if ([string]::IsNullOrEmpty($Version))
{
    # Make sure there is a build number
    if (-not $Env:BUILD_BUILDNUMBER)
    {
        Write-Error ("BUILD_BUILDNUMBER environment variable is missing.")
        exit 1
    }
    else
    {
        $VersionData = [regex]::matches($Env:BUILD_BUILDNUMBER,"(?<Major>\d+)\.(?<Minor>\d+)\.(?<Build>\d+)\.(?<Revision>.*)")
        $NewVersion = ' -Value "{0}"' -f $VersionData[0].Value
    }
}
else
{
    $NewVersion = ' -Value "{0}"' -f $Version.ToString()
}

Write-Verbose "Version: $NewVersion"

# Get and validate the version data
switch($NewVersion.Count)
{
    0
    {
        Write-Error "Could not find version number data in BUILD_BUILDNUMBER."
        exit 1
    }
    1
    {}
    default
    {
        Write-Warning "Found more than instance of version data in BUILD_BUILDNUMBER."
        Write-Warning "Will assume first instance is version."
    }
}


# Apply the version to the diagnostic driver
$files = Get-ChildItem -Path (Join-Path -Path $SourceDirectory -ChildPath "common") -Recurse -Include "Globals.ps1"

if ($files)
{
    Write-Host "Will apply $NewVersion to $($files.Count) files."

    foreach ($file in $files)
    {
        $fileContent = Get-Content -Path $file.FullName
        attrib $file -r
        $fileContent = $fileContent -replace $VersionRegex, $NewVersion
        $fileContent | Out-File -FilePath $file.FullName
        Write-Host "$($file.FullName) - version applied"
    }
}
else
{
    Write-Host "Found no files"
}
