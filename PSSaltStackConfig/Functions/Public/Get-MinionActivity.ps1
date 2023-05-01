<#
.SYNOPSIS
    Gets activities for Minions.
.DESCRIPTION
    This function will use the Invoke-SaltStackAPIMethod command to query the get_returns method on the ret resource to return Activities.
.EXAMPLE
    Get-MinionActivity 

    This will return the 50 most recent activities in SaltStack Config. 50 is the default limit. 
.EXAMPLE
    Get-MinionActivity -Limit 150

    This will return the 150 most recent activities in SaltStack Config by changing Limit to 150.
.EXAMPLE
    Get-MinionActivity -MinionID 'minionname'

    This will return the 50 most recent activities for the MinionID provided
.EXAMPLE
    Get-MinionActivity -MinionID 'minionname' -JobID '20210204178834112766'

    This will return the activity in JobId 20210204570834112766 for the provided MinionID
.EXAMPLE
    Get-MinionActivity -Function state.apply

    This will return the 50 most recent activities in SaltStack Config that us the function state.apply.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Get-MinionActivity {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # MinionID
        [String]
        $MinionID,
        # JobId
        [String]
        $JobID,
        # Function
        [String]
        $Function,
        # Limit
        [Int]
        $Limit = 50,
        # HasErrors
        [Switch]
        $HasErrors,
        # SortBy
        [Validateset('minion_id','function','has_errors','jid')]
        [String]
        $SortBy = 'jid',
        # SortOrder
        [Validateset('Ascending','Descending')]
        [String]
        $SortOrder = 'Descending'
        # Start
        # End
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    $arguments = @{}

    $arguments.Add('sort_by',$SortBy)

    if ($SortOrder -eq 'Descending') {
        $arguments.Add('reverse','true')
    }

    if ($MinionID) {
        $arguments.Add('minion_id',$MinionID)
    }

    $arguments.Add('limit',$Limit)

    if ($JobID) {
        $arguments.Add('jid',$JobID)
    }

    if ($Function) {
        $arguments.Add('fun',$Function)
    }

    if ($HasErrors) {
        $arguments.Add('has_errors','true')
    }
    
    $return = Invoke-SaltStackAPIMethod -Resource ret -Method get_returns -Arguments $arguments

    $results = $return.ret.results 

    $activity = @()

    foreach ($result in $results) {
        $inDesiredState = @()
        $notInDesiredState = @()
        $resultsArray = @()
        
        $resultProperties = $result.return.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name

        $minionChanged = $false

        foreach ($resultProperty in $resultProperties) {

            if ($result.return.$resultProperty.comment -ne  'State was not run because none of the onchanges reqs changed') {
                
                $changed = $false
                
                $testChange = $result.return.$resultProperty.changes.PSObject.members | Select-Object -First 1

                if ($testChange.OverloadDefinitions) {
                    $changed = $false
                } else {
                    $changed = $true
                    $minionChanged = $true
                }

                $resultsObj = $null
                
                $resultsObj = [PSCustomObject]@{
                    ID        = $result.return.$resultProperty.__id__ 
                    Result    = $result.return.$resultProperty.result 
                    Command   = $resultProperty 
                    StartTime = $result.return.$resultProperty.start_time 
                    Duration  = $result.return.$resultProperty.Duration
                    Changes   = $result.return.$resultProperty.changes 
                    PChanges  = $result.return.$resultProperty.pchanges
                    SLS       = $result.return.$resultProperty.__sls__ 
                    Comment   = $result.return.$resultProperty.comment 
                    Name      = $result.return.$resultProperty.name 
                    RunNum    = $result.return.$resultProperty.__run_num__ 
                    SkipWatch = $result.return.$resultProperty.skip_watch
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

        $obj = [PSCustomObject]@{
            MinionID = $result.minion_id
            JID = $result.jid
            Date = ([DateTime]$result.alter_time).ToLocalTime()
            Function = $result.fun
            Arguments = $result.fun_args.mods
            Changes = $minionChanged
            HasErrors = $result.has_errors
            Results = $resultsArray
            InDesiredState = $inDesiredState
            NotInDesiredState = $notInDesiredState
        }

        $activity += $obj

    }

    Write-Output $activity | Select-Object MinionID,JID,Date,Function,Arguments,Changes,HasErrors,Results,InDesiredState,NotInDesiredState
}