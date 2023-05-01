<#
.SYNOPSIS
    Updates an existing Target
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the save_target_group on the tgt resource to update an existing Target group.
.EXAMPLE
    Set-SaltTarget -UUID 5a822264-839d-4bed-8fv5-0394c4q29598 -Description "New Description"

    This will update the Target Group wtih the specified UUID with the new description.
.EXAMPLE
    Set-SaltTarget -Name AppServers -NewName WindowsAppServers

    This will update the Target Group wtih the specified Name with the NewName specified.
.EXAMPLE
    Set-SaltTarget -Name AppServers -TargetMasterID '*'

    This will update the Target Group wtih the specified Name to use All Masters.
.EXAMPLE
    Set-SaltTarget -Name AppServers -TargetType 'compound' -TargetString 'G@environment:Dev and G@role:AppServer'

    This will update the Target String and Target Type for the Target Group wtih the specified Name.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Set-SaltTarget {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Name
        [String]
        $Name,
        # UUID
        [String]
        $UUID,
        # NewName
        [String]
        $NewName,
        # Description
        [String]
        $Description,
        # TargetType
        [String]
        [Validateset('compound','list','grain','glob','grain_pcre','pillar','pillar_pcre','ipcidr','pcre','node')]
        $TargetType,
        # TargetString
        [String]
        $TargetString,
        # TargetMasterID
        [String]
        $TargetMasterID
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    if ($TargetType -or $TargetString) {
        if (!($TargetType -and $TargetString)) {
            throw "If TargetType or TargetString is being updated, both need to be specified when modifying the target with this function."
        }            
    }

    $splat = @{
        SaltConnection = $global:SaltConnection
        ExactMatch = $true
    }

    if ($name) {
        $splat.Add('Name',$name)
    }

    if ($UUID) {
        $splat.Add('UUID',$UUID)
    }

    $target = Get-SaltTarget @splat

    if ($target.Count -eq 0) {
        throw 'No Targets returned based on the information provided.'
    } 

    if ($target.Count -gt 1) {
        throw 'More than one Target was returned based on the information provided.'
    } 

    $arguments = @{
        tgt_uuid = $target.uuid
        wait_for_match = $true
    }

    if ($TargetType -or $TargetString -or $TargetMasterID){
        $newTgt = $null
        $origTargetMasterID = $target.tgt.PSObject.Properties.name

        if ($TargetMasterID) {
            $newTargetMasterID = $TargetMasterID
        } else {
            $newTargetMasterID = $origTargetMasterID 
        }

        if ($TargetType) {
            $newTargetType = $TargetType
        } else {
            $newTargetType = $target.tgt.$origTargetMasterID.tgt_type
        }

        if ($TargetString) {
            $newTargetString = $TargetString
        } else {
            $newTargetString = $target.tgt.$origTargetMasterID.tgt
        }

        $newTgt = @{
            $newTargetMasterID = @{
                tgt = $newTargetString
                tgt_type = $newTargetType
            }
        }

        $arguments.Add('tgt',$newTgt)
    } else {
        $arguments.Add('tgt',$target.tgt)
    }

    if ($NewName) {
        $arguments.Add('name',$NewName)
    } else {
        $arguments.Add('name',$target.name)
    }

    if ($Description) {
        $arguments.Add('desc',$Description)
    } else {
        $arguments.Add('desc',$target.desc)
    }

    $return = Invoke-SaltStackAPIMethod -Resource tgt -Method save_target_group -Arguments $arguments
    
    Write-Output -InputObject $return
    
}
