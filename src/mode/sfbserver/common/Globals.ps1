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
# Filename: Globals.ps1
# Description: Global variables, enumerations, etc., that need to referenced
# across various functions.
#
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

New-Variable -Name OPDTitle `
             -Value "On Premise Diagnostic (OPD) for Skype for Business Server" `
             -Description "Product Title" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SfbServerPowerShellModuleLoaded `
             -Description "" `
             -Value $false `
             -Scope 'Global' `
             -Force

New-Variable -Name SfBServerModule `
             -Description "" `
             -Value "SkypeForBusiness" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name MicrosoftTeamsModule `
             -Description "Microsoft Teams Module" `
             -Value "MicrosoftTeams" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SfBServerCsAdminGroup `
         -Description "" `
             -Value "CsAdministrator" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SfBServerCsServerAdminGroup `
             -Description "" `
             -Value "CsServerAdministrator" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SfBServerRTCAdminGroup `
             -Description "" `
             -Value "RTCUniversalServerAdmins" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SfbServerServiceNameDesc `
             -Description "" `
             -Value "Skype for Business Server Front-End" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SkypeForBusinessFrontendService `
             -Description "Root hive for Skype for Business Server Frontend Service" `
             -Value 'SYSTEM\CurrentControlSet\Services\RtcSrv' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SchannelSettings `
             -Description "Root hive for schannel settings" `
             -Value 'SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name ProxyEnabled `
             -Description "Proxy enabled" `
             -Value 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

#region Certificate Stores
New-Variable -Name LocalMachineCertificateStore `
             -Description "This type of certificate store is local to the computer and is global to all users on the computer. This certificate store is located in the registry under the HKEY_LOCAL_MACHINE root." `
             -Value 'Cert:\LocalMachine\Root' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name IntermediateCertificationAuthority `
             -Description "Intermediate CAs or Sub CAs are Certificate Authorities that issue off an intermediate root" `
             -Value 'Cert:\LocalMachine\CA' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name PersonalCertificateStore `
             -Description "" `
             -Value 'Cert:\LocalMachine\My' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name MaxNumberOfRootCertificates `
             -Value 100 `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

#endregion Certificate Stores

New-Variable -Name SfBServerOnlinePSModule `
             -Value "Skype for Business Online, Windows PowerShell Module" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SIPProxyFQDN `
             -Value "sipfed.online.lync.com" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SIPFederationTLS `
             -Value "_sipfederationtls._tcp" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SIPTLS `
             -Value "_sip._tls" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SIPDir `
             -Value "sipdir.online.lync.com" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name LyncDiscover `
             -Value "lyncdiscover" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name WebDir `
             -Value 'webdir.online.lync.com' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name DNSServer `
             -Value '8.8.8.8' `
             -Description "Google DNS server" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name WinRMHTTPPort `
             -Value 5985 `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name WinRMHTTPSPort `
             -Value 5986 `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name SIPSecurePort `
             -Value 5061 `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name Connections `
             -Value ([Singleton]::GetInstance()) `
             -Scope 'Global' `
             -Force

New-Variable -Name SQLLogSpaceThreshold `
             -Value 60 `
             -Scope 'Global' `
             -Force

New-Variable -Name EnableSessionTicketValue -Value 2 -Scope 'Global' -Option ReadOnly -Force

New-Variable -Name ClientAuthTrustModeValue -Value 2 -Scope 'Global' -Option ReadOnly -Force

Set-Variable -Name ErrorActionPreference -Value 'SilentlyContinue' -Scope 'Global' -Force

#region Updates for Skype for Business Server 2019
# https://support.microsoft.com/help/4470124/updates-for-skype-for-business-server-2019

New-Variable -Name SkypeForBusinessUpdates2019 `
             -Value @() `
             -Scope 'Global' `
             -Description 'Updates for Skype for Business Server 2019' `
             -Force

$SkypeForBusinessUpdates2019 +=
    New-Object PSObject -Property @{
        ProductName   = "Skype for Business Server 2019"
        ComponentName = "Core Components"
        Version       = [System.Version]"7.0.2046.396"
        Update        = "May 11, 2021 Security Update"
        Url           = "https://www.microsoft.com/download/details.aspx?id=58347"
    }
#endregion Updates for Skype for Business Server 2019

#region Updates for Skype for Business Server 2015
# https://support.microsoft.com/help/3061064/updates-for-skype-for-business-server-2015
New-Variable -Name SkypeForBusinessUpdates2015 `
             -Value @() `
             -Scope 'Global' `
             -Description 'Updates for Skype for Business Server 2015' `
             -Force

$SkypeForBusinessUpdates2015 +=
    New-Object PSObject -Property @{
        ProductName   = "Skype for Business Server 2015"
        ComponentName = "Core Components"
        Version       = [System.Version]"6.0.9319.628"
        Update        = "August 2021 Cumulative Update"
        Url           = "https://www.microsoft.com/download/details.aspx?id=47690"
    }

#endregion

New-Variable -Name SkypeForBusinessUpdates `
             -Value @($SkypeForBusinessUpdates2019, $SkypeForBusinessUpdates2015) `
             -Scope 'Global' `
             -Description 'Updates for Skype for Business Server' `
             -Force

