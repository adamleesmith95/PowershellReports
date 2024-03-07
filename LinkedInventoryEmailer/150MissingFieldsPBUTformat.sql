SELECT
	--sph.active_ind , 
	--sph.display_ind , 


	sphlink.product_header_code AS 'Product Header Code',
	sph.description AS 'Product Header Description',
	sphlink.link_product_header_code AS 'Link Product Header Code',
	sph1.description AS 'Link Product Header Description',
	sphlink.sell_quantity AS 'Sell Quantity',
	sphlink.sell_quantity_is_quantity_ind AS 'Sell Quantity Is Quantity Ind',
	sphlink.sell_quantity_is_units_ind AS 'Sell Quantity Is Units Ind',
	sphlink.auto_select_ind AS 'Auto Select Ind',
	sphlink.product_link_type_code AS 'Product Link Type Code',
	splt.description AS 'Product Link Type Description',
	sphlink.auto_add_to_cart_ind AS 'Auto Add To Cart Ind',
	sphlink.default_option AS 'Default Option',
	sphlink.display_in_cart_ind AS 'Display In Cart Ind',
	sphlink.prompt AS 'Prompt',
	sphlink.delete_with_parent_only_ind AS 'Delete With Parent Only Ind',
	sphlink.match_parent_qty_ind AS 'Match Parent Quantity Ind',
	sphlink.special_logic_ind AS 'Special Logic Ind',
	sphlink.display_order AS 'Display Order'

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
--AND (sphlink.auto_add_to_cart_ind = 'Y' OR sphlink.default_option = '1')
--AND sph.CurrencyCode = '2'
ORDER BY
	sphlink.product_header_code ,
	sph.display_order
		