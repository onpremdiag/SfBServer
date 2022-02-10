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
# Filename: RDCheckOnlineSharedSipAddressSpace.ps1
# Description: Determine if the online settings have disabled share SIP address space
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 9/27/2021 1:01 PM
#
#################################################################################
Set-StrictMode -Version Latest

# Bug 33933: Get-CsTenantFederationConfiguration | fl SharedSipAddressSpace

class RDCheckOnlineSharedSipAddressSpace : RuleDefinition
{
    RDCheckOnlineSharedSipAddressSpace([object] $Insight)
    {
        $this.Name        ='RDCheckOnlineSharedSipAddressSpace'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('8CA0FAD5-6733-4336-8B55-BFBB99398B64')
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
                $this.Success = -not $OL_TenantFedConf.SharedSipAddressSpace
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
            if (-not $this.Success)
            {
                $this.Insight.Detection = $global:InsightDetections.'IDSIPHostingProviderSharedAddressSpaceEnabled'
                $this.Insight.Action    = $global:InsightActions.'IDSIPSharedAddressSpaceEnabled'
            }
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}
