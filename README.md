> **This is not a complete module yet. Use at your own risk and make sure to test first.**

# PSSaltStackConfig
SaltStack Config API module providing function wrappers for the SaltStack API REST endpoints.

This module started out as a project to give the ability to run some common commands against SaltStack Config using PowerShell. This module utilizes the API for the SaltStack RAAS service. Documentation for the API can be found at the following VMWare Docs page:

[Working with the API (RaaS)](https://docs.vmware.com/en/VMware-vRealize-Automation-SaltStack-Config/8.4/use-manage-saltstack-config/GUID-FF1A0E3A-CA19-4139-B9DC-C32DC4F76202.html)

A big thanks to [Ephos](https://github.com/ephos) for doing the inital dirty work to set up the API connection.

## Prerquisites
- A licensed deployment of SaltStack Enterprise or VMware vRealize Automation SaltStack Config.
- A user with API access to SaltStack Config.

## Global Connection Variable
This module utilizes a global variable called $global:SaltConnection which stores the details of the connection to the SaltStack API. Running the following command will create the $global:SaltConnection in your current session:

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

This global variable is utilized automatically by the rest of the functions without the need to pass it every time.

## Usage
```powershell
# Install Module
Install-Module PSSaltStackConfig

$credential = Get-Credential # User with API permissions

# Connect to SaltStack Config using the provided credential
# This command will create a Global variable called $global:SaltConnection which will be used for the rest of the functions in this module
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential

Invoke-SaltTestPing -Target 'web01'

```

## API Calls
When designing this module initially, we had some functionality in mind that we wanted to see initially, so those were built out into the current functions.

However, at the core of this module is the function `Invoke-SaltStackAPIMethod` which can be used to run any of the API calls supported the [SaltStack API](https://docs.vmware.com/en/VMware-vRealize-Automation-SaltStack-Config/8.4/use-manage-saltstack-config/GUID-FF1A0E3A-CA19-4139-B9DC-C32DC4F76202.html). 

The `Invoke-SaltStackAPIMethod` takes a Resource, Method and Arguments (optional) as parameters. Here are a few examples on how to use `Invoke-SaltStackAPIMethod` to get data from the API:

### Example 1 - Return all versions of the SaltStack Config server

```powershell
Invoke-SaltStackAPIMethod -Resource api -Method get_versions
```

### Example 2 - Return minion key states setting the limit to 300 instead of truncating the response.

```powershell
Invoke-SaltStackAPIMethod -Resource minions -Method get_minion_key_state -Arguments @{'limit'=300}
```

### Example 3 - Return minion key states from the master_id 'master'  which have a 'pending' key state and will return up to 300 minions.

```powershell
Invoke-SaltStackAPIMethod -Resource minions -Method get_minion_key_state -Arguments @{'limit'=300; 'master_id'='master'; 'key_state'='pending'}
```

### Example 4 - Accept a minion key for 'minionname.domain.local' on the master 'master'.

> Note: The leading comma in the array below. The API requires this leading comma (or at least used to) when passing arrays in certain scenarios. You can find a few examples in some of the functions. 

```powershell
Invoke-SaltStackAPIMethod -Resource minions -Method set_minion_key_state -Arguments @{'state'='accept'; 'minions' = @(,@('master', 'minionname.domain.local'))}
```

