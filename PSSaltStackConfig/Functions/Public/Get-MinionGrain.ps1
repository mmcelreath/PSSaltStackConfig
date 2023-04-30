<#
.SYNOPSIS
    Gets a grain(s) of a Target. Defaut TargetType is glob.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to query the route_cmd method on the cmd resource to return a Target's grain(s).
.EXAMPLE
    Get-MinionGrain -SaltConnection $SaltConnection -Target computername

    This will query SaltStack Config for a vailid key associated with the Target then return all grains for that minion.
.EXAMPLE
    Get-MinionGrain -SaltConnection $SaltConnection -Target computername -Grain osfullname

    This will query SaltStack Config for a valid key associated with the Target then return the 'osfullname' grain for that minion.
.EXAMPLE
    Get-MinionGrain -SaltConnection $SaltConnection -Target 'G@id:web*' -TargetType compound -Grain osfullname

    This will query SaltStack Config using the Target compound and return the 'osfullname' grain for the minions where ID starts with "web".
.EXAMPLE
    Get-MinionGrain -SaltConnection $SaltConnection -Target 'id:web* and os:Windows' -TargetType grain -Grain osfullname 

    This will query SaltStack Config using the Target grains and return the 'osfullname' grain for the minions whose id starts with 'web' and where the os is Windows.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-MinionGrain {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Salt connection object
        [Parameter(Mandatory = $true)]
        [SaltConnection]
        $SaltConnection,
        [Parameter(Mandatory = $true)]
        [String]
        $Target,
        [String]
        [Validateset('glob','compound','grain','list')]
        $TargetType = 'glob',
        [String]
        $Grain,
        [String]
        $Master,
        [Int]
        $Timeout = 300,
        [Switch]
        $Async = $false
    )

    # Needs to be all lowercase
    $TargetType = $TargetType.ToLower()
    $array = @()

    if ($TargetType -eq 'glob') {
        $minionKeyState = Get-MinionKeyState -SaltConnection $SaltConnection -MinionID $Target

        if ($minionKeyState.key_state -ne 'accepted') {
            Write-Error "The key for $Target is not currently accepted or it doesn't exist."
        }
        
        $tgtValue = $minionKeyState.minion
    }

    if ($TargetType -in 'compound','grain','list') {
        $tgtValue = $Target
    }

    $tgt = @{ 
        $Master = @{ tgt = $tgtValue; tgt_type = $TargetType} 
    }

    if ($Grain) {
        $function = 'grains.get'
        $array = @(,$Grain)
    } else {
        $function = 'grains.items'
    }

    $arguments = @{
        cmd = 'local'
        fun = $function
        tgt = $tgt
    }

    if ($Grain) {
        $arg = @{
            arg = $array
        } 
        $arguments.Add('arg', $arg)
    }

    $return = Invoke-SaltStackAPIMethod -SaltConnection $SaltConnection -Resource cmd -Method route_cmd -Arguments $arguments

    $jobID = $return.ret

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        if ($Async) {
            Write-Output $return
        } else {
            Start-Sleep -Seconds 15
            Wait-SaltJob -SaltConnection $SaltConnection -JobID $jobid -Timeout $Timeout | Out-Null
            $results = Get-SaltJobResults -SaltConnection $SaltConnection -JobID $jobID
            Write-Output $results
        }
    }
}
