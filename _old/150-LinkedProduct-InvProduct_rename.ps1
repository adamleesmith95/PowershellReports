#Delete folder so previous days' email does not get sent
Get-ChildItem -Path C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProduct-InvProduct -Include *.* -File -Recurse | foreach { $_.Delete()}
#Connect to SQL and run QUERY 
$SQLServer = "rposdblhotse" 
$SQLDBName = "rtpx2"
$SQLUsername = "VRI_DOMAIN\alsmith1"
$SQLPassword = "EloSept202!"
 
$OuputFile = "C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProduct-InvProduct\$((Get-Date).ToString('MM-dd-yyyy'))_150-LinkedProduct-InvProduct.csv"
 
$SqlQuery = "SELECT
	sph.active_ind , 
	sph.display_ind , 


	sphlink.product_header_code AS 'Product Header Code',
	sph.description AS 'Product Header Description',
	sphlink.link_product_header_code AS 'Link Product Header Code',
	sph1.description AS 'Link Product Header Description',
	--sphlink.sell_quantity AS 'Sell Quantity',
	--sphlink.sell_quantity_is_quantity_ind AS 'Sell Quantity Is Quantity Ind',
	--sphlink.sell_quantity_is_units_ind AS 'Sell Quantity Is Units Ind',
	--sphlink.auto_select_ind AS 'Auto Select Ind',
	sphlink.product_link_type_code AS 'Product Link Type Code',
	splt.description AS 'Product Link Type Description',
	sphlink.auto_add_to_cart_ind AS 'Auto Add To Cart Ind',
	sphlink.default_option AS 'Default Option',
	--sphlink.display_in_cart_ind AS 'Display In Cart Ind',
	--sphlink.prompt AS 'Prompt',
	sphlink.delete_with_parent_only_ind AS 'Delete With Parent Only Ind',
	sphlink.match_parent_qty_ind AS 'Match Parent Quantity Ind' --,
	--sphlink.special_logic_ind AS 'Special Logic Ind',
	--sphlink.display_order AS 'Display Order'

FROM s_product_header_link sphlink
	JOIN s_product_header sph
	ON sphlink.product_header_code = sph.product_header_code
	JOIN s_product_header sph1
	ON sphlink.link_product_header_code = sph1.product_header_code
	JOIN s_product_link_type splt
		ON sphlink.product_link_type_code = splt.product_link_type_code
	WHERE sphlink.link_product_header_code IN
	(


	SELECT DISTINCT
		sphl.product_header_code
		--, spip.InventoryPoolCode
	
	FROM s_product_header_location sphl
		JOIN s_product_inventory_pool spip
		ON sphl.product_code = spip.product_code

	WHERE
		spip.InventoryPoolCode IS NOT NULL
	)

AND sphlink.product_link_type_code = 150 
AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999)
--AND (sphlink.auto_add_to_cart_ind = 'Y' OR sphlink.default_option = '1')
AND sph.product_header_code NOT IN ('84228','84232','84290','84294')

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
$DataSet.Tables[0] | select "active_ind","display_ind","Product Header Code", "Product Header Description", "Link Product Header Code", "Link Product Header Description", <#"Sell Quantity", "Sell Quantity Is Quantity Ind", "Sell Quantity Is Units Ind","Auto Select Ind",#>
	"Product Link Type Code", "Product Link Type Description", "Auto Add To Cart Ind", "Default Option", <#"Display In Cart Ind", "Prompt",#> "Delete With Parent Only Ind", "Match Parent Quantity Ind" <#, "Special Logic Ind", "Display Order"#> | Export-Csv $OuputFile

[int]$LinesInFile = 0
$reader = New-Object IO.StreamReader "C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProduct-InvProduct\$((Get-Date).ToString('MM-dd-yyyy'))_150-LinkedProduct-InvProduct.csv"
 while($reader.ReadLine() -ne $null){ $LinesInFile++ }

If (Import-Csv C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProduct-InvProduct\$((Get-Date).ToString('MM-dd-yyyy'))_150-LinkedProduct-InvProduct.csv)
{ #Send SMTP Message
Send-MailMessage -From 'alsmith1@vailresorts.com' -To 'alsmith1@vailresorts.com' -Subject "$(Get-Date -Format MM-dd-yyyy) 150-LinkedProduct-InvProduct" -Body "Daily 150-LinkedProduct-InvProduct - $LinesInFile" -SmtpServer smtp.vailresorts.com -Attachments (get-childitem "C:\Users\alsmith1\Desktop\PowershellScripts\150-LinkedProduct-InvProduct").fullname
}