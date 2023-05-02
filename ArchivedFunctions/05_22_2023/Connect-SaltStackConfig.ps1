function Connect-SaltStackConfig {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName='Credential')]
    param (
        # Salt master hostname.
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Credential')]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'UseDefaultCredentials')]
        [String]
        $SaltConfigServer,

        # PSCredential object for API access.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Credential')]
        [System.Management.Automation.CredentialAttribute()]
        [PSCredential]
        $Credential,

        # Use current default credentials for API access.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'UseDefaultCredentials')]
        [Switch]
        $UseDefaultCredentials

    )
    process {
        $endpointAuth = New-URI -HostName $SaltConfigServer -ApiEndPoint '/account/login' -Scheme https
        $endpointAPI = New-URI -HostName $SaltConfigServer -ApiEndPoint '/rpc' -Scheme https
        
        $base64AuthInfo = [System.Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $($Credential.UserName),$($Credential.GetNetworkCredential().Password))))

        #### Private Function this stuff
        $invokeRestMethodParams = @{
            Uri = $endpointAuth.ToString()
            Method = 'Get'
            ContentType = 'application/json'
            SessionVariable = 'webSession'
            ErrorAction = 'Stop'
        }

        $powershellVersion = $PSVersionTable.PSVersion

        if ($powershellVersion -ge '6.0') {
            $invokeRestMethodParams.Add('SkipCertificateCheck', $true)
        }
        
        if ($PSCmdlet.ShouldProcess($endpointAuth.Host, "Establishing Api connection to the SaltStack Config: {0}" -f $endpointAuth.ToString())) {
            $response = Invoke-RestMethod @invokeRestMethodParams
        }
        
        $authHeader = @{
            'X-Xsrftoken' = $webSession.Cookies.GetCookies($endpointAuth.uri).Where({$_.Name -ceq '_xsrf'}).Value
            'Authorization' = "Basic $base64AuthInfo"
        }

        # Create global variable $SaltConnection to be used by the rest of the functions in this module
        New-Variable -Name SaltConnection -Visibility Public -Option ReadOnly -Scope Global -Force -Value ([SaltConnection]::new(
            $endpointAuth.ToString(),
            $endpointAPI.ToString(),
            $webSession,
            $Credential,
            $authHeader
        ))
        
        Write-Output -InputObject $SaltConnection
    }
}