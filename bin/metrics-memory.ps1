#
#   metric-windows-ram-usage.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs the Ram Usage in a Graphite acceptable format.
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
#   Released under the same terms as Sensu (the MIT license); see LICENSE for details.
#
param(
    $EntityName = $Args[0]
)

$ThisProcess = Get-Process -Id $pid
$ThisProcess.PriorityClass = "BelowNormal"

. (Join-Path $PSScriptRoot perfhelper.ps1)

if ($null -eq $EntityName) {
    #$EntityName = [System.Net.Dns]::GetHostByName($env:computerName).HostName
    #$EntityName = $EntityName.Replace(".", "_").ToLower()
    $domainName = ${env:USERDNSDOMAIN}.Replace(".", "_")
    $EntityName = "${env:computername}_${domainName}".ToLower()
}

$Memory = (Get-CimInstance -ClassName Win32_OperatingSystem)
$FreeMemory = $Memory.FreePhysicalMemory
$TotalMemory = $Memory.TotalVisibleMemorySize
$UsedMemory = $TotalMemory - $FreeMemory

$a = 0
$b = 0
$strComputer = "localhost"
$a = Get-WmiObject Win32_OperatingSystem -ComputerName $strComputer | Format-List *freePhysical* | Out-String
$b = Get-WmiObject Win32_OperatingSystem -ComputerName $strComputer | Format-List *totalvisiblememory* | Out-String
$a = $a -replace '\D+(\d+)', '$1'
$b = $b -replace '\D+(\d+)', '$1'
$FreeMemoryPercent = [math]::Round($a/$b*10000)/100

$Value = [System.Math]::Round(((($TotalMemory - $FreeMemory)/$TotalMemory)*100), 2)
$Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

Write-host "$EntityName.available $FreeMemoryPercent $Time"
Write-host "$EntityName.memory.free $FreeMemory $Time"
Write-host "$EntityName.memory.total $TotalMemory $Time"
Write-host "$EntityName.memory.used $UsedMemory $Time"
Write-host "$EntityName.memory.percent.used $Value $Time"
