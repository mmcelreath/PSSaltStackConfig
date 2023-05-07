# Get-SaltJob - Examples
Returns a list of Jobs from SaltStack Config.

This function will use the Invoke-SaltStackAPIMethod command to use the get_jobs method on the job resource to return a list of Jobs

### Connect to the SaltStack server

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

### Example - Return all Jobs with a default limit of 200

```powershell
Get-SaltJob

```

### Example - return Jobs matching the name provided

```powershell
Get-SaltJob -Name JobName

```

### Example - Return a Job matching the UUID provided

```powershell
Get-SaltJob -UUID '3706a32-f90c-9756-78e3-25e3te1f4h6b87'

```
