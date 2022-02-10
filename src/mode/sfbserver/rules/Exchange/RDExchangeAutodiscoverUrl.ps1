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
# Filename: RDExchangeAutodiscoverUrl.ps1
# Description: Determine if the OAuth ExchangeAutodiscoverUrl is well configured
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/24/2020 3:24 PM
#
# Last Modified On: 9/24/2020 3:24 PM
#################################################################################
Set-StrictMode -Version Latest

class RDExchangeAutodiscoverUrl : RuleDefinition
{
    RDExchangeAutodiscoverUrl([object] $Insight)
    {
        $this.Name        ='RDExchangeAutodiscoverUrl'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('240C948A-DF21-4654-8B31-4D6178FF0BA7')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        $expectedValue              = "/Autodiscover/Autodiscover.svc"

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $oAuthConfiguration = Get-CsOAuthConfiguration

            if (-not [string]::IsNullOrEmpty($oAuthConfiguration))
            {
                if ($oAuthConfiguration.ExchangeAutodiscoverUrl -notlike "*$($expectedValue)*")
                {
                    # Not well configured for exchange on-premises
                    throw 'IDExchangeAutodiscoverUrlNotConfigured'
                }
            }
            else
            {
                # No oAuth config information returned
                throw 'IDNoOauthConfigurationFound'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDExchangeAutodiscoverUrlNotConfigured
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f "*$($expectedValue)*", $oAuthConfiguration.ExchangeAutodiscoverUrl
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDNoOauthConfigurationFound
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