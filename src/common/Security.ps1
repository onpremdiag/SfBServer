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
# Filename: Security.ps1
# Description: Security/crypto related functions
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 10/20/2021 9:50 AM
#
#################################################################################
Set-StrictMode -Version Latest

function Get-CurrentUserName
{
    return [Security.Principal.WindowsIdentity]::GetCurrent().Name
}

function Test-IsLocalAdministrator
{
    $IsLocalAdmin = $false

    try
    {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    }
    finally
    {
        if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
        {
            $IsLocalAdmin = $true
        }
    }

    return $IsLocalAdmin
}

function Get-StringHash
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $String,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            "MD5",
            "SHA1",
            "SHA256",
            "SHA384",
            "SHA512")]
        [String] $CryptoProvider
    )

    $sb = New-Object System.Text.StringBuilder
    [System.Security.Cryptography.HashAlgorithm]::Create($CryptoProvider).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | `
        ForEach-Object {[void]$sb.Append($_.ToString("x2"))}

    $sb.ToString()
}

function Compare-SecureString
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Security.SecureString] $ReferenceObject,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Security.SecureString] $DifferenceObject
    )

    try
    {
        $bstr1   = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($ReferenceObject)
        $bstr2   = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($DifferenceObject)
        $length1 = [Runtime.InteropServices.Marshal]::ReadInt32($bstr1, -4)
        $length2 = [Runtime.InteropServices.Marshal]::ReadInt32($bstr2, -4)

        if ( $length1 -ne $length2 )
        {
            return $false
        }

        for ( $i = 0; $i -lt $length1; ++$i )
        {
            $b1 = [Runtime.InteropServices.Marshal]::ReadByte($bstr1, $i)
            $b2 = [Runtime.InteropServices.Marshal]::ReadByte($bstr2, $i)
            if ( $b1 -ne $b2 )
            {
                return $false
            }
        }
        return $true
    }
    finally
    {
        if ( $bstr1 -ne [IntPtr]::Zero )
        {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
        }
        if ( $bstr2 -ne [IntPtr]::Zero )
        {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)
        }
    }
}

# Get-CryptoSignature function
#---------------------------------
# Description:
#  Generates a cryptographic of the requested file. This is useful
#  in comparing files to ensure that they are identical
#
# Arguments:
#   file: file to generate signature
#   CryptoProvider:
#     MD5
#     SHA1
#     SHA256
#     SHA384
#     SHA512
#
# Example:
#   Get-CryptoSignature -file c:\windows\system32\ping.exe
#   Returns: 41C4E1E9ABE08B218F5EA60D8AE41A5F523E7534
#
function Get-CryptoSignature
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo] $File ,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            "MD5",
            "SHA1",
            "SHA256",
            "SHA384",
            "SHA512")]
        [String] $CryptoProvider
    )

    switch($CryptoProvider)
    {
        "MD5"        { $cryptoServiceProvider = [System.Security.Cryptography.MD5CryptoServiceProvider] }
        "SHA1"       { $cryptoServiceProvider = [System.Security.Cryptography.SHA1CryptoServiceProvider] }
        "SHA256"     { $cryptoServiceProvider = [System.Security.Cryptography.SHA256CryptoServiceProvider] }
        "SHA384"     { $cryptoServiceProvider = [System.Security.Cryptography.SHA384CryptoServiceProvider] }
        "SHA512"     { $cryptoServiceProvider = [System.Security.Cryptography.SHA512CryptoServiceProvider] }
        Default      { $cryptoServiceProvider = [System.Security.Cryptography.SHA1CryptoServiceProvider] }
    }

    $stream        = $null;
    $hashAlgorithm = New-Object $cryptoServiceProvider
    $stream        = $file.OpenRead();

    $hashStringBuilder = New-Object System.Text.StringBuilder
    $hashAlgorithm.ComputeHash($stream) | ForEach-Object { [void] $hashStringBuilder.Append($_.ToString("X2")) }
    $stream.Close();

    ## We have to be sure that we close the file stream if any exceptions are thrown.
    trap
    {
        if ($null -ne $stream)
        {
            $stream.Close();
        }
        break
    }

    return $hashStringBuilder.ToString()
}

function Protect-String
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $String,

        [Parameter(Mandatory = $true)]
        [String] $Passphrase,

        [Parameter(Mandatory = $false)]
        [String] $Salt = (Get-Date).ToString(),

        [Parameter(Mandatory = $false)]
        [String] $Init = "Yet another key",

        [Switch] $ArrayOutput
    )

    $r = New-Object System.Security.Cryptography.RijndaelManaged
    $pass = [Text.Encoding]::UTF8.GetBytes($Passphrase)
    $nacl = [Text.Encoding]::UTF8.GetBytes($Salt)

    $r.Key = (New-Object Security.Cryptography.PasswordDeriveBytes $pass, $nacl, "SHA1", 5).GetBytes(32) # 256/8
    $r.IV = (New-Object Security.Cryptography.SHA1Managed).ComputeHash([Text.Encoding]::UTF8.GetBytes($Init) )[0..15]

    $c = $r.CreateEncryptor()
    $ms = new-Object IO.MemoryStream
    $cs = new-Object Security.Cryptography.CryptoStream $ms,$c,"Write"
    $sw = new-Object IO.StreamWriter $cs
    $sw.Write($String)
    $sw.Close()
    $cs.Close()
    $ms.Close()
    $r.Clear()

    [byte[]] $result = $ms.ToArray()

    if ($ArrayOutput)
    {
        return $result
    }
    else
    {
        return [Convert]::ToBase64String($result)
    }
}

#region Get-AllTlsSettingsFromRegistry
Function Get-AllTlsSettingsFromRegistry
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Just creating internal objects')]
    [OutputType("System.Collections.Hashtable")]
    param
    (
        [Parameter(Mandatory = $false)][string]$MachineName = $env:COMPUTERNAME,
        [Parameter(Mandatory = $false)][scriptblock]$CatchActionFunction
    )

    Write-VerboseWriter("Calling: Get-AllTlsSettingsFromRegistry")
    Write-VerboseWriter("Passed: [string]MachineName: {0}" -f $MachineName)

#region Constants
    $tlsRegistryBase    = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS {0}\{1}"
    $sslRegistryBase    = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL {0}\{1}"
    $pctRegistryBase    = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT {0}\{1}"
    $mpuhRegistryBase   = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\Multi-Protocol Unified Hello\{0}"
    $cipherRegsitryBase = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\{0}"
    $hashesRegistryBase = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\{0}"
    $keaRegistryBase    = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\{0}"

    $tlsVersions  = @("1.0", "1.1", "1.2")
    $sslVersions  = @("2.0","3.0")
    $pctVersions  = @("1.0")
    $keyValues    = ("Enabled", "DisabledByDefault")
    $cipherValues = @("AES 128/128","AES 256/256","DES 56/56","NULL","RC2 128/128","RC2 40/128","RC2 56/128","RC2 56/56")
    $cipherValues += @("RC4 128/128","RC4 40/128","RC4 56/128","RC4 64/128","Triple DES 168")
    $hashesValues = @("MD5","SHA","SHA256","SHA384","SHA512")
    $keaValues    = @("Diffie-Hellman","ECDH", "PKCS")
#endregion

    [HashTable]$allTlsObjects = @{}

#region Helper Functions

    function Get-HashesMemberValue
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$GetKeyType,

            [Parameter(Mandatory = $false)]
            [object]$KeyValue,

            [Parameter(Mandatory = $true)]
            [string]$HashVersion
        )

        # https://docs.microsoft.com/troubleshoot/windows-server/windows-security/restrict-cryptographic-algorithms-protocols-schannel
        switch ($GetKeyType)
        {
            "Enabled"
            {
                if (($null -eq $KeyValue) -or (-1 -eq $KeyValue))
                {
                    Write-VerboseWriter("Using default value of the OS for {0}" -f $HashVersion)
                    return "O/S Default"
                }
                else
                {
                    if (1 -eq $KeyValue)
                    {
                        return $true
                    }
                    else
                    {
                        return $false
                    }
                }
            }

            Default
            {
                return $false
            }
        }
    }

    function Get-KEAMemberValue
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$GetKeyType,

            [Parameter(Mandatory = $false)]
            [object]$KeyValue,

            [Parameter(Mandatory = $true)]
            [string]$KEAVersion
        )

        # https://docs.microsoft.com/troubleshoot/windows-server/windows-security/restrict-cryptographic-algorithms-protocols-schannel
        switch ($GetKeyType)
        {
            "Enabled"
            {
                if (($null -eq $KeyValue) -or (-1 -eq $KeyValue))
                {
                    Write-VerboseWriter("Using default value of the OS for {0}" -f $KEAVersion)
                    return "O/S Default"
                }
                else
                {
                    if (1 -eq $KeyValue)
                    {
                        return $true
                    }
                    else
                    {
                        return $false
                    }
                }
            }

            Default
            {
                return $false
            }
        }
    }

    function Get-CiphersMemberValue
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$GetKeyType,

            [Parameter(Mandatory = $false)]
            [object]$KeyValue,

            [Parameter(Mandatory = $true)]
            [string]$CipherVersion
        )

        # https://docs.microsoft.com/troubleshoot/windows-server/windows-security/restrict-cryptographic-algorithms-protocols-schannel
        switch ($GetKeyType)
        {
            "Enabled"
            {
                if (($null -eq $KeyValue) -or (-1 -eq $KeyValue))
                {
                    Write-VerboseWriter("Using default value of the OS for {0}" -f $CipherVersion)
                    return "O/S Default"
                }
                else
                {
                    if (1 -eq $KeyValue)
                    {
                        return $true
                    }
                    else
                    {
                        return $false
                    }
                }
            }

            Default
            {
                return $false
            }
        }
    }

    function Get-MPUHMemberValue
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$GetKeyType,

            [Parameter(Mandatory = $false)]
            [object]$KeyValue,

            [Parameter(Mandatory = $true)]
            [string]$ServerClientType
        )

        switch ($GetKeyType)
        {
            "Enabled"
            {
                if ($null -eq $KeyValue)
                {
                    Write-VerboseWriter("Failed to get Multi-Protocol Unified Hello {0} Enabled Key on Server {1}. We are assuming this means it is not enabled." -f `
                        $ServerClientType, `
                        $MachineName)
                    return [String]::Empty
                }
                else
                {
                    Write-VerboseWriter("{0} Enabled Value '{1}'" -f $ServerClientType, $KeyValue)
                    if ($KeyValue -eq 1)
                    {
                        return $true
                    }
                    return $false
                }
            }
            "DisabledByDefault"
            {
                if ($null -eq $KeyValue)
                {
                    Write-VerboseWriter("Failed to get Multi-Protocol Unified Hello {0} Enabled Key on Server {1}. Setting to empty." -f `
                            $ServerClientType, `
                            $MachineName)
                    return [String]::Empty
                }
                else
                {
                    Write-VerboseWriter("{0} Disabled By Default Value '{1}'" -f $ServerClientType, $KeyValue)
                    if ($KeyValue -eq 1)
                    {
                        return $true
                    }
                    return $false
                }
            }
        }
    }

    function Get-SSLMemberValue
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$GetKeyType,

            [Parameter(Mandatory = $false)]
            [object]$KeyValue,

            [Parameter(Mandatory = $true)]
            [string]$ServerClientType,

            [Parameter(Mandatory = $true)]
            [string]$SSLVersion
        )

        switch ($GetKeyType)
        {
            "Enabled"
            {
                if ($null -eq $KeyValue)
                {
                    Write-VerboseWriter("Failed to get SSL {0} {1} Enabled Key on Server {2}. We are assuming this means it is not enabled." -f $SSLVersion, `
                            $ServerClientType, `
                            $MachineName)
                    return [String]::Empty
                }
                else
                {
                    Write-VerboseWriter("{0} Enabled Value '{1}'" -f $ServerClientType, $KeyValue)
                    if ($KeyValue -eq 1)
                    {
                        return $true
                    }
                    return $false
                }
            }
            "DisabledByDefault"
            {
                if ($null -eq $KeyValue)
                {
                    Write-VerboseWriter("Failed to get SSL {0} {1} Disabled By Default Key on Server {2}. Setting to true." -f $SSLVersion, `
                            $ServerClientType, `
                            $MachineName)
                    return [String]::Empty
                }
                else
                {
                    Write-VerboseWriter("{0} Disabled By Default Value '{1}'" -f $ServerClientType, $KeyValue)
                    if ($KeyValue -eq 1)
                    {
                        return $true
                    }
                    return $false
                }
            }
        }
    }

    function Get-PCTMemberValue
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$GetKeyType,

            [Parameter(Mandatory = $false)]
            [object]$KeyValue,

            [Parameter(Mandatory = $true)]
            [string]$ServerClientType,

            [Parameter(Mandatory = $true)]
            [string]$PCTVersion
        )

        switch ($GetKeyType)
        {
            "Enabled"
            {
                if ($null -eq $KeyValue)
                {
                    Write-VerboseWriter("Failed to get PCT {0} {1} Enabled Key on Server {2}. We are assuming this means it is not enabled." -f $PCTVersion, `
                            $ServerClientType, `
                            $MachineName)
                    return [String]::Empty
                }
                else
                {
                    Write-VerboseWriter("{0} Enabled Value '{1}'" -f $ServerClientType, $KeyValue)
                    if ($KeyValue -eq 1)
                    {
                        return $true
                    }
                    return $false
                }
            }
            "DisabledByDefault"
            {
                if ($null -eq $KeyValue)
                {
                    Write-VerboseWriter("Failed to get PCT {0} {1} Disabled By Default Key on Server {2}. Setting to true." -f $PCTVersion, `
                            $ServerClientType, `
                            $MachineName)
                    return [String]::Empty
                }
                else
                {
                    Write-VerboseWriter("{0} Disabled By Default Value '{1}'" -f $ServerClientType, $KeyValue)
                    if ($KeyValue -eq 1)
                    {
                        return $true
                    }
                    return $false
                }
            }
        }
    }

    Function Get-TLSMemberValue
    {
        param
        (
            [Parameter(Mandatory = $true)]
            [string]$GetKeyType,

            [Parameter(Mandatory = $false)]
            [object]$KeyValue,

            [Parameter(Mandatory = $true)]
            [string]$ServerClientType,

            [Parameter(Mandatory = $true)]
            [string]$TlsVersion
        )

        switch ($GetKeyType)
        {
            "Enabled"
            {
                if ($null -eq $KeyValue)
                {
                    Write-VerboseWriter("Failed to get TLS {0} {1} Enabled Key on Server {2}. We are assuming this means it is enabled." -f $TlsVersion, `
                            $ServerClientType, `
                            $MachineName)
                    return [String]::Empty
                }
                else
                {
                    Write-VerboseWriter("{0} Enabled Value '{1}'" -f $ServerClientType, $KeyValue)
                    if ($KeyValue -eq 1)
                    {
                        return $true
                    }

                    return $false
                }
            }
            "DisabledByDefault"
            {
                if ($null -eq $KeyValue)
                {
                    Write-VerboseWriter("Failed to get TLS {0} {1} Disabled By Default Key on Server {2}. Setting to false." -f $TlsVersion, `
                            $ServerClientType, `
                            $MachineName)
                    return [String]::Empty
                }
                else
                {
                    Write-VerboseWriter("{0} Disabled By Default Value '{1}'" -f $ServerClientType, $KeyValue)
                    if ($KeyValue -eq 1)
                    {
                        return $true
                    }
                    return $false
                }
            }
        }
    }

    Function Get-NETDefaultTLSValue
    {
        param
        (
            [Parameter(Mandatory = $false)]
            [object]$KeyValue,

            [Parameter(Mandatory = $true)]
            [string]$NetVersion,

            [Parameter(Mandatory = $true)]
            [string]$KeyName
        )

        if ($null -eq $KeyValue)
        {
            Write-VerboseWriter("Failed to get {0} registry value for .NET {1} version. Setting to false." -f $KeyName, $NetVersion)
            return $false
        }
        else
        {
            Write-VerboseWriter("{0} value '{1}'" -f $KeyName, $KeyValue)
            if ($KeyValue -eq 1)
            {
                return $true
            }
            return $false
        }
    }
#endregion

<#
#region Multi-Protocol Unified Hello
    $allMPUHObjects = @()
    $registryServer = $mpuhRegistryBase -f $pctVersion, "Server"
    $registryClient = $mpuhRegistryBase -f $pctVersion, "Client"

    $currentMPUHObject = New-Object PSCustomObject

    foreach ($getKey in $keyValues)
    {
        $memberServerName = "Server{0}" -f $getKey
        $memberClientName = "Client{0}" -f $getKey

        $serverValue = Invoke-RegistryGetValue `
            -MachineName $MachineName `
            -SubKey $registryServer `
            -GetValue $getKey `
            -CatchActionFunction $CatchActionFunction
        $clientValue = Invoke-RegistryGetValue `
            -MachineName $MachineName `
            -SubKey $registryClient `
            -GetValue $getKey `
            -CatchActionFunction $CatchActionFunction

        $currentMPUHObject | Add-Member -MemberType NoteProperty `
            -Name $memberServerName `
            -Value (Get-MPUHMemberValue -GetKeyType $getKey -KeyValue $serverValue -ServerClientType "Server")

        $currentMPUHObject | Add-Member -MemberType NoteProperty `
            -Name $memberClientName `
            -Value (Get-MPUHMemberValue -GetKeyType $getKey -KeyValue $clientValue -ServerClientType "Client")
    }

    $hashKeyName = "MultiProtocolUnifiedHello"
    $allTlsObjects.Add($hashKeyName, $currentMPUHObject)
#endregion
#>

#region PCT
    $allPCTObjects = @()

    foreach ($pctVersion in $pctVersions)
    {
        $registryServer = $pctRegistryBase -f $pctVersion, "Server"
        $registryClient = $pctRegistryBase -f $pctVersion, "Client"

        $currentPCTObject = New-Object PSCustomObject
        $currentPCTObject | Add-Member -MemberType NoteProperty -Name "PCTVersion" -Value $pctVersion

        foreach ($getKey in $keyValues)
        {
            $memberServerName = "Server{0}" -f $getKey
            $memberClientName = "Client{0}" -f $getKey

            $serverValue = Invoke-RegistryGetValue `
                -MachineName $MachineName `
                -SubKey $registryServer `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction
            $clientValue = Invoke-RegistryGetValue `
                -MachineName $MachineName `
                -SubKey $registryClient `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction

            $currentPCTObject | Add-Member -MemberType NoteProperty `
                -Name $memberServerName `
                -Value (Get-PCTMemberValue -GetKeyType $getKey -KeyValue $serverValue -ServerClientType "Server" -PCTVersion $pctVersion)

            $currentPCTObject | Add-Member -MemberType NoteProperty `
                -Name $memberClientName `
                -Value (Get-PCTMemberValue -GetKeyType $getKey -KeyValue $clientValue -ServerClientType "Client" -PCTVersion $pctVersion)
        }

        $allPCTObjects += $currentPCTObject
    }

    $hashKeyName = "PCT"
    $allTlsObjects.Add($hashKeyName, $allPCTObjects)
#endregion

#region Key Exchange Algorithm (KEA)
    $allKEAObjects = @()

    foreach ($keaValue in $keaValues)
    {
        $currentKEAObject = New-Object PSCustomObject
        $currentKEAObject | Add-Member -MemberType NoteProperty -Name "KeyEchangeAlgorithms" -Value $keaValue

        foreach ($getKey in 'Enabled')
        {
            $registryKey = $keaRegistryBase -f $keaValue
            $registryValue = Invoke-RegistryGetValue `
                -Machine $MachineName `
                -SubKey $registryKey `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction

                $currentKEAObject | Add-Member -MemberType NoteProperty `
                    -Name $getKey `
                    -Value (Get-KEAMemberValue -GetKeyType $getKey -KeyValue $registryValue -KEAVersion $keaValue)
        }

        $allKEAObjects += $currentKEAObject
    }

    $hashKeyName = "KeyExchangeAlgorithms"
    $allTlsObjects.Add($hashKeyName, $allKEAObjects)
