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
# Filename: IDSIPHostingProviderSharedAddressSpaceEnabled.ps1
# Description: SharedAddressSpace is currently enabled so this is likely a hybrid environment. For hybrid please run 'Presence and IM between On-Premises and Online users is not working (Hybrid deployment) diagnostic
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class IDSIPHostingProviderSharedAddressSpaceEnabled : InsightDefinition
{
    IDSIPHostingProviderSharedAddressSpaceEnabled()
    {
        $this.Name      = 'IDSIPHostingProviderSharedAddressSpaceEnabled'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('8dbcc43d-d245-47b3-b5c9-665dd75540ae')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDSIPHostingProviderSharedAddressSpaceEnabled([OPDStatus] $Status)
    {
        $this.Name      = 'IDSIPHostingProviderSharedAddressSpaceEnabled'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('8dbcc43d-d245-47b3-b5c9-665dd75540ae')
        $this.Status    = $Status
    }
}

