#
#   install-checks.ps1
#
# DESCRIPTION:
#   Reinstall Sensu Checks on windows servers
#   It works with PowerShell 5
#
# OUTPUT:
#   plain text
#
# USAGE:
#   Powershell.exe .\install-checks.ps1
# PLATFORMS:
#   Windows
#
$baseUrl = 'http://repositories.geant.org/pub/windows/sensu'
$baseDir = 'C:\ProgramData\Sensu'
$sensuChecks = @(
    "check-cpu.ps1", "check-disk.ps1", "check-memory.ps1", "check-time.ps1",
    "metrics-cpu.ps1", "metrics-disk.ps1", "metrics-memory.ps1", "metrics-time.ps1",
    "metrics-uptime.ps1", "metrics-network.ps1", "perfhelper.ps1"
)

foreach ($check in $sensuChecks) {
    Invoke-WebRequest ${baseUrl}/checks/${check} -OutFile ${baseDir}\checks\${check}
}
