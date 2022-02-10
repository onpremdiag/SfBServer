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
# Filename: RDCheckLocalSQLServerSchemaVersion.ps1
# Description: Check local SQL Server database installed version versus expected version
# Owner: João Loureiro <joaol@microsoft.com>
################################################################################
Set-StrictMode -Version Latest

class RDCheckLocalSQLServerSchemaVersion : RuleDefinition
{
    RDCheckLocalSQLServerSchemaVersion([object] $Insight)
    {
        $this.Name        ='RDCheckLocalSQLServerSchemaVersion'
        $this.Description = $global:RuleDescriptions.($this.Name)
        $this.ExecutionId = [guid]::Empty
        $this.Id          = [guid]::new('2cd95520-aa91-4ada-ad60-7678bbea5b1a')
        $this.Success     = $true
        $this.Insight     = $Insight
        $this.EventId     = Get-EventId($this.Name)
    }

    [bool] RunTest()
    {
        # Test-CsDatabase displays a progress bar. We're going to temporarily turn it off
        $OriginalProgressPreference = $global:ProgressPreference

        try
        {
            Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

            $csLocalDatabases = Test-CsDatabase -LocalService -WarningAction SilentlyContinue

            if(-not [string]::IsNullOrEmpty($csLocalDatabases))
            {
                foreach($csLocalDatabase in ($csLocalDatabases | `
                                             Where-Object {[string]$_.ExpectedVersion -ne [string]$_.InstalledVersion}))
                {
                    if ($csLocalDatabase.DatabaseName -ne "xds")
                    {
                        throw 'IDLocalSQLServerSchemaVersionMismatch'
                     }
                }
            }
            else
            {
                # Test-CsDatabase returned a null
                throw 'IDTestCsDatabaseNoResults'
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
            $exception = $_

            switch($_.ToString())
            {
                IDLocalSQLServerSchemaVersionMismatch
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_.ToString()
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f $csLocalDatabase.DatabaseName, `
                                                    [string]$csLocalDatabase.InstalledVersion, `
                                                    [string]$csLocalDatabase.ExpectedVersion
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                IDTestCsDatabaseNoResults
                {
                    $this.Success           = $false
                    $this.Insight.Name      = $_.ToString()
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name)
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name)
                }

                'Command execution failed: Exception has been thrown by the target of an invocation.'
                {
                    $this.Success           = $false
                    $this.Insight.Name      = "TargetInvocationException"
                    $this.Insight.Detection = $exception.ErrorDetails.Message
                    $this.Insight.Action    = $exception.ErrorDetails.RecommendedAction
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

        return $this.Success
    }

    [void] Execute([object] $obj)
    {
        $global:CurrentRule = $this.Id
        $this.Success       = $this.RunTest()
    }
}