#endregion

#region Hashes
    $allHashesObject = @()

    foreach ($hashesValue in $hashesValues)
    {
        $currentHashesObject = New-Object PSCustomObject
        $currentHashesObject | Add-Member -MemberType NoteProperty -Name "Hashes" -Value $hashesValue

        foreach ($getKey in 'Enabled')
        {
            $registryKey = $hashesRegistryBase -f $hashesValue
            $hashValue = Invoke-RegistryGetValue `
                -MachineName $MachineName `
                -SubKey $registryKey `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction

                $currentHashesObject | Add-Member -MemberType NoteProperty `
                    -Name $getKey `
                    -Value (Get-HashesMemberValue -GetKeyType $getKey -KeyValue $hashValue -HashVersion $hashesValue)
        }

        $allHashesObject += $currentHashesObject
    }

    $hashKeyName = "Hashes"
    $allTlsObjects.Add($hashKeyName, $allHashesObject)
#endregion

#region Ciphers
    $allCiphersObject = @()

    foreach ($cipherValue in $cipherValues)
    {
        $currentCiphersObject = New-Object PSCustomObject
        $currentCiphersObject | Add-Member -MemberType NoteProperty -Name "Cipher" -Value $cipherValue

        foreach ($getKey in 'Enabled')
        {
            $registryKey = $cipherRegsitryBase -f $cipherValue
            $ciphersValue = Invoke-RegistryGetValue `
                -MachineName $MachineName `
                -SubKey $registryKey `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction

                $currentCiphersObject | Add-Member -MemberType NoteProperty `
                    -Name $getKey `
                    -Value (Get-CiphersMemberValue -GetKeyType $getKey -KeyValue $ciphersValue -CipherVersion $cipherValue)
        }

        $allCiphersObject += $currentCiphersObject
    }

    $hashKeyName = "Ciphers"
    $allTlsObjects.Add($hashKeyName, $allCiphersObject)
