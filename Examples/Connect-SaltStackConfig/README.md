# Connect-SaltStackConfig - Examples
Updated this function to use the methodoligy used in the SaltStackConfig module in the PowerShell Gallery.

Modified it to take out passing username and password in plain text in favor of requiring a Credential object.
```
===========================================================================
Module: https://www.powershellgallery.com/packages/SaltStackConfig/
Created by:	Brian Wuchner
Date:		November 27, 2021
Blog:		www.enterpriseadmins.org
Twitter:    @bwuch
===========================================================================
```

Use this function to create the cookie/header to connect to SaltStack Config RaaS API

This function will allow you to connect to a vRealize Automation SaltStack Config RaaS API. A global variable `$global:SaltConnection` will be set with the Servername & Cookie/Header value for use by other functions.

## Example - Connect to the SaltStack server using the default Internal authentication source

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential
```

## Example - Connect to the SaltStack server using a different authentication source (ex. when LDAP authentication has been configured)

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential -AuthSource LDAP_SOURCE_NAME
```

## Example - Connect to a SaltStack server that does not have a valid certificate (TESTING ONLY!)

> Use this method only in test environments where valid certificates are not possible. Do not use in Production

```powershell
Connect-SaltStackConfig -SaltConfigServer <RAAS_Server> -Credential $credential -SkipCertificateCheck
```