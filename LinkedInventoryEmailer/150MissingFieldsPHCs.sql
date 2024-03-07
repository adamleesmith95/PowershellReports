SELECT

	sphlink.product_header_code AS 'Product Header Code',
	sph.description AS 'Product Header Description',
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
ORDER BY
	sphlink.product_header_code ,
	sph.display_order
		