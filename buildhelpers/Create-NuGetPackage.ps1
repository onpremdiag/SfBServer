################################################################################
# MIT License
#
# Copyright (c) 2020 Microsoft and Contributors
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
# Filename: Create-NuGetPackage.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/28/2020 1:12 PM
#
# Last Modified On: 2/28/2020 1:12 PM
#################################################################################

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [String] $OutputPath = $PWD,

    [Parameter(Mandatory = $false)]
    [String] $Version
)

try
{
    $nugetVersion = [System.Version]::Parse($Version)
}
catch
{
    "{0} is not a valid version number. Defaulting to 0.0.0.0" -f $Version | Write-Host
    $nugetVersion = "0.0.0.0"
}


if ($null -ne $env:NUGET_VERSION_OVERRIDE)
{
    $nugetVersion = $env:NUGET_VERSION_OVERRIDE
}
elseif ($null -ne $env:BUILD_BUILDNUMBER)
{
    $nugetVersion = $env:BUILD_BUILDNUMBER
}

"NuGet Version: {0}" -f $nugetVersion | Write-Host

if (-not (Test-Path -Path $OutputPath))
{
    New-Item -ItemType:Directory -Path $OutputPath -Force
}

& nuget pack "$PSScriptRoot\PoPCore.nuspec" -OutputDirectory $OutputPath -Properties "Configuration=Release;Version=$($nugetVersion)" -NoPackageAnalysis