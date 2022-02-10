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
# Filename: RDCheckWinHttpSettings.ps1
# Description: Determine if the WinHTTP settings have been properly configured for TLS 1.0/1.1 deprecation
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 11/23/2021 12:27 PM
#
#################################################################################
Set-StrictMode -Version Latest

class RDCheckWinHttpSettings : RuleDefinition
{
    RDCheckWinHttpSettings([object] $Insight)
    {
        $this.Name        ='RDCheckWinHttpSettings'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('4424DCEF-A828-43C7-92D8-CFDE80E52C5D')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference

        $WinHTTPSettingsx32 = $WinHTTPSettingsx64 = $null

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            # Product Backlog Item 33706: Diagnostic Investment - Validate Skype for Business Server TLS 1.0 / 1.1 deprecation
            # Diagnostic should only check local FE plus SQL associated with current FE pool

            # Current local FE
            $FEServer = $null
            $Pools    = Get-CSPool -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($Pools))
            {
                 $FEServer = $Pools | Where-Object {$_.Services -like '*Registrar*'} | Where-Object {$_.Fqdn -eq $env:COMPUTERNAME+'.'+$env:USERDNSDOMAIN}
            }

            if (-not [string]::IsNullOrEmpty($FEServer))
            {
                $localFE     = $FEServer.Fqdn
                $WinHTTPSettingsx32 = Invoke-RegistryGetValue -MachineName $localFE `
                                        -SubKey 'SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' `
                                        -GetValue 'DefaultSecureProtocols' -DefaultValue $null
                $WinHTTPSettingsx64 = Invoke-RegistryGetValue -MachineName $localFE `
                                        -SubKey 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' `
                                        -GetValue 'DefaultSecureProtocols' -DefaultValue $null

                $finished    = $false

                if (-not [string]::IsNullOrEmpty($WinHTTPSettingsx32) -or -not [string]::IsNullOrEmpty($WinHTTPSettingsx64))
                {
                    $step = 1
                    while(-not $finished)
                    {
                        switch($step)
                        {
                            1 # Check x32 settings for "DefaultSecureProtocols"=dword:00000AA0
                            {
                                if (-not [string]::IsNullOrEmpty($WinHTTPSettingsx32))
                                {
                                    if ($WinHTTPSettingsx32 -eq 0x0AA0)
                                    {
                                        break
                                    }
                                    else
                                    {
                                        throw 'IDWinHTTPSettingsx32'
                                    }
                                }
                                else
                                {
                                    throw 'IDWinHTTPSettingsx32'
                                }
                            }

                            2 # Check x64 settings for "DefaultSecureProtocols"=dword:00000AA0
                            {
                                if (-not [string]::IsNullOrEmpty($WinHTTPSettingsx64))
                                {
                                    if ($WinHTTPSettingsx64 -eq 0x0AA0)
                                    {
                                        break
                                    }
                                    else
                                    {
                                        throw 'IDWinHTTPSettingsx64'
                                    }
                                }
                                else
                                {
                                    throw 'IDWinHTTPSettingsx64'
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
                elseif ([string]::IsNullOrEmpty($WinHTTPSettingsx32))
                {
                    throw 'IDWinHTTPSettingsx32'
                }
                else
                {
                     throw 'IDWinHTTPSettingsx64'
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
                IDWinHTTPSettingsx32
                {
                    $this.Insight.Name      = 'IDWinHttpSecureProtocols'
                    $this.Insight.Detection = ($global:InsightDetections.'IDWinHttpSecureProtocols' -f 'SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp', $WinHTTPSettingsx32, ('0x{0:X2}' -f $WinHTTPSettingsx32))
                    $this.Insight.Action    = $global:InsightActions.'IDWinHttpSecureProtocols'
                    $this.Success           = $false
                }

                IDWinHTTPSettingsx64
                {
                    $this.Insight.Name      = 'IDWinHttpSecureProtocols'
                    $this.Insight.Detection = ($global:InsightDetections.'IDWinHttpSecureProtocols' -f 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp', $WinHTTPSettingsx64, ('0x{0:X2}' -f $WinHTTPSettingsx64))
                    $this.Insight.Action    = $global:InsightActions.'IDWinHttpSecureProtocols'
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