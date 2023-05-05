# Get-MinionGrain - Examples
Gets a grain(s) of a Target. Defaut TargetType is glob.

This function will use the Invoke-SaltStackAPIMethod command to query the route_cmd method on the cmd resource to return a Target's grain(s).

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Return all grains for that minion

```powershell
Get-MinionGrain -Target minionid
```

### Example - Return the 'osfullname' grain for that minion

```powershell
Get-MinionGrain -Target computername -Grain osfullname
```

### Example - Return the 'osfullname' grain for the minions where ID starts with "web" using a compound target type

```powershell
Get-MinionGrain -Target 'G@id:web*' -TargetType compound -Grain osfullname
```

### Example - Query SaltStack Config using the Target grains and return the 'osfullname' grain for the minions whose id starts with 'web' and where the os is Windows.

```powershell
Get-MinionGrain -Target 'id:web* and os:Windows' -TargetType grain -Grain osfullname
```