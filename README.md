# GeoCodes4LIS

Microsoft Teams LIS database requires an address with geo codes. This script will populate geo codes for address and get your input file ready to upload to Teams. This script uses Census.gov website to get the geo codes.

## Usage:

**1**, Edit the input file CivicAddresses-Input.csv and add the addresses you need to get the geo codes for. There is a limit of 10,000 addresses per scirpt run.

**2**, Run GetGeocodes.PS1 to valida the addresses from the input file. This script will create an output file labeled CivicAddresses-Output.csv
    The output file will contain a new column for manual validation. For the latitude and longitude columns there are 3 possible outcome after running the script.    

a, Exactly 1 valid address found and get codes are shows for lat/long. Example of a valid address returned: [Valid address](https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=3301+N+Lucille+Lane,+Lafayette,+CA,+94549&benchmark=Public_AR_Current&format=json)

b, "No address found" - the entered address int he input file could not be validated. Use the manual validation link for more details. Example of an invalid address: [No address found](https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=3301+Lulle+lane+Lane,+Lafayette,+CA,+94549&benchmark=Public_AR_Current&format=json)

c, "Multiple values" - More than one results were returned. IN the exmaple below I did not specify N or S for the street. Example of a multi valued address returned: [Multiple values](https://geocoding.geo.census.gov/geocoder/locations/onelineaddress?address=3301+Lucille+Lane,+Lafayette,+CA,+94549&benchmark=Public_AR_Current&format=json)

**3**, Optional step - Use the UploadValidation.PS1 which will give you counts entries valid and invalid.

**4**, Connect to Microsoft Teams from your powershell window

**5**, Run UploadAddresses.PS1 which will create a file labeled ValidCivicAddresses.csv and will create new LIS civic addresses in your tenant

*Notes:*

1, You should not run the import multiple times for the same file. It will create the addresses multiple times as it will create the same address with a new LocationID.
2, Always edit the input file and re-run the script to get the geo codes.
