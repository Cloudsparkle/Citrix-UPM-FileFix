#requires -modules ActiveDirectory
<#
.SYNOPSIS
  Copy SAP Settings from one userprofile to another
.DESCRIPTION
  This script lets you select a source and destination user. It will then copy SAP NWBC settings files from the source userprofile to the destination and fix permissions
.INPUTS
  Source AD user, Destination AD user
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Bart Jacobs - @Cloudsparkle
  Creation Date:  06/05/2021
  Purpose/Change: Copy SAP NWBC Settings from one user to anoth
.EXAMPLE
  None
#>

$ProfileShare = "" #just make sure it ends with a \
$ADusers = get-aduser -filter *  | select name, samaccountname, SID | sort name

$SourceUser= $ADusers | Out-GridView -Title "Select source user" -OutputMode Single
if ($SourceUser -eq $null)
{
  exit 0
}

$DestinationUser = $ADusers | Out-GridView -Title "Select destination user" -OutputMode Single
if ($DestinationUser -eq $null)
{
  exit 0
}

$Sourcepath = $ProfileShare + $SourceUser.samaccountname + "\UPM_Profile\AppData\Roaming\SAP\NWBC\*.xml"
$Destinationpath = $ProfileShare + $DestinationUser.samaccountname + "\UPM_Profile\AppData\Roaming\SAP\NWBC"
$DestinationXMLpath = $ProfileShare + $DestinationUser.samaccountname + "\UPM_Profile\AppData\Roaming\SAP\NWBC\*.xml"
$DestinationXMLFile1 = $ProfileShare + $DestinationUser.samaccountname + "\UPM_Profile\AppData\Roaming\SAP\NWBC\SAPBCFavorites.xml"
$DestinationXMLFile2 = $ProfileShare + $DestinationUser.samaccountname + "\UPM_Profile\AppData\Roaming\SAP\NWBC\NWBCFavorites.xml"

$SourcePathExists = Test-Path -Path $Sourcepath

if ($SourcePathExists -eq $false)
{
  Write-host "Source files not present. Nothing to copy"
  exit 0
}

$DestinationPathExists = test-path $Destinationpath
if ($DestinationPathExists)
{
  Copy-Item $Sourcepath -Destination $DestinationPath
  icacls $DestinationXMLFile1 /setowner $DestinationUser.samaccountname
  icacls $DestinationXMLFile1 /inheritancelevel:e
  $XML2exists = Test-Path -Path $DestinationXMLFile2
  if ($XML2exists -eq $true)
  {
    icacls $DestinationXMLFile2 /setowner $DestinationUser.samaccountname
    icacls $DestinationXMLFile2 /inheritancelevel:e
  }
}
Else
{
  Write-Host "New user has not started SAP yet"
}
