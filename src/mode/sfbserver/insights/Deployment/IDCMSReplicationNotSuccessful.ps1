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
# Filename: IDCMSReplicationNotSuccessful.ps1
# Description: On-Prem CMS Replication was not successful
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/14/2020 10:55 AM
#
# Last Modified On: 1/14/2020 10:55 AM
#################################################################################
Set-StrictMode -Version Latest

class IDCMSReplicationNotSuccessful : InsightDefinition
{
    IDCMSReplicationNotSuccessful()
    {
        $this.Name      = 'IDCMSReplicationNotSuccessful'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('C9624143-DBCE-4391-B58B-873F851B839C')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDCMSReplicationNotSuccessful([OPDStatus] $Status)
    {
        $this.Name      = 'IDCMSReplicationNotSuccessful'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('C9624143-DBCE-4391-B58B-873F851B839C')
        $this.Status    = $Status
    }
}