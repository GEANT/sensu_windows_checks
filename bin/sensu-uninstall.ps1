#
#   uninstall-sensu.ps1
#
# DESCRIPTION:
#   Uninstall Sensu Agent from Windows servers.
#   It works with PowerShell 5
#
# OUTPUT:
#   plain text
#
# USAGE:
#   Powershell.exe .\uninstall-sensu.ps1
# PLATFORMS:
#   Windows
#
$sensuPackage = 'sensu-go-agent.x64.msi'
$baseUrl = 'http://repositories.geant.org/pub/windows/sensu'
$baseDir = 'C:\ProgramData\Sensu'

# install service and delete downloaded file
Start-Process powershell -Verb runAs -ArgumentList 'Stop-Service', 'SensuAgent'
Start-Process powershell -Verb runAs -Wait -ArgumentList 'C:\Program Files\sensu\sensu-agent\bin\sensu-agent', 'service', 'uninstall'

# invoke-webrequest too slow with progress bar
$ProgressPreference = 'SilentlyContinue'

# fetching and installing Sensu
# if the script is run as Administrator, we can use /quiet
# the way around we need to use /passive and click "yes" to confirm the installation
Invoke-WebRequest ${baseUrl}/${sensuPackage} -OutFile "${env:TEMP}\${sensuPackage}"
Start-process 'msiexec.exe' -Wait -ArgumentList "/uninstall ${env:TEMP}\${sensuPackage} /passive"

Remove-Item -Recurse -Force ${baseDir}
Remove-Item -Force ${env:TEMP}\${sensuPackage}
