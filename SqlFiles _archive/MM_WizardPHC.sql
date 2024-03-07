SELECT DISTINCT
	sph.display_category_code AS DispCatCode,
	sdc.description AS DispCat ,
	sph.product_header_code AS PHC, 
	sph.description AS PHCDescription ,
	sph.active_ind AS Active,
	sph.display_ind AS Display,
	sphmf.mm_function_code AS MMFC,
	ssf.description AS MMFunction ,
	CAST(sph.update_date AS DATE) AS Update_Date ,
	sdrpp.expiration_date AS Max_PHC_Date

FROM s_product_header_mm_function sphmf
	JOIN s_product_header sph
		ON sphmf.product_header_code = sph.product_header_code
	JOIN s_display_category sdc
		ON sph.display_category_code = sdc.display_category_code
	JOIN s_system_function ssf
		ON sphmf.mm_function_code = ssf.system_function_code
	JOIN s_date_range_product_price sdrpp
		ON sph.product_header_code = sdrpp.product_header_code AND sdrpp.expiration_date >= (GETDATE())
WHERE
CAST(sph.update_date AS DATE) <= GETDATE() - 547

AND (sph.active_ind = 'Y' AND sph.display_ind = 'Y')
						

AND sdc.active_ind = 'Y'
AND sph.price_by_season_ind = 'N'

UNION

SELECT DISTINCT
	sph.display_category_code AS DispCatCode ,
	sdc.description AS DispCat ,
	sph.product_header_code AS PHC , 
	sph.description AS PHCDescription ,
	sph.active_ind AS Active ,
	sph.display_ind AS Display ,
	sphmf.mm_function_code AS MMFC ,
	ssf.description AS MMFunction ,
	CAST(sph.update_date AS DATE) AS Update_Date ,
	MAX(psd.PricingSeasonDate) AS Max_PHC_Date 

FROM s_product_header_mm_function sphmf
	JOIN s_product_header sph
		ON sphmf.product_header_code = sph.product_header_code
	JOIN s_display_category sdc
		ON sph.display_category_code = sdc.display_category_code
	JOIN s_system_function ssf
		ON sphmf.mm_function_code = ssf.system_function_code
	JOIN s_season_product_price sspp
		ON sph.product_header_code = sspp.product_header_code
	JOIN PricingSeasonDate psd
		ON sspp.PricingSeasonCode = psd.PricingSeasonCode
WHERE
CAST(sph.update_date AS DATE) <= GETDATE() - 547

AND (sph.active_ind = 'Y' AND sph.display_ind = 'Y')

AND sdc.active_ind = 'Y'
AND sph.price_by_season_ind = 'Y'


GROUP BY
	sph.display_category_code ,
	sdc.description ,
	sph.product_header_code , 
	sph.description ,
	sph.active_ind ,
	sph.display_ind ,
	sphmf.mm_function_code ,
	ssf.description ,
	CAST(sph.update_date AS DATE) 

HAVING
	MAX(psd.PricingSeasonDate) >= (GETDATE())

ORDER BY 
	CAST(sph.update_date AS DATE) DESC