#
#   metric-windows-cpu-load.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs the CPU Usage in a Graphite acceptable format.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Windows
#
# DEPENDENCIES:
#   Powershell
#
# USAGE:
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-cpu-load.ps1
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 sensu-plugins
#   Released under the same terms as Sensu (the MIT license); see LICENSE for details.
#
param(
    $EntityName = $Args[0]
)

$ThisProcess = Get-Process -Id $pid
$ThisProcess.PriorityClass = "BelowNormal"

if ($null -eq $EntityName) {
    #$EntityName = [System.Net.Dns]::GetHostByName($env:computerName).HostName
    #$EntityName = $EntityName.Replace(".", "_").ToLower()
    $domainName = ${env:USERDNSDOMAIN}.Replace(".", "_")
    $EntityName = "${env:computername}_${domainName}".ToLower()
}

$cpu_pcnt_usage = (Get-CimInstance win32_processor | Measure-Object -Property LoadPercentage -Average).Average
$Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

Write-Host "$EntityName.system $cpu_pcnt_usage $Time"
