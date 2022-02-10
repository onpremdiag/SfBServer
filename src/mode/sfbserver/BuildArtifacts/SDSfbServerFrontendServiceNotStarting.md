# Skype for Business Server Frontend service is not starting
**Owner:** David Paulino

# Description

This scenario checks common root cause issues why Skype for Business Server frontend
service is not starting correctly.

[[_TOC_]]

# Execution flow<br/>

::: mermaid
graph LR

Parameter1[\Parameter1\] -.-> Scenario(Scenario)
Parameter2[\Parameter2\] -.-> Scenario(Scenario)
Parameter3[\Parameter3\] -.-> Scenario(Scenario)
Scenario --> Analyzer1(Analyzer1)
Analyzer1 --> Rule1(Rule1)
Rule1 --> Insight1(Insight1)
Rule1 --> Insight2(Insight2)
Insight1 --> Detection(Detection)
Insight1 --> Action(Action)
Insight2 --> ...(...)
:::
___
::: mermaid
graph LR

%%
%% Scenario Name: SDSfbServerFrontendServiceNotStarting
%% Date Generated: 6/23/2021 10:06:59 AM
%% This file is autogenerated. Please do not edit directly
%%
	SDSfbServerFrontendServiceNotStarting(SDSfbServerFrontendServiceNotStarting) --1--> ADCheckLocalSQLServerInstanceAndDBs[ADCheckLocalSQLServerInstanceAndDBs]

	ADCheckLocalSQLServerInstanceAndDBs -- 1.1 --> RDCheckSQLServicesAreRunning[RDCheckSQLServicesAreRunning]
	ADCheckLocalSQLServerInstanceAndDBs -- 1.2 --> RDCheckSFBLocalDBsSingleUserMode[RDCheckSFBLocalDBsSingleUserMode]
	ADCheckLocalSQLServerInstanceAndDBs -- 1.3 --> RDCheckLocalSQLServerSchemaVersion[RDCheckLocalSQLServerSchemaVersion]
	SDSfbServerFrontendServiceNotStarting --2 --> ADCheckQuorumLoss[ADCheckQuorumLoss]

	ADCheckQuorumLoss -- 2.1 --> RDCheckDNSResolution[RDCheckDNSResolution]
	ADCheckQuorumLoss -- 2.2 --> RDCheckSfbServerQuorumLoss[RDCheckSfbServerQuorumLoss]
	SDSfbServerFrontendServiceNotStarting --3 --> ADCheckRootCACertificates[ADCheckRootCACertificates]

	ADCheckRootCACertificates -- 3.1 --> RDCheckMisplacedRootCACertificates[RDCheckMisplacedRootCACertificates]
	ADCheckRootCACertificates -- 3.2 --> RDCheckTooManyCertsRootCA[RDCheckTooManyCertsRootCA]
	SDSfbServerFrontendServiceNotStarting --4 --> ADCheckSChannelRegistryKeys[ADCheckSChannelRegistryKeys]

	ADCheckSChannelRegistryKeys -- 4.1 --> RDCheckSchannelSessionTicket[RDCheckSchannelSessionTicket]
	ADCheckSChannelRegistryKeys -- 4.2 --> RDCheckSchannelTrustMode[RDCheckSchannelTrustMode]
	SDSfbServerFrontendServiceNotStarting --5 --> ADIsSfbServerCertificateValid[ADIsSfbServerCertificateValid]

	ADIsSfbServerCertificateValid -- 5.1 --> RDCheckSfbServerCertificateValid[RDCheckSfbServerCertificateValid]
	ADIsSfbServerCertificateValid -- 5.2 --> RDCheckSfbServerCertificateExpired[RDCheckSfbServerCertificateExpired]
	SDSfbServerFrontendServiceNotStarting --6 --> ADIsSQLBackendConnectionAvailable[ADIsSQLBackendConnectionAvailable]

	ADIsSQLBackendConnectionAvailable -- 6.1 --> RDCheckSQLServerBackendConnection[RDCheckSQLServerBackendConnection]
