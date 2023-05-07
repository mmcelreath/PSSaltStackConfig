# Get-SaltJobResults - Examples
Gets the detailed results of a Salt job. Provides more details than [Get-SaltJobStatus](../Get-SaltJobStatus/README.md)

This function will use the Invoke-SaltStackAPIMethod command to use the get_jid on the cmd resource to return the detailed results of a Salt job.

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Return the detailed results of $JobID

```powershell
Get-SaltJobResults -JobID $JobID

```

### Example - Run a State against a minion, wait for the job to complete, then retrieve the job results using `Get-SaltJobResults`

```powershell
# Start the State job
PS C:\> $jobId = Invoke-SaltState -Target minionid -State test.module

# Wait for the job to finish
PS C:\> Wait-SaltJob -JobID $jobId

JobStatus      : {complete}
State          : completed_all_successful
ScheduleName   : 
TargetName     : 
MinionDetails  : {@{minion_id=minionid; master_id=XXXXX; has_return=True; has_errors=False; alter_time=5/5/2023 6:54:23 PM}}
Function       : state.apply
Origination    : Ad-Hoc
StartTime      : 5/5/2023 6:52:38 PM
User           : username
IsHighstate    : True
JID            : 20230505183238737039
Expected       : 1
Returned       : 1
NotReturned    : 0
ReturnedGood   : 1
ReturnedFailed : 0

PS C:\> $results = Get-SaltJobResults -JobID $jobid
PS C:\> $results

MinionID     : minionid
Results      : {[All, System.Object[]], [InDesiredState, System.Object[]], [NotInDesiredState, System.Object[]]}
Function     : state.apply
FunctionArgs : {test.module}
TimeStamp    : 5/5/2023 7:11:48 PM
Success      : True
Changed      : True
ReturnCode   : 0
Return       : @{file_|-Create Tests Directory_|-c:\Tests_|-directory=; file_|-Create LogFiles Directory_|-c:\LogFiles_|-directory=}

PS C:\> $results.Results

Name                           Value
----                           -----
All                            {@{ID=Create Tests Directory; Result=True; Command=file_|-Create Tests Directory_|-c:\Tests_|-directory; StartTime=15:11:48.121124; Duration=0; Changes=; PChanges=; SLS=tes… 
InDesiredState                 {}
NotInDesiredState              {@{ID=Create Tests Directory; Result=True; Command=file_|-Create Tests Directory_|-c:\Tests_|-directory; StartTime=15:11:48.121124; Duration=0; Changes=; PChanges=; SLS=tes… 

PS C:\> $results.Results.NotInDesiredState

ID        : Create Tests Directory
Result    : True
Command   : file_|-Create Tests Directory_|-c:\Tests_|-directory
StartTime : 15:11:48.121124
Duration  : 0
Changes   : @{c:\Tests=}
PChanges  : 
SLS       : test.module
Comment   : 
Name      : c:\Tests
RunNum    : 1
SkipWatch : 
Changed   : True

ID        : Create LogFiles Directory
Result    : True
Command   : file_|-Create LogFiles Directory_|-c:\LogFiles_|-directory
StartTime : 15:11:48.074235
Duration  : 46.889
Changes   : @{c:\LogFiles=}
PChanges  : 
SLS       : test.module
Comment   : 
Name      : c:\LogFiles
RunNum    : 0
SkipWatch : 
Changed   : True
```
