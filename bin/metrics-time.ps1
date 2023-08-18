
#
#   metrics-time.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs the time skew in a Influx acceptable format.
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
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-ram-usage.ps1
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 sensu-plugins
#   Released under the same terms as  (the MIT license); see LICENSE for details.
#
param(
    $EntityName = $Args[0]
)

$ThisProcess = Get-Process -Id $pid
$ThisProcess.PriorityClass = "BelowNormal"

. (Join-Path $PSScriptRoot perfhelper.ps1)

if ($null -eq $EntityName) {
    $dottedEntityName = [System.Net.Dns]::GetHostByName($env:computerName).HostName
    $EntityName = $dottedEntityName.Replace(".", "_").ToLower()
    #$domainName = ${env:USERDNSDOMAIN}.Replace(".", "_")
    #$EntityName = "${env:computername}_${domainName}".ToLower()
}

$refTimeServer = "ntp5.geant.net"

$skew = w32tm /stripchart /computer:$refTimeServer /period:1 /dataonly /samples:1
$skew = ($skew | Select-Object -Last 1) -replace (".*, ", "")
$skew = $skew -replace ("s$", "") 
$skew = $skew -replace ("\+", "")

$Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

Write-host "$EntityName chronystats.skew=$skew $Time"
