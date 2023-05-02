#
# Module manifest for module 'PSSaltStackConfig'
#
# Generated by: Matt McElreath
#
# Generated on: 4/27/2023
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PSSaltStackConfig.psm1'

# Version number of this module.
ModuleVersion = '0.0.9'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'ee3f3117-1744-41cd-a932-18517aa5ddf9'

# Author of this module
Author = 'Matt McElreath'

# Company or vendor of this module
CompanyName = 'N/A'

# Copyright statement for this module
Copyright = '(c) 2023 Matt McElreath. All rights reserved.'

# Description of the functionality provided by this module
Description = 'SaltStack Config API module. Provides function wrappers for the SaltStack API REST endpoints.'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Connect-SaltStackConfig','Invoke-SaltStackAPIMethod','Get-MinionKeyState','Set-MinionKeyState','Invoke-SaltState','Get-SaltJobStatus','Wait-SaltJob','Get-SaltJobResults',
                    'Invoke-SaltComplianceReport','Get-SaltTarget','Set-SaltTarget','New-SaltTarget','Remove-SaltTarget','Get-SaltJob', 'Get-SaltSchedule','New-SaltSchedule','Set-SaltSchedule',
                    'Remove-SaltSchedule','Get-MinionGrain','Invoke-SaltTestPing','Get-MinionActivity'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'SSE', 'SaltStack', 'SaltStackEnterprise', 'SaltStackConfig', 'Config'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/mmcelreath/PSSaltStackConfig'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
