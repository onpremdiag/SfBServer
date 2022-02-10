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
# Filename: RDServerSocketCoreRatio.ps1
# Description: Determine if the number of sockets/cores meets the requirements
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/26/2022 3:41:32 PM
#
#################################################################################
Set-StrictMode -Version Latest

class RDServerSocketCoreRatio : RuleDefinition
{
    RDServerSocketCoreRatio([object] $Insight)
    {
        $this.Name        ='RDServerSocketCoreRatio'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('5F96FDEC-5532-4194-AABD-67722CDB638F')
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
            $SQLCores = (Invoke-SQLCmd -Query "select cpu_count from sys.dm_os_sys_info" `
                                       -ServerInstance 'localhost\RTCLOCAL').cpu_count

            if ([string]::IsNullOrEmpty($SQLCores) -or $SQLCores -lt 4)
            {
                throw 'IDInsufficientSQLCores'
            }
        }
        catch
        {
            switch ($_.ToString())
            {
                IDInsufficientSQLCores
                {
                    $this.Insight.Name      = $_
                    $this.Success           = $false
                    $this.Insight.Detection = $global:InsightDetections.($_)

                    if([string]::IsNullOrEmpty($SQLCores))
                    {
                        $this.Insight.Status    = 'ERROR'
                        $this.Insight.Action    = ($global:InsightActions.($_) -f 4, 0)
                    }
                    else
                    {
                        $this.Insight.Status    = 'WARNING'
                        $this.Insight.Action    = ($global:InsightActions.($_) -f 4, $SQLCores)
                    }
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
