<#
.SYNOPSIS
    Updates a Schedule in SaltStack Enterprise.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the update method on the schedule resource to update a Schedule.
.EXAMPLE
    Set-SaltSchedule -Name ScheduleA -NewName ScheduleB

    This will rename the schedule "ScheduleA" to the new name of "ShceduleB".
.EXAMPLE
    Set-SaltSchedule -Name ScheduleA -TargetName TestServers

    This will update ScheduleA to target the TestServes Target Group.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Set-SaltSchedule {
    [CmdletBinding(SupportsShouldProcess = $true,DefaultParameterSetName = 'Name')]
    param (
        # Name
        [Parameter(ParameterSetName = 'Name')]
        [String]
        $Name,
        # UUID
        [Parameter(ParameterSetName = 'UUID')]
        [String]
        $UUID,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [String]
        $NewName,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [String]
        $TargetName,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [String]
        $JobName,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [datetime]
        $StartDate,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [String]
        $IntervalUnits,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [String]
        [Validateset('hours','minutes','seconds')]
        $IntervalUnitType,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [Int]
        $SplayStart,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [Int]
        $SplayEnd
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $splat = @{
        SaltConnection = $global:SaltConnection
        ExactMatch = $true
    }

    if ($name) {
        $splat.Add('Name',$Name)
    }

    if ($UUID) {
        $splat.Add('UUID',$UUID)
    }

    $schedule = Get-SaltSchedule @splat

    if ($schedule.Count -eq 0) {
        throw 'No Schedules returned based on the information provided.'
    } 

    if ($schedule.Count -gt 1) {
        throw 'More than one Schedule was returned based on the information provided.'
    } 

    $scheduleID = $schedule.uuid
    $scheduleSched = $schedule.schedule

    $arguments = @{        
        uuid = $scheduleID
    }

    if ($NewName) {
        $arguments.Add('name', $NewName)
    }

    if ($TargetName) {
        $target = Get-SaltTarget -Name $TargetName -ExactMatch
        $targetID = $target.uuid
        $arguments.Add('tgt_uuid', $targetID)
    }

    if ($JobName) {
        $job = Get-Saltjob -Name $JobName -ExactMatch
        $jobID = $job.uuid
        $arguments.Add('job_uuid', $jobID)
    }

    if (($StartDate -ne $null) -or ($IntervalUnits -ne $null) -or ($IntervalUnitType -ne $null) -or ($SplayStart -ne $null) -or ($SplayEnd -ne $null)) {
        $newSchedule = $scheduleSched.PSObject.Copy()

        if ($StartDate) {
            $newSchedule.after = $StartDate
        }

        if (($IntervalUnitType -ne $null) -or ($IntervalUnits -ne $null)) {
            
            $scheduleIntervalType = $scheduleSched.PSObject.properties | Where-Object Name -in 'hours','minutes','seconds' | Select-Object -ExpandProperty Name
            $scheduleIntervalUnits = $scheduleSched.$scheduleIntervalType

            $newIntervalType = $scheduleIntervalType
            $newIntervalUnits = $scheduleIntervalUnits

            if ($IntervalUnitType) {
                $newIntervalType = $IntervalUnitType
            }

            if ($IntervalUnits) {
                $newIntervalUnits = $IntervalUnits
            }
            
            $newSchedule.PSObject.properties.remove($scheduleIntervalType)
            $newSchedule | Add-Member -NotePropertyName $newIntervalType -NotePropertyValue $newIntervalUnits
        }

        if (($SplayStart -ne $null) -or ($SplayEnd -ne $null)) {

            if ($schedule.schedule.splay) {
                $newSplay = $schedule.schedule.splay.PSObject.Copy()
                $newSchedule.PSObject.properties.remove('splay')

                $newSplayHash = @{
                    start = $newSplay.start
                    end = $newSplay.end
                }
            } else {
                $newSplayHash = @{
                    start = 0
                    end = 0
                }
            }

            if ($SplayStart) {
                $newSplayHash.start = $SplayStart
            }

            if ($SplayEnd) {
                $newSplayHash.end = $SplayEnd
            }

            if ($newSplayHash.end -lt $newSplayHash.start) {
                throw 'Splay End cannot be smaller than Splay Start.'
            }

            $newSchedule | Add-Member -NotePropertyName 'splay' -NotePropertyValue $newSplayHash

        }

        $arguments.Add('schedule', $newSchedule)
    }

    $return = Invoke-SaltStackAPIMethod -Resource schedule -Method update -Arguments $arguments

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        Write-Output -InputObject $return
    }

}
