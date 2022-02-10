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
# Filename: Registry.ps1
# Description: Misc functions to interact w/the registry
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 10/21/2021 1:08 PM
#
#################################################################################
Set-StrictMode -Version Latest

# This function is being deprecated. Please use Invoke-RegistryGetValue instead
function Get-RegistryKeyValue
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("HKLM", "HKCU")]
        [string] $Hive,

        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $Key
    )

    if ('HKLM' -eq $Hive)
    {
        $SubKey = "LocalMachine"
    }
    else
    {
        $SubKey = "CurrentUser"
    }

    $keyValue = Invoke-RegistryGetValue -RegistryHive $SubKey -SubKey $Path -GetValue $Key

    return $keyValue
}

# https://github.com/dpaulson45/PublicPowerShellFunctions
Function Invoke-RegistryGetValue
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseOutputTypeCorrectly', '', Justification = 'Multiple output types occur')]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet("ClassesRoot",
                     "CurrentUser",
                     "LocalMachine",
                     "Users",
                     "PerformanceData",
                     "CurrentConfig")]
        [string]$RegistryHive = "LocalMachine",

        [Parameter(Mandatory = $false)]
        [string]$MachineName = $env:COMPUTERNAME,

        [Parameter(Mandatory = $true)]
        [string]$SubKey,

        [Parameter(Mandatory = $false)]
        [string]$GetValue,

        [Parameter(Mandatory = $false)]
        [bool]$ReturnAfterOpenSubKey,

        [Parameter(Mandatory = $false)]
        [object]$DefaultValue,

        [Parameter(Mandatory = $false)]
        [scriptblock]$CatchActionFunction
    )

    Write-VerboseWriter("Calling: Invoke-RegistryGetValue")
    try
    {
        Write-VerboseWriter("Attempting to open the Base Key '{0}' on Server '{1}'" -f $RegistryHive, $MachineName)

        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($RegistryHive, $MachineName)

        Write-VerboseWriter("Attempting to open the Sub Key '{0}'" -f $SubKey)

        $RegKey = $Reg.OpenSubKey($SubKey)

        if ($ReturnAfterOpenSubKey)
        {
            Write-VerboseWriter("Returning OpenSubKey")
            return $RegKey
        }

        Write-VerboseWriter("Attempting to get the value '{0}'" -f $GetValue)
        $returnGetValue = $RegKey.GetValue($GetValue)

        if ($null -eq $returnGetValue -and $null -ne $DefaultValue)
        {
            Write-VerboseWriter("No value found in the registry. Setting to default value: {0}" -f $DefaultValue)
            $returnGetValue = $DefaultValue
        }

        Write-VerboseWriter("Exiting: Invoke-RegistryHandler | Returning: {0}" -f $returnGetValue)
        return $returnGetValue
    }
    catch
    {
        if ($CatchActionFunction -ne $null)
        {
            & $CatchActionFunction
        }

        Write-VerboseWriter("Failed to open the registry for '{0}'" -f $MachineName)
    }
}