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
        [Parameter(Mandatory=$true)]
        [Switch]
        $SkipCertificateCheck,
        [Parameter(Mandatory=$false)]
        [System.Net.SecurityProtocolType]
        $SslProtocol
    )

    $username = $Credential.GetNetworkCredential().username
    $password = $Credential.GetNetworkCredential().password

    if ($SkipCertificateCheck) {
        # This if statement is using example code from https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
        add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    } # end if SkipCertificate Check
    
    if ($SslProtocol) {
        [System.Net.ServicePointManager]::SecurityProtocol = $SslProtocol
    }

    $loginBody = @{'username'=$username; 'password'=$password; 'config_name'=$AuthSource}
    
    try {
        $webRequest = Invoke-WebRequest -Uri "https://$server/account/login" -SessionVariable ws
        $ws.headers.Add('X-Xsrftoken', $webRequest.headers.'x-xsrftoken')
        $webRequest = Invoke-WebRequest -Uri "https://$server/account/login" -WebSession $ws -method POST -body (ConvertTo-Json $loginBody)
        $webRequestJson = ConvertFrom-JSON $webRequest.Content
        
        $global:SaltConnection = New-Object psobject -property @{ 'SscWebSession'=$ws; 'Name'=$server; 'ConnectionDetail'=$webRequestJson; 
        'User'=$webRequestJson.attributes.config_name +'\'+ $username; 'Authenticated'=$webRequestJson.authenticated; PSTypeName='SscConnection' }
    
        # Return the connection object
        $global:SaltConnection
    } catch {
        Write-Error ("Failure connecting to $server. " + $_)
    } # end try/catch block
}