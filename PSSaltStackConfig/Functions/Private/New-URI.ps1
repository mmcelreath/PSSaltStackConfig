function New-URI {
    [CmdletBinding()]
    [OutputType([System.Uri])]
    param (
        # Hostname of web server
        [Parameter(Mandatory = $true)]
        [Alias('Host')]
        [String]
        $HostName,
        # Endpoint/Resource/Path of API
        [Parameter(Mandatory = $false)]
        [Alias('Path','ApiEndPoint','Resource')]
        [String]
        $EndPoint,
        # Scheme of the URI ('file','http','https','mailto')
        [Parameter(Mandatory = $true)]
        [ValidateSet('file','http','https','mailto')]
        [String]
        $Scheme,
        # Port number of web server
        [Parameter(Mandatory = $false)]
        [ValidateRange(1,65535)]
        [Int]
        $Port,
        # Query string to add to URI
        [Parameter(Mandatory = $false)]
        [String]
        $Query
    )
    process {

        $uri = [System.UriBuilder]::new()
        $uri.Host = $HostName
        $uri.Scheme = $Scheme

        if ($PSBoundParameters.ContainsKey('Port')) {
            $uri.Port = $Port
        }
        if ($PSBoundParameters.ContainsKey('EndPoint')) {
            $uri.Path = $EndPoint 
        }
        if ($PSBoundParameters.ContainsKey('Query')) {
            $uri.Query = $Query
        }

        Write-Output -InputObject $uri
    }
}