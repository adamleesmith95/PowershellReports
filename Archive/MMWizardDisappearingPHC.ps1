#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\MMWizardDisappearingPHC -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
##$SQLUsername = "VRI_DOMAIN\alsmith1"
##$SQLPassword = "EloDece202!"
 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\MMWizardDisappearingPHC\$((Get-Date).ToString('MM-dd-yyyy'))_MMWizardDisappearingPHC.csv"
 
$SqlQuery = "

SELECT DISTINCT
	sph.display_category_code ,
	sdc.description DispCat ,
	sph.product_header_code , 
	sph.description PHC ,
	sph.active_ind ,
	sph.display_ind ,
	sphmf.mm_function_code ,
	ssf.description 'Function' ,
	CAST(sph.update_date AS DATE) AS Update_Date ,
	sdrpp.expiration_date Max_PHC_Date -- because s_date_range_product_price has a legit expiration DATE, it's simple just TO ADD that field/column

FROM s_product_header_mm_function sphmf
	JOIN s_product_header sph
		ON sphmf.product_header_code = sph.product_header_code-- starting INITIALLY WITH s_product_header_mm_function TO ONLY bring back PHCs that have MM checkboxes ON them
	JOIN s_display_category sdc
		ON sph.display_category_code = sdc.display_category_code -- TO be able TO exclude DispCats that ARE inactive
	JOIN s_system_function ssf
		ON sphmf.mm_function_code = ssf.system_function_code -- TO bring back the description OF the MM Type
	JOIN s_date_range_product_price sdrpp
		ON sph.product_header_code = sdrpp.product_header_code AND sdrpp.expiration_date >= (GETDATE()) -- JOINing s_date_range_product_price TO this part OF the 1st query AND has a 'current' DATE IN the DATE range
WHERE
CAST(sph.update_date AS DATE) <= GETDATE() - 547 -- Taking today's DATE AND going back 18mths, which IS WHEN it's been noted that these PHCs DROP FROM the MM Wizard --DATEADD(DAY,-365,GETDATE())- 365--'2021-05-07'

AND (sph.active_ind = 'Y' AND sph.display_ind = 'Y') /* ONLY want TO ACTION PHCs that ARE BOTH Active AND Displayed... AND once these properties ARE updated manually IN the UI... //
													// ...they WILL show up IN the MM wizard (AS they've been modified IN thelast 18mths!) */

AND sdc.active_ind = 'Y' -- Again, don't require ANY products that have inactive Display Categories
AND sph.price_by_season_ind = 'N' -- USING this IN combination WITH the date_range_product_price tables that the MAX DATE has a CURRENT DATE IN it

UNION
--This IS the price BY season query unioned together

SELECT DISTINCT
	sph.display_category_code ,
	sdc.description DispCat ,
	sph.product_header_code , 
	sph.description PHC ,
	sph.active_ind ,
	sph.display_ind ,
	sphmf.mm_function_code ,
	ssf.description 'Function' ,
	CAST(sph.update_date AS DATE) AS Update_Date ,
	MAX(psd.PricingSeasonDate) Max_PHC_Date		/* because s_season_product_price also leverages PricingSeasonDate AND there ARE multiple dates IN 1 pricing season... //
												// ...I've had TO leverage the MAX aggregate functionality TO effectively GET the 'expiration' OR LAST DATE in the pricing season */

FROM s_product_header_mm_function sphmf
	JOIN s_product_header sph
		ON sphmf.product_header_code = sph.product_header_code  -- starting INITIALLY WITH s_product_header_mm_function TO ONLY bring back PHCs that have MM checkboxes ON them
	JOIN s_display_category sdc
		ON sph.display_category_code = sdc.display_category_code  -- TO be able TO exclude DispCats that ARE inactive
	JOIN s_system_function ssf
		ON sphmf.mm_function_code = ssf.system_function_code -- TO bring back the description OF the MM Type
	JOIN s_season_product_price sspp
		ON sph.product_header_code = sspp.product_header_code -- AS above, this IS the 'pricing season' version OF the s_date_range_product_price TABLE, that also needs PricingSeasonDate TO GET the actual dates
	JOIN PricingSeasonDate psd
		ON sspp.PricingSeasonCode = psd.PricingSeasonCode -- adding PricingSeasonDate TO GET the dates that pertain TO the relevant s_season_product_price PHCs
WHERE
CAST(sph.update_date AS DATE) <= GETDATE() - 547 -- Taking today's DATE AND going back 18mths, which IS WHEN it's been noted that these PHCs DROP FROM the MM Wizard, once updated (saved) manually in the UI will resolve --DATEADD(DAY,-365,GETDATE())- 365--'2021-05-07'

AND (sph.active_ind = 'Y' AND sph.display_ind = 'Y') /* ONLY want TO ACTION PHCs that ARE BOTH Active AND Displayed... AND once these properties ARE updated manually IN the UI,
													they WILL show up IN the MM wizard (AS they've been modified IN thelast 18mths!) */

AND sdc.active_ind = 'Y' -- Again, don't require ANY products that have inactive Display Categories
AND sph.price_by_season_ind = 'Y' -- USING this IN combination WITH the pricing season DATE AND price BY season tables that the MAX DATE has a CURRENT DATE IN it


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
	MAX(psd.PricingSeasonDate) >= (GETDATE()) -- Due TO requireing a MAX aggregate FUNCTION here, needed TO ADD a GROUP BY clause AND move the aggregate WHERE clause IN TO a HAVING clause instead

ORDER BY 
	CAST(sph.update_date AS DATE) DESC -- bring back the more recent PHCs WITH this issue... just cuz
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
#$DataSet.Tables[0] | select "Product Header Code","Product Header Description","ResortAcronym","active_ind","display_ind","display_order","Link Product Header Code","Link Product Header Description","Auto Add To Cart Ind","Default Option","Delete With Parent Only Ind" | Export-Csv $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\MMWizardDisappearingPHC\$((Get-Date).ToString('MM-dd-yyyy'))_MMWizardDisappearingPHC.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }
 
If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\MMWizardDisappearingPHC\$((Get-Date).ToString('MM-dd-yyyy'))_MMWizardDisappearingPHC.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'alsmith1@vailresorts.com' -Subject "$(Get-Date -Format MM-dd-yyyy) MMWizardDisappearingPHC" -Body "Daily MMWizardDisappearingPHC - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\MMWizardDisappearingPHC").fullname
}