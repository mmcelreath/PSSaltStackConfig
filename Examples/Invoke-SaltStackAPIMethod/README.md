## Making API Calls With Invoke-SaltStackAPIMethod
When designing this module initially, we had some functionality in mind that we wanted to see initially, so those were built out into the current functions.

However, at the core of this module is the function `Invoke-SaltStackAPIMethod` which can be used to run any of the API calls supported the [SaltStack API](https://developer.vmware.com/apis/1179/saltstack-config-raas). 

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
