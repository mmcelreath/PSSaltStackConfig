# Get-SaltJobStatus - Examples
Gets the status of a Salt job. Provides some basic infomration such as success/failure, number of minions returned, etc... For more details on State jobs, use [Get-SaltJobResults](../Get-SaltJobResults/README.md)

This function will use the Invoke-SaltStackAPIMethod command to use the get_cmd_status, get_cmd_details and get_cmds methods on the cmd resource to get the status of a Salt job.

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Return the status of $JobID

```powershell
PS C:\> Get-SaltJobStatus -JobID $JobID

JobStatus      : {complete}
State          : completed_all_successful
ScheduleName   :
TargetName     :
MinionDetails  : {@{minion_id=web01; master_id=XXXX; has_return=True; has_errors=False; alter_time=5/7/2023 10:16:46 PM}}
Function       : test.ping
Origination    : Ad-Hoc
StartTime      : 5/7/2023 10:16:34 PM
User           : username
IsHighstate    : False
JID            : 2023052722863495517
Expected       : 1
Returned       : 1
NotReturned    : 0
ReturnedGood   : 1
ReturnedFailed : 0

```
