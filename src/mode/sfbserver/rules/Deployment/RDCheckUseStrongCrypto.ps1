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
# Filename: RDCheckUseStrongCrypto.ps1
# Description: Determine if SchUseStrongCrypto is set correctly for TLS 1.2
#
# Owner: mmcintyr <mmcintyr@microsoft.com>
# Created On: 12/13/2021 3:43 PM
#
#################################################################################
Set-StrictMode -Version Latest

class RDCheckUseStrongCrypto : RuleDefinition
{
    RDCheckUseStrongCrypto([object] $Insight)
    {
        $this.Name        ='RDCheckUseStrongCrypto'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('0AF485C6-7778-4BF6-98D3-CAF5A52F3867')
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
            $FEServer = $null
            $Pools    = Get-CSPool -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($Pools))
            {
                 $FEServer = $Pools | Where-Object {$_.Services -like '*Registrar*'} | Where-Object {$_.Fqdn -eq $env:COMPUTERNAME+'.'+$env:USERDNSDOMAIN}
            }

            if (-not [string]::IsNullOrEmpty($FEServer))
            {
                $localFE        = $FEServer.Fqdn
                $cryptoSettings = Get-AllTlsSettingsFromRegistry -MachineName $localFE
                $finished       = $false

                foreach($dotNetVersion in ($cryptoSettings.Net | ForEach-Object {$_.NetVersion}))
                {
                    $settings = $cryptoSettings.Net | Where-Object {$_.NetVersion -eq $dotNetVersion}

                    if ($settings.SchUseStrongCrypto)
                    {
                        if (-not $settings.WowSchUseStrongCrypto)
                        {
                            throw 'IDWowStrongCryptoNotSet'
                        }
                    }
                    else
                    {
                        throw 'IDStrongCryptoNotSet'
                    }
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
                IDWowStrongCryptoNotSet
                {
                    $this.Insight.Name      = 'IDStrongCryptoNotSet'
                    $this.Insight.Detection = ($global:InsightDetections.'IDStrongCryptoNotSet' -f $dotNetVersion, 1, [int]$settings.WowSchUseStrongCrypto)
                    $this.Insight.Action    = $global:InsightActions.'IDStrongCryptoNotSet'
                    $this.Success           = $false
                }

                IDStrongCryptoNotSet
                {
                    $this.Insight.Name      = 'IDStrongCryptoNotSet'
                    $this.Insight.Detection = ($global:InsightDetections.'IDStrongCryptoNotSet' -f $dotNetVersion, 1, [int]$settings.SchUseStrongCrypto)
                    $this.Insight.Action    = $global:InsightActions.'IDStrongCryptoNotSet'
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