:::

# Rule specifications
### R1 - RDCheckDNSResolution
- Determine if the IPv4 address can be resolved and the reverse lookup matches<br/>
``` powershell
    $FECount = 1

    $ServerFqdn = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue

    if (-not [string]::IsNullOrEmpty($ServerFqdn))
    {
        $ServerFqdnName = $ServerFqdn.Name

        if (-not [string]::IsNullOrEmpty($ServerFqdnName))
        {
            $PoolFqdn = Get-CsComputer -Identity $ServerFqdn.Name -ErrorAction SilentlyContinue
            if (-not [string]::IsNullOrEmpty($PoolFqdn.Pool))
            {
                $FrontEnds  = Get-CsComputer -Pool $PoolFqdn.Pool

                if ($PoolFqdn.Fqdn -ne $FrontEnds.Fqdn)
                {
                    $FECount = $FrontEnds.Count
                }

                $FEAvailable = 0

                # Test-NetConnection displays a progress bar. We're going to temporarily turn it off
                $OriginalProgressPreference = $global:ProgressPreference
                Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

                foreach($FE in $FrontEnds)
                {
                    $Connection = Resolve-DnsName -Name $FE.Fqdn -Type A -DnsOnly |
                                    Where-Object {$_.Section -eq 'Answer'}

                    if(-not [string]::IsNullOrEmpty($Connection))
                    {
                        # Able to resolve DNS name. Let's lookup by IP address & see if the names match
                        $ReverseLookup = Get-HostEntry -IPAddress $Connection.Ip4Address

                        if ($ReverseLookup -ne $FE.FQDN)
                        {
                            # Rule failure
                            throw 'IDIPv4DoesNotMatchReverseLookup'
                        }
                    }
                    else
                    {
                        # Unable to resolve DNS name
                        # Network connection fails
                        throw 'IDTestNetworkConnectionFails'
                    }
                    }
            }
            else
            {
                # Unable to resolve Pool name
                throw 'IDNullOrEmptyPoolFQDN'
            }
        }
        else
        {
            # Unable to resolve ServerFqdnName
            throw 'IDUnableToResolveServerFQDN'
        }
    }
    else
    {
        # Unable to Resolve-DnsName
        throw 'IDUnableToResolveDNSName'
    }
```

### R2 - RDCheckLocalSQLServerSchemaVersion
- Determine if local SQL Server database installed version is different than expected version<br/>
``` powershell
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
```

### R3 - RDCheckMisplacedRootCACertificates
- Determine if there are misplaced certificates in local machine Root system store<br/>
``` powershell
    if (Test-Path -Path $global:LocalMachineCertificateStore)
    {
        $nonRootCertificates = Get-Childitem $global:LocalMachineCertificateStore -Recurse | Where-Object {$_.Issuer -ne $_.Subject}

        if (@($nonRootCertificates).count -gt 0)
        {
            $this.Success           = $false
            $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f @($nonRootCertificates).count.ToString()
        }
    }
    else
    {
        # Somehow, the certificate store is not being found. This is a PROBLEM!
        $this.Insight.Detection = $global:InsightDetections.'IDLocalCertStoreNotFound'
        $this.Insight.Action    = $global:InsightActions.'IDLocalCertStoreNotFound'
        $this.Success           = $false
    }
```

### R4 - RDCheckSchannelSessionTicket
- Determine if Schannel session ticket TLS optimization is enabled<br/>
``` powershell
    $this.Success = Test-IsEnableSessionTicketOn
```

### R5 - RDCheckSchannelTrustMode
- Determine if Schannel client authentication trust mode registry key is set to exclusive CA<br/>
``` powershell
    $this.Success = Test-IsClientAuthTrustModeSetToTrustCA
```

