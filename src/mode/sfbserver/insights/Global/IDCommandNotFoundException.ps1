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
# Filename: IDCommandNotFoundException.ps1
# Description: Unable to locate command
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/19/2020 2:57 PM
#
# Last Modified On: 10/19/2020 2:57 PM
#################################################################################
Set-StrictMode -Version Latest

class IDCommandNotFoundException : InsightDefinition
{
    IDCommandNotFoundException()
    {
        $this.Name      = 'IDCommandNotFoundException'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('AEE29934-5C3F-4E62-B106-7E239DE00DE2')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDCommandNotFoundException([OPDStatus] $Status)
    {
        $this.Name      = 'IDCommandNotFoundException'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('AEE29934-5C3F-4E62-B106-7E239DE00DE2')
        $this.Status    = $Status
    }
}