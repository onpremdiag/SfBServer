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
# Filename: IDUCSConnectivityNotAvailable.ps1
# Description: Unified Contact Store not available due exchange connectivity problems
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class IDUCSConnectivityNotAvailable : InsightDefinition
{
    IDUCSConnectivityNotAvailable()
    {
        $this.Name      = 'IDUCSConnectivityNotAvailable'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('f9040a91-0e21-456d-a01a-48f9663f5816')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDUCSConnectivityNotAvailable([OPDStatus] $Status)
    {
        $this.Name      = 'IDUCSConnectivityNotAvailable'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('f9040a91-0e21-456d-a01a-48f9663f5816')
        $this.Status    = $Status
    }
}

