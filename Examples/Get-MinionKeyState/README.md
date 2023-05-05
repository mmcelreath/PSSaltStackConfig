# Get-MinionKeyState - Examples
Gets the state of a Minion's key.

This function will use the Invoke-SaltStackAPIMethod command to query the get_minion_key_state method on the minions resource to return a minion's key state.

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Return the key state of a minion id

```powershell
PS C:\> Get-MinionKeyState -MinionID 'minionname.domain.local'

master    minion                        key_state
------    ------                        ---------
master    minionname.domain.local       {accepted}
```

### Example - Return minion key states that are "pending"

```powershell
PS C:\> Get-MinionKeyState -KeyState pending

master    minion                        key_state
------    ------                        ---------
master    minionname1.domain.local      {pending}
master    minionname2.domain.local      {pending}
master    minionname3.domain.local      {pending}

```
