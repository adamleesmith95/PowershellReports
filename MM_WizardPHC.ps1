#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\MM_WizardPHC -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
#$SQLServer = "rpostestdb3\lhotse" 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
##$SQLUsername = "VRI_DOMAIN\alsmith1"

 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\MM_WizardPHC\$((Get-Date).ToString('MM-dd-yyyy'))_MM_WizardPHC.csv"
 
$SqlQuery = "SELECT DISTINCT
	sph.display_category_code AS DispCatCode,
	sdc.description AS DispCat ,
	sph.product_header_code AS PHC, 
	sph.description AS PHCDescription ,
	sph.active_ind AS Active,
	sph.display_ind AS Display,
	sphmf.mm_function_code AS MMFC,
	ssf.description AS MMFunction ,
	CAST(sph.update_date AS DATE) AS Update_Date ,
	sdrpp.expiration_date AS Max_PHC_Date

FROM s_product_header_mm_function sphmf
	JOIN s_product_header sph
		ON sphmf.product_header_code = sph.product_header_code
	JOIN s_display_category sdc
		ON sph.display_category_code = sdc.display_category_code
	JOIN s_system_function ssf
		ON sphmf.mm_function_code = ssf.system_function_code
	JOIN s_date_range_product_price sdrpp
		ON sph.product_header_code = sdrpp.product_header_code AND sdrpp.expiration_date >= (GETDATE())
WHERE
CAST(sph.update_date AS DATE) <= GETDATE() - 547

AND (sph.active_ind = 'Y' AND sph.display_ind = 'Y')
						

AND sdc.active_ind = 'Y'
AND sph.price_by_season_ind = 'N'

UNION

SELECT DISTINCT
	sph.display_category_code AS DispCatCode ,
	sdc.description AS DispCat ,
	sph.product_header_code AS PHC , 
	sph.description AS PHCDescription ,
	sph.active_ind AS Active ,
	sph.display_ind AS Display ,
	sphmf.mm_function_code AS MMFC ,
	ssf.description AS MMFunction ,
	CAST(sph.update_date AS DATE) AS Update_Date ,
	MAX(psd.PricingSeasonDate) AS Max_PHC_Date 

FROM s_product_header_mm_function sphmf
	JOIN s_product_header sph
		ON sphmf.product_header_code = sph.product_header_code
	JOIN s_display_category sdc
		ON sph.display_category_code = sdc.display_category_code
	JOIN s_system_function ssf
		ON sphmf.mm_function_code = ssf.system_function_code
	JOIN s_season_product_price sspp
		ON sph.product_header_code = sspp.product_header_code
	JOIN PricingSeasonDate psd
		ON sspp.PricingSeasonCode = psd.PricingSeasonCode
WHERE
CAST(sph.update_date AS DATE) <= GETDATE() - 547

AND (sph.active_ind = 'Y' AND sph.display_ind = 'Y')

AND sdc.active_ind = 'Y'
AND sph.price_by_season_ind = 'Y'


GROUP BY
	sph.display_category_code ,
	sdc.description ,
	sph.product_header_code , 
	sph.description ,
	sph.active_ind ,
	sph.display_ind ,
	sphmf.mm_function_code ,
	ssf.description ,
	CAST(sph.update_date AS DATE) 

HAVING
	MAX(psd.PricingSeasonDate) >= (GETDATE())

ORDER BY 
	CAST(sph.update_date AS DATE) DESC


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
$DataSet.Tables[0] | select "DispCatCode","DispCat","PHC","PHCDescription","Active","Display","MMFC","MMFunction","Update_Date","Max_PHC_Date"  | Export-Csv -NoTypeInformation $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\MM_WizardPHC\$((Get-Date).ToString('MM-dd-yyyy'))_MM_WizardPHC.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }

If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\MM_WizardPHC\$((Get-Date).ToString('MM-dd-yyyy'))_MM_WizardPHC.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'alsmith1@vailresorts.com' -Subject "$(Get-Date -Format MM-dd-yyyy) MM_WizardPHC" -Body "Daily MM_WizardPHC - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\MM_WizardPHC").fullname
}