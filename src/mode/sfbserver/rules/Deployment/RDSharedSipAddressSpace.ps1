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
# Filename: RDSharedSipAddressSpace.ps1
# Description: Determine if the online settings have enabled share SIP address space
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/24/2020 9:40 AM
#
# Last Modified On: 1/24/2020 9:40 AM
#################################################################################
Set-StrictMode -Version Latest

class RDSharedSipAddressSpace : RuleDefinition
{
    RDSharedSipAddressSpace([object] $Insight)
    {
        $this.Name        ='RDSharedSipAddressSpace'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('B8719689-EDF1-4BDE-8FF1-63B061567400')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $OL_TenantFedConf = Get-CsTenantFederationConfiguration

            if (-not [string]::IsNullOrEmpty($OL_TenantFedConf))
            {
                $this.Success = $OL_TenantFedConf.SharedSipAddressSpace
            }
            else
            {
                $this.Success = $false
            }
        }
        catch
        {
            $this.Success = $false
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}
