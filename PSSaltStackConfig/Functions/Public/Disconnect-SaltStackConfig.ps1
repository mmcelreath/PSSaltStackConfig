Function Disconnect-SaltStackConfig {
    <#
    .SYNOPSIS
    Use this function to create the cookie/header to connect to SaltStack Config RaaS API
    .DESCRIPTION
    This function will allow you to connect to a vRealize Automation SaltStack Config RaaS API.
    A global variable ($global:SaltConnection) will be set with the Servername & Cookie/Header value for use by other functions.
    .EXAMPLE
    Disconnect-SaltStackConfig

    Disconnect from a SaltStack Config server.
#>
    param()

    if (!$global:SaltConnection) {
        Write-Warning 'You are not currently connected to any SaltStack servers. Please connect first using Connect-SaltStackConfig.'
        return
    } else {
        $name = $global:SaltConnection.Name
        $user = $global:SaltConnection.User
        $global:SaltConnection = $null
        Remove-Variable -Name SaltConnection
        Write-Warning "$user has been disconnected fromn $name. To run commands against SaltStack Config, run Connect-SaltStackConfig to create a new connections."
    }

}