#endregion

#region SSL Versions
    $allSSLObjects = @()

    foreach ($sslVersion in $sslVersions)
    {
        $registryServer = $sslRegistryBase -f $sslVersion, "Server"
        $registryClient = $sslRegistryBase -f $sslVersion, "Client"

        $currentSSLObject = New-Object PSCustomObject
        $currentSSLObject | Add-Member -MemberType NoteProperty -Name "SSLVersion" -Value $sslVersion

        foreach ($getKey in $keyValues)
        {
            $memberServerName = "Server{0}" -f $getKey
            $memberClientName = "Client{0}" -f $getKey

            $serverValue = Invoke-RegistryGetValue `
                -MachineName $MachineName `
                -SubKey $registryServer `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction
            $clientValue = Invoke-RegistryGetValue `
                -MachineName $MachineName `
                -SubKey $registryClient `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction

            $currentSSLObject | Add-Member -MemberType NoteProperty `
                -Name $memberServerName `
                -Value (Get-SSLMemberValue -GetKeyType $getKey -KeyValue $serverValue -ServerClientType "Server" -SSLVersion $sslVersion)
            $currentSSLObject | Add-Member -MemberType NoteProperty `
                -Name $memberClientName `
                -Value (Get-SSLMemberValue -GetKeyType $getKey -KeyValue $clientValue -ServerClientType "Client" -SSLVersion $sslVersion)
        }

        $allSSLObjects += $currentSSLObject
    }

    $hashKeyName = "SSL"
    $allTlsObjects.Add($hashKeyName, $allSSLObjects)
