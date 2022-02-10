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
# Filename: IDEdgeConfigDoNotAllowDnsSrvRouting.ps1
# Description: DNS Server routing is not configured for Edge Server
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/13/2020 10:42 AM
#
# Last Modified On: 1/13/2020 10:42 AM
#################################################################################
Set-StrictMode -Version Latest

class IDEdgeConfigDoNotAllowDnsSrvRouting : InsightDefinition
{
    IDEdgeConfigDoNotAllowDnsSrvRouting()
    {
        $this.Name      = 'IDEdgeConfigDoNotAllowDnsSrvRouting'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('3860543A-6A47-470C-83DF-A681E23C120F')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDEdgeConfigDoNotAllowDnsSrvRouting([OPDStatus] $Status)
    {
        $this.Name      = 'IDEdgeConfigDoNotAllowDnsSrvRouting'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('3860543A-6A47-470C-83DF-A681E23C120F')
        $this.Status    = $Status
    }
}

