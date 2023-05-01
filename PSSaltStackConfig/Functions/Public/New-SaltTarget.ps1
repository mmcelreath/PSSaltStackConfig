<#
.SYNOPSIS
    Creates a new Target in SaltStack Enterprise
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the save_target_group on the tgt resource to create a new Target group.
.EXAMPLE
    New-SaltTarget -Name AppServers -TargetType 'compound' -TargetString 'G@environment:Dev and G@role:AppServer' -TargetMasterID '*'

    This will create a Target Group wtih the specified Name usig a 'compound' TargetString.
.EXAMPLE
    New-SaltTarget -Name AppServers -TargetType 'grain' -TargetString 'GrainName:grain_value' -TargetMasterID '*'

    This will create a Target Group wtih the specified Name usig a 'grain' as its target.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function New-SaltTarget {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Name
        [Parameter(Mandatory = $true)]
        [String]
        $Name,
        # Description
        [String]
        $Description,
        # TargetType
        [Parameter(Mandatory = $true)]
        [String]
        [Validateset('compound','list','grain','glob','grain_pcre','pillar','pillar_pcre','ipcidr','pcre','node')]
        $TargetType,
        # TargetString
        [Parameter(Mandatory = $true)]
        [String]
        $TargetString,
        # TargetMasterID
        [Parameter(Mandatory = $true)]
        [String]
        $TargetMasterID
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $splat = @{
        SaltConnection = $global:SaltConnection
        Name = $Name
        ExactMatch = $true
    }

    $target = Get-SaltTarget @splat

    if ($target.Count -gt 0) {
        throw "Another Target Group exists already with the name: $Name"
    } 

    $tgt = @{
        $TargetMasterID = @{
            tgt = $TargetString
            tgt_type = $TargetType
        }
    }

    $arguments = @{
        name = $Name
        desc = $Description
        tgt = $tgt
        wait_for_match = $true
    }

    $return = Invoke-SaltStackAPIMethod -Resource tgt -Method save_target_group -Arguments $arguments

    Write-Output -InputObject $return
    
}
