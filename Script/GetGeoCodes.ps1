<#
  .SYNOPSIS
  Get geo codes for address and prepare input file to be uploaded to Teams

  .DESCRIPTION

1, Use the sample input file to populate your addresses. 
2, Run the script to get the geo codes for the addresses.
3, Validate the data, correct input address where multi valued address or an error returned. Test URL provided in the "Manual Validation URL" column in the output file.

# Test URL invalid https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=3301+Lulle+lane+Lane,+Lafayette,+CA,+94549&benchmark=Public_AR_Current&format=json
# Test URL valid https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=3301+N+Lucille+Lane,+Lafayette,+CA,+94549&benchmark=Public_AR_Current&format=json
# Test URL Multi value return https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=3301+Lucille+Lane,+Lafayette,+CA,+94549&benchmark=Public_AR_Current&format=json


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

# Define the input and output file paths
$inputFile = "$scriptDirectory\CivicAddresses-Input.csv"
$outputFile = "$scriptDirectory\CivicAddresses-Output.csv"

# Define the Geocoding API URL and parameters
#$apiUrl = "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress"
$benchmark = "Public_AR_Current"
$format = "json"

# Read the input CSV file
$addresses = Import-Csv -Path $inputFile

# Initialize an array to hold the output data
$outputData = @()

# Process each address
foreach ($address in $addresses) {
    if (-not $address.Latitude -or -not $address.Longitude) {
        # Construct the address string
        $addressString = [Uri]::EscapeDataString(@($address.HouseNumber, $address.StreetName, $address.City, $address.StateOrProvince, $address.PostalCode | Where-Object { "$_".Trim().Length -gt 0 }) -join ',')
        # Call the Geocoding API
        $apiRequestUrl = "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=$($addressString)&benchmark=$benchmark&format=$format"
        $response = Invoke-RestMethod -Uri $apiRequestUrl -Method Get
        
        # Extract the latitude and longitude from the API response
        if ($response.result.addressMatches.Count -eq 1) {
            $address.Latitude = $response.result.addressMatches[0].coordinates.y
            $address.Longitude = $response.result.addressMatches[0].coordinates.x
        }
        elseif ($response.result.addressMatches.Count -gt 1) {
            $address.Latitude = "Multiple Values"
            $address.Longitude = "Multiple Values"
            Write-Host -ForegroundColor Red "
            Multiple values returned for address: $([uri]::UnescapeDataString($addressString))"
        }
        else {
            $address.Latitude = "No address found"
            $address.Longitude = "No address found"
        }
    }

    # Add the API request URL for manual validation
    $address | Add-Member -MemberType NoteProperty -Name "Manual Validation URL" -Value $apiRequestUrl

    # Add the processed address to the output data array
    $outputData += $address
}

# Export the output data to a new CSV file
$outputData | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "Processing complete. Output saved to $outputFile" -ForegroundColor Green




