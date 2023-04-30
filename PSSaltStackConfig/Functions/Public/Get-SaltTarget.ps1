<#
.SYNOPSIS
    Returns a list of Targets from SaltStack Enterprise.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the get_target_group on the tgt resource to return a list of targets.
.EXAMPLE
    Get-SaltTarget -SaltConnection $SaltConnection

    This will return all Targets with a default limit of 200.
.EXAMPLE
    Get-SaltTarget -SaltConnection $SaltConnection -Name AppServer

    This will return Targets matching the name provided. This is a wildcard match so anything wtih AppServer in the name wil be returned.
.EXAMPLE
    Get-SaltTarget -SaltConnection $SaltConnection -Name AppServer -ExactMatch

    This will return a Target matching the exact name provided.
.EXAMPLE
    Get-SaltTarget -SaltConnection $SaltConnection -UUID '3e396a32-020c-4756-9953-253e1f466b87'

    This will return a Target matching the UUID provided.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-SaltTarget {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Salt connection object
        [Parameter(Mandatory = $true)]
        [SaltConnection]
        $SaltConnection,
        # Name
        [String]
        $Name,
        # UUID
        [String]
        $UUID,
        # ExactMatch
        [Switch]
        $ExactMatch,
        # Limit
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
        $arguments.Add('tgt_uuid',$UUID)
    }
    
    $return = Invoke-SaltStackAPIMethod -SaltConnection $SaltConnection -Resource tgt -Method get_target_group -Arguments $arguments

    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        if (($Name) -and ($ExactMatch)) {
            $targets = $return.ret.results | Where-Object Name -eq $name
        } else {
            $targets = $return.ret.results
        }
    }
        
    Write-Output -InputObject $targets

}
