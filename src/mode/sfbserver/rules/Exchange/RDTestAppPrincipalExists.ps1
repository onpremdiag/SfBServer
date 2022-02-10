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
# Filename: RDTestAppPrincipalExists.ps1
# Description: Determine if the app principal ID exists
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/26/2020 1:17 PM
#
# Last Modified On: 10/26/2020 1:17 PM
#################################################################################
Set-StrictMode -Version Latest

class RDTestAppPrincipalExists : RuleDefinition
{
    RDTestAppPrincipalExists([object] $Insight)
    {
        $this.Name        ='RDTestAppPrincipalExists'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('9AC25090-C7D0-4F21-B1A1-13DD39E7B727')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $ServiceName = "00000004-0000-0ff1-ce00-000000000000"

            # 1. Establish connection with Azure Active Directory (AAD)
            Connect-MsolService -AzureEnvironment $global:OPDOptions.AzureEnvironment -ErrorAction SilentlyContinue

            if ($?)
            {
                # Do the rest
                # 2. Does the service name exist?
                $AppPrincipalSFB = Get-MsolServicePrincipalCredential -ReturnKeyValues $true `
                                        -ServicePrincipalName $ServiceName `
                                        -ErrorAction SilentlyContinue

                if (-not [string]::IsNullOrEmpty($AppPrincipalSFB))
                {
                    # 3. List all SPN's configured for O365
                    $listSPNs = Get-MsolServicePrincipal -ServicePrincipalName $ServiceName |
                                    Select-Object -ExpandProperty ServicePrincipalNames

                    if (-not [string]::IsNullOrEmpty($listSPNs))
                    {
                        # 4. Get the list of all the Skype for Business Server External WebServices
                        $listExternalFQDNs = Get-CsService | Select-Object externalfqdn -Unique |
                                                Where-Object {$_.externalfqdn -ne $null}

                        $success = $false

                        foreach ($listSPN in $listSPNs)
                        {
                            if ($listSPN -like "*$($listExternalFQDNs.ExternalFqdn)*")
                            {
                                $success = $success -bor $true
                                break
                            }
                            else
                            {
                                $success = $success -bor $false
                            }
                        }

                        if (-not $success)
                        {
                            throw 'IDExternalWSNotInSPNList'
                        }
                    }
                    else
                    {
                        throw 'IDNoServicePrincipalNames'
                    }
                }
                else
                {
                    throw 'IDServicePrincipalDoesNotExist'
                }
            }
            else
            {
                throw 'IDUnableToConnectToAAD'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDUnableToConnectToAAD
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDServicePrincipalDoesNotExist
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDNoServicePrincipalNames
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDExternalWSNotInSPNList
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                default
                {
                    $LogArguments = @{
                        LogName   = $global:EventLogName
                        Source    = "Rules"
                        EntryType = "Error"
                        Message   = $_
                        EventId   = 9002
                    }

                    Write-EventLog @LogArguments

                    $this.Success = $false
                }
            }
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}