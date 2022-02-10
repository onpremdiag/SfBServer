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
# Filename: IIS.ps1
# Description: IIS/WCF common functions
# Owner: Rodney Viana <rviana@microsoft.com>
# Created On: 9/10/2018 2:00 PM
#
# Last Modified On: 9/10/2018 2:00 PM (UTC-6)
#################################################################################
Set-StrictMode -Version Latest

# setup some useful values
$ComputerName = $Env:COMPUTERNAME
# $OSVersion = [System.Environment]::OSVersion.Version
Import-Module WebAdministration -ErrorAction Ignore

function Get-RunningAppPools
{

    <#
    .SYNOPSIS
    Get a list of running Web Applications

    .DESCRIPTION
    Returns the list of all running web applications with Application Pool name, process id and hex process id

    .EXAMPLE
    Get-RunningAppPools

    .NOTES
    It requires elevated privileges
    #>
    $result = @();
    foreach($inst in Get-CimInstance Win32_Process -Filter "Name = 'w3wp.exe'")
    {
        $props = @{
            Name   = $inst.CommandLine.Split('`"')[1]
            PID    = $inst.ProcessId
            HexPID = "0x$($inst.ProcessId.ToString('x6'))"
        }
        $result += New-Object PSObject -Property $props

    };
    return $result
}

function Get-WebSites
{
    if(-not (Add-IISSnapIn))
    {
        Write-Error "Unable to load IIS module"
        return $null
    }

    $result = @()
    $sites = Get-WebSite

    foreach ($site in $sites)
    {
        $props = @{
            Id              = $site.id
            Name            = $site.name
            ApplicationPool = $site.applicationPool
            State           = $site.state
            AutoStart       = $site.serverAutoStart
            Bindings        = ($site.bindings.Collection | Select-Object protocol,bindingInformation,sslFlags,isDsMapperEnabled,certificateHash,certificateStoreName)
            Limits          = ($site.limits | Select-Object maxBandwidth,maxConnections,connectionTimeout,maxUrlSegments)
            LogFile         = ($site.logFile | Select-Object logExtFileFlags,customLogPluginClsid,logFormat,logTargetW3C,directory,period,enabled)
            FREB            = ($site.traceFailedRequestsLogging | Select-Object directory,enabled,maxLogFiles,customActionsEnabled)
            #HSTS           = ($site.hsts | Select-Object enabled,redirectHttpToHttps)
            Protocols       = $site.enabledProtocols
            Path            = $site.physicalPath
        }

        $result += (New-Object PSObject -Property $props)
    }
    return $result
}

function Get-AppPools
{
    if(-not (Add-IISSnapIn))
    {
        Write-Error "Unable to load IIS module"
        return $null
    }

    $result = @();
    $appPools = Get-ChildItem IIS:\AppPools

    foreach($appPool in $appPools)
    {
        $props = @{
            Name        = $appPool.name
            AutoStart   = $appPool.autoStart
            is32On64    = $appPool.enable32BitAppOnWin64
            queueLength = $appPool.queueLength
        }
        $result += (New-Object PSObject -Property $props)
    }
    return $result
}

class WebBinding
{
    [string] $Protocol
    [string] $BindingInfo
    [string] $SslFlags

    WebBinding([PSObject] $BindingsCollection)
    {
        $BindingsCollection | ForEach-Object {
            $this.Protocol    = $_.protocol
            $this.BindingInfo = $_.bindingInformation
            $this.SslFlags    = $_.sslFlags
        }
    }
}

class WebSite
{
    hidden [object] $thisSite
    [string] $Name
    [string] $Path
    [uint64] $Id
    [bool] $IsAutoStart
    [string] $State
    [string] $ApplicationPool
    [string] $EnabledProtocols
    [bool] $IsFrebEnabled


    WebSite([string] $SiteName)
    {
        $this.thisSite         = Get-Website -Name $SiteName
        $this.Name             = $this.thisSite.name
        $this.Path             = $this.thisSite.physicalPath
        $this.Id               = $this.thisSite.id
        $this.IsAutoStart      = $this.thisSite.serverAutoStart
        $this.State            = $this.thisSite.state
        $this.ApplicationPool  = $this.thisSite.applicationPool
        $this.EnabledProtocols = $this.thisSite.enabledProtocols
        $this.IsFrebEnabled    = $this.thisSite.traceFailedRequestsLogging.enabled
    }

    static [WebSite[]] GetAll()
    {
        $apps = @()
        Get-WebSite | ForEach-Object { $apps += New-Object WebSite -ArgumentList $_.name }
        return $apps

    }

    [WebBinding[]] GetBindings()
    {
        $binds = @();
        $this.thisSite.bindings.Collection | ForEach-Object {
            $binds += New-Object WebBinding -ArgumentList $_
        }
        return $binds
    }
}

class WebHelper
{
    static [string] AccountFromSid([string] $Sid)
    {
        try
        {
            $objSID  = New-Object System.Security.Principal.SecurityIdentifier ($Sid)
            $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
            return $objUser.Value
        }
        catch
        {
            # we can write this exception to the event log but we do not have a defined method to bubble it up to the UI of the user
            Get-ExceptionInsight "An Exception has occurred in AccountFromSid: " $_
            return "Invalid: $($_.Exception)"
        }
    }
}

