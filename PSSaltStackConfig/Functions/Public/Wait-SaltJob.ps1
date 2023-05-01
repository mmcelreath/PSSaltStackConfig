<#
.SYNOPSIS
    Waits for a Salt job to complete and returns the job status.
.DESCRIPTION
    This function will use Get-SaltJobStatus and wait until the job completes. Once the job is completed, this functions will return the job's status information.
.EXAMPLE
    Wait-SaltJob -JobID $JobId

    This will query the SaltStack Config API and wait for $JobID to complete.
.EXAMPLE
    Wait-SaltJob -JobID $JobId -Timeout 500

    This will query the SaltStack Config API and wait for $JobID to complete with a timeout of 500 seconds (300 is the default value if omitted)
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Wait-SaltJob {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # JobID
        [Parameter(Mandatory = $true)]
        [String]
        $JobID,
        # Timeout
        [int]
        $Timeout = 300
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    # Convert Timeout seconds for while loop
    $Timeout = $Timeout / 3

    # Getting Job Status
    $returnStatus = Get-SaltJobStatus -JobID $JobID
    $jobStatus = $returnStatus.JobStatus

    # Wait for the job to be created
    $i = 1

    while ($jobStatus -eq 'not-found'){
        if($i -gt 15) {
            throw "JID: $JobID was not found."
        } else {
            # Write-Host $jobStatus
            Start-Sleep -Seconds 3
            $returnStatus = Get-SaltJobStatus -JobID $JobID
            $jobStatus = $returnStatus.JobStatus

            $i++
        }
    }

    # Wait for job to complete
    $i = 1

    while ($returnStatus.State -ne 'completed_all_successful') {    
        
        if ($returnStatus.State -eq 'completed_failures') {
            break
        }

        if($i -gt $Timeout) {
            Write-Warning "Command timed out while waiting for JID $JobID to complete."
            break
        } else {
            # Write-Host $returnStatus.State
            Start-Sleep -Seconds 3
            $returnStatus = Get-SaltJobStatus -JobID $JobID

            $i++
        }

    }

    $returnStatus = Get-SaltJobStatus -JobID $JobID

    Write-Output -InputObject $returnStatus

}
