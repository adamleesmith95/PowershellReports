#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\DefCalExpired -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
$SQLUsername = "VRI_DOMAIN\alsmith1"
$SQLPassword = "EloDece202!"
 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\DefCalExpired\$((Get-Date).ToString('MM-dd-yyyy'))DefCalExpired.csv"
 
$SqlQuery = "



CREATE TABLE #ProdSetup
(	
	DC_Code INT ,		 
	DispCat	 nvarchar(50) ,
	DC_Order INT ,
	PHC nvarchar(18) ,
	ProductHeader nvarchar(50) ,
	PH_Order INT ,	
	Active nvarchar(1) ,
	Display	nvarchar(1) ,
	PC INT ,
	Component nvarchar(50) ,
	FirsttDate DATE ,
	LastDate DATE ,
	DefCal nvarchar(50) ,
	DefCalStart DATE ,
	DefCalEnd DATE ,
	DC_Days INT ,
	UpdateID nvarchar(50) ,
	UpdateDate Date
)

-- SELECT statement FOR Price BY DATE Range Pricing Type
	INSERT INTO #ProdSetup 	 

SELECT
	sdc.display_category_code ,
	sdc.description ,
	sdc.display_order ,
	sph.product_header_code ,
	sph.description ,
	sph.display_order ,
	sph.active_ind , 
	sph.display_ind ,
	sdrpp.product_code ,
	sp.description ,
	sdrpp.effective_date ,
	sdrpp.expiration_date ,
	dc.Description + ' - ' + CAST(pdc.DeferralCalendarCode AS nvarchar(10)) ,
	MIN(dcd.RevenueRecognitionDate) ,
	MAX(dcd.RevenueRecognitionDate) ,
	COUNT(dcd.RevenueRecognitionDate) ,
	sph.operator_id ,
	sph.update_date
		
FROM s_display_category sdc
	JOIN s_product_header sph
		ON sdc.display_category_code = sph.display_category_code

	JOIN s_date_range_product_price sdrpp
		ON sdrpp.product_header_code = sph.product_header_code --AND sdrpp.expiration_date > DATEADD(YEAR, @YearsBack, GETDATE())
	JOIN s_product sp
		ON sdrpp.product_code = sp.product_code
	LEFT JOIN ProductDeferralCalendar pdc
		ON sp.product_code = pdc.ProductCode
	LEFT JOIN DeferralCalendar dc
		ON pdc.DeferralCalendarCode = dc.DeferralCalendarCode
	LEFT JOIN DeferralCalendarDate dcd
		ON dc.DeferralCalendarCode = dcd.DeferralCalendarCode

WHERE dc.DeferralCalendarCode IS NOT NULL
AND sdc.active_ind = 'Y' AND sdc.description NOT LIKE '%inactive%' AND sdc.description NOT LIKE '%parking lot%' AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999) AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
AND sph.product_header_code NOT IN ('97805', '113789')
AND MAX(psd.PricingSeasonDate) != '20220430'

GROUP BY
	sdc.display_category_code ,
	sdc.description ,
	sdc.display_order ,
	sph.product_header_code ,
	sph.description ,
	sph.display_order ,
	sph.active_ind , 
	sph.display_ind ,
	sdrpp.product_code ,
	sp.description ,
	sdrpp.effective_date ,
	sdrpp.expiration_date ,
	dc.Description + ' - ' + CAST(pdc.DeferralCalendarCode AS nvarchar(10)) ,
	sph.operator_id ,
	sph.update_date

HAVING MIN(sdrpp.effective_date) > MAX(dcd.RevenueRecognitionDate)

		 
-- SELECT statement FOR Price BY Season Pricing Type  
INSERT INTO #ProdSetup 	 

	SELECT
	sdc.display_category_code ,
	sdc.description ,
	sdc.display_order ,
	sph.product_header_code ,
	sph.description ,
	sph.display_order ,
	sph.active_ind , 
	sph.display_ind ,
	sspp.product_code ,
	sp.description ,
	MIN(psd.PricingSeasonDate) ,
	MAX(psd.PricingSeasonDate) ,
	dc.Description + ' - ' + CAST(pdc.DeferralCalendarCode AS nvarchar(10)) ,
	MIN(dcd.RevenueRecognitionDate) ,
	MAX(dcd.RevenueRecognitionDate) ,
	COUNT(dcd.RevenueRecognitionDate) ,
	sph.operator_id ,
	sph.update_date