#endregion

#region TLS Version
    $tlsObjects = @()

    foreach ($tlsVersion in $tlsVersions)
    {
        $registryServer = $tlsRegistryBase -f $tlsVersion, "Server"
        $registryClient = $tlsRegistryBase -f $tlsVersion, "Client"

        $currentTLSObject = New-Object PSCustomObject
        $currentTLSObject | Add-Member -MemberType NoteProperty -Name "TLSVersion" -Value $tlsVersion

        foreach ($getKey in $keyValues)
        {
            $memberServerName = "Server{0}" -f $getKey
            $memberClientName = "Client{0}" -f $getKey

            $serverValue = Invoke-RegistryGetValue `
                -MachineName $MachineName `
                -SubKey $registryServer `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction
            $clientValue = Invoke-RegistryGetValue `
                -MachineName $MachineName `
                -SubKey $registryClient `
                -GetValue $getKey `
                -CatchActionFunction $CatchActionFunction

            $currentTLSObject | Add-Member -MemberType NoteProperty `
                -Name $memberServerName `
                -Value (Get-TLSMemberValue -GetKeyType $getKey -KeyValue $serverValue -ServerClientType "Server" -TlsVersion $tlsVersion)
            $currentTLSObject | Add-Member -MemberType NoteProperty `
                -Name $memberClientName `
                -Value (Get-TLSMemberValue -GetKeyType $getKey -KeyValue $clientValue -ServerClientType "Client" -TlsVersion $tlsVersion)
        }
        $tlsObjects += $currentTLSObject
    }

    $hashKeyName = "TLS"
    $allTlsObjects.Add($hashKeyName, $tlsObjects)

    #endregion

#region .NET versions
    $allNetVersionObjects = @()
    $netVersions = @("v2.0.50727", "v4.0.30319")
    $registryBase = "SOFTWARE\{0}\.NETFramework\{1}"
    foreach ($netVersion in $netVersions)
    {
        $currentNetTlsDefaultVersionObject = New-Object PSCustomObject
        $currentNetTlsDefaultVersionObject | Add-Member -MemberType NoteProperty -Name "NetVersion" -Value $netVersion

        $SystemDefaultTlsVersions = Invoke-RegistryGetValue `
            -MachineName $MachineName `
            -SubKey ($registryBase -f "Microsoft", $netVersion) `
            -GetValue "SystemDefaultTlsVersions" `
            -CatchActionFunction $CatchActionFunction
        $SchUseStrongCrypto = Invoke-RegistryGetValue `
            -MachineName $MachineName `
            -SubKey ($registryBase -f "Microsoft", $netVersion) `
            -GetValue "SchUseStrongCrypto" `
            -CatchActionFunction $CatchActionFunction
        $WowSystemDefaultTlsVersions = Invoke-RegistryGetValue `
            -MachineName $MachineName `
            -SubKey ($registryBase -f "Wow6432Node\Microsoft", $netVersion) `
            -GetValue "SystemDefaultTlsVersions" `
            -CatchActionFunction $CatchActionFunction
        $WowSchUseStrongCrypto = Invoke-RegistryGetValue `
            -MachineName $MachineName `
            -SubKey ($registryBase -f "Wow6432Node\Microsoft", $netVersion) `
            -GetValue "SchUseStrongCrypto" `
            -CatchActionFunction $CatchActionFunction

        $currentNetTlsDefaultVersionObject = [PSCustomObject]@{
            NetVersion                  = $netVersion
            SystemDefaultTlsVersions    = (Get-NETDefaultTLSValue -KeyValue $SystemDefaultTlsVersions -NetVersion $netVersion -KeyName "SystemDefaultTlsVersions")
            SchUseStrongCrypto          = (Get-NETDefaultTLSValue -KeyValue $SchUseStrongCrypto -NetVersion $netVersion -KeyName "SchUseStrongCrypto")
            WowSystemDefaultTlsVersions = (Get-NETDefaultTLSValue -KeyValue $WowSystemDefaultTlsVersions -NetVersion $netVersion -KeyName "WowSystemDefaultTlsVersions")
            WowSchUseStrongCrypto       = (Get-NETDefaultTLSValue -KeyValue $WowSchUseStrongCrypto -NetVersion $netVersion -KeyName "WowSchUseStrongCrypto")
            SecurityProtocol            = (Invoke-ScriptBlockHandler -ComputerName $MachineName `
                                            -ScriptBlock { ([System.Net.ServicePointManager]::SecurityProtocol).ToString() } `
                                            -CatchActionFunction $CatchActionFunction `
                                            -Authentication Negotiate)

        }

        $allNetVersionObjects += $currentNetTlsDefaultVersionObject
    }

    $hashKeyName = "NET"
    $allTlsObjects.Add($hashKeyName, $allNetVersionObjects)

#endregion

    return $allTlsObjects
}
#endregion