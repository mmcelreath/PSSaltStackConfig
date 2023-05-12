Function Disconnect-SaltStackConfig {
    <#
    .SYNOPSIS
    Use this function to disconnect your session from the SaltStack Config RaaS API
    .DESCRIPTION
    This function will disconnect your session from a vRealize Automation SaltStack Config RaaS API.
    A global variable ($global:SaltConnection) which should have originally been created by the Connect-SaltStackConfig will be set to $null by running this function.
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
        Remove-Variable -Name SaltConnection -Scope global -ErrorAction SilentlyContinue
        Write-Warning "$user has been disconnected fromn $name. To run commands against SaltStack Config, run Connect-SaltStackConfig to create a new connections."
    }

}
