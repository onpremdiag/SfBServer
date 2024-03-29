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
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/5/2018 12:44 PM
#
# Last Modified On: 9/5/2018 12:45 PM
#################################################################################
Set-StrictMode -Version Latest

New-Variable -Name _INC_SPGLOBALS `
    -Description "This lets us know if we've included this file yet" `
    -Scope 'Global' `
    -Value $true `
    -Force

New-Variable -Name EULA `
    -Description "End User License Agreement" `
    -Scope 'Global' `
    -Value @'
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
'@ `
    -Force

New-Variable -Name EventLogName `
    -Description "Event Log Name for OPD" `
    -Scope 'Global' `
    -Value "OPDLog" `
    -Force

New-Variable -Name OPD_REGKEY `
    -Value 'HKLM:\SOFTWARE\Microsoft\OPD' `
    -Description "OnPrem Diagnostics (OPD) Registry Hive" `
    -Scope 'Global' `
    -Option ReadOnly `
    -Force

New-Variable -Name UniqueMessageCache         -Value @{} -Scope 'Global' -Force

New-Variable -Name AppInsightsInitialized     -Value $false -Scope 'Global' -Force
New-Variable -Name AppInsightsTelemetryClient -Value $null -Scope 'Global' -Force

New-Variable -Name CurrentScenario            -Value ([System.Guid]::Empty) -Scope 'Global' -Force
New-Variable -Name CurrentAnalyzer            -Value ([System.Guid]::Empty) -Scope 'Global' -Force
New-Variable -Name CurrentRule                -Value ([System.Guid]::Empty) -Scope 'Global' -Force

New-Variable -Name Connections.Container      -Value @() -Scope 'Global' -Force

New-Variable -Name BreadCrumb -Value ([String]::Empty) -Scope 'Global' -Force

New-Variable -Name GitHubUserName `
             -Value "OnPremDiag" `
             -Description "GitHub user name for release repository" `
             -Scope Global `
             -Force

New-Variable -Name GitHubRepository `
             -Value "%GITHUBREPO%" `
             -Description "Repository name for OPD for %PRODUCT%" `
             -Scope Global `
             -Force

New-Variable -Name OPDVersion `
             -Value "0.0.0000.00000" `
             -Description "Version mask" `
             -Scope 'Global' `
             -Force

New-Variable -Name OPDTitle `
             -Value "On Premise Diagnostics for %PRODUCT% (OPD)" `
             -Description "Product Title" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name CopyrightNotice `
             -Value ("© {0}, Microsoft Corporation. All rights reserved." -f (Get-Date).Year) `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name OPDOwner `
             -Value "OnPrem Diagnostic Support <opd-support@microsoft.com>" `
             -Description "Ultimate owner of all code in OPD" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name MinimumPowershellVersion `
             -Value ([System.Version]"5.1.0.0") `
             -Description "Minimum version of PowerShell required by OPD" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name MinimumNetFramework `
             -Value ([System.Version]"4.7.2") `
             -Description ".NET Framework 4.7.2" `
             -Scope 'Global' `
             -Option Readonly `
             -Force


New-Variable -Name OPDPreRequisites `
             -Value @() `
             -Description "Table of required pre-requisites for OPD to function properly" `
             -Scope 'Global' `
             -Force

New-Variable -Name WebConfigInternal `
             -Value "C:\Program Files\%PRODUCT%\Web Components\Web ticket\Int\web.config" `
             -Scope 'Global' `
             -Force

New-Variable -Name WebConfigExternal `
             -Value "C:\Program Files\%PRODUCT%\Web Components\Web ticket\Ext\web.config" `
             -Scope 'Global' `
             -Force

New-Variable -Name UpgradeExistingWindowsPowerShell `
             -Value "https://docs.microsoft.com/powershell/scripting/windows-powershell/install/installing-windows-powershell?view=powershell-7.1#upgrading-existing-windows-powershell" `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force

New-Variable -Name InstallDotNetFramework `
             -Value 'https://docs.microsoft.com/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed' `
             -Scope 'Global' `
             -Option ReadOnly `
             -Force