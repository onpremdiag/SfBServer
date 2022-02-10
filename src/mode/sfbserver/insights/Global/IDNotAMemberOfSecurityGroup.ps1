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
# Filename: IDNotAMemberOfSecurityGroup.ps1
# Description: Current user is not a member of RTC or RBAC Server groups
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/15/2020 10:46 AM
#
# Last Modified On: 1/15/2020 10:46 AM
#################################################################################
Set-StrictMode -Version Latest

class IDNotAMemberOfSecurityGroup : InsightDefinition
{
    IDNotAMemberOfSecurityGroup()
    {
        $this.Name      = 'IDNotAMemberOfSecurityGroup'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('B9A367F3-61D2-41EE-9EF8-73920C0370C0')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDNotAMemberOfSecurityGroup([OPDStatus] $Status)
    {
        $this.Name      = 'IDNotAMemberOfSecurityGroup'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('B9A367F3-61D2-41EE-9EF8-73920C0370C0')
        $this.Status    = $Status
    }
}

