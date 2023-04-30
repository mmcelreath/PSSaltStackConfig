#Dot source classes.
Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 | Foreach-Object{ . $_.FullName }
#Dot source private functions.
Get-ChildItem -Path $PSScriptRoot\Functions\Private\*.ps1 | Foreach-Object{ . $_.FullName }
#Dot source public functions.
Get-ChildItem -Path $PSScriptRoot\Functions\Public\*.ps1 | Foreach-Object{ . $_.FullName }