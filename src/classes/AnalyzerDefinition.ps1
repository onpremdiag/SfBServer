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
# Filename: AnalyzerDefinition.ps1
# Description: Analyzer definition and factory classes
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
# Analyzer Definition and Factory classes
#

class AnalyzerDefinition
{
    # Properties
    [bool] $Success
    [guid] $ExecutionId
    [guid] $Id
    [object[]] $RuleDefinitions
    [String] $Description
    [string] $ErrorMessage
    [String] $Name
    [object[]] $Results
    [bool] $Executed
    [uint16] $EventId
    [uint16] $Order
    [OPDStatus] $Status
    [object[]] $ParameterDefinitions
    [String] $Metrics
    [System.DateTime] $Expiry = (Get-Date).AddDays(1)

    # Constructor(s)
    AnalyzerDefinition()
    {
        # Empty by design
    }

    [void] Execute([Object] $Obj=$null)
    {
        throw("Must Override Method")
    }
}
