#
#   install-sensu.ps1
#
# DESCRIPTION:
#   Install Sensu Agent on windows servers.
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
$hostName = $env:computername
$domainName = $env:USERDNSDOMAIN.ToLower()
$fqdn = "$hostName.$domainName"

$sensuPackage = 'sensu-go-agent.x64.msi'
$baseUrl = 'http://repositories.geant.org/pub/windows/sensu'
$baseDir = 'C:\ProgramData\Sensu'
$sensuChecks = @(
    "check-cpu.ps1", "check-disk.ps1", "check-memory.ps1", "check-time.ps1",
    "metrics-cpu.ps1", "metrics-disk.ps1", "metrics-memory.ps1", "metrics-time.ps1",
    "metrics-uptime.ps1", "metrics-network.ps1", "perfhelper.ps1"
)

# invoke-webrequest too slow with progress bar
$ProgressPreference = 'SilentlyContinue'

Invoke-WebRequest ${baseUrl}/${sensuPackage} -OutFile "${env:TEMP}\${sensuPackage}"
Start-process 'msiexec.exe' -ArgumentList '/i', "${env:TEMP}\${sensuPackage}" -Wait

New-Item -ErrorAction Ignore -Path ${baseDir}\config\ssl\ -ItemType Directory
New-Item -ErrorAction Ignore -Path ${baseDir}\checks\ -ItemType Directory

Invoke-WebRequest ${baseUrl}/ssl/ca.crt -OutFile ${baseDir}\config\ssl\ca.crt
Invoke-WebRequest ${baseUrl}/agent.yml -OutFile ${baseDir}\config\agent.yml

(Get-Content ${baseDir}\config\agent.yml).replace('COMPUTER_FQDN', $fqdn) | Set-Content ${baseDir}\config\agent.yml
(Get-Content ${baseDir}\config\agent.yml).replace('COMPUTER_HOSTNAME', $hostName) | Set-Content ${baseDir}\config\agent.yml

foreach ($check in $sensuChecks) {
    Invoke-WebRequest ${baseUrl}/checks/${check} -OutFile ${baseDir}\checks\${check}
}

Remove-Item -Force ${env:TEMP}\${sensuPackage}

Start-Process powershell -Verb runAs -Wait -ArgumentList 'C:\Program Files\sensu\sensu-agent\bin\sensu-agent', 'service', 'install'
Start-Process powershell -Verb runAs -ArgumentList 'Restart-Service', 'SensuAgent'
