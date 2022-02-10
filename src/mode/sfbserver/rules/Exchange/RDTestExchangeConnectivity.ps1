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
# Filename: RDTestExchangeConnectivity.ps1
# Description: Verifies that the Skype for Business Server Storage Service is
# working on a Front End Server.
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/1/2020 1:08 PM
#
# Last Modified On: 10/1/2020 1:08 PM
#################################################################################
Set-StrictMode -Version Latest

class RDTestExchangeConnectivity : RuleDefinition
{
    RDTestExchangeConnectivity([object] $Insight)
    {
        $this.Name        ='RDTestExchangeConnectivity'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('11230A83-A251-4859-90E7-78084BE5B869')
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
            $currentSipAddress = Get-ParameterDefinition -Object $this -ParameterName 'PDSipAddress'

            if (-not [string]::IsNullOrEmpty($currentSipAddress))
            {
                $connectivity = Test-CsExStorageConnectivity -SipUri $currentSipAddress -ErrorAction SilentlyContinue

                if ($connectivity -notlike '*passed*')
                {
                    # Test failed
                    throw 'IDNoExchangeConnectivity'
                }
            }
            else
            {
                # no sip address found - we shouldn't hit this
                throw 'IDNoSIPAddress'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDNoExchangeConnectivity
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name) -f $currentSipAddress)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDNoSIPAddress
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name) -f $currentSipAddress)
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name) -f $currentSipAddress)
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