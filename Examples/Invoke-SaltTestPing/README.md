# Invoke-SaltTestPing - Examples
Invokes a Test.Ping command against a Target.

This function will use the Invoke-SaltStackAPIMethod command to use the route_cmd method on the cmd resource to run a test.ping against a target.

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Initiate a Test.Ping against a minion named web01

```powershell
PS C:\> Invoke-SaltTestPing -Target web01                        

MinionID                      Return JobID
--------                      ------ -----
web01                           True 20230502202536953988

```

### Example - Initiate a Test.Ping against all minions that begin with web

```powershell
PS C:\> Invoke-SaltTestPing -Target 'web*'

MinionID                      Return JobID
--------                      ------ -----
web08                           True 20230502202536953988
web07                           True 20230502202536953988
web06                           True 20230502202536953988
web09                           True 20230502202536953988
web10                           True 20230502202536953988

```

### Example - Initiate a Test.Ping against all minions matching the compound Target where the ID grain begins with 'web'

```powershell
Invoke-SaltTestPing -Target 'G@id:web*' -TargetType compound
```

### Example - Asynchronously initiate a Test.Ping against all minions matching the compound Target. The Salt JobID will be returned.

```powershell
PS C:\> $jobId = Invoke-SaltTestPing -Target 'G@id:web*' -TargetType compound -Async

PS C:\> $jobId
20230502202536953988

PS C:\> $result = Wait-SaltJob -JobID $jobId
PS C:\> $result

JobStatus      : {complete}
State          : completed_all_successful
ScheduleName   : 
TargetName     : 
MinionDetails  : {@{minion_id=web08; master_id=XXXX; has_return=True;
                has_errors=False; alter_time=5/5/2023 8:25:53 PM}, 
                @{minion_id=web07; master_id=XXXX; has_return=True; 
                has_errors=False; alter_time=5/5/2023 8:25:53 PM}, 
                @{minion_id=web06; master_id=XXXX; has_return=True; 
                has_errors=False; alter_time=5/5/2023 8:25:53 PM}, 
                @{minion_id=web09; master_id=XXXX; has_return=True; 
                has_errors=False; alter_time=5/5/2023 8:25:53 PM}…}
Function       : test.ping
Origination    : Ad-Hoc
StartTime      : 5/5/2023 8:25:36 PM
User           : username
IsHighstate    : False
JID            : 20230502202536953988
Expected       : 5
Returned       : 5
NotReturned    : 0
ReturnedGood   : 5
ReturnedFailed : 0

PS C:\> $result.MinionDetails                                        

minion_id  : web08
master_id  : XXXX
has_return : True
has_errors : False
alter_time : 5/5/2023 8:25:53 PM

minion_id  : web07
master_id  : XXXX
has_errors : False
alter_time : 5/5/2023 8:25:53 PM

minion_id  : web09
master_id  : XXXX
has_return : True
has_errors : False
alter_time : 5/5/2023 8:25:53 PM

minion_id  : web10
master_id  : XXXX
has_return : True
has_errors : False
alter_time : 5/5/2023 8:25:53 PM
```
