Function Connect-SaltStackConfig {
    <#
    .NOTES
    Updated this function to use the methodoligy used in the SaltStackConfig module in the PowerShell Gallery.
    Modified it to take out passing username and password in plain text in favor of requiring a Credential object.

    ===========================================================================
    Module: https://www.powershellgallery.com/packages/SaltStackConfig/
    Created by:	Brian Wuchner
    Date:		November 27, 2021
    Blog:		www.enterpriseadmins.org
    Twitter:    @bwuch
    ===========================================================================
    .SYNOPSIS
    Use this function to create the cookie/header to connect to SaltStack Config RaaS API
    .DESCRIPTION
    This function will allow you to connect to a vRealize Automation SaltStack Config RaaS API.
    A global variable ($global:SaltConnection) will be set with the Servername & Cookie/Header value for use by other functions.
    .EXAMPLE
    Connect-SaltStackConfig -Server 'salt.example.com' -Credential $InternalUserCred

    This will default to internal user authentication.
    .EXAMPLE
    Connect-SaltStackConfig -Server 'salt.example.com'

    This will prompt for credentials
    .EXAMPLE
    $creds = Get-Credential

    Connect-SaltStackConfig -Server 'salt.example.com' -Credential $creds -AuthSource 'LAB Directory'

    This will connect to the 'LAB Directory' LDAP authentication source using a specified credential.
#>
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Server,
        [Parameter(Mandatory=$false, Position=3)]
        [string]
        $AuthSource='internal',
        [Parameter(Mandatory=$true)]
        [PSCredential]
        $Credential,
        [Parameter(Mandatory=$false)]
        [Switch]
        $SkipCertificateCheck = $false,
        [Parameter(Mandatory=$false)]
        [System.Net.SecurityProtocolType]
        $SslProtocol
    )

    $username = $Credential.GetNetworkCredential().username
    $password = $Credential.GetNetworkCredential().password
    
    if ($SslProtocol) {
        [System.Net.ServicePointManager]::SecurityProtocol = $SslProtocol
    }

    $loginBody = @{'username'=$username; 'password'=$password; 'config_name'=$AuthSource}
    
    try {
        $webSessionRequestParams = @{
            Uri                  = "https://$server/account/login"
            SessionVariable      = 'WebSession'
            SkipCertificateCheck = $SkipCertificateCheck
        }

        $webSessionRequest = Invoke-WebRequest @webSessionRequestParams
        $WebSession.headers.Add('X-Xsrftoken', $webSessionRequest.headers.'x-xsrftoken')

        $webRequestParams = @{
            Uri                  = "https://$server/account/login"
            WebSession           = $WebSession
            method               = 'POST'
            body                 = (ConvertTo-Json $loginBody)
            SkipCertificateCheck = $SkipCertificateCheck
        }

        $webRequest = Invoke-WebRequest @webRequestParams
        $webRequestJson = ConvertFrom-JSON $webRequest.Content
        
        $global:SaltConnection = New-Object psobject -property @{ 'SscWebSession'=$WebSession; 'Name'=$server; 'ConnectionDetail'=$webRequestJson; 
        'User'=$webRequestJson.attributes.config_name +'\'+ $username; 'Authenticated'=$webRequestJson.authenticated; PSTypeName='SscConnection' }
    
        # Return the connection object
        $global:SaltConnection
    } catch {
        Write-Error ("Failure connecting to $server. " + $_)
    } # end try/catch block
}