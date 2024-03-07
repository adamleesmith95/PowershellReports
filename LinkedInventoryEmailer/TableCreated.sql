

CREATE TABLE #InventoriedLinkedProducts
(	sale_product_header_code varchar(10) NULL,
	sale_product_header_description varchar(40) NULL,
	linked_product_header_code varchar(10) NULL,
	--ordered_product_header_code varchar(10) NULL,
	linked_product_header_description varchar(40) NULL,
	inventoried_product_code varchar(10) NULL,
	inventoried_product_code_description varchar(40) NULL
)

INSERT INTO #InventoriedLinkedProducts (sale_product_header_code, sale_product_header_description, linked_product_header_code, linked_product_header_description) 

SELECT
  f1.product_header_code, F1.description, f1.link_product_header_code, F1.LinkedDescription--, f3.col5, f4.col6, f5.col7
FROM
	(
		SELECT DISTINCT
			PH.product_header_code 
			, 	PH.description ,
			--PH.active_ind ,
			--PH.display_ind ,
			--PH.display_order ,
			--PHL.product_link_type_code ,
			--PHL.auto_add_to_cart_ind ,
			--PHL.default_option ,
			PHL.link_product_header_code 
			, PH1.description AS LinkedDescription

			FROM s_product_header_link PHL
				JOIN s_product_header PH
				ON PHL.product_header_code = PH.product_header_code AND (PH.active_ind != 'N' OR PH.display_ind != 'N')
				JOIN s_product_header PH1
				ON PHL.link_product_header_code = PH1.product_header_code
			WHERE PHL.product_link_type_code = 150 
			AND (PHL.auto_add_to_cart_ind = 'Y' OR PHL.default_option = '1')

		) as F1
	SELECT 

	
	
	SELECT * FROM #InventoriedLinkedProducts
	DROP TABLE #InventoriedLinkedProducts