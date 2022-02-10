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
# Filename: IDOnlineOnPremAllowedDomainDoNotMatch.ps1
# Description: The allowed domains for online do not match on-prem
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/21/2020 1:18 PM
#
# Last Modified On: 1/21/2020 1:18 PM
#################################################################################
Set-StrictMode -Version Latest

class IDOnlineOnPremAllowedDomainDoNotMatch : InsightDefinition
{
    IDOnlineOnPremAllowedDomainDoNotMatch()
    {
        $this.Name      = 'IDOnlineOnPremAllowedDomainDoNotMatch'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('619F82CA-4AA8-49CF-ABCF-576A0B0D9F12')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDOnlineOnPremAllowedDomainDoNotMatch([OPDStatus] $Status)
    {
        $this.Name      = 'IDOnlineOnPremAllowedDomainDoNotMatch'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('619F82CA-4AA8-49CF-ABCF-576A0B0D9F12')
        $this.Status    = $Status
    }
}