FROM s_display_category sdc
	JOIN s_product_header sph
		ON sdc.display_category_code = sph.display_category_code

	JOIN s_season_product_price sspp
		ON sspp.product_header_code = sph.product_header_code
	JOIN s_product sp
		ON sspp.product_code = sp.product_code
	JOIN PricingSeasonDate psd
		ON sspp.PricingSeasonCode = psd.PricingSeasonCode
	JOIN PricingSeason ps
		ON sspp.PricingSeasonCode = ps.PricingSeasonCode
	LEFT JOIN ProductDeferralCalendar pdc
		ON sp.product_code = pdc.ProductCode
	LEFT JOIN DeferralCalendar dc
		ON pdc.DeferralCalendarCode = dc.DeferralCalendarCode
	LEFT JOIN DeferralCalendarDate dcd
		ON dc.DeferralCalendarCode = dcd.DeferralCalendarCode

WHERE dc.DeferralCalendarCode IS NOT NULL
AND sdc.active_ind = 'Y' AND sdc.description NOT LIKE '%inactive%' AND sdc.description NOT LIKE '%parking lot%' AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999) AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
AND sph.product_header_code NOT IN ('97805', '113789')
AND MAX(psd.PricingSeasonDate) != '20220430'

GROUP BY
	sdc.display_category_code ,
	sdc.description ,
	sdc.display_order ,
	sph.product_header_code ,
	sph.description ,
	sph.display_order ,
	sph.active_ind , 
	sph.display_ind ,
	sspp.product_code ,
	sp.description ,
	dc.Description + ' - ' + CAST(pdc.DeferralCalendarCode AS nvarchar(10)) ,
	sph.operator_id ,
	sph.update_date

HAVING MIN(psd.PricingSeasonDate) > MAX(dcd.RevenueRecognitionDate)




-- SELECT statement FOR Price BY Season + Location Pricing Type  
INSERT INTO #ProdSetup 	 

SELECT
	sdc.display_category_code ,
	sdc.description ,
	sdc.display_order ,
	sph.product_header_code ,
	sph.description ,
	sph.display_order ,
	sph.active_ind , 
	sph.display_ind ,
	sslpp.product_code ,
	sp.description ,
	MIN(psd.PricingSeasonDate) ,
	MAX(psd.PricingSeasonDate) ,
	dc.Description + ' - ' + CAST(pdc.DeferralCalendarCode AS nvarchar(10)) ,
	MIN(dcd.RevenueRecognitionDate) ,
	MAX(dcd.RevenueRecognitionDate) ,
	COUNT(dcd.RevenueRecognitionDate) ,
	sph.operator_id ,
	sph.update_date

FROM s_display_category sdc
	JOIN s_product_header sph
		ON sdc.display_category_code = sph.display_category_code

	JOIN s_season_location_product_price sslpp
		ON sslpp.product_header_code = sph.product_header_code
	JOIN s_product sp
		ON sslpp.product_code = sp.product_code
	LEFT JOIN ProductDeferralCalendar pdc
		ON sp.product_code = pdc.ProductCode
	JOIN PricingSeasonDate psd
		ON sslpp.PricingSeasonCode = psd.PricingSeasonCode
	JOIN s_location sl
		ON sslpp.sale_location_code = sl.location_code
	JOIN PricingSeason ps
		ON sslpp.PricingSeasonCode = ps.PricingSeasonCode
	LEFT JOIN DeferralCalendar dc
		ON pdc.DeferralCalendarCode = dc.DeferralCalendarCode
	LEFT JOIN DeferralCalendarDate dcd
		ON dc.DeferralCalendarCode = dcd.DeferralCalendarCode

WHERE dc.DeferralCalendarCode IS NOT NULL
AND sdc.active_ind = 'Y' AND sdc.description NOT LIKE '%inactive%' AND sdc.description NOT LIKE '%parking lot%' AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999) AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
AND sph.product_header_code NOT IN ('97805', '113789')
AND MAX(psd.PricingSeasonDate) != '20220430'

