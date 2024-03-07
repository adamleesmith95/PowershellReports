#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\VRRDuplicateMapping -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
##$SQLUsername = "VRI_DOMAIN\alsmith1"
##$SQLPassword = "EloDece202!"
 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\VRRDuplicateMapping\$((Get-Date).ToString('MM-dd-yyyy'))VRRDuplicateMapping.csv"
 
$SqlQuery = "

CREATE TABLE #DoubleVRR (
	DC_Code		int,
	DispCat		VARCHAR(40),
	DispOrder	int,
	PHC			VARCHAR(20),
	PHC_DESC	VARCHAR(40),
	PHC_DispOrder	int,
	Active		VARCHAR(2), 
	Displayed	VARCHAR(2),
	PC_DispOrder	INT,
	Component	VARCHAR(10), 
	PC_Desc		VARCHAR(40),
	SL_Code		int,
	SaleLoc		VARCHAR(MAX)
)

INSERT INTO #DoubleVRR 


SELECT
		sdc.display_category_code ,
		sdc.description ,
		sdc.display_order ,
		sph.product_header_code ,
		--COUNT(sph.product_header_code) AS Num_PHCs ,
		sph.description ,
		sph.display_order ,
		sph.active_ind , 
		sph.display_ind ,
		sph.display_order ,
		sp.product_code , 
		sp.description  ,
		sphl.sale_location_code ,
		sl.description


FROM s_product_header sph
	JOIN s_display_category sdc
		ON sph.display_category_code = sdc.display_category_code AND sdc.active_ind = 'Y'
		AND sdc.description NOT LIKE '%parking lot%' AND sdc.description NOT LIKE '%inactive%'
	JOIN s_product_header_location sphl
		ON sph.product_header_code = sphl.product_header_code AND sphl.sale_location_code IN (10,22)
		AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999)
		AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
	JOIN s_product sp
		ON sphl.product_code = sp.product_code
	JOIN s_location sl
		ON sphl.sale_location_code = sl.location_code
WHERE sp.product_code IN (

	SELECT DISTINCT vbpm.ResellerProductId
	FROM dbo.vrr_bundled_product_mapping vbpm

	)

SELECT 
	d.DC_Code				,
	d.DispCat				,
	d.DispOrder			,
	d.PHC					,
	--COUNT(d.PHC) AS NumComponents ,
	d.PHC_DESC			,
	d.PHC_DispOrder		,
	d.Active				,
	d.Displayed			,
	d.PC_DispOrder		,
	d.Component			,
	d.PC_Desc				,
	d.SL_Code				,
	d.SaleLoc				,
	v.VrrProductId ,
	v.VrrProductDescription ,
	v.LocationCode

FROM #DoubleVRR d
	JOIN vrr_bundled_product_mapping v
		ON d.Component = v.ResellerProductId

WHERE d.PHC IN (
			SELECT 
	d.PHC --,
	--COUNT(d.PHC) AS NumComponents --,
	--d.PHC_DESC

FROM #DoubleVRR d

--WHERE d.PHC = '112227'

GROUP BY
	d.PHC --,
	--d.PHC_DESC

HAVING
	COUNT(d.PHC) > 1
	
	
)

AND d.PHC NOT IN ('133041','133042','91418','91419','94620','95010','152646','152648','152647','152645') /*Park City/Canyon's multi-location components*/

DROP TABLE #DoubleVRR

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
$DataSet.Tables[0] | select "DC_Code", "DispCat", "DispOrder", "PHC", "PHC_DESC", "PHC_DispOrder", "Active", "Displayed", "PC_DispOrder", "Component", "PC_Desc", "SL_Code", "SaleLoc", "VrrProductId", "VrrProductDescription", "LocationCode" | Export-Csv -NoTypeInformation $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\VRRDuplicateMapping\$((Get-Date).ToString('MM-dd-yyyy'))VRRDuplicateMapping.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }

If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\VRRDuplicateMapping\$((Get-Date).ToString('MM-dd-yyyy'))VRRDuplicateMapping.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'alsmith1@vailresorts.com' -Subject "$(Get-Date -Format MM-dd-yyyy) VRRDuplicateMapping" -Body "Daily VRRDuplicateMapping - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\VRRDuplicateMapping").fullname
}