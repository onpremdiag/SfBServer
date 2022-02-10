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
# Filename: RDCheckTooManyCertsRootCA.ps1
# Description: Check if there are more than 100 certificates in root CA store
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckTooManyCertsRootCA : RuleDefinition
{
    RDCheckTooManyCertsRootCA([object] $Insight)
    {
        $this.Name        ='RDCheckTooManyCertsRootCA'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('c2ddb934-b260-48ce-99dc-312c45bfeab1')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule         = $this.Id
        $OriginalProgressPreference = $global:ProgressPreference
        $this.Success               = $true

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            if (Test-Path -Path $global:LocalMachineCertificateStore)
            {
                $certificates = Get-ChildItem -Path $global:LocalMachineCertificateStore -ErrorAction SilentlyContinue

                if($null -ne $certificates)
                {
                    if ($certificates.Count -gt $global:MaxNumberOfRootCertificates)
                    {
                        $this.Success           = $false
                        $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f ($certificates.Count).ToString()
                        $this.Insight.Action    = $global:InsightActions.($this.Insight.Name) -f $global:MaxNumberOfRootCertificates
                    }
                }
                else
                {
                    # No certificates found
                    $this.Insight.Detection = $global:InsightDetections.'IDNoCertificatesFound'
                    $this.Insight.Action    = $global:InsightActions.'IDNoCertificatesFound'
                    $this.Success           = $false
                }
            }
            else
            {
                # Somehow, the certificate store is not being found. This is a PROBLEM!
                $this.Insight.Detection = $global:InsightDetections.'IDLocalCertStoreNotFound'
                $this.Insight.Action    = $global:InsightActions.'IDLocalCertStoreNotFound'
                $this.Success           = $false
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