### R6 - RDCheckSFBLocalDBsSingleUserMode
- Determine if local Skype for Business Server databases are in single user mode<br/>
``` powershell
    $SQLServer = ".\RTCLOCAL"
    $SQLQuery  = "SELECT  name FROM sys.databases WHERE name IN ('rtc','rtcdyn') and (state != 0 or user_access_desc = 'SINGLE_USER');"

    try
    {
        Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

        $dbList = Invoke-Sqlcmd -ServerInstance $SQLServer -Query $SQLQuery -ConnectionTimeout 10

        foreach ($db in $dbList)
        {
            $this.Success = $false
            $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f $db.name
            break
        }
    }
```

### R7 - RDCheckSfbServerCertificateExpired
- Determine if Skype for Business Server Frontend certificate is expired<br/>
``` powershell
    $validCertificates = @(Get-CsCertificate -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {$_.NotAfter -ge (Get-Date) -and $_.Use -eq "Default"})

    if ($validCertificates.count -eq 0)
    {
        $this.Success = $false
    }
```

### R8 - RDCheckSfbServerCertificateValid
- Determine if the certificates on the Front End and Pool server are valid<br/>
``` powershell
    $validCertificates = @(Get-CsCertificate -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {$_.NotAfter -ge (Get-Date) -and $_.Use -eq "Default"})

    if ($validCertificates.Count -gt 0)
    {
        $ServerFQDN = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue
        if (-not [string]::IsNullOrEmpty($ServerFQDN))
        {
            $ServerName = $ServerFQDN.Name
            if (-not [string]::IsNullOrEmpty($ServerName))
            {
                $PoolFQDN = Get-CsComputer -Identity $ServerName -ErrorAction SilentlyContinue

                if (-not [string]::IsNullOrEmpty($PoolFQDN.Pool))
                {
                    $SANOnCert = Test-SanOnCert -SAN $ServerName -Certificate $validCertificates
                    if ($SANOnCert)
                    {
                        $SANOnCert = Test-SanOnCert -SAN $PoolFQDN.Fqdn -Certificate $validCertificates
                        if (-not $SANOnCert)
                        {
                            throw 'IDPoolFqdnCertNotOnSan'
                        }
                        else
                        {
                            $this.Success = $true
                        }
                    }
                    else
                    {
                        throw 'IDFrontendFqdnCertNotOnSan'
                    }
                }
                else
                {
                    throw 'IDNullOrEmptyPoolFQDN'
                }
            }
            else
            {
                throw 'IDUnableToResolveServerFQDN'
            }
        }
        else
        {
            throw 'IDUnableToResolveDNSName'
        }
    }
    else
    {
        throw 'IDNoValidCertificates'
    }
```

### R9 - RDCheckSfbServerQuorumLoss
- Determine if minimum number of frontend servers required to start pool are available<br/>
``` powershell
    $FECount = 1

    $ServerFqdn = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue

    if (-not [string]::IsNullOrEmpty($ServerFqdn))
    {
        $ServerFqdnName = $ServerFqdn.Name

        if (-not [string]::IsNullOrEmpty($ServerFqdnName))
        {
            $PoolFqdn = Get-CsComputer -Identity $ServerFqdn.Name -ErrorAction SilentlyContinue
            if (-not [string]::IsNullOrEmpty($PoolFqdn.Pool))
            {
                $FrontEnds  = Get-CsComputer -Pool $PoolFqdn.Pool

                if ($PoolFqdn.Fqdn -ne $FrontEnds.Fqdn)
                {
                    $FECount = $FrontEnds.Count
                }

                $FEAvailable = 0

                # Test-NetConnection displays a progress bar. We're going to temporarily turn it off
                $OriginalProgressPreference = $global:ProgressPreference
                Set-Variable -Name ProgressPreference -Scope 'Global' -Value "SilentlyContinue" -Force

                foreach($FE in $FrontEnds)
                {
                    $Connection = Test-NetConnection -ComputerName $FE.Fqdn -Port 5090 -WarningAction SilentlyContinue
                    if(-not [string]::IsNullOrEmpty($Connection))
                    {
                        if($Connection.TcpTestSucceeded)
                        {
                            $FEAvailable++
                        }
                    }
                    else
                    {
                        # Unable to resolve DNS name
                        # Network connection fails
                        throw 'IDTestNetworkConnectionFails'
                    }
                    }

                Set-Variable -Name ProgressPreference -Scope 'Global' -Value $OriginalProgressPreference -Force

                if ($FECount -ne $FEAvailable)
                {
                    $this.Success           = $false
                    $this.Insight.Detection = $global:InsightDetections.($this.Insight.Name) -f $FEAvailable, $FECount
                    $this.Insight.Action    = $global:InsightActions.($this.Insight.Name) -f $PoolFqdn
                }
            }
            else
            {
                # Unable to resolve Pool name
                throw 'IDNullOrEmptyPoolFQDN'
            }
        }
        else
        {
            # Unable to resolve ServerFqdnName
            throw 'IDUnableToResolveServerFQDN'
        }
    }
    else
    {
        # Unable to Resolve-DnsName
        throw 'IDUnableToResolveDNSName'
    }
```

