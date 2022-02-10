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
# Filename: IDSQLDriveFull.ps1
# Description: SQL Drives full event in Application log
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/8/2022 9:51:17 AM
#
#################################################################################
Set-StrictMode -Version Latest

class IDSQLDriveFull : InsightDefinition
{
    IDSQLDriveFull()
    {
        $this.Name      = 'IDSQLDriveFull'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('A1D79C07-837E-4643-8AE9-FBE8DFB304CC')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDSQLDriveFull([OPDStatus] $Status)
    {
        $this.Name      = 'IDSQLDriveFull'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('A1D79C07-837E-4643-8AE9-FBE8DFB304CC')
        $this.Status    = $Status
    }
}

