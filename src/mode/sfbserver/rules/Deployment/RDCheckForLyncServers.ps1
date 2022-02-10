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
# Filename: RDCheckForLyncServers.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/18/2021 10:34 AM
#
# Last Modified On: 3/18/2021 10:34 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckForLyncServers : RuleDefinition
{
    RDCheckForLyncServers([object] $Insight)
    {
        $this.Name        ='RDCheckForLyncServers'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('5F4E0CDC-3866-4725-8F8D-EE7053A1DE73')
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

            if (@(Get-CSService | Where-Object {$_.Version -lt 7}).Count -ne 0)
            {
                throw 'IDLyncServerFound'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDLyncServerFound
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
