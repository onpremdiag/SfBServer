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
# Filename: RDTestExchangeCertificateForAutodiscover.ps1
# Description: Determine if the Exchange On-Premises certificate SAN is configured
# for autodiscovery or wildcard
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/21/2020 11:04 AM
#
# Last Modified On: 10/21/2020 11:04 AM
#################################################################################
Set-StrictMode -Version Latest

class RDTestExchangeCertificateForAutodiscover : RuleDefinition
{
    RDTestExchangeCertificateForAutodiscover([object] $Insight)
    {
        $this.Name        ='RDTestExchangeCertificateForAutodiscover'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('A58F553B-822D-4F20-86EE-D735814AF598')
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

            $ExchangeServer  = Get-ParameterDefinition -Object $this -ParameterName 'PDExchangeServer'
            $AutoDiscoverUrl = "https://{0}/autodiscover/autodiscover.json" -f $ExchangeServer
            $Certificate     = Test-CertificateSubject -Url $AutoDiscoverUrl

            if (-not $Certificate)
            {
                throw 'IDAutoDiscoverDoesNotExist'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDAutoDiscoverDoesNotExist
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

                    $this.Success           = $false
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $ExchangeServer
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name)) -f $ExchangeServer
                }
            }
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}