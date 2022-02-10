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
# Filename: RDCheckUserUCSConnectivity.ps1
# Description: Determine if user contact list can effectively retrieved from Exchange
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckUserUCSConnectivity : RuleDefinition
{
    RDCheckUserUCSConnectivity([object] $Insight)
    {
        $this.Name        ='RDCheckUserUCSConnectivity'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('e5924c3d-d4af-43cf-b45e-989f42bdbadb')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        $currentSipAddress          = $null
        $currentSipAddress          = Get-ParameterDefinition -Object $this -ParameterName 'PDSipAddress'

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $ServerFqdn = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($ServerFqdn))
            {
                $ServerFqdnName = $ServerFqdn.Name

                if (-not [string]::IsNullOrEmpty($ServerFqdnName))
                {
                    $PoolFqdn = Get-CsComputer -Identity $ServerFqdnName -ErrorAction SilentlyContinue

                    if (-not [string]::IsNullOrEmpty($PoolFqdn.Pool))
                    {
                        $ucsStatus = Test-CsUnifiedContactStore -TargetFqdn $PoolFqdn.Pool -UserSipAddress $currentSipAddress -ErrorAction SilentlyContinue

                        if (-not [string]::IsNullOrEmpty($ucsStatus))
                        {
                            if ($ucsStatus.Result -eq "Failure")
                            {
                                $this.Success           = $false
                                $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                                $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                            }
                        }
                    }
                    else
                    {
                        # Server Pool FQDN is null
                        throw 'IDUnableToResolveServerFQDN'
                    }
                }
                else
                {
                    # Unable to resolve ServerFqdnName
                    throw 'IDUnableToResolveServerFQDN'
                }
            }
            else
            {
                # Unable to Resolve-DnsName
                throw 'IDUnableToResolveDNSName'
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
                IDUnableToResolveServerFQDN
                {
                    $this.Insight.Detection = $global:InsightDetections.'IDUnableToResolveServerFQDN'
                    $this.Insight.Action    = $global:InsightActions.'IDUnableToResolveServerFQDN'
                    $this.Success           = $false
                }

                IDUnableToResolveDNSName
                {
                    $this.Insight.Detection = $global:InsightDetections.'IDUnableToResolveDNSName'
                    $this.Insight.Action    = $global:InsightActions.'IDUnableToResolveDNSName'
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

