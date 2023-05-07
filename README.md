# PSSaltStackConfig
A PowerShell module for the SaltStack Config API providing function wrappers for the SaltStack API REST endpoints.

This module started out as a project to give the ability to run some common commands against SaltStack Config using PowerShell. I started by converting a few of the most common Salt Linux commands I was running day to day and continued building on top of that. If you don't see a built in command that you're looking for, I suggest checking out the documentation for the [Invoke-SaltStackAPIMethod](#making-api-calls-with-invoke-saltstackapimethod) command below which can be used to call any API method directly.

This module utilizes the API for the SaltStack RAAS service. Documentation for the API can be found at the following VMWare Docs pages:

[Working with the API (RaaS)](https://docs.vmware.com/en/VMware-vRealize-Automation-SaltStack-Config/8.4/use-manage-saltstack-config/GUID-FF1A0E3A-CA19-4139-B9DC-C32DC4F76202.html)

[Aria Automation Config API Documentation](https://developer.vmware.com/apis/1179/saltstack-config-raas)

A big thanks to [Ephos](https://github.com/ephos) for doing the inital dirty work to set up the the initial API connection.

## Prerquisites
- A licensed deployment of SaltStack Enterprise or VMware vRealize Automation SaltStack Config.
- A user with API access to SaltStack Config.

## Global Connection Variable
This module utilizes a global variable called `$global:SaltConnection` which stores the details of the connection to the SaltStack API. Running the following command will create the `$global:SaltConnection` in your current session:

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

## Making API Calls With Invoke-SaltStackAPIMethod
When designing this module, we had some functionality in mind that we wanted to see initially, so those were built out into the current functions.

However, at the core of this module is the function `Invoke-SaltStackAPIMethod` which can be used to run any of the API calls supported the [SaltStack API](https://developer.vmware.com/apis/1179/saltstack-config-raas). 

The `Invoke-SaltStackAPIMethod` takes a Resource, Method and Arguments (optional) as parameters. Here are a few examples on how to use `Invoke-SaltStackAPIMethod` to get data from the API:

Check out the examples under [Invoke-SaltStackAPIMethod](./Examples/Invoke-SaltStackAPIMethod/README.md) for more details.
