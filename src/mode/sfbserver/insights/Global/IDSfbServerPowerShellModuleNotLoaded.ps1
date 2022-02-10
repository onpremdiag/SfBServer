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
# Filename: IDSfbServerPowerShellModuleNotLoaded.ps1
# Description: Verifies that the Skype for Business Server PowerShell snap-in is loaded
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class IDSfbServerPowerShellModuleNotLoaded : InsightDefinition
{
    IDSfbServerPowerShellModuleNotLoaded()
    {
        $this.Name      = 'IDSfbServerPowerShellModuleNotLoaded'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('10a8a00e-5b00-4502-9aad-e61e0fad90de')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDSfbServerPowerShellModuleNotLoaded([OPDStatus] $Status)
    {
        $this.Name      = 'IDSfbServerPowerShellModuleNotLoaded'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('10a8a00e-5b00-4502-9aad-e61e0fad90de')
        $this.Status    = $Status
    }
}

