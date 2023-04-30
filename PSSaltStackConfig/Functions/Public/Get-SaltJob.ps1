<#
.SYNOPSIS
    Returns a list of Jobs from SaltStack Enterprise.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the get_jobs method on the job resource to return a list of Jobs.
.EXAMPLE
    Get-SaltJob -SaltConnection $SaltConnection

    This will return all Jobs with a default limit of 200.
.EXAMPLE
    Get-SaltJob -SaltConnection $SaltConnection -Name TestJob

    This will return Jobs matching the name provided.
.EXAMPLE
    Get-SaltJob -SaltConnection $SaltConnection -UUID '3e376a32-f90c-4756-7933-253e1f4h6b87'

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
        # Salt connection object
        [Parameter(Mandatory = $true)]
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'UUID')]
        [SaltConnection]
        $SaltConnection,
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

    $arguments = @{
        limit = $Limit
    }
    
    if ($Name) {
        $arguments.Add('name',$Name)
    }

    if ($UUID) {
        $arguments.Add('job_uuid',$UUID)
    }

    $return = Invoke-SaltStackAPIMethod -SaltConnection $SaltConnection -Resource job -Method get_jobs -Arguments $arguments

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
