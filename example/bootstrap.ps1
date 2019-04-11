
#########################################################
# bootstrap script for ansible
# configures - powershell, firewall, and winrm settings
#########################################################

$username = "<username>"
$password = "<password>"

###

$url = "https://raw.githubusercontent.com/jborean93/ansible-windows/master/scripts/Upgrade-PowerShell.ps1"
$file = "$env:temp\Upgrade-PowerShell.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

&$file -Version 5.1 -Username $username -Password $password -Verbose

###

$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file

winrm enumerate winrm/config/Listener

winrm quickconfig

winrm get winrm/config/Service

winrm get winrm/config/Winrs

(Get-Service -Name winrm).Status

###
