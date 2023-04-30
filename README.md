# PSSaltStackConfig
SaltStack Config API module providing function wrappers for the SaltStack API REST endpoints.

## Prerquisites
- A licensed deployment of SaltStack Enterprise or VMware vRealize Automation SaltStack Config.
- A user with API access to SaltStack Config.

## Usage
```powershell
# Install Module
Install-Module PSSaltStackConfig

$credential = Get-Credential # User with API permissions

# Connect to SaltStack Config using the provided credential
Connect-SaltStackConfig -SaltEnterpriseServer <RAAS_Server> -Credential $credential

Invoke-SaltTestPing -SaltConnection $SaltConnection -Target 'web01'

```
