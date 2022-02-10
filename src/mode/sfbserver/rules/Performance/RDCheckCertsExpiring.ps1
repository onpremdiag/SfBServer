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
# Filename: RDCheckCertsExpiring.ps1
# Description: Determines if any Skype for Business Server certs are near expiry
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 2/2/2022 11:12:25 AM
#
#################################################################################
Set-StrictMode -Version Latest

class RDCheckCertsExpiring : RuleDefinition
{
    RDCheckCertsExpiring([object] $Insight)
    {
        $this.Name        ='RDCheckCertsExpiring'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('9045F20B-F45D-4F77-AEF7-AA75445F1537')
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

            # Check all the certificates on the local server configured for
            # Skype for Business. Look for expiring date within next 45 days.
            # If found, alert user on renewing the specific certificate using
            # a message.
            $expiry               = (Get-Date).AddDays(45)
            $ExpiringCertificates = Get-CsCertificate | Where-Object {$_.NotAfter -lt $expiry}

            if (-not [string]::IsNullOrEmpty($ExpiringCertificates))
            {
                if ($ExpiringCertificates.Count -gt 0)
                {
                    throw 'IDExpiringCertificates'
                }
            }
        }
        catch
        {
            switch ($_.ToString())
            {
                IDExpiringCertificates
                {
                    $sb = New-Object -TypeName System.Text.StringBuilder

                    foreach($expiringCertficate in $ExpiringCertificates)
                    {
                        $sb.AppendLine() | Out-Null
                        $sb.AppendLine("   $($global:MiscStrings.'CertSubject'): {0}" -f $expiringCertficate.Subject) | Out-Null
                        $sb.AppendLine("$($global:MiscStrings.'CertThumbprint'): {0}" -f $expiringCertficate.Thumbprint) | Out-Null
                        $sb.AppendLine("       $($global:MiscStrings.'CertUse'): {0}" -f $expiringCertficate.Use) | Out-Null
                        $sb.AppendLine("$($global:MIscStrings.'CertExpiresOn'): {0}" -f $expiringCertficate.NotAfter) | Out-Null
                    }

                    $this.Insight.Name      = $_
                    $this.Insight.Action    = $global:InsightActions.$_
                    $this.Insight.Detection = ($global:InsightDetections.$_ -f $sb.ToString())
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

