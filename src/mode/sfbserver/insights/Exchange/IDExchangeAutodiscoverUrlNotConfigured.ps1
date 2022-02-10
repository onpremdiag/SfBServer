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
# Filename: IDExchangeAutodiscoverUrlNotConfigured.ps1
# Description: No information returned from Get-CsOAuthConfiguration call
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 9/24/2020 3:46 PM
#
# Last Modified On: 9/24/2020 3:46 PM
#################################################################################
Set-StrictMode -Version Latest

class IDExchangeAutodiscoverUrlNotConfigured : InsightDefinition
{
    IDExchangeAutodiscoverUrlNotConfigured()
    {
        $this.Name      = 'IDExchangeAutodiscoverUrlNotConfigured'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('B3026737-BF4C-40AB-85CE-6DDC6939FE5C')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDExchangeAutodiscoverUrlNotConfigured([OPDStatus] $Status)
    {
        $this.Name      = 'IDExchangeAutodiscoverUrlNotConfigured'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('B3026737-BF4C-40AB-85CE-6DDC6939FE5C')
        $this.Status    = $Status
    }
}