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
# Filename: RDTestOAuthServerConfiguration.ps1
# Description: Determine if the OAuthServer configuration is correct
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/19/2020 9:52 AM
#
# Last Modified On: 10/19/2020 9:52 AM
#################################################################################
Set-StrictMode -Version Latest

class RDTestOAuthServerConfiguration : RuleDefinition
{
    RDTestOAuthServerConfiguration([object] $Insight)
    {
        $this.Name        ='RDTestOAuthServerConfiguration'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('2F8F9756-9700-449B-81EC-250AADA280EF')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        $expectedValue              = "https://accounts.accesscontrol.windows.net/{0}/metadata/json/1"

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $OAuthServerConfiguration = Get-CsOAuthServer -Identity 'microsoft.sts'

            if (-not [string]::IsNullOrEmpty($OAuthServerConfiguration))
            {
                $TenantID = $OAuthServerConfiguration.Realm

                if (-not [string]::IsNullOrEmpty($TenantID))
                {
                    $expectedValue = $expectedValue -f $TenantID

                    if ($OAuthServerConfiguration.MetadataUrl -ne $expectedValue)
                    {
                        throw 'IDWrongOnlineMetadataUrlConfiguration'
                    }
                }
                else
                {
                    throw 'IDNoTenantIDFound'
                }
            }
            else
            {
                # No oAuth config information returned
                throw 'IDNoOAuthServer'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDWrongOnlineMetadataUrlConfiguration
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $expectedValue, $OAuthServerConfiguration.MetadataUrl
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDNoTenantIDFound
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDNoOAuthServer
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