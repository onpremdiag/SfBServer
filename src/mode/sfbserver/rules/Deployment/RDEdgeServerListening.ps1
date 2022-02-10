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
# Filename: RDEdgeServerListening.ps1
# Description: Determine if the edge server is listening on port $global:WinRMHTTPPort
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/4/2020 12:40 PM
#
# Last Modified On: 2/4/2020 12:40 PM
#################################################################################
Set-StrictMode -Version Latest

class RDEdgeServerListening : RuleDefinition
{
    RDEdgeServerListening([object] $Insight)
    {
        $this.Name        ='RDEdgeServerListening'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('93E0A697-D273-4471-9F05-F6D4C62BBBEB')
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

            $EdgePools = @(Get-CsService -EdgeServer | Where-Object {$_.AccessEdgeExternalSipPort -eq $global:SIPSecurePort})

            if (-not [string]::IsNullOrEmpty($EdgePools))
            {
                foreach ($edgePool in $EdgePools)
                {
                    $edgeServers = (Get-CsPool -Identity $edgePool.PoolFqdn).Computers

                    foreach ($edgeServer in $edgeServers)
                    {
                        if(-not (Test-NetConnection -ComputerName $edgeServer -Port $global:WinRMHTTPPort).TcpTestSucceeded)
                        {
                            $this.Success = $false
                            $this.Insight.Detection = $this.Insight.Detection -f $edgeServer
                            break
                        }
                    }
                }
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
