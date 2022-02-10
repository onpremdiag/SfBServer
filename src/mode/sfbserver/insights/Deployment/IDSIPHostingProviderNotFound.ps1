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
# Filename: IDSIPHostingProviderNotFound.ps1
# Description: Hosting provider for Skype for Business Online federation
# tenants is missing
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/10/2020 12:19 PM
#
# Last Modified On: 1/10/2020 12:20 PM
#################################################################################
Set-StrictMode -Version Latest

class IDSIPHostingProviderNotFound : InsightDefinition
{
    IDSIPHostingProviderNotFound()
    {
        $this.Name      = 'IDSIPHostingProviderNotFound'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('F1EA2B43-0776-40FA-9ED2-F3728C918DCC')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDSIPHostingProviderNotFound([OPDStatus] $Status)
    {
        $this.Name      = 'IDSIPHostingProviderNotFound'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('F1EA2B43-0776-40FA-9ED2-F3728C918DCC')
        $this.Status    = $Status
    }
}