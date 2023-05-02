<#
.SYNOPSIS
    Sets the state of a Minions key.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the set_minion_key_state method on the minions resource to set a minion's key state.
.EXAMPLE
    Set-MinionKeyState -MinionID 'minionname.domain.local' -KeyState accept

    This will accept the key for the specified minion if the key is currently pending.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Set-MinionKeyState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [String]
        $Master = '*',
        # MinionID
        [Parameter(Mandatory = $true)]
        [String]
        $MinionID,
        # KeyState
        [Parameter(Mandatory = $true)]
        [String]
        [Validateset('accept', 'delete', 'reject')]
        $KeyState
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $arguments = @{
        'state'   = "$KeyState";
        'minions' = @(, @($Master, "$MinionID"))
    }

    $return = Invoke-SaltStackAPIMethod -Resource minions -Method set_minion_key_state -Arguments $arguments

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message

        Write-Error "$errorMessage - $errorDetail"

    }
    else {
        Write-Output -InputObject $return.ret
    }

}
