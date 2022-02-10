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
# Filename: RDCheckSharedAddressSpaceNotEnabled.ps1
# Description: Determine if the SIP hosting provider has SharedAddressSpace disabled
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckSharedAddressSpaceNotEnabled : RuleDefinition
{
    RDCheckSharedAddressSpaceNotEnabled([object] $Insight)
    {
        $this.Name        ='RDCheckSharedAddressSpaceNotEnabled'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('12e7c01a-d8fe-4d13-b5e4-e28fe10d083a')
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

            $HostingProvider = Get-CsHostingProvider | Where-Object {$_.ProxyFqdn -eq $global:SIPProxyFQDN }

            if ($HostingProvider)
            {
                if ($HostingProvider.EnabledSharedAddressSpace)
                {
                    throw $this.Insight.Name
                }
            }
            else
            {
                throw "IDNoSIPProxyFqdnFound"
            }
        }
        catch
        {
            switch ($_.ToString())
            {

                $this.Insight.Name
                {
                    $this.Success = $false
                }

                IDNoSIPProxyFqdnFound
                {
                    $this.Insight.Name      = 'IDNoSIPProxyFqdnFound'
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                    $this.Success           = $false
                }

                default
                {
                    $LogArguments = @{
                        LogName   = $global:EventLogName
                        Source    = "Rules"
                        EntryType = "Error"
                        Message   = $_
                        EventId   = 9002
                    }

                    Write-EventLog @LogArguments

                    $this.Success = $false
                }
            }
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}