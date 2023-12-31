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

. (Join-Path $PSScriptRoot perfhelper.ps1)

if ($null -eq $EntityName) {
    #$EntityName = [System.Net.Dns]::GetHostByName($env:computerName).HostName
    #$EntityName = $EntityName.Replace(".", "_").ToLower()
    $domainName = ${env:USERDNSDOMAIN}.Replace(".", "_")
    $EntityName = "${env:computername}_${domainName}".ToLower()
}

$cpu_pcnt_usage = (Get-CimInstance win32_processor | Measure-Object -Property LoadPercentage -Average).Average

Write-Host "$EntityName.system $cpu_pcnt_usage $Time"


#$perfCategoryID = Get-PerformanceCounterByID -Name 'Processor Information'
#$localizedCategoryName = Get-PerformanceCounterLocalName -ID $perfCategoryID

#$counters = New-Object System.Collections.ArrayList

#[void]$counters.Add('% Processor Time')
#[void]$counters.Add('% Idle Time')
#[void]$counters.Add('% User Time')
#[void]$counters.Add('% Interrupt Time')

#foreach ($counter in $counters) {
#    $perfCounterID = Get-PerformanceCounterByID -Name $counter
#    $localizedCounterName = Get-PerformanceCounterLocalName -ID $perfCounterID
#    $value = [System.Math]::Round((Get-Counter "\$localizedCategoryName(_total)\$localizedCounterName" -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue)
#
#    $Time = DateTimeToUnixTimestamp -DateTime (Get-Date)
#
#    if ($counter -eq '% Processor Time') { Write-Host "$EntityName.system $value $Time" }
#    #if ($counter -eq '% Processor Time') { Write-Host "$EntityName.cpu.percent.total $value $Time" }
#    if ($counter -eq '% Idle Time') { Write-Host "$EntityName.cpu.percent.idle $value $Time" }
#    if ($counter -eq '% User Time') { Write-Host "$EntityName.cpu.percent.user $value $Time" }
#    if ($counter -eq '% Interrupt Time') { Write-Host "$EntityName.cpu.percent.interrupt $value $Time" }
#}

#Write-Host "$EntityName.cpu.count $(Get-WmiObject -Class Win32_Processor | Measure-Object -Property NumberOfLogicalProcessors -Sum | Select-Object -ExpandProperty Sum) $Time"
