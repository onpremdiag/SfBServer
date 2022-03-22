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
# Filename: RDAllowFederatedPartners.ps1
# Description: Determine if allow all federated partners are allowed
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/23/2020 3:16 PM
#
# Last Modified On: 1/23/2020 3:16 PM
#################################################################################
Set-StrictMode -Version Latest

class RDAllowFederatedPartners : RuleDefinition
{
    RDAllowFederatedPartners([object] $Insight)
    {
        $this.Name        ='RDAllowFederatedPartners'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('7B7FA8F4-BE5E-4284-AEA4-C45364D31D17')
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
            $OL_AccessEdge    = $null
            $OL_TenantFedConf = $null
            $OL_OpenFed       = $null

            try
            {
                $OP_AccessEDGE = Get-CsAccessEdgeConfiguration
            }
            catch
            {
                $OP_AccessEDGE = $null
            }

            try
            {
                $OL_TenantFedConf = Get-CsTenantFederationConfiguration

                #Bug 34828: SFB OPD - Federation is not working : False positive error when open federation is enabled
                $OL_OpenFed       = ($OL_TenantFedConf.AllowedDomains.AllowedDomain.Count -eq 0) -and ($OL_TenantFedConf.BlockedDomains.Count -eq 0)
            }
            catch
            {
                $OL_OpenFed = $false
            }

            if (($null -ne $OP_AccessEdge) -and ($null -ne $OL_OpenFed))
            {
                $this.Success = ($OP_AccessEDGE.EnablePartnerDiscovery -eq $OL_OpenFed)
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