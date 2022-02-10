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
# Filename: IDEdgeCertsNotOnSan.ps1
# Description: Certificate not located on edge server
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/19/2020 12:28 PM
#
# Last Modified On: 2/19/2020 12:28 PM
#################################################################################
Set-StrictMode -Version Latest

class IDEdgeCertsNotOnSan : InsightDefinition
{
    IDEdgeCertsNotOnSan()
    {
        $this.Name      = 'IDEdgeCertsNotOnSan'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('E7986220-2E42-4973-8AE1-E73AC6EDAB5D')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDEdgeCertsNotOnSan([OPDStatus] $Status)
    {
        $this.Name      = 'IDEdgeCertsNotOnSan'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('E7986220-2E42-4973-8AE1-E73AC6EDAB5D')
        $this.Status    = $Status
    }
}
