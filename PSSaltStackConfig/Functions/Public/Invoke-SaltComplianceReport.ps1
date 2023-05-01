<#
.SYNOPSIS
    Uses Invoke-SaltState and Get-SaltJobResults to run a compliance report against a Target.
.DESCRIPTION
    This function will use the Invoke-SaltState and Get-SaltJobResults commands to run a compliance report against a set of Targets.
.EXAMPLE

.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Invoke-SaltComplianceReport {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Salt connection object
        [Parameter(Mandatory = $true)]
        [SaltConnection]
        $SaltConnection,
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
        [Validateset('glob','compound')] # To add: 'grain','list','compound'
        $TargetType = 'glob',
        # Exclude
        [String]
        $Exclude,
        # Timeout
        [Int]
        $Timeout = 500
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $jobid = Invoke-SaltState -SaltConnection $global:SaltConnection -TargetType $TargetType -Target $Target -State $State -Exclude $Exclude

    $i = 0

    while ($i -le 60) {
        $status = Get-SaltJobStatus -SaltConnection $global:SaltConnection -JobID $jobid

        if ($status.JobStatus -ne 'not-found') {
            break
        } else {
            Start-Sleep -s 5
            $status = Get-SaltJobStatus -SaltConnection $global:SaltConnection -JobID $jobid
        }
        
        $i++
    }
    
    $jobStatus = Wait-SaltJob -SaltConnection $global:SaltConnection -JobID $jobId -Timeout $Timeout

    $minions = Get-SaltJobResults -SaltConnection $global:SaltConnection -JobID $jobid

    $results = @()

    foreach ($minion in $minions) {
        
        $notInDesiredState = ''

        if ($minion.Changed) {
            $counter = 0
            foreach ($s in $minion.Results.NotInDesiredState) {
                [string]$runNum = $s.RunNum
                $stateID = $runNum + ": " + $s.ID
                if ($counter -lt ($minion.Results.NotInDesiredState.Count - 1)) {
                    $notInDesiredState += $stateID + "`n"
                } else {
                    $notInDesiredState += $stateID
                }
                $counter++
            }
        } else {
            $notInDesiredState = 'NONE'
        }
        
        $obj = [PSCustomObject]@{
            ComputerName = $minion.minionID
            Success = $minion.Success
            Changed = $minion.Changed
            NotInDesiredState = $notInDesiredState
        }

        $results += $obj
    }

    Write-Output -InputObject $results

}