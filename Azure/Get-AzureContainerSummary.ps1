<# Get-AzureContainerSummary.ps1
Purpose:
    Get Azure Storage Account Summaries: Accounts, Containers, Blobs 
Author:
    John McDonough (jmcdonough@fortinet.com) github: (@movinalot)
    Fortinet, Inc.
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [String]
    $Subscription,
    [Parameter(Mandatory=$false)]
    [Array]
    $AccountList = @()
)

function ConvertTo-HumanReadableByteSize {
    param (
        [parameter(ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [double]$InputObject
    )

    if ($InputObject -eq 0) {
        return "0 Bytes"
    }
    
    $magnitude = [math]::truncate([math]::log($InputObject, 1024))
    $normalized = $InputObject / [math]::pow(1024, $magnitude)
    
    $magnitudeName = switch ($magnitude) {
        0 { "Bytes"; Break }
        1 { "KB"; Break }
        2 { "MB"; Break }
        3 { "GB"; Break }
        4 { "TB"; Break }
        5 { "PB"; Break }
        Default { Throw "Byte value too big" }
    }
    
    "{0:n2} {1}" -f ($normalized, $magnitudeName)
}

$storageAccountNameAndSize = [ordered]@{}

$null = Select-AzSubscription -Subscription $Subscription

if ($AccountList.Length -gt 0) {
    $StorageAccounts = @(Get-AzStorageAccount | Where-Object { $AccountList.Contains($_.StorageAccountName) })
} else {
    $StorageAccounts = @(Get-AzStorageAccount)
}

$subscriptionStorageLength = 0
foreach ($storageAccount in $StorageAccounts) {

    $accountContainerLength = 0
    $accountContainerCount = 0
    $accountBlobCount = 0




    $StorageContainers = @($storageAccount | Get-AzStorageContainer)

    if ($StorageContainers.Length -gt 0) {
        Write-Output "+$("-" * 96)+"
        Write-Output "| Storage Account: $($storageAccount.StorageAccountName) -- Container Details $(" " * (55 - $storageAccount.StorageAccountName.Length)) |"
        Write-Output "+$("-" * 66)+$("-" * 12)+$("-" * 16)+"
        Write-Output "| Container Name $(" " * 49) | Blob Count | Container Size |"
        Write-Output "+$("-" * 66)+$("-" * 12)+$("-" * 16)+"
    } else {
        Write-Output "+$("-" * 96)+"
        Write-Output "| Storage Account: $($storageAccount.StorageAccountName) -- Account has 0 containers $(" " * (48 - $storageAccount.StorageAccountName.Length)) |"
        Write-Output "+$("-" * 66)+$("-" * 12)+$("-" * 16)+`n"
        continue
    }

    foreach ($storageContainer in $StorageContainers) {
        $accountContainerCount += 1
        $containerLength = 0

        $storageBlobs = @($storageContainer |  Get-AzStorageBlob)

        $blobCount = 0
        foreach ($storageBlob in $storageBlobs) {
            $containerLength += $storageBlob.Length
            $accountContainerLength += $storageBlob.Length
            $subscriptionStorageLength += $storageBlob.Length
            $blobCount += 1
            $accountBlobCount += 1
        }
        Write-Output "| $($storageContainer.Name) $(" " * (63 - $storageContainer.Name.Length )) | $(" " * (9 - $blobCount.ToString().Length)) $blobCount | $(" " * (13 - $($(ConvertTo-HumanReadableByteSize $containerLength)).Length)) $(ConvertTo-HumanReadableByteSize $containerLength) |"
    }

    Write-Output "+$("-" * 66)+$("-" * 12)+$("-" * 16)+"
    Write-Output "| Container Summary $(" " * 30) Container Count | Blob Count |     Total Size |"
    Write-Output "+$("-" * 66)+$("-" * 12)+$("-" * 16)+"
    Write-Output "|$(" " * (64 - $accountContainerCount.ToString().Length)) $accountContainerCount | $(" " * (9 - $accountBlobCount.ToString().Length)) $accountBlobCount | $(" " * (13 - $($(ConvertTo-HumanReadableByteSize $accountContainerLength)).Length)) $(ConvertTo-HumanReadableByteSize $accountContainerLength) |"
    Write-Output "+$("-" * 66)+$("-" * 12)+$("-" * 16)+`n"

    $storageAccountNameAndSize.Add($storageAccount.StorageAccountName, $(ConvertTo-HumanReadableByteSize $accountContainerLength))
}

Write-Output "`n+$("-" * 51)+"
Write-Output "| Total Storage Size is:  $($(ConvertTo-HumanReadableByteSize $subscriptionStorageLength)) $(" " * (24 - $($(ConvertTo-HumanReadableByteSize $subscriptionStorageLength)).Length)) |"
Write-Output "+$("-" * 30)+$("-" * 20)+"
Write-Output "| Storage Account Name         |               Size |"

foreach($storageAccountName in $storageAccountNameAndSize.keys)
{
    Write-Output "+$("-" * 30)+$("-" * 20)+"
    Write-Output "| $storageAccountName $(" " * (27 - $storageAccountName.Length)) | $(" " * (17 - $($storageAccountNameAndSize[$storageAccountName]).Length)) $($storageAccountNameAndSize[$storageAccountName]) |"
}

Write-Output "+$("-" * 30)+$("-" * 20)+`n"

