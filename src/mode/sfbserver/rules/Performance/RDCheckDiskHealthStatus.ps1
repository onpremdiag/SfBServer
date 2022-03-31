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
# Filename: RDCheckDiskHealthStatus.ps1
# Description: Determine if the HealthStatus of the disk is healthy
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/3/2022 11:43:15 AM
#
#################################################################################
Set-StrictMode -Version Latest

class RDCheckDiskHealthStatus : RuleDefinition
{
    RDCheckDiskHealthStatus([object] $Insight)
    {
        $this.Name        ='RDCheckDiskHealthStatus'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('8D3E1767-77E8-4D58-B70D-17CEA02BEDEF')
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

            # Check the disk status on the server for database and log disks,
            # validate its healthy by looking at HealthStatus attribute has
            # the value set to ‘Healthy’
            #
            # If it is not found healthy, notify user with the message, and
            # recommend looking into system event logs for any disk errors
            # and looking at the disk troubleshooting from OS
            # (Operating Systems) perspective
            #

            $DiskHealthStatus = Get-DiskStorageNodeView | Where-Object {$_.HealthStatus -ne 'Healthy'}

            if (-not [string]::IsNullOrEmpty($DiskHealthStatus))
            {
                throw 'IDUnhealthyDisk'
            }
        }
        catch
        {
            switch ($_.ToString())
            {
                IDUnhealthyDisk
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Action    = $global:InsightActions.$_
                    $this.Insight.Detection = $global:InsightDetections.$_
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

