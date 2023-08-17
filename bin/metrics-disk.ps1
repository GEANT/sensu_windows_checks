#
#   metric-windows-disk-usage.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs Disk Usage metrics in a Graphite acceptable format.
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
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-disk-usage.ps1
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
    $EntityName = "${env:computername}.${domainName}".ToLower()
}

$AllDisks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" | Where-Object { $_.DeviceID -notmatch "[ab]:" }

foreach ($ObjDisk in $AllDisks) {
    $DeviceId = $ObjDisk.DeviceID -replace ":", ""

    $UsedSpace = [System.Math]::Round((($ObjDisk.Size - $ObjDisk.Freespace)/1MB), 2)
    $AvailableSpace = [System.Math]::Round(($ObjDisk.Freespace/1MB), 2)
    $AvailableBytes = [System.Math]::Round(($ObjDisk.Freespace/1KB), 2)
    $UsedPercentage = [System.Math]::Round(((($ObjDisk.Size - $ObjDisk.Freespace)/$ObjDisk.Size)*100), 2)

    $Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

    Write-Host "$EntityName.disk.usage.$DeviceId.UsedMB $UsedSpace $Time"
    Write-Host "$EntityName.disk.usage.$DeviceId.FreeMB $AvailableSpace $Time"
    Write-Host "$EntityName.disk.$DeviceId.avail $AvailableBytes $Time"
    Write-Host "$EntityName.disk.usage.$DeviceId.UsedPercentage $UsedPercentage $Time"
}