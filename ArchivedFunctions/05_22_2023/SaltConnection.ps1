class SaltConnection {
    [String]$AuthURI
    [String]$APIURI
    [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
    [PSCredential] $Credential
    [HashTable] $AuthHeader 

    SaltConnection(
        [String]$AuthURI,
        [String]$APIURI,
        [Microsoft.PowerShell.Commands.WebRequestSession]$WebRequestSession,
        [PSCredential] $Credential,
        [HashTable] $AuthHeader
    ){
        $this.AuthURI = $AuthURI
        $this.APIURI = $APIURI
        $this.WebSession = $WebRequestSession
        $this.Credential = $Credential
        $this.AuthHeader = $AuthHeader
    }
}