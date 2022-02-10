################################################################################
# MIT License
#
# Copyright (c) 2020 Microsoft and Contributors
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
# Filename: Create-SankeyData.ps1
# Description: Create Source->Destination records for Sankey Chart generation
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 5/7/2020 12:05 PM
#
# Last Modified On: 5/7/2020 1:35 PM
#################################################################################

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string] $SourceDirectory,

    [Parameter(Mandatory = $false)]
    [string] $TestRoot = "$SourceDirectory\OnPremDiagTests",

    [Parameter(Mandatory = $false)]
    [string] $FilePath =  (Join-Path -Path $SourceDirectory -ChildPath "SankeyData.csv"),

    [Parameter(Mandatory = $false)]
    [string] $Output = (Join-Path -Path $SourceDirectory -ChildPath "BuildArtifacts"),

    [Parameter(Mandatory = $true)]
    [string] $Product
)

Set-StrictMode -Version Latest

$sourceRoot = Join-Path -Path $SourceDirectory -ChildPath "src"

# Load resource files needed for tests
. (Join-Path -Path $sourceRoot -ChildPath common\Utils.ps1)
. (Join-Path -Path $sourceRoot -ChildPath common\Globals.ps1)

Initialize-CommonResourceStrings -Root $sourceRoot

. (Join-Path -Path $sourceRoot -ChildPath classes\ParameterDefinition.ps1)
. (Join-Path -Path $sourceRoot -ChildPath classes\InsightDefinition.ps1)
. (Join-Path -Path $sourceRoot -ChildPath classes\RuleDefinition.ps1)
. (Join-Path -Path $sourceRoot -ChildPath classes\AnalyzerDefinition.ps1)
. (Join-Path -Path $sourceRoot -ChildPath classes\ScenarioDefinition.ps1)

# Added type to allow for dependent rule definition to load
Add-Type -TypeDefinition @"
namespace Microsoft.SharePoint.Administration
{
    public enum SPObjectStatus
    {
        Online         = 0,
        Disabled       = 1,
        Offline        = 2,
        Unprovisioning = 3,
        Provisioning   = 4,
        Upgrading      = 5,
    }
}
"@


$global:scriptName = ($MyInvocation.MyCommand.Name).Split('.')[0]

$list      = @()

if ([string]::IsNullOrEmpty($Product))
{
    $products = Get-ChildItem -Path "$sourceRoot\mode" -Directory
}
else
{
    $products = Get-ChildItem -Path "$sourceRoot\mode" -Directory | Where-Object {$_.PSPath -match $Product}
}

foreach ($prod in $products)
{
    Initialize-ModeResourceStrings -MyMode $prod.basename -Root $SourceRoot

    $parameters = Get-ChildItem -Path "$sourceRoot\mode\$prod\parameters"  -Filter PD*.ps1 -Recurse
    $insights   = Get-ChildItem -Path "$sourceRoot\mode\$prod\insights"  -Filter ID*.ps1 -Recurse
    $rules      = Get-ChildItem -Path "$sourceRoot\mode\$prod\rules"     -Filter RD*.ps1 -Recurse
    $analyzers  = Get-ChildItem -Path "$sourceRoot\mode\$prod\analyzers" -Filter AD*.ps1 -Recurse
    $scenarios  = Get-ChildItem -Path "$sourceRoot\mode\$prod\scenarios" -Filter SD*.ps1 -Recurse

    #$insights, $rules, $analyzers, $scenarios, $parameters | ForEach-Object {. $_.FullName}
    $insights   | ForEach-Object {. $_.FullName}
    $parameters | ForEach-Object {. $_.FullName}
    $rules      | ForEach-Object {. $_.FullName}
    $analyzers  | ForEach-Object {. $_.FullName}
    $scenarios  | ForEach-Object {. $_.FullName}


    $sankeyData = @()

    foreach($scenario in $scenarios)
    {
        try
        {
            $s = New-Object -TypeName $scenario.BaseName -ArgumentList ([guid]::Empty)

            if ($s.AnalyzerDefinitions)
            {
                foreach ($analyzer in $s.AnalyzerDefinitions)
                {
                    $flow = New-Object PSObject
                    Add-Member -InputObject $flow -MemberType NoteProperty -Name "Source"      -Value $s.Name
                    Add-Member -InputObject $flow -MemberType NoteProperty -Name "Destination" -Value $analyzer.Name
                    $sankeyData += $flow
                }
            }

            if ($s.ParameterDefinitions)
            {
                foreach ($parameter in $s.ParameterDefinitions)
                {
                    $flow = New-Object psobject
                    Add-Member -InputObject $flow -MemberType NoteProperty -Name "Source"      -Value $parameter.Name
                    Add-Member -InputObject $flow -MemberType NoteProperty -Name "Destination" -value $s.Name
                    $sankeyData += $flow
                }
            }
        }
        catch
        {
            "Unable to create instance of {0}: {1}" -f $scenario.Name, $_ | Write-Host
        }
        finally
        {
            $s = $null
        }
    }
}

foreach($analyzer in $analyzers)
{
    try
    {
        $a = New-Object -TypeName $analyzer.BaseName

        if ($a.RuleDefinitions)
        {
            foreach ($rule in $a.RuleDefinitions)
            {
                $flow = New-Object PSObject
                Add-Member -InputObject $flow -MemberType NoteProperty -Name "Source"      -Value $a.Name
                Add-Member -InputObject $flow -MemberType NoteProperty -Name "Destination" -Value $rule.Name
                $sankeyData += $flow
            }
        }
    }
    catch
    {
        "Unable to create instance of {0}: {1}" -f $analyzer.BaseName, $_ | Write-Host
    }
    finally
    {
        $s = $null
    }
}

# Create output folder, if it doesn't already exist
if (!(Test-Path -Path $Output))
{
    New-Item -ItemType Directory -Path $Output
}

# Did we specify a product?
if ([string]::IsNullOrEmpty($Product))
{
    $FilePath = Join-Path -Path $Output -ChildPath "SankeyData.csv"
}
else
{
    $FilePath = Join-Path -Path $Output -ChildPath "SankeyData-$Product.csv"
}

if (Test-Path -Path $FilePath)
{
    Remove-Item -Path $FilePath -Force
}

$sankeyData | Export-Csv -Path $FilePath -Force -NoTypeInformation