New-Variable -Name O365ServicePoints `
             -Value @("https://adminwebservice.microsoftonline.com","https://login.microsoft.com") `
             -Scope 'Global' `
             -Description 'O365 Service Endpoints' `
             -Force

New-Variable -Name O365CRLs `
             -Value @("https://crl.microsoft.com","https://mscrl.microsoft.com") `
             -Scope 'Global' `
             -Description 'O365 Certificate Revocation Lists' `
             -Force

New-Variable -Name SOC6000Installed `
             -Value 0x00001000 `
             -Scope 'Global' `
             -Description 'SkypeOnlineConnector 6.0.0.0' `
             -Force

New-Variable -Name SOC7000Installed `
             -Value 0x00000100 `
             -Scope 'Global' `
             -Description 'SkypeOnlineConnector 7.0.0.0' `
             -Force

New-Variable -Name MT116Installed `
             -Value 0x00000010 `
             -Scope 'Global' `
             -Description 'MicrosoftTeams 1.1.6' `
             -Force

New-Variable -Name MT200Installed `
             -Value 0x00000001 `
             -Scope 'Global' `
             -Description 'MicrosoftTeams 2.0.0' `
             -Force

New-Variable -Name MinimumMicrosoftTeams `
             -Value ([System.Version]"2.3.1") `
             -Description "Minimum version of MicrosoftTeams 2.3.1" `
             -Scope 'Global' `
             -Option Readonly `
             -Force

New-Variable -Name MicrosoftTeamsModule `
             -Value 'Microsoft Teams PowerShell Module' `
             -Scope 'Global' `
             -Force

New-Variable -Name MinimumSkypeForBusiness `
             -Value ([System.Version]"6.0.0.0") `
             -Description "Minimum version of SkypeForBusiness" `
             -Scope 'Global' `
             -Option Readonly `
             -Force

New-Variable -Name SkypeForBusinessModule `
             -Value 'SkypeForBusiness Module' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name InstalSkypeForBusinessModule `
             -Value 'https://docs.microsoft.com/skypeforbusiness/manage/management-shell' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name InstallMicrosoftTeamsPowerShellModule `
             -Value 'https://docs.microsoft.com/microsoftteams/teams-powershell-install' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name MinimumAzureAD `
             -Value ([System.Version]"1.1.183.57") `
             -Description "Minimum version of Azure Active Directory (AAD) 1.1.183.57" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name AzureADModule `
             -Value 'Microsoft Azure Active Directory Module for Windows PowerShell' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name InstallAzureADModule `
             -Value 'https://docs.microsoft.com/powershell/azure/active-directory/overview?view=azureadps-1.0&preserve_view=true' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

#region SQL Express Version
New-Variable -Name SQLExpress2014 `
             -Value @() `
             -Scope 'Global' `
             -Description 'SQL Server Express Edition 2014' `
             -Force

$SQLExpress2014 +=
    New-Object PSObject -Property @{
        Description    = 'Microsoft SQL Server 2014 Service Pack 3 (SP3)'
        ProductVersion = [System.Version]"12.0.6024.0"
        ProductLevel   = 'SP3'
        Edition        = "Express Edition 2014"
        URL            = "https://www.microsoft.com/download/details.aspx?id=57473"
    }

New-Variable -Name SQLExpress2016 `
             -Value @() `
             -Scope 'Global' `
             -Description 'SQL Server Express Edition 2016' `
             -Force

$SQLExpress2016 +=
    New-Object PSObject -Property @{
        Description    = 'Microsoft SQL Server 2016 Service Pack 3 (SP3)'
        ProductVersion = [System.Version]"13.0.6300.2"
        ProductLevel   = 'SP3'
        Edition        = "Express Edition 2016"
        URL            = "https://www.microsoft.com/download/details.aspx?id=103440"
    }

New-Variable -Name SQLExpress2017 `
             -Value @() `
             -Scope 'Global' `
             -Description 'SQL Server Express Edition 2017' `
             -Force

$SQLExpress2017 +=
    New-Object PSObject -Property @{
        Description    = 'SQL Server 2017 for Microsoft Windows Latest Cumulative Update'
        ProductVersion = [System.Version]"14.0.3430.2"
        ProductLevel   = 'CU28'
        Edition        = "Express Edition 2017"
        URL            = "https://www.microsoft.com/download/details.aspx?id=56128"
    }

New-Variable -Name SQLExpress2019 `
             -Value @() `
             -Scope 'Global' `
             -Description 'SQL Server Express Edition 2019' `
             -Force

$SQLExpress2019 +=
    New-Object PSObject -Property @{
        Description    = 'SQL Server 2019 for Microsoft Windows Latest Cumulative Update'
        ProductVersion = [System.Version]"15.0.4198.2"
        ProductLevel   = 'CU15'
        Edition        = "Express Edition 2019"
        URL            = "https://www.microsoft.com/download/details.aspx?id=100809"
    }

New-Variable -Name SQLExpressVersions `
             -Value @($SQLExpress2014, $SQLExpress2016, $SQLExpress2017, $SQLExpress2019) `
             -Scope 'Global' `
             -Description 'SQL Server Express Version' `
             -Force
#endregion