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
# Filename: RDExchangePowerShellCmdletsLoaded.ps1
# Description: Determine if the Exchange cmdlets are loaded. If not, load them.
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 10/20/2020 11:53 AM
#
# Last Modified On: 10/20/2020 11:53 AM
#################################################################################
Set-StrictMode -Version Latest

class RDExchangePowerShellCmdletsLoaded : RuleDefinition
{
    RDExchangePowerShellCmdletsLoaded([object] $Insight)
    {
        $this.Name        ='RDExchangePowerShellCmdletsLoaded'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('DB01183B-BB2A-4D7A-BB20-5336857EE92C')
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

            # Let's see if we've already got the cmdlets (Exchange) that we need access to
            if (-not (Get-Command -Name Get-ClientAccessService -ErrorAction SilentlyContinue))
            {
                $session = New-PSSession -ConfigurationName Microsoft.Exchange `
                                         -ConnectionUri "http://$($obj.ExchangeServer)/PowerShell" `
                                         -Authentication Kerberos `
                                         -Credential $obj.Credential `
                                         -ErrorAction SilentlyContinue

                if (-not [string]::IsNullOrEmpty($session))
                {
                    # Import commands from the Exchange Session
                    $remoteSession = Import-RemoteSession -Session $Session

                    if (-not [string]::IsNullOrEmpty($remoteSession))
                    {
                        # Did we import the command(s)? Let's check
                        if (-not ($remoteSession.ExportedCommands | Where-Object {$_.Keys -eq 'Get-ClientAccessService'}))
                        {
                            throw 'IDUnableToImportExchangeCmdlets'
                        }
                    }
                    else
                    {
                        throw 'IDUnableToImportRemoteSession'
                    }
                }
                else
                {
                    throw 'IDNoSession'
                }
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDUnableToImportExchangeCmdlets
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $obj.ExchangeServer
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name)) -f $obj.ExchangeServer
                }

                IDUnableToImportRemoteSession
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $obj.ExchangeServer
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name)) -f $obj.ExchangeServer
                }

                IDNoSession
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $obj.ExchangeServer
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
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