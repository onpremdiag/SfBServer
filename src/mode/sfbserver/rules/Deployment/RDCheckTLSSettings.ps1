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
# Filename: RDCheckTLSSettings.ps1
# Description: Determine if the TLS 1.2, or better, has been properly enabled
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 11/17/2021 10:30 AM
#
#################################################################################
Set-StrictMode -Version Latest

class RDCheckTLSSettings : RuleDefinition
{
    RDCheckTLSSettings([object] $Insight)
    {
        $this.Name        ='RDCheckTLSSettings'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('8AE216DE-ED9B-4E43-90DE-53B2869F597B')
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
                $tlsSettings = Get-AllTlsSettingsFromRegistry -MachineName $localFE
                $finished    = $false

                $step = 1
                while(-not $finished)
                {
                    switch($step)
                    {
                        1 # TLS 1.2 Server should be enabled
                        {
                            $tls12 = $tlsSettings.tls | Where-Object {$_.TLSVersion -eq '1.2'}

                            if (-not [string]::IsNullOrEmpty($tls12))
                            {
                                if (-not $tls12.ServerDisabledByDefault -and $tls12.ServerEnabled)
                                {
                                    break
                                }
                                else
                                {
                                    throw 'IDTLS12NotEnabled'
                                }
                            }
                            else
                            {
                                throw 'IDTLS12NotEnabled'
                            }
                        }

                        2 # TLS 1.1 should be disabled
                        {
                            $tls11 = $tlsSettings.tls | Where-Object {$_.TLSVersion -eq '1.1'}

                            if (-not [string]::IsNullOrEmpty($tls11))
                            {
                                if ($tls11.ServerDisabledByDefault -and -not $tls11.ServerEnabled)
                                {
                                    break
                                }
                                else
                                {
                                    throw 'IDTLS11NotDisabled'
                                }
                            }
                            else
                            {
                                throw 'IDTLS11NotDisabled'
                            }
                        }

                        3 # TLS 1.0 should be disabled
                        {
                            $tls10 = $tlsSettings.tls | Where-Object {$_.TLSVersion -eq '1.0'}

                            if (-not [string]::IsNullOrEmpty($tls10))
                            {
                                if ($tls10.ServerDisabledByDefault -and -not $tls10.ServerEnabled)
                                {
                                    break
                                }
                                else
                                {
                                    throw 'IDTLS10NotDisabled'
                                }
                            }
                            else
                            {
                                throw 'IDTLS10NotDisabled'
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
                IDTLS12NotEnabled
                {
                    $this.Insight.Name      = 'IDTLSNotEnabled'
                    $this.Insight.Detection = ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.2', $tls12.ServerDisabledByDefault, $tls12.ServerEnabled)
                    $this.Insight.Action    = $global:InsightActions.'IDTLSNotEnabled'
                    $this.Success           = $false
                }

                IDTLS11NotDisabled
                {
                    $this.Insight.Name      = 'IDTLSNotEnabled'
                    $this.Insight.Detection = ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.1', $tls11.ServerDisabledByDefault, $tls11.ServerEnabled)
                    $this.Insight.Action    = $global:InsightActions.'IDTLSNotEnabled'
                    $this.Success           = $false
                }

                IDTLS10NotDisabled
                {
                    $this.Insight.Name      = 'IDTLSNotEnabled'
                    $this.Insight.Detection = ($global:InsightDetections.'IDTLSNotEnabled' -f 'TLS1.0', $tls10.ServerDisabledByDefault, $tls10.ServerEnabled)
                    $this.Insight.Action    = $global:InsightActions.'IDTLSNotEnabled'
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