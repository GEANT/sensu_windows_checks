#
#   metric-windows-network.ps1
#
# DESCRIPTION:
#   This plugin collects and outputs all Network Adapater Statistic in a Graphite acceptable format.
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
#   Powershell.exe -NonInteractive -NoProfile -ExecutionPolicy Bypass -NoLogo -File C:\\etc\\sensu\\plugins\\metric-windows-network.ps1
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

$perfCategoryID = Get-PerformanceCounterByID -Name 'Network Interface'
$localizedCategoryName = Get-PerformanceCounterLocalName -ID $perfCategoryID

foreach ($ObjNet in (Get-Counter -Counter "\$localizedCategoryName(*)\*").CounterSamples) {
    $Measurement = ($ObjNet.Path).Trim("\\") -replace "\\", "." -replace " ", "_" -replace "[(]", "." -replace "[)]", "" -replace "[\{\}]", "" -replace "[\[\]]", "" -replace "network_interface", "net_dev"

    $Measurement = $Measurement.Remove(0, $Measurement.IndexOf("."))
    $Path = $EntityName + $Measurement

    $Path = $Path.Replace("/sec", "_per_sec")
    $Path = $Path.Replace("/s", "_per_sec")
    $Path = $Path.Replace("bytes", "kB")
    $Path = $Path.Replace(":", "")
    $Path = $Path.Replace(",", "")
    $Path = $Path.Replace("ä", "ae")
    $Path = $Path.Replace("ö", "oe")
    $Path = $Path.Replace("ü", "ue")
    $Path = $Path.Replace("ß", "ss")

    if ($Measurement -clike '*bytes_*') {
        $Value = [System.Math]::Round(($ObjNet.CookedValue / 1024), 0)
    }
    else {
        $Value = [System.Math]::Round(($ObjNet.CookedValue), 0)
    }

    $Time = DateTimeToUnixTimestamp -DateTime (Get-Date)

    Write-Host "$Path $Value $Time"
}
