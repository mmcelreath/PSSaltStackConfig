# Set-MinionKeyState - Examples
Sets the state of a Minions key.

This function will use the Invoke-SaltStackAPIMethod command to use the set_minion_key_state method on the minions resource to set a minion's key state.

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Accept the key for the specified minion if the key is currently pending

```powershell
Set-MinionKeyState -MinionID minionname.domain.local -KeyState accept
```

### Example - Accept the key for the specified minion if the key is currently pending on a specific Master

```powershell
Set-MinionKeyState -MinionID minionname.domain.local -KeyState accept -Master saltmaster
```

### Example - Reject the key for the specified minion

```powershell
Set-MinionKeyState -MinionID minionname.domain.local -KeyState reject
```

### Example - Delete the key for the specified minion

```powershell
Set-MinionKeyState -MinionID minionname.domain.local -KeyState delete
```
