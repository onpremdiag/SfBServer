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
# Filename: IDNoEdgeCertsFound.ps1
# Description: No certificates found on edge server
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 3/22/2022 1:40:44 PM
#
#################################################################################
Set-StrictMode -Version Latest


class IDNoEdgeCertsFound : InsightDefinition
{
    IDNoEdgeCertsFound()
    {
        $this.Name      = 'IDNoEdgeCertsFound'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('1F81BA3A-3CF4-43DE-A755-1ECB0D546C8E')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDNoEdgeCertsFound([OPDStatus] $Status)
    {
        $this.Name      = 'IDNoEdgeCertsFound'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('1F81BA3A-3CF4-43DE-A755-1ECB0D546C8E')
        $this.Status    = $Status
    }
}
