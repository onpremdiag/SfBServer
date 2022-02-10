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
# Filename: RDCheckTenantModernAuthEnabled .ps1
# Description: Determine if Modern Authentication is enabled
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 5/4/2021 11:59 AM
#
# Last Modified On: 5/4/2021 11:59 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckTenantModernAuthEnabled  : RuleDefinition
{
    RDCheckTenantModernAuthEnabled ([object] $Insight)
    {
        $this.Name        ='RDCheckTenantModernAuthEnabled'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('4DDDE4A2-891B-4779-B442-25F058E9875D')
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

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            if ($this.IsSharedAddressSpaceEnabled())
            {
                $OAuthConfiguration = Get-CsOauthConfiguration -ErrorAction SilentlyContinue

                if (-not [string]::IsNullOrEmpty($OAuthConfiguration))
                {
                    $ClientAdalAuthOverride = $OAuthConfiguration.ClientAdalAuthOverride

                    if (-not [string]::IsNullOrEmpty($ClientAdalAuthOverride) -and $ClientAdalAuthOverride -ne 'Allowed')
                    {
                        throw 'IDModernAuthSfboNotEnabled'
                    }
                }
                else
                {
                    throw 'IDUnableToGetOAuthConfiguration'
                }
            }
            else
            {
                throw 'IDDoNotAllowSharedSipAddressSpace'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDModernAuthSfboNotEnabled
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_) -f 'Allowed', $ClientAdalAuthOverride
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                    $this.Status            = [OPDStatus]::ERROR
                }

                IDUnableToGetOAuthConfiguration
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                    $this.Status            = [OPDStatus]::ERROR
                }

                IDDoNotAllowSharedSipAddressSpace
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