### R10 - RDCheckSQLServerBackendConnection
- Determine if SQL Server back end connectivity is available<br/>
``` powershell
    $ServerFqdn = Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction SilentlyContinue

    if (-not [string]::IsNullOrEmpty($ServerFqdn))
    {
        $ServerFqdnName = $ServerFqdn.Name

        if ($null -ne $ServerFqdnName)
        {
            $PoolFqdn = Get-CsComputer -Identity $ServerFqdn.Name -ErrorAction SilentlyContinue
            if ($null -ne $PoolFqdn.Pool)
            {
                $Service = Get-CsService -UserServer -PoolFqdn $PoolFqdn.Pool -ErrorAction SilentlyContinue

                if (-not [string]::IsNullOrEmpty($Service))
                {
                    if (-not [string]::IsNullOrEmpty($Service.UserDatabase))
                    {
                        $BackendFqdn = $Service.UserDatabase.split(":")[1]

                        if(-not [string]::IsNullOrEmpty($BackendFqdn))
                        {
                            $csRemoteDatabases = Test-CsDatabase -ConfiguredDatabases `
                                                                    -SqlServerFqdn $BackendFqdn `
                                                                    -ErrorAction SilentlyContinue `
                                                                    -WarningAction SilentlyContinue
                            if ([string]::IsNullOrEmpty($csRemoteDatabases))
                            {
                                # Test-CsDatabase returned a null
                                throw 'IDTestCsDatabaseNoResults'
                            }
                        }
                    }
                    else
                    {
                        throw 'IDUnableToGetServiceInfo'
                    }
                }
                else
                {
                    # Service information not available
                    throw 'IDUnableToGetServiceInfo'
                }
            }
            else
            {
                # Server Pool FQDN is null
                throw 'IDUnableToResolveServerFQDN'
            }
        }
        else
        {
            # Unable to resolve ServerFqdnName
            throw 'IDUnableToResolveServerFQDN'
        }
    }
    else
    {
        # Unable to Resolve-DnsName
        throw 'IDUnableToResolveDNSName'
    }
```

### R11 - RDCheckSQLServicesAreRunning
- Determine if local SQL Server services are running<br/>
``` powershell
    $sqlInstanceServices = Get-Service -DisplayName "SQL Server (*)"

    if(-not [string]::IsNullOrEmpty($sqlInstanceServices))
    {
        foreach ($sqlInstance in $sqlInstanceServices)
        {
            if ($sqlInstance.Status -ne 'Running')
            {
                $this.Success = $false
                break
            }
        }
    }
    else
    {
        # No SQL services found
        $this.Insight.Detection = $global:InsightDetections.'IDNoSQLServiceInstancesFound'
        $this.Insight.Action    = $global:InsightActions.'IDNoSQLServiceInstancesFound'
        $this.Success           = $false
    }
