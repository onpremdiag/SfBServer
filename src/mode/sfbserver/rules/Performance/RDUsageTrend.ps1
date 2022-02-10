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
# Product Backlog Item 31037: Diagnostic Investment - Response Group Usage
#   Report not working (customer feedback)
#
# Filename: RDUsageTrend.ps1
# Description: Determine if the Usage Report returns results in the expected
# time limit (60 sec)
#
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 10/18/2021 11:37 AM
#
#################################################################################
Set-StrictMode -Version Latest

class RDUsageTrend : RuleDefinition
{
    RDUsageTrend([object] $Insight)
    {
        $this.Name        ='RDUsageTrend'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('24F23EF8-DB46-4BE7-A5F9-7BBA35D8E33A')
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
            $StartTime    = (Get-Date).AddMonths(-1)
            $EndTime      = (Get-Date)
            $WorkFlowUri  = [string]::Empty
            $Size         = '1440'

            $ArgumentList = "StartTime = '$($StartTime)'", "EndTime = '$($EndTime)'",
                            "WorkFlowUri = '$($WorkFlowUri)'", "Size = '$($Size)'"

            $MonitoringDatabase = Get-CsService -MonitoringDatabase #| Select-Object -Property PoolFqdn, SqlInstanceName

            if (-not [string]::IsNullOrEmpty($MonitoringDatabase))
            {
                $SQLDatabase        = $MonitoringDatabase.PoolFqdn

                if (-not [string]::IsNullOrEmpty($MonitoringDatabase.SqlInstanceName))
                {
                    $SQLDatabase = "{0}\{1}" -f $MonitoringDatabase.PoolFqdn, $MonitoringDatabase.SqlInstanceName
                }

                # If we return in <= 60 seconds, it's considered a pass, regardless of results returned
                $SQLArguments = @{
                    ServerInstance = $SQLDatabase
                    Database       = 'LcsCDR'
                    QueryTimeout   = 60
                    ConnectionTime = 60
                    Query          = "EXEC [dbo].[CdrRGSUsageTrend] @_StartTime = `$(StartTime),
                                        @_EndTime = `$(EndTime), @_WorkflowUri = `$(WorkFlowUri),
                                        @_Interval = `$(Size), @_WindowSize = `$(Size)"
                    Variable       = $ArgumentList
                }

                $TimeToRun = Measure-Command { Invoke-Sqlcmd @SQLArguments }

                # Did we timeout?
                if ($TimeToRun.TotalSeconds -gt 60)
                {
                    throw 'IDRGSUsageTrend'
                }
            }
            else
            {
                throw 'IDNoMonitoringRole'
            }
        }
        catch
        {
            switch ($_.ToString())
            {
                IDRGSUsageTrend
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.$_
                    $this.Insight.Action    = $global:InsightActions.$_
                    $this.Success           = $false
                }

                IDNoMonitoringRole
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.$_
                    $this.Insight.Action    = $global:InsightActions.$_
                    $this.Insight.Status    = [OPDStatus]::WARNING
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
