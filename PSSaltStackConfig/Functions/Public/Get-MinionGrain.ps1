<#
.SYNOPSIS
    Gets a grain(s) of a Target. Defaut TargetType is glob.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to query the route_cmd method on the cmd resource to return a Target's grain(s).
.EXAMPLE
    Get-MinionGrain -Target computername

    This will query SaltStack Config for a vailid key associated with the Target then return all grains for that minion.
.EXAMPLE
    Get-MinionGrain -Target computername -Grain osfullname

    This will query SaltStack Config for a valid key associated with the Target then return the 'osfullname' grain for that minion.
.EXAMPLE
    Get-MinionGrain -Target 'G@id:web*' -TargetType compound -Grain osfullname

    This will query SaltStack Config using the Target compound and return the 'osfullname' grain for the minions where ID starts with "web".
.EXAMPLE
    Get-MinionGrain -Target 'id:web* and os:Windows' -TargetType grain -Grain osfullname 

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
        [Parameter(Mandatory = $true)]
        [String]
        $Target,
        [String]
        [Validateset('glob','compound','grain','list')]
        $TargetType = 'glob',
        [String]
        $Grain,
        [String]
        $Master = '*', # Default to '*' for "All Masters". To do: add ability to pass multiple masters
        [Int]
        $Timeout = 300,
        [Switch]
        $Async = $false
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    # Needs to be all lowercase
    $TargetType = $TargetType.ToLower()
    $array = @()

    if ($TargetType -eq 'glob') {
        $minionKeyState = Get-MinionKeyState -MinionID $Target

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

    $return = Invoke-SaltStackAPIMethod -Resource cmd -Method route_cmd -Arguments $arguments

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
            Wait-SaltJob -JobID $jobid -Timeout $Timeout | Out-Null
            $results = Get-SaltJobResults -JobID $jobID
            Write-Output $results
        }
    }
}
