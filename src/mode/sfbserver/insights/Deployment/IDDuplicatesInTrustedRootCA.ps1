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
# Filename: IDDuplicatesInTrustedRootCA.ps1
# Description: Duplicate certificates found in Root CA
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 12/10/2020 10:50 AM
#
# Last Modified On: 12/10/2020 10:50 AM
#################################################################################
Set-StrictMode -Version Latest

class IDDuplicatesInTrustedRootCA : InsightDefinition
{
    IDDuplicatesInTrustedRootCA()
    {
        $this.Name      = 'IDDuplicatesInTrustedRootCA'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('FB9A638E-6808-4B24-989E-043190FC45B8')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDDuplicatesInTrustedRootCA([OPDStatus] $Status)
    {
        $this.Name      = 'IDDuplicatesInTrustedRootCA'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('FB9A638E-6808-4B24-989E-043190FC45B8')
        $this.Status    = $Status
    }
}
