<#
.SYNOPSIS
    Sets the state of a Minions key.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the set_minion_key_state method on the minions resource to set a minion's key state.
.EXAMPLE
    Set-MinionKeyState -SaltConnection $SaltConnection -MinionID 'minionname.domain.local' -KeyState accept

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
        # Salt connection object
        [Parameter(Mandatory = $true)]
        [SaltConnection]
        $SaltConnection,
        [String]
        $Master,
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

    $arguments = @{
        'state'   = "$KeyState";
        'minions' = @(, @($Master, "$MinionID"))
    }

    $return = Invoke-SaltStackAPIMethod -SaltConnection $SaltConnection -Resource minions -Method set_minion_key_state -Arguments $arguments

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message

        Write-Error "$errorMessage - $errorDetail"

    }
    else {
        Write-Output -InputObject $return.ret
    }

}
