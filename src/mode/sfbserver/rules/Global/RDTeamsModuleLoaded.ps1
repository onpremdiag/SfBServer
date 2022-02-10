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
# Filename: RDTeamsModuleLoaded.ps1
# Description: Determine if the required version MicrosoftTeams module is loaded
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 6/21/2021 11:35 AM
#
#################################################################################
Set-StrictMode -Version Latest

class RDTeamsModuleLoaded : RuleDefinition
{
    RDTeamsModuleLoaded([object] $Insight)
    {
        $this.Name        ='RDTeamsModuleLoaded'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('F984DD96-DB30-416B-997F-9D15E0C590BC')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule = $this.Id

        if (Test-ModuleLoaded -ModuleName $global:MicrosoftTeamsModule)
        {
            $this.Success = $true
        }
        else
        {
            # MicrosoftTeams Module is not installed. Tell them where to get it
            $this.Success           = $false
            $this.Insight.Detection = $global:InsightDetections.'IDTeamsModuleNotLoaded'
            $this.Insight.Action    = $global:InsightActions.'IDTeamsModuleNotLoaded'
        }
    }
}