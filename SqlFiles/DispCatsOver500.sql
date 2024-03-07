/*
Adam Smith 10/7/23
Query TO stop users adding more than 500 PHCs TO a Display Category, which makes SOME PHCs NOT visible IN the UI
*/

SELECT 
	sdc.display_category_code ,
	sdc.description ,
	sdc.active_ind ,
	COUNT(sph.product_header_code) Num_PHCs

FROM s_display_category sdc
	JOIN s_product_header sph
		ON sdc.display_category_code = sph.display_category_code

WHERE
	sdc.display_category_code NOT IN (2121,2947,3861,4342,7078,8014,9006,9008,9026,9043,9070,9077,10999,12537,15691) 

GROUP BY
	sdc.display_category_code ,
	sdc.description ,
	sdc.active_ind

HAVING COUNT(sph.product_header_code) > 500
	
	