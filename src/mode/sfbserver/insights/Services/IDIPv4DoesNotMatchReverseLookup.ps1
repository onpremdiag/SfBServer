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
# Filename: IDIPv4DoesNotMatchReverseLookup.ps1
# Description: IPv4 name resolution does not match reverse dns lookup
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class IDIPv4DoesNotMatchReverseLookup : InsightDefinition
{
    IDIPv4DoesNotMatchReverseLookup()
    {
        $this.Name      = 'IDIPv4DoesNotMatchReverseLookup'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('A248C4FB-FFCB-48F0-9FED-731B67D926EA')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDIPv4DoesNotMatchReverseLookup([OPDStatus] $Status)
    {
        $this.Name      = 'IDIPv4DoesNotMatchReverseLookup'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('A248C4FB-FFCB-48F0-9FED-731B67D926EA')
        $this.Status    = $Status
    }
}