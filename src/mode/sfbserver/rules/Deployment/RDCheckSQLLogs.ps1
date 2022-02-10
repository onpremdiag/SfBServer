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
# Filename: RDCheckSQLLogs.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/8/2021 2:08 PM
#
# Last Modified On: 1/8/2021 2:08 PM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckSQLLogs : RuleDefinition
{
    RDCheckSQLLogs([object] $Insight)
    {
        $this.Name        ='RDCheckSQLLogs'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('9ACBA769-CA88-4241-8CF1-A9451B4DD6A1')
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
                                $csRemoteDatabases = Test-CsDatabase -ConfiguredDatabases `
                                                                     -SqlServerFqdn $BackendFqdn `
                                                                     -ErrorAction SilentlyContinue `
                                                                     -WarningAction SilentlyContinue
                                if (-not [string]::IsNullOrEmpty($csRemoteDatabases))
                                {
                                    foreach ($remoteDatabase in ($csRemoteDatabases | Where-Object {$_.DatabaseName -eq 'rtcxds'}))
                                    {
                                        $logSpace = Invoke-SqlCmd -ServerInstance $remoteDatabase.DataSource `
                                                        -Query 'DBCC SQLPERF(logspace)'

                                        if (-not [string]::IsNullOrEmpty($logSpace))
                                        {
                                            $logSpaceUsed = ($logSpace | Where-Object {$_.'Database Name' -eq 'rtcxds'}).'Log Space Used (%)'

                                            if ($logSpaceUsed -gt $global:SQLLogSpaceThreshold)
                                            {
                                                throw 'IDLogSpaceThreshold'
                                            }
                                        }
                                        else
                                        {
                                            throw 'IDNoLogSpace'
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
                IDLogSpaceThreshold
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_) -f $remoteDatabase.DataSource, `
                                                $remoteDatabase.DatabaseName, `
                                                $global:SQLLogSpaceThreshold, `
                                                $logSpaceUsed
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDNoLogSpace
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_) -f $remoteDatabase.DataSource, `
                                                $remoteDatabase.DatabaseName
                    $this.Insight.Action    = $global:InsightActions.($_)
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