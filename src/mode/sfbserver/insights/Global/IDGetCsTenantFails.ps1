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
# Filename: IDGetCsTenantFails.ps1
# Description: Call to Get-CsTenant has failed
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 4/19/2021 3:24 PM
#
# Last Modified On: 4/19/2021 3:24 PM
#################################################################################
Set-StrictMode -Version Latest

class IDGetCsTenantFails : InsightDefinition
{
    IDGetCsTenantFails()
    {
        $this.Name      = 'IDGetCsTenantFails'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('B07F4A0C-CC80-42A5-81D2-E40FC67D66F0')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDGetCsTenantFails([OPDStatus] $Status)
    {
        $this.Name      = 'IDGetCsTenantFails'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('B07F4A0C-CC80-42A5-81D2-E40FC67D66F0')
        $this.Status    = $Status
    }
}