class WebAppPool
{
    [string] $Name
    [uint32] $QueueLength
    [bool] $Is32On64
    [bool] $IsAutoStart
    [string] $RuntimeVersion
    [bool] $AllowAnonymous
    [string] $StartMode
    [bool] $IsStarted
    [string] $State
    [string] $Sid
    [string] $Account
    [bool] $IsCpuAffinity
    [bool] $IdentityType
    [string] $UserName
    [bool] $LoadUserProfile
    [bool] $IsGarden
    [bool] $IsPingEnabled
    [string] $PingInterval
    [string] $PipeLineMode
    [int64] $RecycleMemory
    [int64] $RecyclePrivateMemory
    [int64] $RecycleRequests
    [string] $RecycleSchedule
    [string] $RecyclePeriod

    WebAppPool([string] $AppPoolName)
    {
        $pool                      = (Get-ChildItem IIS:\AppPools | Where-Object { $_.Name -eq $AppPoolName })
        $this.Name                 = $pool.name
        $this.QueueLength          = $pool.queueLength
        $this.Is32On64             = $pool.enable32BitAppOnWin64
        $this.IsAutoStart          = $pool.autoStart
        $this.RuntimeVersion       = $pool.managedRuntimeVersion
        $this.AllowAnonymous       = $pool.passAnonymousToken
        $this.StartMode            = $pool.startMode
        $this.IsStarted            = $pool.state -eq "Started"
        $this.State                = $pool.state
        $this.Sid                  = $pool.applicationPoolSid
        $this.Account              = [WebHelper]::AccountFromSid($this.Sid)
        $this.IsCpuAffinity        = $pool.cpu.smpAffinitized
        $this.IdentityType         = $pool.processModel.identityType
        $this.UserName             = $pool.processModel.userName
        $this.LoadUserProfile      = $pool.processModel.loadUserProfile
        $this.IsGarden             = $pool.processModel.maxProcesses -ne 1
        $this.IsPingEnabled        = $pool.processModel.pingingEnabled
        $this.PingInterval         = $pool.processModel.pingInterval
        $this.PipeLineMode         = $pool.managedPipelineMode
        $this.RecycleMemory        = $pool.recycling.periodicRestart.memory
        $this.RecyclePrivateMemory = $pool.recycling.periodicRestart.privateMemory
        $this.RecycleRequests      = $pool.recycling.periodicRestart.requests
        [string]$sched             = '';$pool.recycling.periodicRestart.schedule.Collection | ForEach-Object { $sched += " " + $_.value }
        $this.RecycleSchedule      = $sched.Trim()
        $this.RecyclePeriod        = $pool.recycling.periodicRestart.time
    }

    static [WebAppPool[]] GetAll()
    {
        $appPools = @()
        Get-ChildItem IIS:\AppPools | ForEach-Object {
            $appPools += New-Object WebAppPool -ArgumentList $_.Name
        }

        return $appPools
    }

    [int64] GetPid()
    {
        foreach($inst in Get-CimInstance Win32_Process -Filter "Name = 'w3wp.exe'")
        {
            [string]$appName = $inst.CommandLine.Split('`"')[1];
            if($appName -eq $this.Name)
            {
                return $inst.ProcessId
            }

        };
        return -1

    }

    static [WebAppPool[]] GetRunning()
    {
        $appPools = @()

        Get-CimInstance Win32_Process -Filter "Name = 'w3wp.exe'" | ForEach-Object {
            $appPools += New-Object WebAppPool -ArgumentList $_.CommandLine.Split('`"')[1]
        }

        return $appPools
    }

    [WebSite[]] GetWebSites()
    {
        $sites = @()
        Get-WebSite | Where-Object { $_.applicationPool -eq $this.Name } | ForEach-Object {
            $sites += New-Object WebSite -ArgumentList $_.Name
        }
        return $sites
    }

    [WebApp[]] GetWebApps()
    {
        $apps = @()
        Get-WebApplication | Where-Object { $_.applicationPool -eq $this.Name } | ForEach-Object {
            $app += New-Object WebApp -ArgumentList $_,path
        }
        return $apps
    }
}

class WebApp
{
    [string] $Path
    [string] $ApplicationPool
    [string] $PhysicalPath
    [string] $Protocols
    [string] $SiteName

    WebApp([string] $AppPath, [bool] $IsSite = $false)
    {
        $Webapp = $null
        if($IsSite)
        {
            Get-WebApplication -Site $AppPath
        }
        else
        {
            Get-WebApplication -Name $AppPath
        }

        $this.Path            = $Webapp.path
        $this.ApplicationPool = $Webapp.applicationPool
        $this.PhysicalPath    = $Webapp.PhysicalPath
        $this.Protocols       = $Webapp.enabledProtocols
        $this.SiteName        = $Webapp.ItemXPath.Split("'")[1]

    }

    webApp([object] $WebApp)
    {
        $this.Path            = $Webapp.path
        $this.ApplicationPool = $Webapp.applicationPool
        $this.PhysicalPath    = $Webapp.PhysicalPath
        $this.Protocols       = $Webapp.enabledProtocols
        $this.SiteName        = $Webapp.ItemXPath.Split("'")[1]

    }

    static [WebApp[]] GetAll()
    {
        $apps = @()
        Get-WebApplication | ForEach-Object {
            $apps += New-Object WebApp -ArgumentList $_
        }
        return $apps
    }

    static [WebApp[]] GetBySite([string] $SiteName)
    {
        $apps = @()
        Get-WebApplication -Site $SiteName | ForEach-Object {
            $apps += New-Object WebApp -ArgumentList $_
        }
        return $apps
    }

    [WebAppPool] GetAppPool()
    {
        return New-Object WebAppPool -ArgumentList $this.ApplicationPool
    }
}

