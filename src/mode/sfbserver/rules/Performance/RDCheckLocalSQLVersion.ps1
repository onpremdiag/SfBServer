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
# Filename: RDCheckLocalSQLVersion.ps1
# Description: Determine if the Local SQL Express version is running the
# latest service pack/cumulative update
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/28/2022 11:37:20 AM
#
#################################################################################
Set-StrictMode -Version Latest

class RDCheckLocalSQLVersion : RuleDefinition
{
    RDCheckLocalSQLVersion([object] $Insight)
    {
        $this.Name        ='RDCheckLocalSQLVersion'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('3DC230EA-1C2C-493C-A365-F9E07FF8A76D')
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

            $ServerFqdn = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($ServerFqdn))
            {
                $ServerFqdnName = $ServerFqdn.Name
                if (-not [string]::IsNullOrEmpty($ServerFqdnName))
                {
                    if ($ServerFqdnName -is [array])
                    {
                        $ServerFqdnName = $ServerFqdnName[0]
                    }

                    $PoolFqdn = Get-CsComputer -Identity $ServerFqdnName -ErrorAction SilentlyContinue

                    if (-not [string]::IsNullOrEmpty($PoolFqdn))
                    {
                        $Service = Get-CsService -UserServer -PoolFqdn $PoolFqdn.Pool -ErrorAction SilentlyContinue

                        if (-not [string]::IsNullOrEmpty($Service))
                        {
                            $BackendFqdn = $Service.UserDatabase.split(":")[1]

                            if(-not [string]::IsNullOrEmpty($BackendFqdn))
                            {
                                $LocalSqlExpress = Test-CsDatabase -ConfiguredDatabases `
                                                                     -SqlServerFqdn $BackendFqdn `
                                                                     -ErrorAction SilentlyContinue `
                                                                     -WarningAction SilentlyContinue
                                if (-not [string]::IsNullOrEmpty($LocalSqlExpress))
                                {
                                    foreach ($instance in ($LocalSqlExpress | Where-Object {$_.DatabaseName -eq 'rtcxds' -and $_.SQLServerVersion.Edition -like '*Express*'}))
                                    {
                                        $SQLExpressVersion = $instance.SQLServerVersion.ProductVersion

                                        if ([string]::IsNullOrEmpty($SQLExpressVersion))
                                        {
                                            throw 'IDCheckSQLVersion'
                                        }
                                        else
                                        {
                                            $ExpressSqlVersion = $global:SqlExpressVersions | Where-Object {$_.ProductVersion.Major -eq $SQLExpressVersion.Major}

                                            if($SQLExpressVersion.CompareTo($ExpressSQLVersion.ProductVersion) -lt 0)
                                            {
                                                throw 'IDUpgradeSQLExpress'
                                            }
                                        }
                                    }
                                }
                                else
                                {
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
                        throw 'IDUnableToGetServiceInfo'
                    }
                }
                else
                {
                    throw 'IDUnableToResolveServerFQDN'
                }
            }
            else
            {
                throw 'IDUnableToResolveDNSName'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDUpgradeSQLExpress
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($_) -f $ExpressSQLVersion.ProductVersion.ToString(), $SQLExpressVersion.ToString())
                    $this.Insight.Action    = ($global:InsightActions.($_) -f $ExpressSQLVersion.Description,$ExpressSqlVersion.URL)
                    $this.Success           = $false
                }

                IDTestCsDatabaseNoResults
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_) -f $BackendFqdn
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDUnableToResolveDNSName
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDUnableToResolveServerFQDN
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDUnableToGetServiceInfo
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
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