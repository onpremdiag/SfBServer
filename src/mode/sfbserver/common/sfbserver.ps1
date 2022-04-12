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
# Filename: sfbserver.ps1
# Description: Global variables, enumerations, etc., that need to referenced
# across various functions.
#
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

############################################################
## public function to test if Skype for Business Server
## PowerShell module is available
##
## Owner: Jo�o Loureiro <joaol@microsoft.com>
## Last Modified On: 4/10/2019 03:46 PM (GMT+1)
############################################################
Set-StrictMode -Version Latest

function Get-HostEntry
{
    param
    (
        [string] $IPAddress
    )

    $HostName = [string]::Empty

    if (-not [string]::IsNullOrEmpty($IPAddress))
    {
        $HostName = [System.Net.Dns]::GetHostEntry($IPAddress).HostName
    }

    return $HostName
}


function Test-SfbServerPSModuleIsLoaded
{
    $var = Get-Variable -Name $global:SfBServerPowerShellModuleLoaded -ErrorAction SilentlyContinue

    if ([string]::IsNullOrEmpty($var) -or $var.Value -eq $false)
    {
        $global:SfBServerPowerShellModuleLoaded = Test-ModuleLoaded -ModuleName $global:SfBServerModule
    }

    return $global:SfbServerPowerShellModuleLoaded
}

function Test-SfbServerPSModuleIsInstalled
{
    return (Test-IsModuleInstalled -DisplayName $global:SfBServerOnlinePSModule)
}

function Test-IsUSAMember
{
    param
    (
        [string] $SAMAccountName
    )

    $IsMember = $false
    $UserGroups = $null

    try
    {
        if (Initialize-Module -ModuleName 'ActiveDirectory')
        {
            $UserGroups = Get-ADAccountAuthorizationGroup $env:USERNAME |
                Where-Object {$_.SamAccountName -eq $SAMAccountName}
        }
        else
        {
            #Unable to load AD cmdlets
        }
    }
    catch
    {
        #throw $_
        $IsMember = $false
    }
    finally
    {
        if(-not [string]::IsNullOrEmpty($UserGroups))
        {
            $ISMember = $UserGroups.SamAccountName -eq $SAMAccountName
        }
    }

    return $ISMember
}

############################################################
## public function to test if this server is a
## Skype for Business Server Frontend
##
## Owner: Jo�o Loureiro <joaol@microsoft.com>
## Last Modified On: 16/10/2019 14:02 PM (GMT+1)
############################################################

function Test-IsSkypeForBusinessFrontend
{
    $isFrontend = $false
    $RegVal = Invoke-RegistryGetValue -RegistryHive "LocalMachine" -SubKey $SkypeForBusinessFrontendService -GetValue "Description"

    if ($RegVal -eq $SfbServerServiceNameDesc)
    {
        $isFrontend = $true
    }
    return $isFrontend
}

############################################################
## public function to test if current account has
## Skype for Business Server administrative privileges
##
## Owner: Jo�o Loureiro <joaol@microsoft.com>
## Last Modified On: 29/10/2019 5:19 PM (GMT+1)
############################################################

function Test-IsSkypeForBusinessServerAdminAccount
{
    $IsServerAdminAccount = $false

    foreach ($group in $global:SfBServerCsAdminGroup, $global:SfBServerCsServerAdminGroup, $global:SfBServerRTCAdminGroup)
    {
        $IsServerAdminAccount = $IsServerAdminAccount -or (Test-IsADGroupMember $group)
        if ($IsServerAdminAccount)
        {
            break
        }
    }

    return $IsServerAdminAccount
}

############################################################
## public function to test if current account is
## member of particular domain group
##
## Owner: Jo�o Loureiro <joaol@microsoft.com>
## Last Modified On: 31/10/2019 1:57 PM (GMT+1)
############################################################

function Test-IsADGroupMember
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $group
    )

    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole($group)

}

############################################################
## public function to test if Schannel session ticket
## TLS optimization is turned on
##
## Owner: Jo�o Loureiro <joaol@microsoft.com>
## Last Modified On: 02/12/2019 5:54 PM (GMT)
############################################################

function Test-IsEnableSessionTicketOn
{
    $isEnableSessionTicketEnabled = $false
    $RegValue = Invoke-RegistryGetValue -RegistryHive "LocalMachine" -SubKey $SchannelSettings -GetValue "EnableSessionTicket"

    if (-not [string]::IsNullOrEmpty($RegValue) -and $RegValue -eq $global:EnableSessionTicketValue)
    {
        $isEnableSessionTicketEnabled = $true
    }
    return $isEnableSessionTicketEnabled
}

############################################################
## public function to test if Schannel trust mode is
## set to 'Exclusive CA Trust' mode
##
## Owner: Jo�o Loureiro <joaol@microsoft.com>
## Last Modified On: 02/12/2019 5:57 PM (GMT)
############################################################

function Test-IsClientAuthTrustModeSetToTrustCA
{
    $isClientAuthTrustModeSetToTrustCA = $false
    $RegValue = Invoke-RegistryGetValue -RegistryHive "LocalMachine" -SubKey $SchannelSettings -GetValue "ClientAuthTrustMode"

    if (-not [string]::IsNullOrEmpty($RegValue) -and $RegValue -eq $global:ClientAuthTrustModeValue)
    {
        $isClientAuthTrustModeSetToTrustCA = $true
    }
    return $isClientAuthTrustModeSetToTrustCA
}

#
# This file contains product specific functions, types, etc
#

