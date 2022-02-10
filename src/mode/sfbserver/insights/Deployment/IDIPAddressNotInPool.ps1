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
# Filename: IDIPAddressNotInPool.ps1
# Description: Unable to locate current IP address in list of Pool IP addresses
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/28/2021 11:51 AM
#
# Last Modified On: 1/28/2021 11:51 AM
#################################################################################
Set-StrictMode -Version Latest

class IDIPAddressNotInPool : InsightDefinition
{
    IDIPAddressNotInPool()
    {
        $this.Name      = 'IDIPAddressNotInPool'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('850C417D-B732-4637-AB11-5A03300183B8')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDIPAddressNotInPool([OPDStatus] $Status)
    {
        $this.Name      = 'IDIPAddressNotInPool'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('850C417D-B732-4637-AB11-5A03300183B8')
        $this.Status    = $Status
    }
}
