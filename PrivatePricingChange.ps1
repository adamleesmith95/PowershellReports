# Define the folder paths
$sourceFolder = "C:\Users\alsmith1\Desktop\PowershellScripts\SqlFiles\PrivatePricingIncrease"
$outputFolder = "C:\Users\alsmith1\Desktop\PowershellScripts\SqlFiles\PrivatePricingChangesEmail"

# Get the two most recent XLSX files in the source folder
$recentFiles = Get-ChildItem -Path $sourceFolder -Filter "*.xlsx" | Sort-Object LastWriteTime -Descending | Select-Object -First 2

# Check if there are at least two recent files
if ($recentFiles.Count -lt 2) {
    Write-Host "There are not enough recent XLSX files to compare."
    Pause
    exit
}

# Load the Import-Excel module if not already loaded
if (-not (Get-Module -Name ImportExcel -ListAvailable)) {
    Install-Module -Name ImportExcel -Scope CurrentUser -Force
}
Import-Module ImportExcel

# Load the two most recent files into Excel worksheets
$worksheet1 = Import-Excel -Path $recentFiles[0].FullName
$worksheet2 = Import-Excel -Path $recentFiles[1].FullName

# Initialize an array to store the results
$results = @()

# Ensure both worksheets have the same number of rows
$rowCount = [Math]::Min($worksheet1.Count, $worksheet2.Count)

# Iterate through each row in both worksheets
for ($i = 0; $i -lt $rowCount; $i++) {
    $row1 = $worksheet1[$i]
    $row2 = $worksheet2[$i]

    # Initialize a custom object to store the row data
    $result = New-Object PSCustomObject

    # Iterate through all columns dynamically and compare their values
    foreach ($column in $worksheet2 | Get-Member -MemberType Properties | Where-Object { $_.Name -ne "PSObject" }) {
        $columnName = $column.Name
        $value1 = $row1.$columnName
        $value2 = $row2.$columnName

        # Check if the values are different
        if ($value1 -ne $value2) {
            # Add the column from the second file and the "Original" column from the first file
            $result | Add-Member -MemberType NoteProperty -Name $columnName -Value $value2
            $result | Add-Member -MemberType NoteProperty -Name "Original$columnName" -Value $value1
        } else {
            # Add the column from the second file as-is
            $result | Add-Member -MemberType NoteProperty -Name $columnName -Value $value2
        }
    }

    # Add the result to the results array if there are any changes
    if ($result.PSObject.Properties.Count -gt 0) {
        $results += $result
    }
}

# Create a timestamp for the output file without time
$timestamp = Get-Date -Format "yyyyMMdd"

# Define the output file path
$outputFile = Join-Path -Path $outputFolder -ChildPath ("{0}-PricingChanges.xlsx" -f $timestamp)

# Export the results to a new XLSX file
$results | Export-Excel -Path $outputFile -AutoSize -WorksheetName "Differences"

# Display a message and pause before closing
Write-Host "Differences have been exported to $outputFile."
Pause
