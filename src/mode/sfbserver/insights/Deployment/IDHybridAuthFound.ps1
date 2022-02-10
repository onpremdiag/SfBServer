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
# Filename: IDHybridAuthFound.ps1
# Description: Hybrid authentication found
# Owner: MIke McIntyre <mmcintyr@microsoft.com>
# Created On: 4/14/2021 4:13 PM
#
# Last Modified On: 4/14/2021 4:14 PM
#################################################################################
Set-StrictMode -Version Latest

class IDHybridAuthFound : InsightDefinition
{
    IDHybridAuthFound()
    {
        $this.Name      = 'IDHybridAuthFound'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('59E6F025-0BF6-4D96-9D77-39889C0C8C28')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDHybridAuthFound([OPDStatus] $Status)
    {
        $this.Name      = 'IDHybridAuthFound'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('59E6F025-0BF6-4D96-9D77-39889C0C8C28')
        $this.Status    = $Status
    }
}
