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
# Filename: Insight.ps1
# Description: Insight definition and factory classes
# Owner: mmcintyr@microsoft.com
# Created On: 07/31/2018 17:15:30
################################################################################
Set-StrictMode -Version Latest

enum OPDStatus
{
    ERROR   = 1
    WARNING = 2
    INFO    = 4
    SUCCESS = 8
}

#
# Insight Definition and Factory classes
#

class InsightDefinition
{
    # Properties
    [guid] $Id
    [String] $Name
    [String] $Detection
    [String] $Action
    [OPDStatus] $Status

    # Constructor(s)
    InsightDefinition()
    {
        # Empty by design
    }
}
