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
# Filename:  IDSQLPerfIssues.ps1
# Description: SQL has encountered I/O requests taking too long
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/7/2022 4:16:26 PM
#
#################################################################################
Set-StrictMode -Version Latest

class IDSQLPerfIssues : InsightDefinition
{
    IDSQLPerfIssues()
    {
        $this.Name      = 'IDSQLPerfIssues'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('10EF6583-78D7-42BE-B3C7-9699C1166A6E')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDSQLPerfIssues([OPDStatus] $Status)
    {
        $this.Name      = 'IDSQLPerfIssues'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('10EF6583-78D7-42BE-B3C7-9699C1166A6E')
        $this.Status    = $Status
    }
}
