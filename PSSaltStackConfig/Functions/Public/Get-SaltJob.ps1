<#
.SYNOPSIS
    Returns a list of Jobs from SaltStack Enterprise.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the get_jobs method on the job resource to return a list of Jobs.
.EXAMPLE
    Get-SaltJob

    This will return all Jobs with a default limit of 200.
.EXAMPLE
    Get-SaltJob -Name TestJob

    This will return Jobs matching the name provided.
.EXAMPLE
    Get-SaltJob -UUID '3e376a32-f90c-4756-7933-253e1f4h6b87'

    This will return a Job matching the UUID provided.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-SaltJob {
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
        limit = $Limit
    }
    
    if ($Name) {
        $arguments.Add('name',$Name)
    }

    if ($UUID) {
        $arguments.Add('job_uuid',$UUID)
    }

    $return = Invoke-SaltStackAPIMethod -Resource job -Method get_jobs -Arguments $arguments

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        if (($Name) -and ($ExactMatch)) {
            $jobs = $return.ret.results | Where-Object Name -eq $name
        } else {
            $jobs = $return.ret.results
        }
    }
        
    Write-Output -InputObject $jobs

}
