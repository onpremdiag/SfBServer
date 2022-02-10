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
# Filename: IDLogSpaceThreshold.ps1
# Description: SQL Log Space has reached its threshold value (80%)
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/11/2021 4:19 PM
#
# Last Modified On: 1/11/2021 4:19 PM
#################################################################################
Set-StrictMode -Version Latest

class IDLogSpaceThreshold : InsightDefinition
{
    IDLogSpaceThreshold()
    {
        $this.Name      = 'IDLogSpaceThreshold'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('5648C00E-B29A-4FE5-9E51-B70F4BA31F5E')
        $this.Status    = [OPDStatus]::ERROR
    }

    IDLogSpaceThreshold([OPDStatus] $Status)
    {
        $this.Name      = 'IDLogSpaceThreshold'
        $this.Action    = $global:InsightActions.($this.Name)
        $this.Detection = $global:InsightDetections.($this.Name)
        $this.Id        = [guid]::new('5648C00E-B29A-4FE5-9E51-B70F4BA31F5E')
        $this.Status    = $Status
    }
}

