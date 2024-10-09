<#
    .SYNOPSIS
    Count and display how many addresses willbe uploaded or failed because of error or multi value returened. 

    .DESCRIPTION

    1, Use the GetGeoCodes.ps1 script to create the output file. 
    2, Run the script to get the counts

    .EXAMPLE
    Run the script and follow the instructions to get the geo codes for the addresses in the input file.
    
    .NOTES
    Version:        1.0
    Author:         LSomi@Microsoft.com
    Creation Date:  October 2024

## Disclaimer
# (c)2024 Microsoft Corporation. All rights reserved. This document is provided "as-is." Information and views expressed in this document,
# including URL and other Internet Web site references, may change without notice. You bear the risk of using it.
# This document does not provide you with any legal rights to any intellectual property in any Microsoft product.
# You may copy and use this document for your internal, reference purposes. You may modify this document for your internal purposes.
<#
# Modify below this line at your own risk. 
********************************************************************************************************************
#>

[CmdletBinding()]
param ()
#
# Get the directory where the script is running
Write-Host -ForegroundColor Green "Press enter to use the current directory or enter a valid directory or enter path for the script location."
$scriptDirectory = Read-Host  " "
if (-not $scriptDirectory) {
    $scriptDirectory = (Get-Location).Path
}

# Path to the CSV file
$csvPath = "$scriptDirectory\CivicAddresses-Output.csv"

# Import the CSV file
$addresses = Import-Csv -Path $csvPath


$validCount = 0
$invalidCount = 0

foreach ($address in $addresses) {
    try {
        if ([string]::IsNullOrWhiteSpace($address.Latitude) -or 
            [string]::IsNullOrWhiteSpace($address.Longitude) -or
            [double]::Parse($address.Latitude) -lt -90 -or [double]::Parse($address.Latitude) -gt 90 -and
            [double]::Parse($address.Longitude) -lt -180 -or [double]::Parse($address.Longitude) -gt 180) {
            Write-Host -ForegroundColor Yellow "Skipping address with invalid or missing latitude/longitude: $($address.StreetName), $($address.City), $($address.State), Lat= $($address.Latitude), Long= $($address.Longitude)"
            $invalidCount++
            continue
        }

        Write-host -ForegroundColor Green "Valid records $($address.StreetName), $($address.City), $($address.State), Lat= $($address.Latitude), Long= $($address.Longitude)"
        $validCount++
    } catch {
        Write-Host -ForegroundColor Red "Failed to add address: $($address.StreetName), $($address.City), $($address.State). Error: $_"
        $invalidCount++
    }
}

Write-Host -ForegroundColor Green "
    Total valid addresses: $validCount
    "
Write-Host -ForegroundColor Red "
    Total invalid addresses: $invalidCount
    "



    # Filter out invalid rows and export valid rows to a new CSV file
    $validAddresses = $addresses | Where-Object {
        try {
            -not [string]::IsNullOrWhiteSpace($_.Latitude) -and
            -not [string]::IsNullOrWhiteSpace($_.Longitude) -and
            [double]::Parse($_.Latitude) -ge -90 -and [double]::Parse($_.Latitude) -le 90 -and
            [double]::Parse($_.Longitude) -ge -180 -and [double]::Parse($_.Longitude) -le 180
        } catch {
            $false
        }
    }

    $validAddresses | Export-Csv -Path "$scriptDirectory\ValidCivicAddresses.csv" -NoTypeInformation

    Write-Host -ForegroundColor Green "Filtered valid addresses have been exported to $scriptDirectory\ValidCivicAddresses.csv"