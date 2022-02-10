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
# Filename: RDSfbServerPowerShellModuleLoaded.ps1
# Description: Determine if this is a Skype for Business Server frontend and the PowerShell snap-in is available
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDSfbServerPowerShellModuleLoaded : RuleDefinition
{
    RDSfbServerPowerShellModuleLoaded([object] $Insight)
    {
        $this.Name        ='RDSfbServerPowerShellModuleLoaded'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('1b1171fb-7f0e-4eae-96eb-90a40b564f13')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule = $this.Id

        if (Test-SfbServerPSModuleIsInstalled)
        {
            $this.Success = Test-SfbServerPSModuleIsLoaded
        }
        else
        {
            # PowerShell Module is not installed. Tell them where to get it
            $this.Success           = $false
            $this.Insight.Detection = $global:InsightDetections.'IDSfBOnlinePShellNotInstalled'
            $this.Insight.Action    = $global:InsightActions.'IDSfBOnlinePShellNotInstalled'
        }
    }
}

