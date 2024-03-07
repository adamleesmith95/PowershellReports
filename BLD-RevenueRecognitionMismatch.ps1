#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\BLD-RevenueRecognitionMismatch -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
#$SQLUsername = "VRI_DOMAIN\alsmith1"
 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\BLD-RevenueRecognitionMismatch\$((Get-Date).ToString('MM-dd-yyyy'))BLD-RevenueRecognitionMismatch.csv"
 
$SqlQuery = "

CREATE TABLE #backload (
	product_header_code nvarchar(10) ,
	description nvarchar(40) ,
	NumComponents INT ,
	display_category_code nvarchar(40) ,
	DispCat nvarchar(40) ,
	display_ORDER nvarchar(40)
	)

INSERT INTO #backload ( product_header_code ,	description , NumComponents , display_category_code , DispCat ,	display_ORDER) 




		SELECT  sph.product_header_code 
				,sph.description
				,COUNT(sph.product_header_code) AS NumComponents ,
				sdc.display_category_code ,
				sdc.description ,
				sph.display_order 
		FROM s_product_header sph
			JOIN s_display_category sdc
				ON sph.display_category_code = sdc.display_category_code
			JOIN s_product_header_location sphl
				ON sph.product_header_code = sphl.product_header_code
			JOIN s_product sp
				ON sphl.product_code = sp.product_code
		WHERE sph.product_header_code IN (
								  								   
				SELECT 
					sph.product_header_code 
					--,sph.description

				FROM s_product_header sph
					JOIN s_display_category sdc
						ON sph.display_category_code = sdc.display_category_code
					JOIN s_product_header_location sphl
						ON sph.product_header_code = sphl.product_header_code
					JOIN s_product sp
						ON sphl.product_code = sp.product_code

				WHERE --sdc.description LIKE '%WBS:%'
				 sdc.active_ind = 'Y'
				AND sdc.description NOT LIKE '%parking lot%'
				AND sdc.description NOT LIKE '%inactive%'
				AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999)
				AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
				AND sp.deferral_pattern_code = 6
				AND sphl.sale_location_code IN (10,22)
				)

		AND sphl.sale_location_code IN (10,22)
		AND sdc.display_order NOT BETWEEN 170100 AND 170260
		AND sdc.display_order NOT BETWEEN 1001 AND 69005


		GROUP BY
			sph.product_header_code 
				,sph.description
				,
				sdc.description ,
				sph.display_order	,
				sdc.display_category_code
		HAVING 
			COUNT(sph.product_header_code) > 1
			AND sdc.display_category_code NOT IN (1652)
			AND sdc.description NOT LIKE '%tube%'
	
		ORDER BY
			sdc.description ,
			sph.display_order

SELECT dc.description DispCat, ph.product_header_code, ph.description , ph.active_ind , ph.display_ind , ph.display_order ,p.product_code , p.description Component
	FROM s_product_header ph
		JOIN  s_product_header_location phl
			ON ph.product_header_code = phl.product_header_code
		JOIN s_product p
			ON phl.product_code = p.product_code
		JOIN s_display_category dc
			ON ph.display_category_code = dc.display_category_code
WHERE ph.product_header_code IN (



SELECT product_header_code FROM #backload	 )
AND phl.sale_location_code IN (10,22)
AND p.deferral_pattern_code = 6
AND ph.product_header_code NOT IN ('114310','6D42275','95303','6D54016','95330','6D54017','6D54019','6D45804','95054','6D54022','95092','6D54023','95130','6D54025','95182','103388','103389','103450','103453','104850','104851','105604','106734','106977','107000','114461','121206','121207','124188','128704','128705','132100','149688','73205','13715','79724') /*VL/BC SRS 6Pack products - may not reuse, also might want the setup as-is*/
AND ph.product_header_code NOT IN ('115706','117186','102692') /*Child 4&Under 1Day Comp Lift components */
AND ph.product_header_code NOT IN ('150699','150701','161275','161277','118122','118123','118125','20323','20324','20325','52864') /*requested by Emily and Tori 6/11/22*/
AND ph.product_header_code NOT IN ('116352','116350','116055','161283')/*Adam excluded SP as the BLD is not priced*/
AND ph.product_header_code NOT IN ('127779')/*Adam excluded WB CWX/TOTW as $0 2nd component*/
AND ph.product_header_code NOT IN ('118719','168003')/*Mari requested exclusion of */
AND ph.product_header_code NOT IN ('167870','167873')/*Fresh Tracks 2-4-1 excluded, as both Components are BLD */


DROP TABLE #backload
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
$DataSet.Tables[0] | select "DispCat","product_header_code","description", "active_ind", "display_ind", "display_order", "product_code", "Component" | Export-Csv -NoTypeInformation $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\BLD-RevenueRecognitionMismatch\$((Get-Date).ToString('MM-dd-yyyy'))BLD-RevenueRecognitionMismatch.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }
 
#$recipients = "Adam Smith <alsmith1@vailresorts.com>, Teams Channel <8c045465.vailresorts.onmicrosoft.com@amer.teams.ms>"
$recipients = "<alsmith1@vailresorts.com>", "<8c045465.vailresorts.onmicrosoft.com@amer.teams.ms>"


If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\BLD-RevenueRecognitionMismatch\$((Get-Date).ToString('MM-dd-yyyy'))BLD-RevenueRecognitionMismatch.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To $recipients -Subject "$(Get-Date -Format MM-dd-yyyy) BLD-RevenueRecognitionMismatch" -Body "Daily BLD-RevenueRecognitionMismatch - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\BLD-RevenueRecognitionMismatch").fullname
}