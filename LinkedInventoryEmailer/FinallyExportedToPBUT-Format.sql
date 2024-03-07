/* ---------------------------------
------ Product Header Link-5 -------
----------------------------------*/
SELECT
	PHL.product_header_code AS 'Product Header Code',
	PH.description AS 'Product Header Description',
	PHL.link_product_header_code AS 'Link Product Header Code',
	LPH.description AS 'Link Product Header Description',
	PHL.sell_quantity AS 'Sell Quantity',
	PHL.sell_quantity_is_quantity_ind AS 'Sell Quantity Is Quantity Ind',
	PHL.sell_quantity_is_units_ind AS 'Sell Quantity Is Units Ind',
	PHL.auto_select_ind AS 'Auto Select Ind',
	PHL.product_link_type_code AS 'Product Link Type Code',
	PLT.description AS 'Product Link Type Description',
	PHL.auto_add_to_cart_ind AS 'Auto Add To Cart Ind',
	PHL.default_option AS 'Default Option',
	PHL.display_in_cart_ind AS 'Display In Cart Ind',
	PHL.prompt AS 'Prompt',
	PHL.delete_with_parent_only_ind AS 'Delete With Parent Only Ind',
	PHL.match_parent_qty_ind AS 'Match Parent Quantity Ind',
	PHL.special_logic_ind AS 'Special Logic Ind',
	PHL.display_order AS 'Display Order'

FROM
	s_product_header_link PHL
	JOIN s_product_header PH
		ON PHL.product_header_code = PH.product_header_code
	JOIN s_product_header LPH
		ON PHL.link_product_header_code = LPH.product_header_code
	JOIN s_product_link_type PLT
		ON PHL.product_link_type_code = PLT.product_link_type_code
WHERE  
	-- Enter WHERE criteria below --
	ph.display_category_code = 1038
			-- End WHERE --

		ORDER BY
			PHL.product_link_type_code DESC,
			PHL.product_header_code ASC,			
			PHL.link_product_header_code ASC





