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
# Filename: LoadResourceFiles.ps1
# Description: <TODO>
# Owner: Mike McIntyre <mmcintyr@microsoft.com>
# Created On: 11/28/2018 10:56 AM
#
# Last Modified On: 6/13/2019 1:59 PM
#################################################################################
function Initialize-ModeResourceStrings
{
    param
    (
        [Parameter(Mandatory = $false)]
        [string] $Root = $PSScriptRoot,

        [Parameter(Mandatory = $true)]
        [String] $MyMode
    )

    try
    {
        Add-Type -AssemblyName System.Windows.Forms

        # Let's load the event id resource file
        $eventIDs = "$Root\mode\$MyMode\common\EventIDs.psd1"

        if (Test-Path -Path $eventIDs)
        {
            New-Variable -Name "ProductEventIDs" `
                -Description 'ProductEventIDs Event ID resources' `
                -Scope Global `
                -Force `
                -Value (Import-PowerShellDataFile -Path $eventIDs)
        }

        # Resource string files that should be loaded
        $resourceFiles  = @('AnalyzerDescriptions','InsightActions', 'InsightDetections' )
        $resourceFiles += @('RuleDescriptions','ScenarioDescriptions')
        $resourceFiles += @('AreaTitles','AreaDescriptions')
        $resourceFiles += @('ParameterDescriptions', 'ParameterExampleText', 'ParameterPrompts')
        $resourceFiles += @('MiscStrings')

        if(-not (Get-Variable -Name OPDOptions -ErrorAction SilentlyContinue))
        {
            $culture = "en-US"
        }
        else
        {
            $culture = $global:OPDOptions.OriginalCulture
        }

        foreach ($resourceFile in $resourceFiles)
        {
            # Target resource file
            $resourceStrings = Join-Path -Path "$Root\Mode\$MyMode\locale\$culture" -ChildPath "$resourceFile.psd1"

            # Check to see if we have a resource file for this locale. If not, default to en-US
            if ($false -eq (Test-Path -Path $resourceStrings))
            {
                $culture = [System.Globalization.CultureInfo]"en-US"
                $stringsFile = Join-Path -Path "$Root\Mode\$MyMode\locale\$culture" -ChildPath "$resourceFile.psd1"

                #Write-EventLog -LogName $global:EventLogName -Source $global:scriptName -EntryType Warning `
                #    -Message ("Missing resource file: '{0}'. Default to: '{1}'" -f (Split-Path -Path $resourceStrings -Leaf), `
                #                                                                   (Split-Path -Path $stringsFile -Leaf)) `
                #    -EventId 9818
            }

            New-Variable -Name $resourceFile `
                -Description 'Resource file' `
                -Scope Global `
                -Force `
                -Value (Import-LocalizedData -BaseDirectory  "$Root\Mode\$MyMode\locale\$culture" -UICulture $culture -FileName $resourceFile)
        }

        Join-EventIDs
    }
    catch
    {
        throw "Unable to load resource files: {0}" -f $_
    }
}

function Initialize-CommonResourceStrings
{
    param
    (
        [Parameter(Mandatory = $false)]
        [String] $Root = $PSScriptRoot
    )

    try
    {
        Add-Type -AssemblyName System.Windows.Forms

        ## Let's load the event id resource file
        $resourceFile = Join-Path -Path "$Root\common" -ChildPath EventIDs.psd1

        New-Variable -Name "OPDEventIDs" `
            -Description 'OPD Event ID resources' `
            -Scope Global `
            -Force `
            -Value (Import-PowerShellDataFile -Path $resourceFile)

        # Resource string files that should be loaded
        $resourceFiles  = @('CommonStrings', 'OPDStrings')

        $culture = ([System.Threading.Thread]::CurrentThread.CurrentCulture).Name

        foreach ($resourceFile in $resourceFiles)
        {
            # Target resource file
            $resourceStrings = Join-Path -Path "$Root\locale\$culture" -ChildPath "$resourceFile.psd1"

            # Check to see if we have a resource file for this locale. If not, default to en-US
            if ($false -eq (Test-Path -Path $resourceStrings))
            {
                $culture = [System.Globalization.CultureInfo]"en-US"
                $stringsFile = Join-Path -Path "$Root\local\$culture" -ChildPath "$resourceFile.psd1"

                #Write-EventLog -LogName $global:EventLogName -Source $global:scriptName -EntryType Warning `
                #    -Message ("Missing resource file: '{0}'. Default to: '{1}'" -f (Split-Path -Path $expectedResxFile -Leaf), `
                #                                                                   (Split-Path -Path $resxFile -Leaf)) `
                #    -EventId 9818
            }

            New-Variable -Name $resourceFile `
                -Description 'Resource file' `
                -Scope Global `
                -Force `
                -Value (Import-LocalizedData -BaseDirectory "$Root\locale\$culture" -UICulture $culture -FileName $resourceFile)
        }
    }
    catch
    {
        throw "Unable to load resource files: {0}" -f $_
    }
}
function Import-ResourceFiles
{
    param
    (
        [Parameter(Mandatory = $true)]
        [String] $Root,

        [Parameter(Mandatory = $true)]
        [String] $MyMode

    )
        Initialize-CommonResourceStrings -Root $Root
        Initialize-ModeResourceStrings -Root $Root -MyMode $MyMode

        Join-EventIDs
}

function Join-EventIDs
{
    try
    {
        Add-Type -AssemblyName System.Windows.Forms

        $eventIDs = $global:OPDEventIds + $global:ProductEventIDs

        New-Variable -Name 'EventIDs' `
                     -Description 'OPD/Product Event ID resources' `
                     -Scope Global `
                     -Force `
                     -Value $eventIDs
    }
    catch
    {
        throw "Unable to combine EventID resource files: {0}" -f $_
    }
}

$global:OPDOptions  = @{
    OriginalCulture  = ([System.Threading.Thread]::CurrentThread.CurrentCulture).Name
}