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
# Filename: IDInsufficientMemory2015.ps1
# Description: Insufficient memory for SFB2019 front end server
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/26/2022 12:44:34 PM
#
#################################################################################
Set-StrictMode -Version Latest

class IDInsufficientMemory2015 : InsightDefinition
{
    IDInsufficientMemory2015()
    {
        $this.Name      = 'IDInsufficientMemory2015'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('CD845A28-EC9C-42C9-95F9-005D0CD5AA14')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDInsufficientMemory2015([OPDStatus] $Status)
    {
        $this.Name      = 'IDInsufficientMemory2015'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('CD845A28-EC9C-42C9-95F9-005D0CD5AA14')
        $this.Status    = $Status
    }
}