GROUP BY
	sdc.display_category_code ,
	sdc.description ,
	sdc.display_order ,
	sph.product_header_code ,
	sph.description ,
	sph.display_order ,
	sph.active_ind , 
	sph.display_ind ,
	sslpp.product_code ,
	sp.description ,
	dc.Description + ' - ' + CAST(pdc.DeferralCalendarCode AS nvarchar(10)) ,
	sph.operator_id ,
	sph.update_date

HAVING MIN(psd.PricingSeasonDate) > MAX(dcd.RevenueRecognitionDate)

-- SELECT statement FOR Price BY DATE Range + Location Pricing Type  
INSERT INTO #ProdSetup 	 

SELECT
	sdc.display_category_code ,
	sdc.description ,
	sdc.display_order ,
	sph.product_header_code ,
	sph.description ,
	sph.display_order ,
	sph.active_ind , 
	sph.display_ind ,
	sdrlpp.product_code ,
	sp.description ,
	sdrlpp.effective_date ,
	sdrlpp.expiration_date , 
	dc.Description + ' - ' + CAST(pdc.DeferralCalendarCode AS nvarchar(10)) ,
	MIN(dcd.RevenueRecognitionDate) ,
	MAX(dcd.RevenueRecognitionDate) ,
	COUNT(dcd.RevenueRecognitionDate) ,
	sph.operator_id ,
	sph.update_date

FROM s_display_category sdc
	JOIN s_product_header sph
		ON sdc.display_category_code = sph.display_category_code
	JOIN s_date_range_location_product_price sdrlpp
		ON sdrlpp.product_header_code = sph.product_header_code	 --AND sdrlpp.expiration_date > DATEADD(YEAR, @YearsBack, GETDATE())
	JOIN s_product sp
		ON sdrlpp.product_code = sp.product_code
	LEFT JOIN ProductDeferralCalendar pdc
		ON sp.product_code = pdc.ProductCode
	LEFT JOIN DeferralCalendar dc
		ON pdc.DeferralCalendarCode = dc.DeferralCalendarCode
	LEFT JOIN DeferralCalendarDate dcd
		ON dc.DeferralCalendarCode = dcd.DeferralCalendarCode

WHERE dc.DeferralCalendarCode IS NOT NULL
AND sdc.active_ind = 'Y' AND sdc.description NOT LIKE '%inactive%' AND sdc.description NOT LIKE '%parking lot%' AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999) AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
AND sph.product_header_code NOT IN ('97805', '113789')
AND MAX(psd.PricingSeasonDate) != '20220430'

GROUP BY
	sdc.display_category_code ,
	sdc.description ,
	sdc.display_order ,
	sph.product_header_code ,
	sph.description ,
	sph.display_order ,
	sph.active_ind , 
	sph.display_ind ,
	sdrlpp.product_code ,
	sp.description ,
	sdrlpp.effective_date ,
	sdrlpp.expiration_date , 
	dc.Description + ' - ' + CAST(pdc.DeferralCalendarCode AS nvarchar(10)) ,
	sph.operator_id ,
	sph.update_date

HAVING MIN(sdrlpp.effective_date) > MAX(dcd.RevenueRecognitionDate)
	  
-- Basic SELECT statement TO RETURN * FROM Temptable #ProdSetup 	  



SELECT * FROM #ProdSetup p
WHERE p.LastDate > GETDATE()
ORDER BY
	DC_Order ,
	PH_Order ,
	FirsttDate

-- DROP TABLE AT the END OF the query
DROP TABLE #ProdSetup




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
$DataSet.Tables[0] | select "DC_Code", "DispCat", "DC_Order", "PHC", "ProductHeader", "PH_Order", "Active", "Display", "PC", "Component", "FirsttDate", "LastDate", "DefCal", "DefCalStart", "DefCalEnd", "DC_Days", "UpdateID", "UpdateDate" | Export-Csv $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\DefCalExpired\$((Get-Date).ToString('MM-dd-yyyy'))DefCalExpired.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }

If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\DefCalExpired\$((Get-Date).ToString('MM-dd-yyyy'))DefCalExpired.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'alsmith1@vailresorts.com' -Subject "$(Get-Date -Format MM-dd-yyyy) DefCalExpired" -Body "Daily DefCalExpired - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\DefCalExpired").fullname
}