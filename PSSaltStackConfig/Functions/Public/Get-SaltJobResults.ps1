<#
.SYNOPSIS
    Gets the detailed results of a Salt job.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to use the get_jid on the cmd resource to return the detailed results of a Salt job.
.EXAMPLE
    Get-SaltJobResults -JobID $JobID

    This will return the detailed results of $JobID.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-SaltJobResults {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # JobID
        [Parameter(Mandatory = $true)]
        [String]
        $JobID
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $arguments = @{
        jid = $JobID
    }
    
    $jobResults = Invoke-SaltStackAPIMethod -Resource ret -Method get_jid -Arguments $arguments
    
    $properties = $jobResults.ret.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name
    
    $results = @{}
    $resultsArray = @()
    $minions = @()
    
    foreach ($property in $properties) {
    
        $results = $jobResults.ret.$property.return
    
        $inDesiredState = @()
        $notInDesiredState = @()
        $resultsArray = @()
    
        foreach ($result in $results) {
            
            $resultProperties = $result.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name
    
            $minionChanged = $false
    
            foreach ($resultProperty in $resultProperties) {
    
                if ($jobResults.ret.$property.return.$resultProperty.comment -ne  'State was not run because none of the onchanges reqs changed') {
                    
                    $changed = $false
                    
                    $testChange = $jobResults.ret.$property.return.$resultProperty.changes.PSObject.members | Select -First 1
    
                    if ($testChange.OverloadDefinitions) {
                        $changed = $false
                    } else {
                        $changed = $true
                        $minionChanged = $true
                    }
    
                    $resultsObj = $null
                    
                    $resultsObj = [PSCustomObject]@{
                        ID        = $jobResults.ret.$property.return.$resultProperty.__id__ 
                        Result    = $jobResults.ret.$property.return.$resultProperty.result 
                        Command   = $resultProperty 
                        StartTime = $jobResults.ret.$property.return.$resultProperty.start_time 
                        Duration  = $jobResults.ret.$property.return.$resultProperty.Duration
                        Changes   = $jobResults.ret.$property.return.$resultProperty.changes 
                        PChanges  = $jobResults.ret.$property.return.$resultProperty.pchanges
                        SLS       = $jobResults.ret.$property.return.$resultProperty.__sls__ 
                        Comment   = $jobResults.ret.$property.return.$resultProperty.comment 
                        Name      = $jobResults.ret.$property.return.$resultProperty.name 
                        RunNum    = $jobResults.ret.$property.return.$resultProperty.__run_num__ 
                        SkipWatch = $jobResults.ret.$property.return.$resultProperty.skip_watch
                        Changed   = $changed
                    }
    
                    $resultsArray += $resultsObj
                    
                    if ($changed) {
                        $notInDesiredState += $resultsObj
                    } else {
                        $inDesiredState += $resultsObj
                    }
                }
    
            }
    
        }

        $resultsHash = [ordered]@{
            All = $resultsArray
            InDesiredState = $InDesiredState
            NotInDesiredState = $notInDesiredState
        }
    
        $minionDetails = [PSCustomObject]@{
            MinionID     = $jobResults.ret.$property.id
            Results      = $resultsHash
            Function     = $jobResults.ret.$property.fun
            FunctionArgs = $jobResults.ret.$property.fun_args
            TimeStamp    = $jobResults.ret.$property._stamp
            Success      = $jobResults.ret.$property.success
            Changed      = $minionChanged
            ReturnCode   = $jobResults.ret.$property.retcode
            Return       = $jobResults.ret.$property.return
        }
    
        $minions += $minionDetails
    
    }
    
    Write-Output -InputObject $minions

}
