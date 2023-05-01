<#
.SYNOPSIS
    Removes a Schedule from SaltStack Enterprise.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the remove method on the schedule resource to return a list of Schedules.
.EXAMPLE
    Remove-SaltSchedule -Name ScheduleA

    This will remove the Schedule ScheduleA using it's name.
.EXAMPLE
    Remove-SaltSchedule -UUID e33ef27b-8a29-45c1-972c-c2a5f5472a29

    This will remove the Schedule with the UUID e33ef27b-8a29-45c1-972c-c2a5f5472a29.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Remove-SaltSchedule {
    [CmdletBinding(SupportsShouldProcess = $true,DefaultParameterSetName = 'Name')]
    param (
        # Name
        [Parameter(ParameterSetName = 'Name')]
        [String]
        $Name,
        # UUID
        [Parameter(ParameterSetName = 'UUID')]
        [String]
        $UUID
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $splat = @{
        SaltConnection = $global:SaltConnection
    }

    if ($name) {
        $splat.Add('Name',$Name)
        $splat.Add('ExactMatch',$true)
    }

    if ($UUID) {
        $splat.Add('UUID',$UUID)
    }

    $schedule = Get-SaltSchedule @splat

    if ($schedule.Count -eq 0) {
        throw "No Schedules found with the information provided."
    } elseif ($schedule.Count -gt 1) {
        throw "More than one Schedule was found matching the information provided."
    }

    $scheduleID = $schedule.uuid

    $arguments = @{
        uuid = $scheduleID
    }

    $return = Invoke-SaltStackAPIMethod -Resource schedule -Method remove -Arguments $arguments
    
    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        Write-Output -InputObject $return  
    }

}
