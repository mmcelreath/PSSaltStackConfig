<#
.SYNOPSIS
    Gets the status of a Salt job.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the get_cmd_status, get_cmd_details and get_cmds methods on the cmd resource to get the status of a Salt job.
.EXAMPLE
    Get-SaltJobStatus -JobID $JobID

    This will return the status of $JobID.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-SaltJobStatus {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # JobID
        [Parameter(Mandatory = $true)]
        [String]
        $JobID
        
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    # This is how many records to return at a time. The default is 50. We're setting it to 1,000. Often used with page
    # Will need to update these functions if the number of possible minions grows to over 1,000.
    $limit = 1000

    # Getting Job Status

    # Array formatted with leading comma in order to work with SaltStack Config
    $array = @(,$JobID)

    $arguments = @{
        jids = $array
    }

    $returnCmdStatus = Invoke-SaltStackAPIMethod -Resource cmd -Method get_cmd_status -Arguments $arguments

    if ($returnCmdStatus.error) {
        $errorDetail = $returnCmdStatus.error.detail.state
        $errorMessage = $returnCmdStatus.error.message

        throw "$errorMessage - $errorDetail"

    } else {
        $jobStatus = $returnCmdStatus.ret
    }

    # Getting Job Details

    $arguments = @{
        jid = $JobID
        limit = $limit
    }

    $returndCmdDetails = Invoke-SaltStackAPIMethod -Resource cmd -Method get_cmd_details -Arguments $arguments

    if ($return.error) {
        $errorDetail = $returndCmdDetails.error.detail.state
        $errorMessage = $returndCmdDetails.error.message

        throw "$errorMessage - $errorDetail"

    } else {
        $jobDetails = $returndCmdDetails.ret.results
    }

    # Getting Job

    $arguments = @{
        jid = $JobID
        limit = $limit
    }

    $returndCmd = Invoke-SaltStackAPIMethod -Resource cmd -Method get_cmds -Arguments $arguments

    if ($return.error) {
        $errorDetail = $returndCmd.error.detail.state
        $errorMessage = $returndCmd.error.message

        throw "$errorMessage - $errorDetail"

    } else {
        $job = $returndCmd.ret.results
    }

    $properties = @{
        JobStatus = $jobStatus
        MinionDetails = $jobDetails
        State = $job.state
        JID = $job.jid
        User = $job.user
        StartTime = $job.start_time
        Expected = $job.expected
        Returned = $job.returned
        ReturnedGood = $job.returned_good
        ReturnedFailed = $job.returned_Failed
        NotReturned = $job.not_returned
        Function = $job.fun
        Origination = $job.origination
        IsHighstate = $job.is_highstate
        ScheduleName = $job.sched_name
        TargetName = $job.tgt_name
    }

    $obj = New-Object -TypeName PSCustomObject -Property $properties

    Write-Output -InputObject $obj | Select-Object JobStatus,State,ScheduleName,TargetName,MinionDetails,Function,Origination,StartTime,User,IsHighstate,JID,Expected,Returned,NotReturned,ReturnedGood,ReturnedFailed

}
