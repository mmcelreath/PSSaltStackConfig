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

    This will query the SaltStack Config API and wait for $JobID to complete with a timeout of 500 seconds (60 is the default value if omitted)
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
        $Timeout = 60
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    }

    $date = Get-Date

    # Getting Job Status
    $returnStatus = Get-SaltJobStatus -JobID $JobID
    $jobStatus = $returnStatus.JobStatus

    $timeDifference = $date - $returnStatus.StartTime.ToLocalTime()

    if ($timeDifference.TotalSeconds -gt $Timeout) {
        # If the duration of the Job ID has already exceeded the $Timeout, return the job status
        $returnStatus = Get-SaltJobStatus -JobID $JobID

        Write-Output -InputObject $returnStatus
    } else {
        # Wait for the job to be created
        $i = 1

        while ($jobStatus -eq 'not-found'){
            if($i -gt 5) {
                throw "JID: $JobID was not found."
            } else {
                Write-Verbose "Waiting for job $jobID to start..."
                Start-Sleep -Seconds 5
                $returnStatus = Get-SaltJobStatus -JobID $JobID
                $jobStatus = $returnStatus.JobStatus

                $i++
            }
        }

        # Wait for job to complete
        while ($returnStatus.State -ne 'completed_all_successful') {

            Write-Verbose "Waiting for job $jobID to finish..."

            if ($returnStatus.State -eq 'completed_failures') {
                break
            }

            $date = Get-Date
            $timeDifference = $date - $returnStatus.StartTime.ToLocalTime()

            if($timeDifference.TotalSeconds -gt $Timeout) {
                Write-Warning "Command timed out while waiting for JID $JobID to complete. Try setting -Timeout to a value higher than 60."
        
                break
            } else {
                # Write-Host $returnStatus.State
                Start-Sleep -Seconds 5
                $returnStatus = Get-SaltJobStatus -JobID $JobID -Verbose:$false
            }

        }

        $returnStatus = Get-SaltJobStatus -JobID $JobID

        Write-Output -InputObject $returnStatus
    }
}
