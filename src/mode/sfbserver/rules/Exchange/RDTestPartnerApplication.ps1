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
# Filename: RDTestPartnerApplication.ps1
# Description: Determine if the Exchange application service exists and has
# the correct values
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/27/2020 3:45 PM
#
# Last Modified On: 10/27/2020 3:45 PM
#################################################################################
Set-StrictMode -Version Latest

class RDTestPartnerApplication : RuleDefinition
{
    RDTestPartnerApplication([object] $Insight)
    {
        $this.Name        ='RDTestPartnerApplication'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('912367CC-9B14-4EF4-91E1-E99913F3A42C')
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

            $ServiceName = "00000002-0000-0ff1-ce00-000000000000"

            $PartnerApplication = Get-CsPartnerApplication -Identity "Microsoft.Exchange"

            if (-not [string]::IsNullOrEmpty($PartnerApplication))
            {
                if ($PartnerApplication.Enabled)
                {
                    if ($PartnerApplication.ApplicationIdentifier -ne $ServiceName)
                    {
                        throw 'IDWrongPartnerApplication'
                    }
                }
                else
                {
                    throw 'IDPartnerApplicationDisabled'
                }
            }
            else
            {
                throw 'IDNoPartnerApplication'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDNoPartnerApplication
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDPartnerApplicationDisabled
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDWrongPartnerApplication
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
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
