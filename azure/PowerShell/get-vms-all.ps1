Get-AzVm -Status | Select-Object ResourceGroupName, Location, Name, PowerState -ExpandProperty HardwareProfile | Format-Table; "Total VMs: " + $(Get-AzVM).count
