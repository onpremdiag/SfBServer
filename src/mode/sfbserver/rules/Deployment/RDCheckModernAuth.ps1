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
# Filename: RDCheckModernAuth.ps1
# Description: Checks to see if Legacy modern authentication is being used
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/14/2021 10:55 AM
#
# Last Modified On: 4/14/2021 10:55 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckModernAuth : RuleDefinition
{
    RDCheckModernAuth([object] $Insight)
    {
        $this.Name        ='RDCheckModernAuth'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('9C8216F2-2A2D-4F45-BE50-3EDE71F28962')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [bool] IsSharedAddressSpaceEnabled()
    {
        $Enabled = $false

        $HostingProvider = Get-CsHostingProvider | Where-Object {$_.ProxyFqdn -eq $global:SIPProxyFQDN }

        if (-not [string]::IsNullOrEmpty($HostingProvider))
        {
            $Enabled = $HostingProvider.EnabledSharedAddressSpace
        }

        return $Enabled
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference

        $ModernAuthFound            = $false

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $command = Get-Command -Module $global:SfBServerModule -Name Get-CsOauthConfiguration

            if (-not [string]::IsNullOrEmpty($command))
            {
                $Configuration = & $command
            }
            else
            {
                $Configuration = $null
            }

            if (-not [string]::IsNullOrEmpty($Configuration))
            {
                $Servers = $Configuration.OAuthServers

                if (-not [string]::IsNullOrEmpty($Servers))
                {
                    foreach ($stsServer in $Servers)
                    {
                        if ($stsServer.IssuerIdentifier -eq 'sts.windows.net')
                        {
                            $ModernAuthFound = $true
                            break
                        }
                    }
                }
                else
                {
                    throw 'IDNotOAuthServers'
                }
            }
            else
            {
                throw 'IDUnableToGetOAuthConfiguration'
            }

            if ($ModernAuthFound -and -not ($this.IsSharedAddressSpaceEnabled()))
            {
                # error
                throw 'IDModernAuthNotEnabled'
            }
            elseif (-not $ModernAuthFound -and $this.IsSharedAddressSpaceEnabled())
            {
                # error
                throw 'IDModernAuthNotEnabled'
            }
            elseif (-not $ModernAuthFound -and -not ($this.IsSharedAddressSpaceEnabled()))
            {
                # warning
                throw 'IDLegacyModernAuthDetected'
            }

            $ClientAuth = $Configuration.ClientAuthorizationOAuthServerIdentity

            if ([string]::IsNullOrEmpty($ClientAuth) -or ($ClientAuth -ne 'evoSTS'))
            {
                # error
                throw 'IDClientOAuthDisabled'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDModernAuthNotEnabled
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                    $this.Status            = [OPDStatus]::ERROR
                }

                IDNotOAuthServers
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                    $this.Status            = [OPDStatus]::INFO
                }

                IDUnableToGetOAuthConfiguration
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                    $this.Status            = [OPDStatus]::INFO
                }

                IDLegacyModernAuthDetected
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                    $this.Status            = [OPDStatus]::WARNING
                }

                IDClientOAuthDisabled
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                    $this.Status            = [OPDStatus]::ERROR
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
