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
# Filename: RDCheckAutoDiscoverURL.ps1
# Description: Determine if the SIP hosting provider AutodiscoverURL is valid
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 1/16/2020 10:54 AM
#
# Last Modified On: 1/16/2020 10:54 AM
#################################################################################
Set-StrictMode -Version Latest

class RDCheckAutoDiscoverURL : RuleDefinition
{
    RDCheckAutoDiscoverURL([object] $Insight)
    {
        $this.Name        ='RDCheckAutoDiscoverURL'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('50189DDE-53A9-44A9-9AF6-0D7343BF6634')
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

            $HostingProvider = SkypeForBusiness\Get-CsHostingProvider | Where-Object {$_.ProxyFqdn -eq $global:SIPProxyFQDN }

            if (-not $HostingProvider)
            {
                $this.Success = $false
            }
            else
            {
                $this.Success = $HostingProvider.AutodiscoverURL -match "^https://(webdir[\w]*)\..*$"
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
