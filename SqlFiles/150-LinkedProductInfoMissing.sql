SELECT

	sphlink.product_header_code AS 'Product Header Code',
	sph.description AS 'Product Header Description',
	LEFT(sph.description,2) AS 'ResortAcronym' ,
	sph.active_ind AS 'Active',
	sph.display_ind AS 'Display',
	sph.display_order AS 'DisplayOrder',
	sphlink.link_product_header_code AS 'Link Product Header Code',
	sph1.description AS 'Link Product Header Description',
	sphlink.auto_add_to_cart_ind AS 'Auto Add To Cart Ind',
	sphlink.default_option AS 'Default Option',
	sphlink.delete_with_parent_only_ind AS 'Delete With Parent Only Ind'
	
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
AND sphlink.product_header_code NOT IN ('145740','147653','147654','148006','148007','148388','148389','148390','148391','149481','149483'/*,'96644'*/) -- Removed as no one over 3+ weeks has updated or removed - so I am just ignoring from now on*/
ORDER BY
	sphlink.product_header_code ,
	sph.display_order