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
# Filename: RDDuplicatesInTrustedRootCA.ps1
# Description: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 12/7/2020 12:29 PM
#
# Last Modified On: 12/7/2020 12:30 PM
#################################################################################
Set-StrictMode -Version Latest

class RDDuplicatesInTrustedRootCA : RuleDefinition
{
    RDDuplicatesInTrustedRootCA([object] $Insight)
    {
        $this.Name        ='RDDuplicatesInTrustedRootCA'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('8D1C58CC-411D-4E58-982D-96CA886BBC23')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        [bool] $Success             = $true

        try
        {
            # Test-CsDatabase displays a progress bar. We're going to temporarily turn it off
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            if (Test-Path -Path $global:LocalMachineCertificateStore)
            {
                $DuplicateCerts = Get-ChildItem -Path $global:LocalMachineCertificateStore |
                                    Group-Object -Property Thumbprint |
                                    Where-Object {$_.Count -gt 1} |
                                    Select-Object -ExpandProperty Group |
                                    Select-Object -Property Thumbprint, FriendlyName, Issuer, Subject

                if (-not [string]::IsNullOrEmpty($DuplicateCerts))
                {
                    throw 'IDDuplicatesInTrustedRootCA'
                }
            }
            else
            {
                throw 'IDLocalCertStoreNotFound'
            }
        }
        catch
        {
            switch($_.ToString())
            {
                IDDuplicatesInTrustedRootCA
                {
                    $sb = New-Object Text.StringBuilder
                    foreach ($cert in ($DuplicateCerts | Sort-Object -Unique))
                    {
                        $msg = $global:InsightDetections.($_) -f $cert.FriendlyName, $cert.Issuer, $cert.Subject, $cert.Thumbprint
                        $sb.AppendLine($msg) | Out-Null
                    }

                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = $sb.ToString()
                    $this.Insight.Action    = ($global:InsightActions.($this.Insight.Name)) -f $global:LocalMachineCertificateStore
                }

                IDLocalCertStoreNotFound
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_
                    $this.Insight.Detection = ($global:InsightDetections.($this.Insight.Name)) -f $global:LocalMachineCertificateStore
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