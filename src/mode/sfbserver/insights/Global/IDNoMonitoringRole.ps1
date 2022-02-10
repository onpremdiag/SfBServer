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
# Filename: IDNoMonitoringRole.ps1
# Description: No monitoring database found
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 12/10/2021 9:44 AM
#
#################################################################################
Set-StrictMode -Version Latest

class IDNoMonitoringRole : InsightDefinition
{
    IDNoMonitoringRole()
    {
        $this.Name      = 'IDNoMonitoringRole'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('FE18C2A9-66A6-4FF7-8750-626DEFA70F29')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDNoMonitoringRole([OPDStatus] $Status)
    {
        $this.Name      = 'IDNoMonitoringRole'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('FE18C2A9-66A6-4FF7-8750-626DEFA70F29')
        $this.Status    = $Status
    }
}