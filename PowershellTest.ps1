#Connect to SQL and run QUERY 
$SQLServer = "rpostestdb3\lhotse" 
$SQLDBName = "rtpx2"
$SQLUsername = "VRI_DOMAIN\alsmith1"
$SQLPassword = "July202@"
 
$OuputFile = "C:\Users\alsmith1\Desktop\Powershell\Powershell.csv"
 
$SqlQuery = "SELECT
      [ip_number]
      ,[internal_access_code]
      ,[scan_process_order_code]
      ,[product_code]
      ,[effective_date]
      ,[expiration_date]
      ,[mr_transaction_id]

FROM [rtpx2].[dbo].[ip_pass_prepaid_access]
WHERE product_code IN (133487,133480,133491)
AND expiration_date = '2020-11-15 00:00:00.000' --Can change to 2021 to see if any new ones have been sold with the correct expiration
ORDER BY effective_date"
   
##Delete the output file if it already exists
If (Test-Path $OuputFile ){
    Remove-Item $OuputFile
}
  
Write-Host "INFO: Exporting data from $SQLDBName to $OuputFile" -foregroundcolor white -backgroundcolor blue
  
## - Connect to SQL Server using non-SMO class 'System.Data': 
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection 
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security=True;"
  
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand 
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
  
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
$SqlAdapter.SelectCommand = $SqlCmd
  
$DataSet = New-Object System.Data.DataSet 
$SqlAdapter.Fill($DataSet) 
$SqlConnection.Close() 
 
#Output RESULTS to CSV
$DataSet.Tables[0] | select "ip_number","internal_access_code","scan_process_order_code","product_code","effective_date","expiration_date","mr_transaction_id" | Export-Csv -NoTypeInformation $OuputFile

Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'alsmith1@vailresorts.com' -Subject 'Daily Component Errors' -Body 'Daily Component Errors' -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\Powershell").fullname