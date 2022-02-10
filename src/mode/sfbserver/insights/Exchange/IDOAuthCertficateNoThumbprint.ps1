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
# Filename: IDOAuthCertficateNoThumbprint.ps1
# Description: No thumbprint was found on the certificate
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/15/2020 3:44 PM
#
# Last Modified On: 10/15/2020 3:44 PM
#################################################################################
Set-StrictMode -Version Latest

class IDOAuthCertficateNoThumbprint : InsightDefinition
{
    IDOAuthCertficateNoThumbprint()
    {
        $this.Name      = 'IDOAuthCertficateNoThumbprint'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('C4A163AA-9F66-4DAA-8F8A-2E018077E11C')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDOAuthCertficateNoThumbprint([OPDStatus] $Status)
    {
        $this.Name      = 'IDOAuthCertficateNoThumbprint'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('C4A163AA-9F66-4DAA-8F8A-2E018077E11C')
        $this.Status    = $Status
    }
}
