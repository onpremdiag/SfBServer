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
# Filename: RDCsPartnerApplication.ps1
# Description: Determine if the partner application exists and is configured
# with the proper value
#
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/25/2020 9:55 AM
#
# Last Modified On: 9/25/2020 9:55 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCsPartnerApplication : RuleDefinition
{
    RDCsPartnerApplication([object] $Insight)
    {
        $this.Name        ='RDCsPartnerApplication'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('30B80F4B-8DE3-414A-911C-E8381101FA9A')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        $expectedValue              = "/Autodiscover/metadata/json/1"

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $PartnerApplication = Get-CsPartnerApplication -Identity EXCHANGE -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($PartnerApplication))
            {
                if ($PartnerApplication.AuthToken -notlike "*$($expectedValue)")
                {
                    # wrong metadaturl configuration
                    throw 'IDWrongMetadataUrlConfiguration'
                }
            }
            else
            {
                # unable to get partner application information
                throw 'IDNoPartnerApplication'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDWrongMetadataUrlConfiguration
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f "*$($expectedValue)", $PartnerApplication.AuthToken
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDNoPartnerApplication
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