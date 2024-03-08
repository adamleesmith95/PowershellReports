# Define the folder paths
$todayFolderPath = "C:\Users\alsmith1\Desktop\PowershellScripts\Privates\Today"
$yesterdayFolderPath = "C:\Users\alsmith1\Desktop\PowershellScripts\Privates\Yesterday"
$outputFolderPath = "C:\Users\alsmith1\Desktop\PowershellScripts\Privates\Differences"
$previousOutputFolderPath = "C:\Users\alsmith1\Desktop\PowershellScripts\Privates\Previous Differences"
$previousComparedFolderPath = "C:\Users\alsmith1\Desktop\PowershellScripts\Privates\Previous Compared"
$folderToMoveToToday = "C:\Users\alsmith1\Desktop\PowershellScripts\SqlFiles\PrivateRateIncrease"

# Get the current date and time for appending to the file name
$timestamp = Get-Date -Format "yyyy-MM-dd"

# Move file from Yesterday to Previous Compared
$yesterdayFile = Get-ChildItem -Path $yesterdayFolderPath -Filter *.xlsx | Select-Object -First 1
if ($yesterdayFile) {
    Move-Item -Path $yesterdayFile.FullName -Destination $previousComparedFolderPath -Force
}

# Move file from Today to Yesterday
$todayFile = Get-ChildItem -Path $todayFolderPath -Filter *.xlsx | Select-Object -First 1
if ($todayFile) {
    Move-Item -Path $todayFile.FullName -Destination $yesterdayFolderPath -Force
}

# Move all files from folderToMoveToToday to Today
Get-ChildItem -Path $folderToMoveToToday -File | Move-Item -Destination $todayFolderPath -Force

# Check if the Differences folder exists, and create it if needed
if (-not (Test-Path -Path $outputFolderPath -PathType Container)) {
    New-Item -Path $outputFolderPath -ItemType Directory -Force
}

# Check if the Previous Differences folder exists, and create it if needed
if (-not (Test-Path -Path $previousOutputFolderPath -PathType Container)) {
    New-Item -Path $previousOutputFolderPath -ItemType Directory -Force
}

# Move existing files from Differences to Previous Differences
Get-ChildItem -Path $outputFolderPath | Move-Item -Destination $previousOutputFolderPath -Force

# Load the Import-Excel module
Import-Module ImportExcel

# Reload file paths after moving
$yesterdayFile = Get-ChildItem -Path $yesterdayFolderPath -Filter *.xlsx | Select-Object -First 1
$todayFile = Get-ChildItem -Path $todayFolderPath -Filter *.xlsx | Select-Object -First 1

# Debugging: Output the file names being compared
Write-Host "Yesterday File: $($yesterdayFile.FullName)"
Write-Host "Today File: $($todayFile.FullName)"

# Load data from the "Today" Excel file
$dataToday = Import-Excel -Path $todayFile.FullName

# Debugging: Output the contents of the "Today" Excel file
Write-Host "Today File Contents:"
$dataToday | Format-Table

# Load data from the "Yesterday" Excel file
$dataYesterday = Import-Excel -Path $yesterdayFile.FullName

# Debugging: Output the contents of the "Yesterday" Excel file
Write-Host "Yesterday File Contents:"
$dataYesterday | Format-Table

# Compare the two datasets and find differences
$differences = Compare-Object $dataYesterday $dataToday -Property DisplayCategory, ProductHeaderCode, ProductHeader, PHOrder, effective_date, price, sale_location_code, SaleLoc -PassThru

# Check if there are differences
if ($differences.Count -gt 0) {
    # Add a column to indicate the source file in the Differences array
    $uniqueDifferences = @()
    $differences | ForEach-Object {
        $row = $_
        $sourceFile = if ($row.SideIndicator -eq "<=") {
            $yesterdayFile.Name
        } elseif ($row.SideIndicator -eq "=>") {
            $todayFile.Name
        } else {
            "Unknown"
        }
        $uniqueRow = $row | Add-Member -MemberType NoteProperty -Name 'SourceFile' -Value $sourceFile -PassThru
        if (-not ($uniqueDifferences -contains $uniqueRow)) {
            $uniqueDifferences += $uniqueRow
        }
    }

    # Construct the description with file dates
    $description = "Differences between $($yesterdayFile.Name) and $($todayFile.Name)"

    # Output the description
    Write-Host $description

    # Export to CSV with the date and time appended to the file name
    $csvPath = Join-Path -Path $outputFolderPath -ChildPath "$timestamp-PrivateRateDifferences.csv"
    $uniqueDifferences | Export-Csv -Path $csvPath -NoTypeInformation -Force

    Write-Host "Differences exported to $csvPath"
} else {
    Write-Host "No differences found. No file saved in the Differences folder."
}

# Define the email parameters
$emailFrom = "alsmith1@vailresorts.com"
$emailTo = "alsmith1@vailresorts.com"
$emailSubject = "$dateString $($file.BaseName)"
$emailBody = "Daily $($file.BaseName) - $($DataTable.Rows.Count)"

# Define the path to the CSV file you want to attach
$attachmentPath = $csvPath  # Assuming you want to attach the CSV generated earlier

# Send the email with the excel file attached
Send-MailMessage -From $emailFrom -To $emailTo -Subject $emailSubject -Body $emailBody -Attachments $attachmentPath -SmtpServer "smtp.vailresorts.com"

# Debugging statements
Write-Host "Number of differences: $($differences.Count)"

# Add a pause at the end
Write-Host "Press Enter to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
