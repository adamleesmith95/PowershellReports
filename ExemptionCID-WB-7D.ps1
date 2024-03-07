#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\ExemptionCID-WB -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
##$SQLUsername = "VRI_DOMAIN\alsmith1"
 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\ExemptionCID-WB\$((Get-Date).ToString('MM-dd-yyyy'))_ExemptionCID-WB-7D.csv"
 
$SqlQuery = "SELECT ReservationExemptionId
      ,IPCode
      ,ScanDate
      ,MRTransactionId
      ,TransactionLineNumber
      ,ReservationId
      ,ReservationLineNumber
      ,ExemptionReason
      ,StatusCode
      ,CreateOperatorId
      ,CreateDate
      ,UpdateOperatorId
      ,UpdateDate
      ,ResortCode
FROM ip_reservation_exemption
WHERE ResortCode  = 80
AND ScanDate >= GETDATE()
AND ScanDate <= GETDATE() + 7

ORDER BY ScanDate
		"
   
##Delete the output file if it already exists
If (Test-Path $OuputFile ){
    Remove-Item $OuputFile
}
  
#Write-Host "INFO: Exporting data from $SQLDBName to $OuputFile" -foregroundcolor white -backgroundcolor blue
  
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
$DataSet.Tables[0] | select "ReservationExemptionId","IPCode","ScanDate","MRTransactionId","TransactionLineNumber","ReservationId","ReservationLineNumber","ExemptionReason","StatusCode","CreateOperatorId","CreateDate","UpdateOperatorId","UpdateDate","ResortCode" | Export-Csv -NoTypeInformation $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\ExemptionCID-WB\$((Get-Date).ToString('MM-dd-yyyy'))_ExemptionCID-WB-7D.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }
 
If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\ExemptionCID-WB\$((Get-Date).ToString('MM-dd-yyyy'))_ExemptionCID-WB-7D.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'Slwatkins@vailresorts.com' -Subject "$(Get-Date -Format MM-dd-yyyy) ExemptionCID-WB" -Body "Daily ExemptionCID-WB - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\ExemptionCID-WB").fullname
}