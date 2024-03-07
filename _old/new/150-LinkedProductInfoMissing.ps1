#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProductInfoMissing -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
$SQLUsername = "VRI_DOMAIN\alsmith1"
$SQLPassword = "EloDece202!"
 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProductInfoMissing\$((Get-Date).ToString('MM-dd-yyyy'))_LinkedPHC-MissingInfo.csv"
 
$SqlQuery = "SELECT

	sphlink.product_header_code AS 'Product Header Code',
	sph.description AS 'Product Header Description',
	LEFT(sph.description,2) as ResortAcronym ,
	sph.active_ind ,
	sph.display_ind ,
	sph.display_order ,
	sphlink.link_product_header_code AS 'Link Product Header Code',
	sph1.description AS 'Link Product Header Description'
	--sphlink.auto_add_to_cart_ind AS 'Auto Add To Cart Ind',
	--sphlink.default_option AS 'Default Option',
	--sphlink.delete_with_parent_only_ind AS 'Delete With Parent Only Ind'
	
FROM s_product_header_link sphlink
	JOIN s_product_header sph
	ON sphlink.product_header_code = sph.product_header_code
	JOIN s_product_header sph1
	ON sphlink.link_product_header_code = sph1.product_header_code
	JOIN s_product_link_type splt
		ON sphlink.product_link_type_code = splt.product_link_type_code
WHERE

sphlink.product_link_type_code = 150 
AND (sphlink.auto_add_to_cart_ind IS NULL OR sphlink.default_option IS NULL OR sphlink.delete_with_parent_only_ind IS NULL)
AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999)
AND sph.active_ind = 'Y'
AND (sph.description NOT LIKE '%-WU%' AND sph.description NOT LIKE '% WU%')
AND sphlink.product_header_code NOT IN ('133938','134036','1D39616','1D39621','1D58347','1D98345','2D39622','3D45636','3D45642','3D45649','6D42275','6D54016','6D54017','86303','95531','1D92110','1D92111','3D45656','3D45661','3D45663','3D55654','86031','143686','143693','144667','144669','136766','143708','143716','143723','143725','143727') -- As per Mel, removed these PHCs for VL, BC, AT, CR, WC & HU
AND sphlink.product_header_code NOT IN ('145740','147653','147654','148006','148007','148388','148389','148390','148391','149481','149483'/*,'96644'*/) -- Removed as no one over 3+ weeks has updated or removed - so I am just ignoring from now on
ORDER BY
	sphlink.product_header_code ,
	sph.display_order
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
$DataSet.Tables[0] | select "Product Header Code","Product Header Description","ResortAcronym","active_ind","display_ind","display_order","Link Product Header Code","Link Product Header Description","Auto Add To Cart Ind","Default Option","Delete With Parent Only Ind" | Export-Csv $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProductInfoMissing\$((Get-Date).ToString('MM-dd-yyyy'))_LinkedPHC-MissingInfo.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }
 
If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProductInfoMissing\$((Get-Date).ToString('MM-dd-yyyy'))_LinkedPHC-MissingInfo.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'alsmith1@vailresorts.com' -Subject "$(Get-Date -Format MM-dd-yyyy) 150-LinkedPHC-MissingInfo" -Body "Daily 150-LinkedPHC-MissingInfo - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProductInfoMissing").fullname
}