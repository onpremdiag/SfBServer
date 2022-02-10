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
# Filename: IDSIPHostingProviderAutodiscoverURLInvalid.ps1
# Description: The AuotdiscoverURL for the SIP hosting provider is invalid
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/16/2020 11:05 AM
#
# Last Modified On: 1/16/2020 11:05 AM
#################################################################################
Set-StrictMode -Version Latest

class IDSIPHostingProviderAutodiscoverURLInvalid : InsightDefinition
{
    IDSIPHostingProviderAutodiscoverURLInvalid()
    {
        $this.Name      = 'IDSIPHostingProviderAutodiscoverURLInvalid'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('7E690C60-B982-4EC4-BAB3-5445C62C3832')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDSIPHostingProviderAutodiscoverURLInvalid([OPDStatus] $Status)
    {
        $this.Name      = 'IDSIPHostingProviderAutodiscoverURLInvalid'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('7E690C60-B982-4EC4-BAB3-5445C62C3832')
        $this.Status    = $Status
    }
}
