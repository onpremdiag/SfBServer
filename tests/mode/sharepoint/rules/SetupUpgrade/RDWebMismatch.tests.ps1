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
# Filename: RDWebMismatch.tests.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 6/13/2019 1:59 PM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
Set-StrictMode -Version Latest

$sut      = $PSCommandPath -replace '^(.*)\\OnPremDiagtests\\(.*?)\\(.*?)\.tests\.*ps1', '$1\src\$2\$3.ps1'
$root     = $PSCommandPath -replace '^(.*)\\OnPremDiagTests\\(.*)', '$1'
$srcRoot  = "$root\src"
$testRoot = "$root\OnPremDiagTests"
$testMode = $PSCommandPath -match "^(.*)\\OnPremDiagtests\\(.*?)\\(?<Mode>.*?)\\(.*?)\.tests\.*ps1"
$mode     = $Matches.Mode

# Load resource files needed for tests
. "$testRoot\testhelpers\LoadResourceFiles.ps1"
Import-ResourceFiles -Root $srcRoot -MyMode $mode

. "$srcRoot\common\Globals.ps1"
. "$srcRoot\common\Utils.ps1"
. "$srcRoot\common\PowershellRemoting.ps1"
. "$srcRoot\mode\$mode\common\Globals.ps1"
. "$srcRoot\mode\$mode\common\$mode.ps1"
. "$srcRoot\classes\RuleDefinition.ps1"
. "$srcRoot\classes\InsightDefinition.ps1"
. "$srcRoot\mode\$mode\insights\SetupUpgrade\IDWebMismatch.ps1"
. "$testRoot\mocks\SharePointMocks.ps1"
. "$testRoot\mocks\IISMocks.ps1"

. $sut

Describe -Tag 'SharePoint' "RDWebMismatch" {
    Context "RDWebMismatch" {

        $rd = [RDWebMismatch]::new([IDWebMismatch]::new())
        BeforeEach {

            Mock Write-Progress {}

            Mock Write-OPDEventLog {}

            Mock Get-SPWebAppPaths {
                return @(
                    @{
                        Path = "C:\inetpub\wwwroot\wss\VirtualDirectories\2000";
                        Url = "http://contoso:2000"
                    }
                );
            }

            Mock Get-ChildItem {
                return @(
                    @{ Fullname = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\BIN\STSSOAP.DLL" },
                    @{ Fullname = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\STSSOAP.DLL" },
                    @{ Fullname = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\BIN\Microsoft.SharePoint.ApplicationPages.dll" },
                    @{ Fullname = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.ApplicationPages.dll" }
                )
            } #-ParameterFilter { $Recurse -eq $true }

            Mock Get-RemoteItems {
                $ret = @{}
                $ret["STSSOAP.DLL"] = @{
                        FileVersion = "1.0.0.0"
                    }
                $ret["Microsoft.SharePoint.ApplicationPages.dll"] = @{
                        FileVersion = "1.0.0.0"
                    }
                return $ret
            }

            Mock Get-SPServer {
                return @(
                    @{
                        ServiceInstances = @(
                            @{
                                TypeName = "Microsoft SharePoint Foundation Web Application";
                                Status = "Online";
                                Server = @{ Name = "WFE" }
                            }
                        )
                    }
                )
            }

            Mock Test-RemotePath { return $true }

        }

        It "Found no issues with the DLLs" {
            Mock Get-RemoteFilteredChildItem {
                return @(
                    @{
                        Name = "STSSOAP.DLL";
                        VersionInfo = "...FileVersion: 1.0.0.0"
                    },
                    @{
                        Name = "Microsoft.SharePoint.ApplicationPages.dll";
                        VersionInfo = "...FileVersion: 1.0.0.0"
                    }
                )
            }

            $rd.Execute($null)
            $rd.Success | Should -BeTrue
            }

        It "Found errors with the DLLs" {
            Mock Get-RemoteFilteredChildItem {
                return @(
                    @{
                        Name = "STSSOAP.DLL";
                        VersionInfo = "...FileVersion: 1.0.0.1"
                    },
                    @{
                        Name = "Microsoft.SharePoint.ApplicationPages.dll";
                        VersionInfo = "...FileVersion: 1.0.0.0"
                    }
                )
            }

            $rd.Execute($null)
            $rd.Success | Should -BeTrue
        }
    }
}