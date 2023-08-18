#
#   install-sensu.ps1
#
# DESCRIPTION:
#   Upgrade Sensu Agent on Windows servers.
#   It works with PowerShell 5
#
# OUTPUT:
#   plain text
#
# USAGE:
#   Powershell.exe .\install-sensu.ps1
# PLATFORMS:
#   Windows
#
$sensuPackage = 'sensu-go-agent.x64.msi'
$baseUrl = 'http://repositories.geant.org/pub/windows/sensu'

# invoke-webrequest too slow with progress bar
$ProgressPreference = 'SilentlyContinue'

# fetching and installing Sensu
# if the script is run as Administrator, we can use /quiet
# the way around we need to use /passive and click "yes" to confirm the installation
Invoke-WebRequest ${baseUrl}/${sensuPackage} -OutFile "${env:TEMP}\${sensuPackage}"
Start-process 'msiexec.exe' -Wait -ArgumentList "/i ${env:TEMP}\${sensuPackage} /passive"

# install service and delete downloaded file
Start-Process powershell -Verb runAs -Wait -ArgumentList 'C:\Program Files\sensu\sensu-agent\bin\sensu-agent', 'service', 'install'
Start-Process powershell -Verb runAs -ArgumentList 'Restart-Service', 'SensuAgent'

Remove-Item -Force ${env:TEMP}\${sensuPackage}
