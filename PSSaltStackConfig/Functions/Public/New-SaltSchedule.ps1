<#
.SYNOPSIS
    Creates a Schedule in SaltStack Enterprise.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the save method on the schedule resource to create a Schedule.
.EXAMPLE
    New-SaltSchedule -Name ScheduleA -TargetName TestServers -JobName test.ping -StartDate (Get-Date).AddMinutes(5) -IntervalUnits 5 -IntervalUnitType hours

    This will create a schedule named "ScheduleA" which will run the test.ping job targeting the TestServers target group starting 5 minutes after the current date and time which will run every 5 hours.
.EXAMPLE
    New-SaltSchedule -Name ScheduleA -TargetName TestServers -JobName test.ping -StartDate "11/16/2020 9:50" -IntervalUnits 5 -IntervalUnitType hours

    This will create a schedule named "ScheduleA" which will run the test.ping job targeting the TestServers target group starting on a specific date/time which will run every 5 hours.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function New-SaltSchedule {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,
        [Parameter(Mandatory = $true)]
        [String]
        $TargetName,
        [Parameter(Mandatory = $true)]
        [String]
        $JobName,
        [Parameter(Mandatory = $true)]
        [datetime]
        $StartDate,
        [Parameter(Mandatory = $true)]
        [String]
        $IntervalUnits,
        [Parameter(Mandatory = $true)]
        [String]
        [Validateset('hours','minutes','seconds')]
        $IntervalUnitType,
        [String]
        $Timezone = 'America/New_York',
        [Int]
        $SplayStart,
        [Int]
        $SplayEnd
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $schedule = Get-SaltSchedule -Name $Name -ExactMatch

    if ($schedule.Count -gt 0) {
        throw "Another Schedule exists already with the name: $Name"
    } 

    $job = Get-SaltJob -Name $JobName -ExactMatch
    $target = Get-SaltTarget -Name $TargetName -ExactMatch

    if ($job.Count -eq 0) {
        throw "No Jobs found with the name: $JobName"
    } elseif ($job.Count -gt 1) {
        throw "More than one Job was found matching the name: $JobName"
    }

    if ($target.Count -eq 0) {
        throw "No Targets found with the name: $TargetName"
    } elseif ($target.Count -gt 1) {
        throw "More than one Target was found matching the name: $TargetName"
    }

    $jobID = $job.uuid
    $targetID = $target.uuid

    $schedule = @{
        after = $StartDate
        $IntervalUnitType = $IntervalUnits
        timezone = $Timezone
        
    }

    if (($SplayStart -ne $null) -or ($SplayEnd -ne $null)) {
        $splay = @{
            start = $SplayStart
            end = $SplayEnd
        }

        $schedule.add('splay', $splay)
    }

    $arguments = @{
        name = $name
        schedule = $schedule
        tgt_uuid = $targetID
        job_uuid = $jobID
    }

    $return = Invoke-SaltStackAPIMethod -Resource schedule -Method save -Arguments $arguments
    
    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        Write-Output -InputObject $return
    }
      
}
