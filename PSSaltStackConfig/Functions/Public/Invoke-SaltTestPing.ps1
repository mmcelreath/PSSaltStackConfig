<#
.SYNOPSIS
    Invokes a Test.Ping command against a Target.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the route_cmd method on the cmd resource to run a test.ping against a target.
.EXAMPLE
    Invoke-SaltTestPing -Target 'web01'

    This will initiate a Test.Ping against web01.
.EXAMPLE
    Invoke-SaltTestPing -Target 'web*'

    This will initiate a Test.Ping against all minions that begin with web.
.EXAMPLE
    Invoke-SaltTestPing -Target 'G@id:web*' -TargetType compound

    This will initiate a Test.Ping against all minions matching the compound Target.
.EXAMPLE
    Invoke-SaltTestPing -Target 'G@id:web*' -TargetType compound -Async

    This will asynchronously initiate a Test.Ping against all minions matching the compound Target. The Salt JobID will be returned.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Invoke-SaltTestPing {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Target
        [Parameter(Mandatory = $true)]
        [String]
        $Target,
        [String]
        $Master = '*',
        # TargetType
        [String]
        [Validateset('glob','compound')] # To add: 'grain','list'
        $TargetType = 'glob',
        # Timeout
        [Int]
        $Timeout = 300,
        # Async
        [Switch]
        $Async
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    # Needs to be all lowercase
    $TargetType = $TargetType.ToLower()

    $tgtValue = $Target

    if ($TargetType -eq 'compound') {
        $tgtValue = $Target
    }

    $tgt = @{ 
        $Master = @{ tgt = $tgtValue; tgt_type = $TargetType} 
    }

    $arguments = @{
        cmd = 'local'
        fun = 'test.ping'
        tgt = $tgt
    }
    
    $return = Invoke-SaltStackAPIMethod -Resource cmd -Method route_cmd -Arguments $arguments

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message

        throw "$errorMessage - $errorDetail"

    } else {
        $jobId = $return.ret
    }

    if ($Async) {
        # Return the JobID associated with this job and exit
        Write-Output $return.ret
    } else {
        $waitResult = Wait-SaltJob -JobID $jobId -Timeout $Timeout
        $waitJobID = $waitResult.JID

        $output = @()

        $jobStatus = Get-SaltJobStatus -JobID $waitJobID

        foreach ($detail in $jobStatus.MinionDetails) {
            $results = [PSCustomObject]@{
                MinionID = $detail.minion_id
                Return = $detail.has_return
                JobID = $waitJobID
            }

            $output += $results
        }

        Write-Output $output

    }

}
