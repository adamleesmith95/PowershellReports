#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\NULL-DefCals -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
$SQLUsername = "VRI_DOMAIN\alsmith1"
$SQLPassword = "EloSept202!"
 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\NULL-DefCals\$((Get-Date).ToString('MM-dd-yyyy'))_NULL-DefCals.csv"
 
$SqlQuery = "SELECT DISTINCT
				sdc.display_order AS 'display_order' ,
				sdc.description AS 'DispCat' ,
				sph.product_header_code AS 'product_header_code' ,
				sph.description AS 'PHC' ,
				sph.active_ind AS 'PH_Status' ,
				sph.display_ind as 'PH_Display' ,
				sp.product_code AS 'product_code' ,
				sp.description AS 'Component' ,
				sp.active_ind AS 'active_ind' ,
				sp.display_ind AS 'display_ind' ,
				sp.deferral_pattern_code AS 'deferral_pattern_code' ,
				sdp.description AS 'Deferral' ,
				pdc.DeferralCalendarCode AS 'DeferralCalendarCode' ,
				dc.description AS 'Def_Calendar' ,
				sp.operator_id AS 'operator_id' ,
				sp.update_date AS 'update_date'
				
				

FROM s_display_category sdc ( NOLOCK )
JOIN s_product_header sph ( NOLOCK )
ON sph.display_category_code = sdc.display_category_code
JOIN s_product_header_location sphl ( NOLOCK )
ON sphl.product_header_code = sph.product_header_code
JOIN s_product sp ( NOLOCK )
ON sp.product_code = sphl.product_code
JOIN s_deferral_pattern sdp ( NOLOCK )
ON sp.deferral_pattern_code = sdp.deferral_pattern_code AND sp.deferral_pattern_code = 4

LEFT OUTER JOIN ProductDeferralCalendar pdc ( NOLOCK )
INNER JOIN DeferralCalendar dc ( NOLOCK )
ON pdc.DeferralCalendarCode = dc.DeferralCalendarCode
ON sp.product_code = pdc.ProductCode


WHERE

pdc.DeferralCalendarCode IS NULL


ORDER BY
		sdc.display_order ,
		sph.product_header_code
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
$DataSet.Tables[0] | select "display_order", "DispCat", "product_header_code", "PHC", "PH_Status", "PH_Display", "product_code", "Component", "active_ind", "display_ind", "deferral_pattern_code", "Deferral", "DeferralCalendarCode", "Def_Calendar", "operator_id", "update_date" | Export-Csv $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\NULL-DefCals\$((Get-Date).ToString('MM-dd-yyyy'))_NULL-DefCals.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }
 
If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\NULL-DefCals\$((Get-Date).ToString('MM-dd-yyyy'))_NULL-DefCals.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'alsmith1@vailresorts.com' -Subject "$(Get-Date -Format MM-dd-yyyy) NULL-DefCals" -Body "Daily NULL-DefCals - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\NULL-DefCals").fullname
}