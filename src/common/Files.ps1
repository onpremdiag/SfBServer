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
# Filename: Files.ps1
# Description: Various file utility functions
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 8/21/2018 4:18 PM
#
# Last Modified On: 8/23/2018 3:55 PM
#################################################################################
Set-StrictMode -Version Latest

Function Import-ScriptConfigFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$ScriptConfigFileLocation
    )

    Write-VerboseWriter("Calling: Import-ScriptConfigFile")
    Write-VerboseWriter("Passed: [string]ScriptConfigFileLocation: '$ScriptConfigFileLocation'")

    if (!(Test-Path $ScriptConfigFileLocation))
    {
        throw [System.Management.Automation.ParameterBindingException] "Failed to provide valid ScriptConfigFileLocation"
    }

    try
    {
        $content = Get-Content $ScriptConfigFileLocation -ErrorAction Stop
        $jsonContent = $content | ConvertFrom-Json
    }
    catch
    {
        throw "Failed to convert ScriptConfigFileLocation from a json type object."
    }

    $jsonContent |
        Get-Member |
        Where-Object { $_.MemberType -ne "Method" } |
        ForEach-Object {
            Write-VerboseWriter("Adding variable $($_.Name)")
            Set-Variable -Name $_.Name -Value ($jsonContent.$($_.Name)) -Scope Script
        }
}

function Get-FileVersions
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet(
            "MD5",
            "SHA1",
            "SHA256",
            "SHA384",
            "SHA512")]
        [String] $CryptoProvider,
        [String] $Filter,
        [Switch] $Recurse
    )

    $data = @()

    if(Test-Path $path)
    {
        $fileList = Get-ChildItem -Path $path -Filter $Filter -Recurse:$Recurse -ErrorAction SilentlyContinue| `
            ForEach-Object {Get-Command $_.FullName -ErrorAction SilentlyContinue}
        $now = "{0:G}" -f (Get-Date)

        foreach($f in $fileList)
        {
            $fileData = "" | Select-Object MachineName,Timestamp,FileName,DirectoryName,FileVersion,`
                CompanyName,IsDebug,Language,Mode,FileSize,`
                CreationTime,CreationTimeUTC,Checksum

            $fileData.MachineName     = $env:computerName
            $fileData.Timestamp       = $now

            if ($null -ne $f.FileVersionInfo.ProductVersion) {$fileData.FileVersion  = $f.FileVersionInfo.ProductVersion.Trim()}
            if ($null -ne $f.FileVersionInfo.CompanyName) {$fileData.CompanyName  = $f.FileVersionInfo.CompanyName.Trim()}
            if ($null -ne $f.FileVersionInfo.Language) {$fileData.Language = $f.FileVersionInfo.Language.Trim()}

            $metaData = Get-ChildItem $f.Path -ErrorAction SilentlyContinue
            $fileData.FileSize        = "{0:N0}" -f $metaData.Length
            $fileData.FileName        = $metaData.PSChildName
            $fileData.Mode            = $metaData.Mode
            $fileData.CreationTime    = $metaData.CreationTime.ToString()
            $fileData.CreationTimeUTC = $metaData.CreationTimeUTC.ToString()
            $fileData.DirectoryName   = $metaData.DirectoryName
            $fileData.IsDebug         = $f.FileVersionInfo.IsDebug

            # If we specified a signature, let's get it now
            if ($null -ne $CryptoProvider)
            {
                $fileData.Checksum = Get-CryptoSignature -File $f.Path -CryptoProvider $CryptoProvider
            }

            $data += $fileData
        }
    }

    return $data
}

function Convert-StringToFileName
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $StringToConvertToFileName
    )

    $result = $StringToConvertToFileName
    $result = $result -replace "\\", "_"
    $result = $result -replace "/", "_"
    $result = $result -replace " ", "_"
    $result = $result -replace "\?", ""
    $result = $result -replace ":", ""
    $result = $result -replace ">", ""
    $result = $result -replace "<", ""
    $result = $result -replace "\(", "_"
    $result = $result -replace "\)", "_"
    $result = $result -replace "\*", ""
    $result = $result -replace "\|", "_"
    $result = $result -replace "{", ""
    $result = $result -replace "}", ""

    return $result
}

