SELECT DISTINCT
	spip.product_code 
	--, spip.InventoryPoolCode
	
FROM s_product_header_location sphl
	JOIN s_product_inventory_pool spip
	ON sphl.product_code = spip.product_code

WHERE sphl.product_header_code IN

	(
	
		SELECT DISTINCT
			PH.product_header_code 
			--, 	PH.description ,
			--PH.active_ind ,
			--PH.display_ind ,
			--PH.display_order ,
			--PHL.product_link_type_code ,
			--PHL.auto_add_to_cart_ind ,
			--PHL.default_option ,
			--PHL.link_product_header_code 
			--, PH1.description

		FROM s_product_header_link PHL
			JOIN s_product_header PH
			ON PHL.product_header_code = PH.product_header_code AND (PH.active_ind != 'N' OR PH.display_ind != 'N')
			JOIN s_product_header PH1
			ON PHL.link_product_header_code = PH1.product_header_code
		WHERE PHL.product_link_type_code = 150 
		AND (PHL.auto_add_to_cart_ind = 'Y' OR PHL.default_option = '1')

	)
	AND spip.InventoryPoolCode IS NOT NULL