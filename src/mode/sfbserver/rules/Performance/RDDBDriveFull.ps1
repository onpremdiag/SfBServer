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
# Filename: RDDBDriveFull.ps1
# Description: Determines if there are any ES_E_DATABASE_DRIVE_FULL (30596)
# event in the application log
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/8/2022 9:46:29 AM
#
#################################################################################
Set-StrictMode -Version Latest

class RDDBDriveFull : RuleDefinition
{
    RDDBDriveFull([object] $Insight)
    {
        $this.Name        ='RDDBDriveFull'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('FAB0EE31-BB5A-4C12-8539-5E7E1B86B3B2')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        $ES_E_DATABASE_DRIVE_FULL   = 30596

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            # Check the database drive free space and alert if it's approaching its capacity.
            # Alert for event ID 30596 - ES_E_DATABASE_DRIVE_FULL

            $Events = Get-WinEvent -LogName Application -MaxEvents 300 | Where-Object {$_.Id -eq $ES_E_DATABASE_DRIVE_FULL}

            if ($Events)
            {
                throw 'IDSQLDriveFull'
            }

        }
        catch
        {
            switch ($_.ToString())
            {
                IDSQLDriveFull
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

