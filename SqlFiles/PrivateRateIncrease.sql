/* 
	Adding the price BY season & location pricing type
*/
DECLARE @SRSStartDate AS DATE = '2023-11-01'


SELECT 

	sdc.description AS DisplayCategory,
	sph.product_header_code AS ProductHeaderCode,
	sph.description AS ProductHeader,
	sph.display_order AS PHOrder ,
	CONVERT(DATE,psd.PricingSeasonDate) AS effective_date,
	sslpp.price ,
	CAST(sslpp.sale_location_code AS VARCHAR) sale_location_code ,
	sloc.description SaleLoc


FROM s_season_location_product_price sslpp

	JOIN s_location sloc
		ON sslpp.sale_location_code = sloc.location_code

	JOIN s_product_header sph ( NOLOCK )
	ON sslpp.product_header_code = sph.product_header_code

	JOIN dbo.s_display_category sdc ( NOLOCK )
	ON sph.display_category_code = sdc.display_category_code

	JOIN PricingSeasonDate psd
		ON sslpp.PricingSeasonCode = psd.PricingSeasonCode

	JOIN s_lob sl
		ON sph.primary_lob_code = sl.lob_code AND sl.lob_summary_code = 205 /* Privates */

	


WHERE
	CONVERT(DATE,psd.PricingSeasonDate) >= @SRSStartDate
	AND sdc.active_ind = 'Y'
	AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
	AND sdc.description NOT LIKE '%parking lot%'
	AND sdc.description NOT LIKE '%inactive%'
	AND sdc.description NOT LIKE '%hold%'
	AND sph.product_header_code IN ('167227','167225','167218','167221','167228','167949','167219','167951','167226','167222','167201','167220','97559','97560','97558','97547','97548','97546','11176','11168','61105','11170','78097','11122','11125','61099','11127','78098','128230','128231','128232','128227','128228','128229','51412','51403','51406','51516','51503','51506','79402','71863','71865','71870','79391','71832','71833','71836','11308','11302','11305','62442','11297','11299','66785','66882','66883','66772','66862','66863','77832','77921','77927','77676','77735','77811','97553','97554','97552','97541','97542','97540','106472','106480','106484','102933','106317','106384')
	AND sloc.description NOT LIKE 'VRR:%'
	AND sloc.location_code NOT IN (26010)



UNION ALL


/* 
	Unioning the price BY season pricing type
*/

SELECT 

	sdc.description AS DisplayCategory,
	sph.product_header_code AS ProductHeaderCode,
	sph.description AS ProductHeader,
	sph.display_order AS PHOrder ,
	CONVERT(DATE,psd.PricingSeasonDate) AS effective_date,
	sspp.price ,
	'N/A' AS sale_location_code ,
	'N/A' AS SaleLoc


FROM s_product_header sph ( NOLOCK )

	JOIN s_season_product_price sspp ( NOLOCK )
	ON sph.product_header_code = sspp.product_header_code

	JOIN dbo.s_display_category sdc ( NOLOCK )
	ON sph.display_category_code = sdc.display_category_code

	JOIN PricingSeasonDate psd
		ON sspp.PricingSeasonCode = psd.PricingSeasonCode

	JOIN s_product sp ( NOLOCK )
	ON sspp.product_code = sp.product_code

	LEFT JOIN s_product_tax spt ( NOLOCK )
	ON sp.product_code = spt.product_code

	LEFT JOIN s_tax stax  ( NOLOCK )
	ON spt.tax_code = stax.tax_code

	JOIN s_lob sl
		ON sph.primary_lob_code = sl.lob_code AND sl.lob_summary_code = 205 /* Privates */


WHERE
	CONVERT(DATE,psd.PricingSeasonDate) >= @SRSStartDate
	AND sdc.active_ind = 'Y'
	AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
	AND sdc.description NOT LIKE '%parking lot%'
	AND sdc.description NOT LIKE '%inactive%'
	AND sdc.description NOT LIKE '%hold%'
	AND sph.product_header_code IN ('167227','167225','167218','167221','167228','167949','167219','167951','167226','167222','167201','167220','97559','97560','97558','97547','97548','97546','11176','11168','61105','11170','78097','11122','11125','61099','11127','78098','128230','128231','128232','128227','128228','128229','51412','51403','51406','51516','51503','51506','79402','71863','71865','71870','79391','71832','71833','71836','11308','11302','11305','62442','11297','11299','66785','66882','66883','66772','66862','66863','77832','77921','77927','77676','77735','77811','97553','97554','97552','97541','97542','97540','106472','106480','106484','102933','106317','106384')



/* 
	Ordering BY so that the result SETs always RETURN the same way WHEN running the compare PS1 script against the 2 days
*/

ORDER BY
		sdc.description ,
		sph.display_order,
		sph.product_header_code ,
		effective_date ,
		price ,
		Saleloc

