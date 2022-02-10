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
# Filename: build_utils.ps1
# Description: Helper/utility functions to be used by the build script
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/7/2018 4:52 PM
#
# Last Modified On: 9/7/2018 4:52 PM
#################################################################################
Set-StrictMode -Version Latest

# Allows us to run a script within a specific locale
# For example, Using-Culture -Culture fr-fr {script block} will cause an locale
# specific properties to be used for the French language. The default is fall back
# en-US (English-United States)
#
function Using-Culture
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Globalization.CultureInfo] $Culture,

        [Parameter(Mandatory = $true)]
        [ScriptBlock] $ScriptBlock
    )

    $OldCulture   = [System.Threading.Thread]::CurrentThread.CurrentCulture
    $OldUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture

    try
    {
        [System.Threading.Thread]::CurrentThread.CurrentCulture   = $Culture
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $Culture
        Invoke-Command $ScriptBlock
    }
    finally
    {
        [System.Threading.Thread]::CurrentThread.CurrentCulture   = $OldCulture
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $OldUICulture
    }
}

function Install-BuildModule
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Version] $Version
    )

    $matchingVersion = [System.Version]::new("0.0.0")
    $modules         = Get-Module -Name $Name -ListAvailable -ErrorAction SilentlyContinue
    $loadModule      = $true

    foreach ($module in $modules)
    {
        if ($module.Version.CompareTo($Version) -eq 0)
        {
            $loadModule      = $false
            $matchingVersion = $module.Version
            break
        }
        else
        {
            $loadModule = $true
        }
    }

    # Do we need to load the module?
    if ($true -eq $loadModule)
    {
        try
        {
            'Installing {0} {1}' -f $Name, $Version.ToString() | Write-Output
            Install-Module -Name $Name `
                -RequiredVersion $Version.ToString() `
                -Scope CurrentUser `
                -SkipPublisherCheck `
                -Force

            $modules = Get-Module -Name $Name -ListAvailable -ErrorAction SilentlyContinue
            foreach ($module in $modules)
            {
                '{0} {1} installed successfully' -f $module.Name, $module.Version.ToString() | Write-Output
            }
        }
        catch
        {
            $repos = Get-PSRepository
            foreach ($repo in $repos)
            {
                "           Name: {0}" -f $repo.Name           | Write-Error
                "        Trusted: {0}" -f $repo.Trusted        | Write-Error
                "Source Location: {0}" -f $repo.SourceLocation | Write-Error
            }

            "Unable to install {0} {1}" -f $Name, $_ | Write-Error
        }
    }
    else
    {
        'Detected {0} {1} already installed' -f $Name, $matchingVersion.ToString() | Write-Output
    }
}