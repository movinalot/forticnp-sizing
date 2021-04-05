Get-AzStorageAccount | Get-AzStorageContainer | Get-AzStorageBlob | Measure-Object -Property Length -Sum | Select-Object @{Name="Total Storage MB";Expression={[math]::round($_.Sum/1MB,2)}}
