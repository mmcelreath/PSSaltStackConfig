# Invoke-SaltState - Examples
Invokes a State.Apply command against a Target. Returns the Job ID of the state run. `Get-SaltJobStatus` can be used to check the status of a job. Use `Wait-SaltJob` to wait for the job to finish. Use `Get-SaltJobResults` to retrieve the results of a job once it is finished.

This function will use the Invoke-SaltStackAPIMethod command to use the route_cmd method on the cmd resource to run a state.apply against a target.

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Run a highstate against a single target with TargetType = glob

```powershell
Invoke-SaltState -Target minionid -State highstate -TargetType glob
```

### Example - Run a State against a single target in test mode

```powershell
Invoke-SaltState -Target minionid -State highstate -TargetType glob -Test
```

### Example - Run the webserver state file against minionid on the specified master server. The -Master parameter defaults to '*' for all masters

```powershell
Invoke-SaltState -Target minionid -State webserver -Master <saltmaster>
```

### Example - Run a Salt state against a single minion. TargetType defaults to "glob"

```powershell
Invoke-SaltState -Target minionid -State webserver
```

### Example - Run a highstate against minionid, excluding the initial_setup and set_psversion states. The Exclude parameter should be a comma separated string
```powershell
Invoke-SaltState -Target minionid -State highstate -Exclude 'initial_setup,set_psversion'
```

### Example - Run a highstate against a compound target where the webserver grain is set to true

```powershell
Invoke-SaltState -Target 'G@webserver:true' -TargetType compound -State highstate
```

### Example - Run a State against a minion, wait for the job to complete, then retrieve the job results

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