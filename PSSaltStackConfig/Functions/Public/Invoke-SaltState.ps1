<#
.SYNOPSIS
    Invokes a State.Apply command against a Target.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the route_cmd method on the cmd resource to run a state.apply against a target.
.EXAMPLE
    Invoke-SaltState -Target computername -State webserver

    This will run the webserver state file against computername.
.EXAMPLE
    Invoke-SaltState -Target computername -State webserver -Test

    This will initiate a test run the webserver state file against computername.
.EXAMPLE
    Invoke-SaltState -Target computername -State highstate -Exclude 'psreposetup,set_psversion_grain'

    This will run a highstate against computername, excluding the psreposetup and set_psversion_grain states. The Exclude parameter should be a 
    comma separated string.
.EXAMPLE
    Invoke-SaltState -Target 'G@webserver:true' -TargetType compound -State highstate 

    This will run a highstate against the compound target where the webserver grain is set to true.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Invoke-SaltState {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Target
        [Parameter(Mandatory = $true)]
        [String]
        $Target,
        # State
        [Parameter(Mandatory = $true)]
        [String]
        $State,
        # TargetType
        [String]
        [Validateset('glob','compound')] # To add: 'grain','list'
        $TargetType = 'glob',
        [String]
        $Master = '*',
        # Exclude
        [String]
        $Exclude,
        # Test
        [Switch]
        $Test,
        # Timeout
        [Int]
        $Timeout = 300
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

    if ($TargetType -eq 'compound') {
        $tgtValue = $Target
    }

    $tgt = @{ 
        $Master = @{ tgt = $tgtValue; tgt_type = $TargetType} 
    }

    if ($State -eq 'highstate') {
        $array = @()
        $function = 'state.highstate'
    } else {
        $array = @(,$State)
        $function = 'state.apply'
    }

    if ($Exclude) {
        # $array += "exclude=$Exclude"
        $array = @(,"exclude=$Exclude")
    }

    if ($Test) {
        $array += 'test=true'
    }

    $arg = @{
        arg = $array
    }    

    $arguments = @{
        cmd = 'local'
        fun = 'state.apply'
        tgt = $tgt
        arg = $arg
    }

    $return = Invoke-SaltStackAPIMethod -Resource cmd -Method route_cmd -Arguments $arguments

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message

        Write-Error "$errorMessage - $errorDetail"

    } else {
        Write-Output -InputObject $return.ret
    }
}
