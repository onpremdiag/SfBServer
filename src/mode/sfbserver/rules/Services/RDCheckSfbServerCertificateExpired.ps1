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
# Filename: RDCheckSfbServerCertificateExpired.ps1
# Description: Determine if local system Skype for Business Server certificate
# is expired
#
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckSfbServerCertificateExpired : RuleDefinition
{
    RDCheckSfbServerCertificateExpired([object] $Insight)
    {
        $this.Name        ='RDCheckSfbServerCertificateExpired'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('ec6af2d8-73ea-4c41-98ce-ecd995d936a3')
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

            $validCertificates = @(Get-CsCertificate -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {$_.NotAfter -ge (Get-Date) -and $_.Use -eq "Default"})

            if ($validCertificates.count -eq 0)
            {
                $this.Success = $false
            }
        }
        catch [System.Management.Automation.PropertyNotFoundException]
        {
            $this.Insight.Detection = $global:InsightDetections.'IDPropertyNotFoundException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDPropertyNotFoundException'
            $this.Success           = $false
        }
        catch [System.Management.Automation.CommandNotFoundException]
        {
            $this.Insight.Detection = $global:InsightDetections.'IDCommandNotFoundException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDCommandNotFoundException'
            $this.Success           = $false
        }
        catch
        {
            $this.Insight.Detection = $global:InsightDetections.'IDException' -f $_.Exception.Message
            $this.Insight.Action    = $global:InsightActions.'IDException'
            $this.Success           = $false
        }
        finally
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force
        }
    }
}

