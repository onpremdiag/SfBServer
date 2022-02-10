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
# Filename: RDIsUniversalServerAdmin.ps1
# Description: Determine if the current user has access to the required cmdlets
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/9/2020 3:51 PM
#
# Last Modified On: 1/9/2020 3:51 PM
#################################################################################
Set-StrictMode -Version Latest

class RDIsUniversalServerAdmin : RuleDefinition
{
    RDIsUniversalServerAdmin([object] $Insight)
    {
        $this.Name        ='RDIsUniversalServerAdmin'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('95D367FD-6238-4BB2-919E-4CB2D27015BC')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule = $this.Id

        if (Initialize-Module -ModuleName 'ActiveDirectory')
        {
            $isAMember = (Test-IsUSAMember -SAMAccountName 'RTCUniversalServerAdmins') -or
                         (Test-IsUSAMember -SAMAccountName 'CsServerAdministrator') -or
                         (Test-IsUSAMember -SAMAccountName 'CsHelpdesk')

            if (-not $IsAMember)
            {
                $this.Success = $false
                $this.Insight.Detection = $this.Insight.Detection -f ("{0}@{1}" -f $env:USERNAME, $env:USERDOMAIN)
            }
        }
        else
        {
            # Unable to load Active Directory Module
            $this.Success           = $false
            $this.Insight.Detection = $global:InsightDetections.'IDUnableToLoadADModule'
            $this.Insight.Action    = $global:InsightActions.'IDUnableToLoadADModule'
        }
    }
}