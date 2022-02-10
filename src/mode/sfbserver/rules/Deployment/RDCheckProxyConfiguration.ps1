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
# Filename: RDCheckProxyConfiguration.ps1
# Description: Checks for mismatch in registry proxy settings and web.config files
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/20/2021 11:18 AM
#
# Last Modified On: 4/20/2021 11:18 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckProxyConfiguration : RuleDefinition
{
    RDCheckProxyConfiguration([object] $Insight)
    {
        $this.Name        ='RDCheckProxyConfiguration'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('8F0126F7-6BB7-4E3A-B124-92D56EC1FB97')
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

            if (Test-Path -Path $global:ProxyEnabled)
            {
                $registryKey = Invoke-RegistryGetValue -RegistryHive "CurrentUser" `
                                    -SubKey "Software\Microsoft\Windows\CurrentVersion\Internet Settings" `
                                    -GetValue "ProxyEnable"

                # Let's get the current server version. This will give us our baseline for comparison
                $CurrentProduct = Get-CsServerVersion

                if (-not [string]::IsNullOrEmpty($CurrentProduct))
                {
                    if ($CurrentProduct -match "^(?<Product>.*)\((?<Version>\d+\.\d+\.\d+\.\d+)\).*$")
                    {
                        $Product = $Matches.Product.Trim()

                        foreach ($configFile in $global:WebConfigInternal, $global:WebConfigExternal)
                        {
                            $configFile = $configFile.Replace('%PRODUCT%', $Product)

                            if (Test-Path -Path $configFile)
                            {
                                $config = [xml](Get-Content -Path $configFile)
                                if ($config.HasChildNodes)
                                {
                                    $proxyAddress = $config.configuration.'system.net'.defaultproxy.proxy.proxyaddress

                                    $proxy = [bool]$registryKey.ProxyEnable

                                    if ($proxy -and [string]::IsNullOrEmpty($proxyAddress) -or
                                        -not $proxy -and -not [string]::IsNullOrEmpty($proxyAddress))
                                    {
                                        throw 'IDProxyMismatch'
                                    }
                                }
                                else
                                {
                                    throw 'IDFileIsEmpty'
                                }
                            }
                            else
                            {
                                throw 'IDFileDoesNotExist'
                            }
                        }
                    }
                    else
                    {
                        throw 'IDUnableToGetVersion'
                    }
                }
                else
                {
                    throw 'IDGetCsServerVersionFailed'
                }
            }
            else
            {
                throw 'IDRegistryKeyNotFound'
            }
        }
        catch [System.Management.Automation.PropertyNotFoundException]
        {
            $this.Insight.Detection = $global:InsightDetections.'IDPropertyNotFoundException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDPropertyNotFoundException'
            $this.Success           = $false
        }
        catch
        {
            switch($_.ToString())
            {
                IDProxyMismatch
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($_) -f $configFile)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDRegistryKeyNotFound
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($_) -f $global:ProxyEnabled)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDPropertyNotFoundException
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($_) -f "$($global:ProxyEnabled).ProxyEnable")
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDGetCsServerVersionFailed
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDUnableToGetVersion
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDFileDoesNotExist
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($_) -f $configFile)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDFileIsEmpty
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($_) -f $configFile)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
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

