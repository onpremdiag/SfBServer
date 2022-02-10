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
# Filename: IDNoServicePrincipalNames.ps1
# Description: Unable to get service principal name information
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/26/2020 3:42 PM
#
# Last Modified On: 10/26/2020 3:43 PM
#################################################################################
Set-StrictMode -Version Latest

class IDNoServicePrincipalNames : InsightDefinition
{
    IDNoServicePrincipalNames()
    {
        $this.Name      = 'IDNoServicePrincipalNames'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('3500FEDA-DFA3-46FA-AD26-E71FF3133DC5')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDNoServicePrincipalNames([OPDStatus] $Status)
    {
        $this.Name      = 'IDNoServicePrincipalNames'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('3500FEDA-DFA3-46FA-AD26-E71FF3133DC5')
        $this.Status    = $Status
    }
}
