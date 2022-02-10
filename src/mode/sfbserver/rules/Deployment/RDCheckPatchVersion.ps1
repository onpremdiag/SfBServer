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
# Filename: RDCheckPatchVersion.ps1
# Description: Checks Skype for Business version against most current
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 12/1/2020 1:00 PM
#
# Last Modified On: 12/1/2020 1:01 PM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckPatchVersion : RuleDefinition
{
    RDCheckPatchVersion([object] $Insight)
    {
        $this.Name        ='RDCheckPatchVersion'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('06B5032E-FE65-4C40-928E-3439855929CD')
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

            # Determine which version we're running
            $CurrentProduct = Get-CsServerVersion
            if(-not [string]::IsNullOrEmpty($CurrentProduct))
            {
                $ProductName = $global:SkypeForBusinessUpdates |
                                    ForEach-Object {$_.ProductName} |
                                    Sort-Object -Unique |
                                    Where-Object {$CurrentProduct.Contains($_)}

                if(-not [string]::IsNullOrEmpty($ProductName))
                {
                    $expectedPatches = $global:SkypeForBusinessUpdates | Where-Object {$_.ProductName -eq $ProductName}
                    $actualPatches   = Get-csServerPatchVersion

                    foreach($patch in $actualPatches)
                    {
                        $patchFound = $expectedPatches | Where-Object {$_.ComponentName -eq ($patch.ComponentName.Split(',')[1].TrimStart(' '))}

                        if (-not [string]::IsNullOrEmpty($patchFound))
                        {
                            if (([System.Version]$patch.Version).CompareTo($patchFound.Version) -ge 0)
                            {
                                break
                            }
                            else
                            {
                                throw 'IDPatchUpdateAvailable'
                            }
                        }
                    }
                }
                else
                {
                    throw 'IDUnableToGetProductName'
                }
            }
            else
            {
                throw 'IDUnableToGetVersion'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDPatchUpdateAvailable
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_) -f $patch.ComponentName, $patch.Version, $patchFound.Version
                    $this.Insight.Action    = $global:InsightActions.($_) -f $patchFound.Update, $patchFound.Url
                    $this.Insight.Status    = [OPDStatus]::WARNING
                }

                IDUnableToGetProductName
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                }

                IDUnableToGetVersion
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
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