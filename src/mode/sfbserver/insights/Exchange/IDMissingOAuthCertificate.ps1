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
# Filename: IDMissingOAuthCertificate.ps1
# Description: No OAuth certificate found
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/15/2020 3:49 PM
#
# Last Modified On: 10/15/2020 3:49 PM
#################################################################################
Set-StrictMode -Version Latest

class IDMissingOAuthCertificate : InsightDefinition
{
    IDMissingOAuthCertificate()
    {
        $this.Name      = 'IDMissingOAuthCertificate'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('658450A9-C101-4BA3-985B-CB7270107FB4')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDMissingOAuthCertificate([OPDStatus] $Status)
    {
        $this.Name      = 'IDMissingOAuthCertificate'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('658450A9-C101-4BA3-985B-CB7270107FB4')
        $this.Status    = $Status
    }
}
