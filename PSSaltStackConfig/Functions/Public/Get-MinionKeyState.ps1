<#
.SYNOPSIS
    Gets the state of a Minions key.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to query the get_minion_key_state method on the minions resource to return a minion's key state.
.EXAMPLE
    Get-MinionKeyState -MinionID 'minionname.domain.local'

    This will return the key state of a minion id.
.EXAMPLE
    Get-MinionKeyState -MinionID 'minionname.domain.local' -KeyState accepted

    This will return minion key state of a minion if it is in the "accepted" state. Otherwise, the return will be empty.
.EXAMPLE
    Get-MinionKeyState -KeyState pending

    This will return minion key states that are "pending".
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-MinionKeyState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # MinionID
        [String]
        $MinionID,
        # KeyState
        [String]
        [Validateset('pending','accepted','rejected','denied')]
        $KeyState
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $arguments = @{}

    # Sets no limit to the number of results to return
    $arguments.Add('limit','0')

    if ($MinionID) {
        if ($KeyState) {
            # MinionID and KeyState specified
            $arguments.Add('minion_id',$minionID)
            $arguments.Add('key_state',$KeyState)
        } else {
            # Only MinionID Specified
            $arguments.Add('minion_id',$minionID)
        }
    } elseif ($KeyState) {
        # Only KeyState provided
        $arguments.Add('key_state',$KeyState)
    }

    $return = Invoke-SaltStackAPIMethod -Resource minions -Method get_minion_key_state -Arguments $arguments

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        $results = $return.ret.results
        Write-Output -InputObject $results
    }

}
