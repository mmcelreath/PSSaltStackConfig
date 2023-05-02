<#
.SYNOPSIS
    Invokes an API endpoint on the SaltStack Config server.
.DESCRIPTION
    This function will hit an endpoint and method on the SaltStack Config Servers HTTP bridge.  The HTTP bridge is a REST wrapper for the RPC API.
.EXAMPLE
    Invoke-SaltStackAPIMethod -Resource api -Method get_versions

    This will return all versions of the SaltStack Config server.
.EXAMPLE
    Invoke-SaltStackAPIMethod -Resource minions -Method get_minion_key_state -Arguments @{'limit'=300}

    This will return minion key states and return 300 instead of truncating the response.
.EXAMPLE
    Invoke-SaltStackAPIMethod -Resource minions -Method get_minion_key_state -Arguments @{'limit'=300; 'master_id'='master'; 'key_state'='pending'}

    This will return minion key states from the 'master' master which have a 'pending' key state and will return up to 300 minions.
.EXAMPLE
    Invoke-SaltStackAPIMethod -Resource minions -Method set_minion_key_state -Arguments @{'state'='accept'; 'minions' = @(,@('master', 'minionname.domain.local'))}

    This will accept a minion key for 'minionname.domain.local' on the master 'master'.
.EXAMPLE
    Invoke-SaltStackAPIMethod -Resource minions -Method set_minion_key_state -Arguments @{'state'='accept'; 'minions' = @(@('master', 'minion1.domain.local'),@('master', 'minion2.domain.local'))}

    This will accept a minion keys for 'minion1.domain.local' and 'minion2.domain.local' on the master 'master'.
.OUTPUTS
    PSCustomObject
.NOTES
    General notes
.LINK
#>
function Invoke-SaltStackAPIMethod {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Resource
        [Parameter(Mandatory = $true)]
        [String]
        $Resource,
        # Method
        [Parameter(Mandatory = $true)]
        [String]
        $Method,
        # Method arguments
        [Parameter(Mandatory = $false)]
        [HashTable]
        $Arguments
    )

    # Check to see if there is an existing connection to SaltStack
    if (!$global:SaltConnection) {
        Write-Error 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } 

    # $resource should be in the form of '<resource>.<method>'.
    # For example 'admin.trim_database' or 'api.get_versions'
    $requestBodyHash = @{
        resource = $Resource
        method = $Method
    }

    if ($PSBoundParameters.ContainsKey('Arguments')) {
        $requestBodyHash.Add('kwarg', $Arguments)
    }

    $requestBody = $requestBodyHash | ConvertTo-Json -Depth 10

    $invokeRestMethodProps = @{
        Uri = "https://$($global:SaltConnection.Name)/rpc"
        Method = 'Post'
        Body = $requestBody
        WebSession = $global:SaltConnection.SscWebSession
    }

    $powershellVersion = $PSVersionTable.PSVersion

    if ($powershellVersion -ge '6.0') {
        $invokeRestMethodProps.Add('SkipCertificateCheck', $true)
    }

    #kwarg is how to pass options to a method
    if ($PSCmdlet.ShouldProcess($(([System.Uri]$global:SaltConnection.uri).Host) , "The following RPC API resource and method will be invoked: $Resource\$Method"))
    {
        try {
            $return = Invoke-RestMethod @invokeRestMethodProps

            Write-Output -InputObject $return
        } catch {
            Write-Error -Category ConnectionError -Exception "RPC API call to SaltStack Config API failed with the following error:`n`t$($_.Exception.Message)" -ErrorAction Stop
        }
    }
}