# Responsible for testing any pre-conditions that need to be satisfied prior to
# execution (Optional)
#
function Invoke-SupportabilityPreChecks
{
    $passedSupportabilityChecks = $true

    $scenario = [SDSfbServerPSModuleLoadedAndIsFrontend]::new($global:ExecutionId)
    $scenario.AnalyzerDefinitions | ForEach-Object {$_.Success = $true; $_.Results = $null}

    Invoke-Scenario -Scenario $scenario

    $failures = $scenario.AnalyzerDefinitions | Where-Object {$_.Success -eq $false}

    if ($null -ne $failures)
    {
        $sb = New-Object -TypeName System.Text.StringBuilder
        foreach ($failure in $failures.Results)
        {
            $failure.Description                                         | Write-OPD -Status ERROR
            $global:OPDStrings.'Detection' -f $failure.Insight.Detection | Write-OPD -Status ERROR -IndentLevel 1
            $global:OPDStrings.'Action' -f $failure.Insight.Action       | Write-OPD -Status ERROR -IndentLevel 1
        }

        $passedSupportabilityChecks = $false
    }

    $passedSupportabilityChecks = $passedSupportabilityChecks -band (Test-MicrosoftTeamsModule)
    $passedSupportabilityChecks = $passedSupportabilityChecks -band (Test-SkypeForBusinessModule)
    $passedSupportabilityChecks = $passedSupportabilityChecks -band (Test-AzureADModule)

    return $passedSupportabilityChecks
}

function Test-SanOnCert
{
    param
    (
        [Parameter(Mandatory = $true)]
        [object] $SAN,

        [Parameter(Mandatory = $true)]
        [object] $Certificate
    )

    $found = $false

    foreach($name in $Certificate.AlternativeNames)
    {
        if ($SAN -eq $name)
        {
            $found = $true
            break
        }
    }

    return $found
}

function Test-MicrosoftTeamsModule
{
    $isLoaded = $global:OPDPreRequisites | Where-Object {$_.Description -eq $global:MicrosoftTeamsModule}

    if ([string]::IsNullOrEmpty($isLoaded))
    {
        $modules = Get-Module -Name 'MicrosoftTeams' -ListAvailable -ErrorAction SilentlyContinue | Sort-Object -Property Version

        $prereq = New-Object PSObject
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Description" -Value $global:MicrosoftTeamsModule
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Minimum Required Version" -Value $global:MinimumMicrosoftTeams
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Installed Version" -Value "Not Found"
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Help" -Value $global:InstallMicrosoftTeamsPowerShellModule
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Passed" -Value $false

        if (-not [string]::IsNullOrEmpty($modules))
        {
            foreach ($module in $modules)
            {
                $prereq.'Installed Version' = ($module.Version).ToString()

                if ($module.Version.CompareTo($global:MinimumMicrosoftTeams) -ge 0)
                {
                    $prereq.Passed = $true
                    break
                }
                else
                {
                    $prereq.Passed = $false
                }
            }
        }

        $global:OPDPreRequisites += $prereq
        return $prereq.Passed
    }

    return $isLoaded.Passed
}

function Test-SkypeForBusinessModule
{
    $isLoaded = $global:OPDPreRequisites | Where-Object {$_.Description -eq $global:SkypeForBusinessModule}

    if ([string]::IsNullOrEmpty($isLoaded))
    {
        $modules = Get-Module -Name 'SkypeForBusiness' -ListAvailable -ErrorAction SilentlyContinue | Sort-Object -Property Version

        $prereq = New-Object PSObject
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Description" -Value $global:SkypeForBusinessModule
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Minimum Required Version" -Value $global:MinimumSkypeForBusiness
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Installed Version" -Value "Not Found"
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Help" -Value $global:InstalSkypeForBusinessModule
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Passed" -Value $false

        if (-not [string]::IsNullOrEmpty($modules))
        {
            foreach ($module in $modules)
            {
                $prereq.'Installed Version' = ($module.Version).ToString()

                if ($module.Version.CompareTo($global:MinimumSkypeForBusiness) -ge 0)
                {
                    $prereq.Passed = $true
                    break
                }
                else
                {
                    $prereq.Passed = $false
                }
            }
        }

        $global:OPDPreRequisites += $prereq
        return $prereq.Passed
    }

    return $isLoaded.Passed
}

# Task 32927: Exchange Hybrid/Online deployment check if AzureAD module is installed
function Test-AzureADModule
{
    $isLoaded = $global:OPDPreRequisites | Where-Object {$_.Description -eq $global:AzureADModule}

    if ([string]::IsNullOrEmpty($isLoaded))
    {
        $modules = Get-Module -Name 'MSOnline' -ListAvailable -ErrorAction SilentlyContinue | Sort-Object -Property Version

        $prereq = New-Object PSObject
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Description" -Value $global:AzureADModule
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Minimum Required Version" -Value $global:MinimumAzureAD
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Installed Version" -Value "Not Found"
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Help" -Value $global:InstallAzureADModule
        Add-Member -InputObject $prereq -MemberType NoteProperty -Name "Passed" -Value $false

        if (-not [string]::IsNullOrEmpty($modules))
        {
            foreach ($module in $modules)
            {
                $prereq.'Installed Version' = ($module.Version).ToString()

                if ($module.Version.CompareTo($global:MinimumAzureAD) -ge 0)
                {
                    $prereq.Passed = $true
                    break
                }
                else
                {
                    $prereq.Passed = $false
                }
            }
        }

        $global:OPDPreRequisites += $prereq
        return $prereq.Passed
    }

    return $isLoaded.Passed
}