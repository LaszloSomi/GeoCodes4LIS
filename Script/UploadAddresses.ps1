<#
    .SYNOPSIS
    Upload the addresses to Teams with geo codes based on the output file. Skip the addresses where geo codes are are not valid and are null or text

    .DESCRIPTION

    0, Connect to teams using Connect-MicrosoftTeams
    1, Use the GetGeoCodes.ps1 script to create the output file. 
    2, Run the script which will create a ValidCivicAddresses.csv file and upload the address

    .EXAMPLE
    Run the script and follow the instructions to get the geo codes for the addresses in the input file.
    
    New-CsOnlineLisCivicAddress -HouseNumber 1 -StreetName 'Microsoft Way' -City Redmond -StateorProvince Washington -CountryOrRegion US -PostalCode 98052 -Description "West Coast Headquarters" -CompanyName Contoso -Latitude 47.63952 -Longitude -122.12781 -Elin MICROSOFT_ELIN

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

# Filter out invalid rows and export valid rows to a new CSV file
$validAddresses = $addresses | Where-Object {
    try {
        -not [string]::IsNullOrWhiteSpace($_.Latitude) -and
        -not [string]::IsNullOrWhiteSpace($_.Longitude) -and
        [double]::Parse($_.Latitude) -ge -90 -and [double]::Parse($_.Latitude) -le 90 -and
        [double]::Parse($_.Longitude) -ge -180 -and [double]::Parse($_.Longitude) -le 180
    }
    catch {
        $false
    }
}

$validAddresses | Export-Csv -Path "$scriptDirectory\ValidCivicAddresses.csv" -NoTypeInformation

Write-Host -ForegroundColor Green "Filtered valid addresses have been exported to $scriptDirectory\ValidCivicAddresses.csv"


# Loop through each row in the CSV file
foreach ($address in $validAddresses) {
    try {
        # Create a hashtable to store non-null properties
        $addressProperties = @{}

        # Add properties to the hashtable if they are not null
        if ($address.StreetAddress) { $addressProperties["StreetAddress"] = $address.StreetAddress }
        if ($address.City) { $addressProperties["City"] = $address.City }
        if ($address.State) { $addressProperties["State"] = $address.State }
        if ($address.Country) { $addressProperties["Country"] = $address.Country }
        if ($address.PostalCode) { $addressProperties["PostalCode"] = $address.PostalCode }
        if ($address.Description) { $addressProperties["Description"] = $address.Description }
        if ($address.CityAlias) { $addressProperties["CityAlias"] = $address.CityAlias }
        if ($address.CompanyName) { $addressProperties["CompanyName"] = $address.CompanyName }
        if ($address.CountryOrRegion) { $addressProperties["CountryOrRegion"] = $address.CountryOrRegion }
        if ($address.Elin) { $addressProperties["Elin"] = $address.Elin }
        if ($address.HouseNumber) { $addressProperties["HouseNumber"] = $address.HouseNumber }
        if ($address.HouseNumberSuffix) { $addressProperties["HouseNumberSuffix"] = $address.HouseNumberSuffix }
        if ($address.Latitude) { $addressProperties["Latitude"] = $address.Latitude }
        if ($address.Longitude) { $addressProperties["Longitude"] = $address.Longitude }
        if ($address.PostDirectional) { $addressProperties["PostDirectional"] = $address.PostDirectional }
        if ($address.PreDirectional) { $addressProperties["PreDirectional"] = $address.PreDirectional }
        if ($address.StateOrProvince) { $addressProperties["StateOrProvince"] = $address.StateOrProvince }
        if ($address.StreetName) { $addressProperties["StreetName"] = $address.StreetName }
        if ($address.StreetSuffix) { $addressProperties["StreetSuffix"] = $address.StreetSuffix }

        # Process the row with New-CsOnlineLisCivicAddress command using the hashtable
        New-CsOnlineLisCivicAddress @addressProperties

        Write-Host -ForegroundColor Green "Address added: $($address.StreetName), $($address.City), $($address.State)"
    }
    catch {
        Write-Host -ForegroundColor Red "Failed to add address: $($address.StreetName), $($address.City), $($address.State). Error: $_"
    }
}
