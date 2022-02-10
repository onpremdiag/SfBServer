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
# Filename: Update-OPD.ps1
# Description: Download newest version of OPD and replace the existing version
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 6/5/2019 11:50 AM
#
# Last Modified On: 6/5/2019 11:50 AM
#################################################################################
[cmdletbinding()]
param
(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Version] $CurrentVersion,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $InstallationFolder,

    [Parameter(Mandatory = $false)]
    [int32] $ParentPID,

    [Parameter(Mandatory = $false)]
    [String] $Product = "%GITHUBREPO%"
)

New-Variable -Name GitHubUserName `
             -Value "OnPremDiag" `
             -Description "GitHub user name for release repository" `
             -Force

New-Variable -Name GitHubRepository `
             -Value "%GITHUBREPO%" `
             -Description "Repository name for OPD for %GITHUBREPO%" `
             -Force

function Extract-LatestUpdate
{
    param
    (
        [System.IO.FileInfo] $Source
    )

    $destinationFolder = Join-Path -Path $env:Temp -ChildPath ([Guid]::NewGuid())
    $upgradeFolder = $null

    try
    {
        [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
        $archive = $Source.FullName

        "[+] Extracting files..." | Write-Host -ForegroundColor Green

        $archive | Expand-Archive -DestinationPath $destinationFolder

        "[+] File extraction complete" | Write-Host -ForegroundColor Green
    }
    catch
    {
        "[-] Unable to extract files" | Write-Host -ForegroundColor Red
        throw "Unable to extract files"
    }
    finally
    {
        if (Test-Path -Path $destinationFolder)
        {
            $upgradeFolder = Join-Path -Path $destinationFolder `
                                       -ChildPath ([IO.Compression.ZipFile]::OpenRead($archive).Entries)[0].FullName.TrimEnd('/')

            # Unblock the files
            Get-ChildItem -Path $upgradeFolder -Recurse | Unblock-File
        }
    }

    return $upgradeFolder
}

function Get-LatestOPDRelease
{
    param
    (
        [String] $CurrentVersionNumber
    )

    $releaseParams = @{
        Uri    = "https://api.github.com/repos/$GitHubUserName/$GitHubRepository/releases";
        Method = 'GET';
    }

    try
    {
        $releases =  Invoke-RestMethod @releaseParams

        $availableReleases = @()

        foreach($tag in ($releases | ForEach-Object {$_.tag_name}))
        {
            $assets = ($releases | Where-Object {$_.tag_name -eq $tag}).assets
            if ($assets.Length -ne 0)
            {
                $obj = New-Object PSObject
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "Type" -Value $tag.Split('.')[1]
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "Version" -Value ([System.Version]$tag)
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "URL" -Value $assets.browser_download_url
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "CurrentVersion" -Value  ([System.Version]$CurrentVersionNumber)

                $availableReleases += $obj
            }
        }

        $latestRelease = $availableReleases | `
                            Where-Object {$_.Type -eq $CurrentVersionNumber.Split('.')[1]} | `
                            Sort-Object -Property Version -Descending | `
                            Select-Object -First 1

        if ($latestRelease.CurrentVersion -ge $latestRelease.Version)
        {
            $latestRelease = $null
        }
    }
    catch
    {
        $latestRelease = $null
    }

    return $latestRelease
}

function Get-LatestUpdate
{
    param
    (
        [object] $UpdateInfo
    )

    $downloaded  = $null
    $fileName    = $UpdateInfo.Version
    $destination = Join-Path -Path $env:TEMP -ChildPath "$fileName.zip"

    try
    {
        if (Test-Path -Path $destination)
        {
            Remove-Item -Path $destination -Force
        }

        "[+] Downloading latest version of OPD from GitHub..." | Write-Host -ForegroundColor Green

        $startTime = Get-Date

        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($UpdateInfo.URL, $destination)

        "[+] Download complete: {0} seconds" -f $((Get-Date).Subtract($startTime).Seconds) | Write-Host -ForegroundColor Green
    }
    catch
    {
        "[-] Unable to download the latest version of OPD" | Write-Host -ForegroundColor Red
        throw "Unable to download update"
    }
    finally
    {
        if (Test-Path -Path $destination)
        {
            $downloaded = Get-ChildItem -Path $destination
        }
    }

    return $downloaded
}

function Test-UpgradeAvailable
{
    # Let's get the currently running version
    return Get-LatestOPDRelease -CurrentVersionNumber $CurrentVersion
}

#
# Start the upgrade process
#

if ($ParentPID -gt 0)
{
    Stop-Process -Id $ParentPID -Force
}

Set-Location -Path $env:TEMP

$updateInfo        = Get-LatestOPDRelease -CurrentVersionNumber $CurrentVersion
$newVersionArchive = Get-LatestUpdate -UpdateInfo $updateInfo
$newVersionFolder  = Extract-LatestUpdate -Source $newVersionArchive

try
{
    Remove-Item -Path $InstallationFolder -Recurse -Force -ErrorAction SilentlyContinue
    xcopy $newVersionFolder $InstallationFolder /E /I /Q | Out-Null

    Start-Sleep -Seconds 3

    # start new version of OPD (admin) & exit Update-OPD
    $command        = "& Set-Location -Path $InstallationFolder;$InstallationFolder\OPD-Console.ps1 -Mode $Product -CheckForUpdate No"
    $bytes          = [Text.Encoding]::UniCode.GetBytes($command)
    $encodedCommand = [Convert]::ToBase64String($bytes)

    Start-Process "$psHome\PowerShell.exe" -Verb Runas -ArgumentList "-NoExit", ("-EncodedCommand $encodedCommand")

}
catch
{
    "[-] Unable to rename destination folder" | Write-Host -ForegroundColor Red
}
finally
{
    # Cleanup the extracted folder & the zip file
    Remove-Item -Path $newVersionFolder  -Recurse -Force
    Remove-Item -Path $newVersionArchive -Recurse -Force
    Stop-Process -Id $PID
}


