<#
.SYNOPSIS
    Returns a list of Schedules from SaltStack Enterprise.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the get method on the schedule resource to return a list of Schedules.
.EXAMPLE
    Get-SaltSchedule

    This will return all Schedules with a default limit of 200.
.EXAMPLE
    Get-SaltSchedule -Name AppServer

    This will return Schedules matching the name provided. This is a wildcard match so anything wtih AppServer in the name wil be returned.
.EXAMPLE
    Get-SaltSchedule -UUID '3e396a37-020c-4756-9953-2p3e1f466b87'

    This will return a Schedule matching the UUID provided.
.EXAMPLE
    Get-SaltSchedule -Name AppServer -ExactMatch

    This will return a Target matching the exact name provided.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-SaltSchedule {
    [CmdletBinding(SupportsShouldProcess = $true,DefaultParameterSetName = 'Name')]
    param (
        # Name
        [Parameter(ParameterSetName = 'Name')]
        [Array]
        $Name,
        # UUID
        [Parameter(ParameterSetName = 'UUID')]
        [String]
        $UUID,
        # ExactMatch
        [Switch]
        $ExactMatch,
        # Limit
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [Int]
        $Limit = 200
    )
    
    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $arguments = @{
        limit = $limit
    }
    
    if ($name) {
        $arguments.Add('names',$Name)
    }

    if ($UUID) {
        $arguments.Add('uuid',$UUID)
    }

    $return = Invoke-SaltStackAPIMethod -Resource schedule -Method get -Arguments $arguments
    
    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        if (($Name) -and ($ExactMatch)) {
            $schedules = $return.ret.results | Where-Object Name -eq $name
        } else {
            $schedules = $return.ret.results
        }
    }

    Write-Output -InputObject $schedules

}
