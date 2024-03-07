# Define the SQL Server connection parameters
$SQLServer = "rposdblhotse"
$SQLDBName = "rtpx2"

# Define the folder where the SQL files are located
$folder = "C:\Users\alsmith1\Desktop\PowershellScripts\SqlFiles"

# Get a list of all the SQL files in the folder
$files = Get-ChildItem $folder -Filter "*.sql"

# Loop through each SQL file
foreach ($file in $files)
{

	
    # Define the file path for the SQL file
    $sqlFilePath = Join-Path $folder $file

    # Define the folder where the results will be saved
    $resultsFolder = Join-Path $folder $file.BaseName

    # Create the results folder if it doesn't already exist
    if (!(Test-Path $resultsFolder))
    {
        New-Item -ItemType Directory -Path $resultsFolder
    }

    # Define the file path where the results will be saved
    $dateString = Get-Date -Format yyyy-MM-dd
    $resultsFilePath = Join-Path $resultsFolder "$dateString-$($file.BaseName).xlsx"


    # Connect to the SQL Server
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security=True;"
    $SqlConnection.Open()

    # Create the SQL command object
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = Get-Content $sqlFilePath
    $SqlCmd.Connection = $SqlConnection

    # Execute the SQL query and save the results to a DataTable object
    $DataTable = New-Object System.Data.DataTable
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $SqlAdapter.Fill($DataTable)
	# Shows all the queries that run so you can see where the issues are occurring - comment this back out once all queries are running correctly
	#Write-Host -Debug $SqlCmd.CommandText
	Write-Host "INFO: Exporting data from $SQLDBName to $OuputFile" -foregroundcolor white -backgroundcolor blue
	
    # Remove any existing files from the results folder
    If (Test-Path $resultsFilePath )
    {
        Remove-Item -Path $resultsFilePath -Force
    }
	
	# Check if the DataTable contains any rows -- This does not seem to work just yet as files are still being saved in folders when there is no data 12/10/22
	if ($DataTable.Rows.Count -gt 0)
	{
    # Export the DataTable to an Excel file
    $DataTable | Export-Excel -Path $resultsFilePath
	}

	# Define the email parameters
	$emailFrom = "alsmith1@vailresorts.com"
	$emailTo = "alsmith1@vailresorts.com"
	$emailSubject = "$dateString $($file.BaseName)"
	$emailBody = "Daily $($file.BaseName) - $($DataTable.Rows.Count)"

	# Send the email with the excel file attached
	Send-MailMessage -From $emailFrom -To $emailTo -Subject $emailSubject -Body $emailBody -Attachments $resultsFilePath -SmtpServer "smtp.vailresorts.com"

    # Close the SQL connection
    $SqlConnection.Close()
	

}

	# Pause script
	Read-Host -Prompt "Press any key to continue"