```

### R12 - RDCheckTooManyCertsRootCA
- Determine if there are too many certificates in local machine root CA store<br/>
``` powershell
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
```

# Messages
When particular rule detects an issue (return value is false) an **Insight detection**
and an **Insight Action** are displayed in addition to an **Analyzer message** and **Rule description**.
For more details, see example below:

(...)
<span style="color:green">[+] Verifies if target domain is approved for federation **-> Analyzer message**
&nbsp;&nbsp;&nbsp;&nbsp;[+] Determine if open federation is enabled or target domain is approved for federation **-> Rule message**</span>
<span style="color:red">[-] Verifies the on-premise domains configuration match Office 365 tenant domain configuration **-> Analyzer message**
&nbsp;&nbsp;&nbsp;&nbsp;[-] Determine if the on-premise domains configuration match Office 365 tenant domain configuration **-> Rule message**
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[-] Detection : The allowed federated domain configured in your On Premise environment, '[Domain not found]', and your O365 Tenant, 'domainnotinonprem.com', do not match. **-> Insight detection message**
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[-] Action : Please review Allowed domains list in the on-premises deployment as that must exactly match the Allowed domains list for your online tenant. For more information please refer to the following article https://docs.microsoft.com/skypeforbusiness/hybrid/plan-hybrid-connectivity. **-->Insight action message**</span>
(...)


### Scenario Description
| **Language** | **Name** | **Description** |
|:----------|:------|:-------------|
| en-US | SDSfbServerFrontendServiceNotStarting | The front end service is not starting in Skype for Business Server




### Analyzer Descriptions
| **#** | **Language** | **Name** | **Description** |
|:------|:----------|:------|:-------------|
| A1 | en-US | ADCheckLocalSQLServerInstanceAndDBs | Verifies if local SQL Server instances are running, databases are not in single user mode and schema version is correct|
| A2 | en-US | ADCheckQuorumLoss | Verifies if minimum required number of servers to have quorum are up and running|
| A3 | en-US | ADCheckRootCACertificates | Verifies the local machine certificate store configuration is correct|
| A4 | en-US | ADCheckSChannelRegistryKeys | Verifies the schannel client authentication trust mode and session ticket TLS optimization registry keys configuration|
| A5 | en-US | ADIsSfbServerCertificateValid | Verifies if Skype for Business Server Frontend certificate is not expired|
| A6 | en-US | ADIsSQLBackendConnectionAvailable | Verifies the SQL Server back end connectivity|


### Rule Descriptions
| **#** | **Language** | **Name** | **Description** |
|:------|:---------|:-----|:------------|
| R1 | en-US | RDCheckDNSResolution | Determine if the IPv4 address can be resolved and the reverse lookup matches |
| R2 | en-US | RDCheckLocalSQLServerSchemaVersion | Determine if local SQL Server database installed version is different than expected version |
| R3 | en-US | RDCheckMisplacedRootCACertificates | Determine if there are misplaced certificates in local machine Root system store |
| R4 | en-US | RDCheckSchannelSessionTicket | Determine if Schannel session ticket TLS optimization is enabled |
| R5 | en-US | RDCheckSchannelTrustMode | Determine if Schannel client authentication trust mode registry key is set to exclusive CA |
| R6 | en-US | RDCheckSFBLocalDBsSingleUserMode | Determine if local Skype for Business Server databases are in single user mode |
| R7 | en-US | RDCheckSfbServerCertificateExpired | Determine if Skype for Business Server Frontend certificate is expired |
| R8 | en-US | RDCheckSfbServerCertificateValid | Determine if the certificates on the Front End and Pool server are valid |
| R9 | en-US | RDCheckSfbServerQuorumLoss | Determine if minimum number of frontend servers required to start pool are available |
| R10 | en-US | RDCheckSQLServerBackendConnection | Determine if SQL Server back end connectivity is available |
| R11 | en-US | RDCheckSQLServicesAreRunning | Determine if local SQL Server services are running |
| R12 | en-US | RDCheckTooManyCertsRootCA | Determine if there are too many certificates in local machine root CA store |


### Insight detection descriptions
| **#** | **Language** | **Name** | **Description** |
|:------|:---------|:-----|:------------|
| ID1 | en-US | IDFrontendFqdnCertNotOnSan | Unable to find FQDN of the local server in Skype for Business Server certificate. |
| ID2 | en-US | IDIPv4DoesNotMatchReverseLookup | DNS IPv4 name does not match reverse DNS IP address {0} lookup. Expected: {1}, Actual: {2} |
| ID3 | en-US | IDLocalSQLServerSchemaVersionMismatch | The Skype for Business Server local database: '{0}', installed version: '{1}', does not match expected version: '{2}'. |
| ID4 | en-US | IDNoValidCertificates | No Skype for Business Server certificates have been found. |
| ID5 | en-US | IDNullOrEmptyPoolFQDN | The Pool FQDN, '{0}', is either null or empty. |
| ID6 | en-US | IDPoolFqdnCertNotOnSan | Unable to find Skype for Business pool FQDN in Skype for Business Server certificate. |
| ID7 | en-US | IDTestCsDatabaseNoResults | Unable to verify connectivity to one or more Skype for Business Server databases. |
| ID8 | en-US | IDTestNetworkConnectionFails | Unable to verify network connection with '{0}'. |
| ID9 | en-US | IDUnableToGetServiceInfo | Unable to get information about the services and server roles being used in your Skype for Business Server infrastructure. |
| ID10 | en-US | IDUnableToResolveDNSName | Unable to resolve DNS query for one or more of your Skype for Business Server server(s). |
| ID11 | en-US | IDUnableToResolveServerFQDN | Unable to resolve the FQDN for your Skype for Business Server. |


### Insight action descriptions
| **#** | **Language** | **Name** | **Description** |
|:------|:---------|:-----|:------------|
| IA1 | en-US | IDFrontendFqdnCertNotOnSan | Please ensure that Skype for Business frontend certificate meets requirements described at https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/environmental-requirements#Certs. |
| IA2 | en-US | IDIPv4DoesNotMatchReverseLookup | Please verify if the DNS record entry is correct as hosts files entries. |
| IA3 | en-US | IDLocalSQLServerSchemaVersionMismatch | Please install latest Skype for Business Server cumulative update. |
| IA4 | en-US | IDNoValidCertificates | Please ensure that Skype for Business frontend certificate meets requirements described at https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/environmental-requirements#Certs. |
| IA5 | en-US | IDNullOrEmptyPoolFQDN | Please confirm that 'Get-CsComputer -Identity {0}' cmdlet returns a non-empty result. |
| IA6 | en-US | IDPoolFqdnCertNotOnSan | Please ensure that Skype for Business frontend certificate meets requirements described at https://docs.microsoft.com/skypeforbusiness/plan-your-deployment/requirements-for-your-environment/environmental-requirements#Certs. |
| IA7 | en-US | IDTestCsDatabaseNoResults | The 'Test-CsDatabase -LocalService' returned an empty result. If problem persists please contact your system administrator or open a support ticket with Microsoft. |
| IA8 | en-US | IDTestNetworkConnectionFails | Please confirm DNS server is reachable. If problem persists please contact your system administrator or open a support ticket with Microsoft. |
| IA9 | en-US | IDUnableToGetServiceInfo | Please confirm that 'Get-CsComputer' and 'Get-CsService' cmdlet execution is successful. |
| IA10 | en-US | IDUnableToResolveDNSName | Please confirm that 'Resolve-DnsName' cmdlet successfully performs a DNS query for each Edge Server in the Edge pool and each Frontend in the Frontend pool. |
| IA11 | en-US | IDUnableToResolveServerFQDN | Please execute 'Resolve-DnsName -Name $env:COMPUTERNAME -Type A' cmdlet and confirm valid output is returned. |