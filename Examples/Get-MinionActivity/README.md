# Get-MinionActivity - Examples
Gets activities for Minions.

This function will use the Invoke-SaltStackAPIMethod command to query the get_returns method on the ret resource to return Activities.

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Return the 50 most recent activities in SaltStack Config. 50 is the default limit

```powershell
Get-MinionActivity 

```

### Example - Return the 150 most recent activities in SaltStack Config by changing Limit to 150

```powershell
Get-MinionActivity -Limit 150

```

### Example - Return the 50 most recent activities for the MinionID provided

```powershell
Get-MinionActivity -MinionID 'minionid'

```

### Example - Return the activity in JobId 20210204570834112766 for the provided MinionID

```powershell
Get-MinionActivity -MinionID 'minionid' -JobID '20210204178834112766'

```

### Example - Return the 50 most recent activities in SaltStack Config that use the function state.apply

```powershell
Get-MinionActivity -Function state.apply

```
