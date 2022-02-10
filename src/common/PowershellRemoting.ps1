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
# Filename: PowershellRemoting.ps1
# Description: Various PowershellRemoting related functions
# Owner: Stefan Goﬂner <stefang@microsoft.com>
# Created On: 11/09/2018 23:04
#
# Last Modified On: 11/09/2018 23:04
#################################################################################
Set-StrictMode -Version Latest

function Test-RemotePath
(
    [string] $Server,
    [string] $Path
)
{
    $remoteScriptBlock = [scriptblock]::Create( @"
        Test-Path -Path `"$Path`"
"@)

    $exists = Invoke-Command -ComputerName $Server -ScriptBlock $remoteScriptBlock
    return $exists
}

function Get-RemoteFilteredChildItem
(
    [string] $Server,
    [string] $Path,
    [string] $PublicKeyToken
)
{
    $remoteScriptBlock = [scriptblock]::Create( @"
        `$files = Get-ChildItem -Path `"$Path`"
        `$files | Where-Object { `$_.Extension -eq `".dll`" -and  ([System.Reflection.AssemblyName]::GetAssemblyName(`$_.FullName).FullName.Contains(`"$PublicKeyToken`")) }
"@)

    $childItems = Invoke-Command -ComputerName $Server -ScriptBlock $remoteScriptBlock
    return $childItems
}

function Get-RemoteItems
(
    [string] $Server,
    [object] $ItemList
)
{
    $ItemArrayString = "```"" + ($ItemList -join "```",```"") + "```""

    $remoteScriptBlock = [scriptblock]::Create( @"
        `$ItemsList = Invoke-Command -ScriptBlock ([scriptblock]::create( `" @( $ItemArrayString ) `" ))

        `$result = @{}

        foreach (`$item in `$ItemsList)
        {
            if (Test-Path -Path `$item)
            {
                `$file = get-item -Path `$item
                `$result[`$file.Name] = `$file.VersionInfo
            }

        }
        return `$result
"@)

    $item = Invoke-Command -ComputerName $Server -ScriptBlock $remoteScriptBlock
    return $item
}
