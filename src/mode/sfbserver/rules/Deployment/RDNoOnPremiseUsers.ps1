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
# Filename: RDNoOnPremiseUsers.ps1
# Description: Determine if there are any online users still present
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 7/13/2021 1:56 PM
#
#################################################################################
Set-StrictMode -Version Latest

class RDNoOnPremiseUsers : RuleDefinition
{
    RDNoOnPremiseUsers([object] $Insight)
    {
        $this.Name        ='RDNoOnPremiseUsers'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('6D58D525-7A0C-41F1-8E0C-792CA858DEC2')
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

            $Users = Get-CsUser -Filter { HostingProvider -eq "SRV:"}

            $OnPremiseUsers = $Users | Select-Object Identity, SipAddress, UserPrincipalName, RegistrarPool

            $Users = Get-CsOnlineUser

            $OnlineUsers = $Users | Where-Object {$_.Enabled -and -not [string]::IsNullOrEmpty($_.OnPremHostingProvider)} | `
            Select-object -Property SipAddress, InterpretedUserType, OnPremHostingProvider

            if (-not [string]::IsNullOrEmpty($OnlineUsers) -or $OnlineUsers -is [array] -or -not [string]::IsNullOrEmpty($OnPremiseUsers) -or $OnPremiseUsers -is [array])
            {
                throw 'IDOnPremiseUsersFound'
            }
            else
            {
                $OnlineUsers = $Users | Where-Object {$_.Enabled -and `
                     -not [string]::IsNullOrEmpty($_.MCOValidationError) -or `
                     -not [string]::IsNullOrEmpty($_.ProvisioningStamp) -or `
                     -not [string]::IsNullOrEmpty($_.SubProvisioningStamp)
                } | Select-object -Property SipAddress, InterpretedUserType, OnPremHostingProvider, MCOValidationError, *ProvisioningStamp

                if (-not [string]::IsNullOrEmpty($OnlineUsers) -or $OnlineUsers -is [array])
                {
                    throw 'IDUsersValidationErrorFound'
                }
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDOnPremiseUsersFound
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
                    $this.Success           = $false
                }

                IDUsersValidationErrorFound
                {
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $global:InsightDetections.($_)
                    $this.Insight.Action    = $global:InsightActions.($_)
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
