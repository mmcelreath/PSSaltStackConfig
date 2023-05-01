<#
.SYNOPSIS
    Removes a Target from SaltStack Enterprise.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the remove method on the tgt resource to return a list of Targets.
.EXAMPLE
    Remove-SaltTarget -Name TargetA

    This will remove the Schedule TargetA using it's name.
.EXAMPLE
    Remove-SaltTarget -UUID e33ef27b-8a29-45c1-972c-c2a5f5472a29

    This will remove the Target with the UUID e33ef27b-8a29-45c1-972c-c2a5f5472a29.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Remove-SaltTarget {
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
        $Force
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $splat = @{
        SaltConnection = $global:SaltConnection
    }

    if ($name) {
        $splat.Add('Name',$Name)
        $splat.Add('ExactMatch',$true)
    }

    if ($UUID) {
        $splat.Add('UUID',$UUID)
    }

    $target = Get-SaltTarget @splat

    if ($target.Count -eq 0) {
        throw "No Targets found with the information provided."
    } elseif ($target.Count -gt 1) {
        throw "More than one Target was found matching the information provided."
    }

    $targetID = $target.uuid

    $arguments = @{
        tgt_uuid = $targetID
    }

    if ($Force) {
        $arguments.Add('force',$true)
    }

    $return = Invoke-SaltStackAPIMethod -Resource tgt -Method delete_target_group -Arguments $arguments
    
    if ($return.error) {
        $errorDetail = $return.error.detail.state
        $errorMessage = $return.error.message
        Write-Error "$errorMessage - $errorDetail"
    } else {
        Write-Output -InputObject $return  
    }

}
