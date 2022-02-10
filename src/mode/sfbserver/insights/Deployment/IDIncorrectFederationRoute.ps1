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
# Filename: IDIncorrectFederationRoute.ps1
# Description: More than one edge pool server configured for federation
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/14/2020 12:52 PM
#
# Last Modified On: 1/14/2020 12:53 PM
#################################################################################
Set-StrictMode -Version Latest

class IDIncorrectFederationRoute : InsightDefinition
{
    IDIncorrectFederationRoute()
    {
        $this.Name      = 'IDIncorrectFederationRoute'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('D9DE193F-78FC-437F-8B8E-11F5F551EC23')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDIncorrectFederationRoute([OPDStatus] $Status)
    {
        $this.Name      = 'IDIncorrectFederationRoute'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('D9DE193F-78FC-437F-8B8E-11F5F551EC23')
        $this.Status    = $Status
    }
}
