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
# Filename: Globals.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/12/2018 4:51 PM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
Set-StrictMode -Version Latest

BeforeAll {
    $sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
    $root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
    $myPath   = $PSCommandPath
    $srcRoot  = "$root\src"
    $testRoot = "$root\OnPremDiagTests"
    $testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
    $mode     = $Matches.Mode

    Get-ChildItem -Path "$srcRoot\classes" -Recurse -Filter *.ps1 | ForEach-Object {. $_.FullName}

    # Load resource files needed for tests
    . (Join-Path -Path $testRoot -ChildPath testhelpers\LoadResourceFiles.ps1)

    Import-ResourceFiles -Root $srcRoot -MyMode $mode

    . (Join-Path -Path $srcRoot -ChildPath common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath common\Utils.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\Globals.ps1)
    . (Join-Path -Path $srcRoot -ChildPath mode\$mode\common\$mode.ps1)

    . $sut
}

Describe -Tag 'SfBServer' "Globals" {
    Context "Global variables, enumerations, etc., that need to referenced" {
        It "OPDTitle" {
            $value = Get-Variable -Name OPDTitle -Scope 'Global'

            $value.Name        | Should -Be 'OPDTitle'
            $value.Description | Should -Be 'Product Title'
            $value.Value       | Should -Be 'On Premise Diagnostic (OPD) for Skype for Business Server'
            $value.Options     | Should -Be ReadOnly
        }

        It "SfBServerModule" {
            $value = Get-Variable -Name SfBServerModule -Scope 'Global'

            $value.Name        | Should -Be 'SfBServerModule'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 'SkypeForBusiness'
            $value.Options     | Should -Be ReadOnly
        }

        It "SfBServerCsAdminGroup" {
            $value = Get-Variable -Name SfBServerCsAdminGroup -Scope 'Global'

            $value.Name        | Should -Be 'SfBServerCsAdminGroup'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 'CsAdministrator'
            $value.Options     | Should -Be ReadOnly
        }

        It "SfBServerCsServerAdminGroup" {
            $value = Get-Variable -Name SfBServerCsServerAdminGroup -Scope 'Global'

            $value.Name        | Should -Be 'SfBServerCsServerAdminGroup'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 'CsServerAdministrator'
            $value.Options     | Should -Be ReadOnly
        }

        It "SfBServerRTCAdminGroup" {
            $value = Get-Variable -Name SfBServerRTCAdminGroup -Scope 'Global'

            $value.Name        | Should -Be 'SfBServerRTCAdminGroup'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 'RTCUniversalServerAdmins'
            $value.Options     | Should -Be ReadOnly
        }

        It "SfbServerServiceNameDesc" {
            $value = Get-Variable -Name SfbServerServiceNameDesc -Scope 'Global'

            $value.Name        | Should -Be 'SfbServerServiceNameDesc'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 'Skype for Business Server Front-End'
            $value.Options     | Should -Be ReadOnly
        }

        It "SkypeForBusinessFrontendService" {
            $value = Get-Variable -Name SkypeForBusinessFrontendService -Scope 'Global'

            $value.Name        | Should -Be 'SkypeForBusinessFrontendService'
            $value.Description | Should -Be 'Root hive for Skype for Business Server Frontend Service'
            $value.Value       | Should -Be 'SYSTEM\CurrentControlSet\Services\RtcSrv'
            $value.Options     | Should -Be ReadOnly
        }

        It "SchannelSettings" {
            $value = Get-Variable -Name SchannelSettings -Scope 'Global'

            $value.Name        | Should -Be 'SchannelSettings'
            $value.Description | Should -Be 'Root hive for schannel settings'
            $value.Value       | Should -Be 'SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel'
            $value.Options     | Should -Be ReadOnly
        }

        It "LocalMachineCertificateStore" {
            $value = Get-Variable -Name LocalMachineCertificateStore -Scope 'Global'

            $value.Name        | Should -Be 'LocalMachineCertificateStore'
            $value.Description | Should -Be "This type of certificate store is local to the computer and is global to all users on the computer. This certificate store is located in the registry under the HKEY_LOCAL_MACHINE root."
            $value.Value       | Should -Be 'Cert:\LocalMachine\Root'
            $value.Options     | Should -Be ReadOnly
        }

        It "MaxNumberOfRootCertificates" {
            $value = Get-Variable -Name MaxNumberOfRootCertificates -Scope 'Global'

            $value.Name        | Should -Be 'MaxNumberOfRootCertificates'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 100
            $value.Options     | Should -Be ReadOnly
        }

        It "SfBServerOnlinePSModule" {
            $value = Get-Variable -Name SfBServerOnlinePSModule -Scope 'Global'

            $value.Name        | Should -Be 'SfBServerOnlinePSModule'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be "Skype for Business Online, Windows PowerShell Module"
            $value.Options     | Should -Be ReadOnly
        }

        It "SIPProxyFQDN" {
            $value = Get-Variable -Name SIPProxyFQDN -Scope 'Global'

            $value.Name        | Should -Be 'SIPProxyFQDN'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be "sipfed.online.lync.com"
            $value.Options     | Should -Be ReadOnly
        }

        It "SIPFederationTLS" {
            $value = Get-Variable -Name SIPFederationTLS -Scope 'Global'

            $value.Name        | Should -Be 'SIPFederationTLS'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be "_sipfederationtls._tcp"
            $value.Options     | Should -Be ReadOnly
        }

        It "WinRMHTTPPort" {
            $value = Get-Variable -Name WinRMHTTPPort -Scope 'Global'

            $value.Name        | Should -Be 'WinRMHTTPPort'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 5985
            $value.Options     | Should -Be ReadOnly
        }

        It "WinRMHTTPSPort" {
            $value = Get-Variable -Name WinRMHTTPSPort -Scope 'Global'

            $value.Name        | Should -Be 'WinRMHTTPSPort'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 5986
            $value.Options     | Should -Be ReadOnly
        }

        It "SIPSecurePort" {
            $value = Get-Variable -Name SIPSecurePort -Scope 'Global'

            $value.Name        | Should -Be 'SIPSecurePort'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 5061
            $value.Options     | Should -Be ReadOnly
        }

        It "Connections" {
            $value = Get-Variable -Name Connections -Scope 'Global'

            $value.Name        | Should -Be 'Connections'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be ([Singleton]::GetInstance())
        }

        It "EnableSessionTicketValue" {
            $value = Get-Variable -Name EnableSessionTicketValue -Scope 'Global'

            $value.Name        | Should -Be 'EnableSessionTicketValue'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 2
            $value.Options     | Should -Be ReadOnly
        }

        It "ClientAuthTrustModeValue" {
            $value = Get-Variable -Name ClientAuthTrustModeValue -Scope 'Global'

            $value.Name        | Should -Be 'ClientAuthTrustModeValue'
            $value.Description | Should -Be ([string]::Empty)
            $value.Value       | Should -Be 2
            $value.Options     | Should -Be ReadOnly
        }
    }
}