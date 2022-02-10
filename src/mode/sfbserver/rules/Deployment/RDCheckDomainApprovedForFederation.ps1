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
# Filename: RDCheckDomainApprovedForFederation.ps1
# Description: Determine if target domain is approved for federation
# Owner: Jo�o Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckDomainApprovedForFederation : RuleDefinition
{
    RDCheckDomainApprovedForFederation([object] $Insight)
    {
        $this.Name        ='RDCheckDomainApprovedForFederation'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('d6e9f80c-3d37-4086-9a95-cecc18c27138')
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

            $EdgeConfiguration = Get-CsAccessEdgeConfiguration
            $RemoteDomainFqdn  = Get-ParameterDefinition -Object $this -ParameterName 'PDRemoteFqdnDomain'

            if ($EdgeConfiguration.EnablePartnerDiscovery)
            {
                $BlockedDomain    = Get-CsBlockedDomain | Where-Object {$_.Domain -eq $RemoteDomainFqdn }

                if (-not [string]::IsNullOrEmpty($BlockedDomain))
                {
                    $this.Success           = $false
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f $RemoteDomainFqdn
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name) -f $RemoteDomainFqdn
                }
            }
            else
            {
                $AllowedDomain    = Get-CsAllowedDomain | Where-Object {$_.Domain -eq $RemoteDomainFqdn }

                if ([string]::IsNullOrEmpty($AllowedDomain))
                {
                    $this.Success           = $false
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f $RemoteDomainFqdn
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name) -f $RemoteDomainFqdn
                }
            }
        }
        catch [System.Management.Automation.PropertyNotFoundException]
        {
            $this.Insight.Detection = $global:InsightDetections.'IDPropertyNotFoundException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDPropertyNotFoundException'
            $this.Success           = $false
        }
        catch [System.Management.Automation.CommandNotFoundException]
        {
            $this.Insight.Detection = $global:InsightDetections.'IDCommandNotFoundException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDCommandNotFoundException'
            $this.Success           = $false
        }
        catch
        {
            $this.Insight.Detection = $global:InsightDetections.'IDException'
            $this.Insight.Action    = $global:InsightActions.'IDException'
            $this.Success           = $false
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}

