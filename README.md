> **This is not a complete module yet. Use at your own risk and make sure to test first.**

# PSSaltStackConfig
SaltStack Config API module providing function wrappers for the SaltStack API REST endpoints.

This module started out as a project to give the ability to run some common commands against SaltStack Config using PowerShell. This module utilizes the API for the SaltStack RAAS service. Documentation for the API can be found at the following VMWare Docs page:

[Working with the API (RaaS)](https://docs.vmware.com/en/VMware-vRealize-Automation-SaltStack-Config/8.4/use-manage-saltstack-config/GUID-FF1A0E3A-CA19-4139-B9DC-C32DC4F76202.html)

A big thanks to [Ephos](https://github.com/ephos) for doing the inital dirty work to set up the API connection.

## Prerquisites
- A licensed deployment of SaltStack Enterprise or VMware vRealize Automation SaltStack Config.
- A user with API access to SaltStack Config.

## Usage
```powershell
# Install Module
Install-Module PSSaltStackConfig

$credential = Get-Credential # User with API permissions

# Connect to SaltStack Config using the provided credential
# This command will create a Global variable called $global:SaltConnection which will be used for the rest of the functions in this module
Connect-SaltStackConfig -SaltEnterpriseServer <RAAS_Server> -Credential $credential

Invoke-SaltTestPing -Target 'web01'

```

