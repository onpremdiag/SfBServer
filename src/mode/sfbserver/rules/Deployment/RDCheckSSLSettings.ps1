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
# Filename: RDCheckSSLSettings.ps1
# Description: Checks to see if SSL 3.0/SSL 2.0 are disabled properly
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 11/22/2021 3:14 PM
#
#################################################################################
Set-StrictMode -Version Latest

class RDCheckSSLSettings : RuleDefinition
{
    RDCheckSSLSettings([object] $Insight)
    {
        $this.Name        ='RDCheckSSLSettings'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('ED24425E-9B20-40BE-8BAD-52166755C8B3')
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

            # Product Backlog Item 33706: Diagnostic Investment - Validate Skype for Business Server TLS 1.0 / 1.1 deprecation
            # Diagnostic should only check local FE plus SQL associated with current FE pool

            # Current local FE
            $FEServer    = $null
            $Pools       = Get-CSPool -ErrorAction SilentlyContinue
            $LocalServer = $env:COMPUTERNAME+'.'+$env:USERDNSDOMAIN

            if (-not [string]::IsNullOrEmpty($Pools))
            {
                # Bug 34470: TLS checks not detecting front end server
                $FEServer = $Pools | Where-Object {$_.Services -like '*Registrar*'} | Where-Object {$_.Computers -like "*$($LocalServer)*"}
            }

            if (-not [string]::IsNullOrEmpty($FEServer))
            {
                $localFE     = $LocalServer
                $SSLSettings = Get-AllTlsSettingsFromRegistry -MachineName $localFE
                $finished    = $false

                $step = 1
                while(-not $finished)
                {
                    switch($step)
                    {
                        1 # SSL 3.0 should be disabled by default (true) and not enabled (false)
                        {
                            $ssl30 = $SSLSettings.ssl | Where-Object {$_.SSLVersion -eq '3.0'}

                            if (-not [string]::IsNullOrEmpty($ssl30))
                            {
                                if ($ssl30.ServerDisabledByDefault -and -not $ssl30.ServerEnabled)
                                {
                                    break
                                }
                                else
                                {
                                    throw 'IDSSL30NotDisabled'
                                }
                            }
                            else
                            {
                                throw 'IDSSL30NotDisabled'
                            }
                        }

                        2 # SSL 2.0 should be disabled by default (true) and not enabled (false)
                        {
                            $ssl20 = $SSLSettings.SSL | Where-Object {$_.SSLVersion -eq '2.0'}

                            if (-not [string]::IsNullOrEmpty($ssl20))
                            {
                                if ($ssl20.ServerDisabledByDefault -and -not $ssl20.ServerEnabled)
                                {
                                    break
                                }
                                else
                                {
                                    throw 'IDSSL20NotDisabled'
                                }
                            }
                            else
                            {
                                throw 'IDSSL20NotDisabled'
                            }
                        }

                        default
                        {
                            $finished = $true
                        }
                    }

                    $step++
                }
            }
            else
            {
                throw 'IDNotFEMachine'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDSSL30NotDisabled
                {
                    $this.Insight.Name      = 'IDSSLNotDisabled'
                    $this.Insight.Detection = ($global:InsightDetections.'IDSSLNotDisabled' -f 'SSL 3.0', $ssl30.ServerDisabledByDefault, $ssl30.ServerEnabled)
                    $this.Insight.Action    = $global:InsightActions.'IDSSLNotDisabled'
                    $this.Success           = $false
                }

                IDSSL20NotDisabled
                {
                    $this.Insight.Name      = 'IDTLSNotEnabled'
                    $this.Insight.Detection = ($global:InsightDetections.'IDSSLNotDisabled' -f 'SSL 2.0', $ssl20.ServerDisabledByDefault, $ssl20.ServerEnabled)
                    $this.Insight.Action    = $global:InsightActions.'IDSSLNotDisabled'
                    $this.Success           = $false
                }

                IDNotFEMachine
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
