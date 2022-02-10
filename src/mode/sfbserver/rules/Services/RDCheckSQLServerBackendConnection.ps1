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
# Filename: RDCheckSQLServerBackendConnection.ps1
# Description: Check if SQL Server backend connectivity is operational
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckSQLServerBackendConnection : RuleDefinition
{
    RDCheckSQLServerBackendConnection([object] $Insight)
    {
        $this.Name        ='RDCheckSQLServerBackendConnection'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('319f7c78-d73b-418a-a0e1-5937d0dcbe32')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [bool] RunTest()
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        [bool] $Success             = $true

        try
        {
            # Test-CsDatabase displays a progress bar. We're going to temporarily turn it off
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $ServerFqdn = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($ServerFqdn))
            {
                $ServerFqdnName = $ServerFqdn.Name

                if ($null -ne $ServerFqdnName)
                {
                    $PoolFqdn = Get-CsComputer -Identity $ServerFqdn.Name -ErrorAction SilentlyContinue
                    if ($null -ne $PoolFqdn.Pool)
                    {
                        $Service = Get-CsService -UserServer -PoolFqdn $PoolFqdn.Pool -ErrorAction SilentlyContinue

                        if (-not [string]::IsNullOrEmpty($Service))
                        {
                            if (-not [string]::IsNullOrEmpty($Service.UserDatabase))
                            {
                                $BackendFqdn = $Service.UserDatabase.split(":")[1]

                                if(-not [string]::IsNullOrEmpty($BackendFqdn))
                                {
                                    $csRemoteDatabases = Test-CsDatabase -ConfiguredDatabases `
                                                                         -SqlServerFqdn $BackendFqdn `
                                                                         -ErrorAction SilentlyContinue `
                                                                         -WarningAction SilentlyContinue
                                    if ([string]::IsNullOrEmpty($csRemoteDatabases))
                                    {
                                        # Test-CsDatabase returned a null
                                        throw 'IDTestCsDatabaseNoResults'
                                    }
                                }
                            }
                            else
                            {
                                throw 'IDUnableToGetServiceInfo'
                            }
                        }
                        else
                        {
                            # Service information not available
                            throw 'IDUnableToGetServiceInfo'
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
            $Success                = $false
        }
        catch
        {
            switch($_.ToString())
            {
                IDTestCsDatabaseNoResults
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $Success                = $false
                }

                IDUnableToGetServiceInfo
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $Success                = $false
                }

                IDUnableToResolveServerFQDN
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $Success                = $false
                }

                IDUnableToResolveDNSName
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $Success                = $false
                }

                IDException
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_) -f $_.Exception.Message
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $Success                = $false
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

        return $Success
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule = $this.Id
        $this.Success       = $this.RunTest()
    }

}

