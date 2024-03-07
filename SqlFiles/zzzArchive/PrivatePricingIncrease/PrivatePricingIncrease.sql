/* 9/7/23 alsmith1 - TABLE created TO ADD multiple LOB VALUES INTO somewhat OF a DECLARE/SET scenario - so you don't have TO ADD/adjust it FOR every UNION WHERE statement */
CREATE TABLE #LOBtable (VALUE INT)
INSERT INTO #LOBtable (VALUE) VALUES (205)
INSERT INTO #LOBtable (VALUE) VALUES (215)
INSERT INTO #LOBtable (VALUE) VALUES (301)
INSERT INTO #LOBtable (VALUE) VALUES (302)

IF OBJECT_ID(N'dbo.#LOBtable', N'U') IS NOT NULL
    DROP TABLE #LOBtable

DECLARE @ActiveInd VARCHAR = 'N'
DECLARE @DisplayInd VARCHAR = 'N'
DECLARE @DisplayOrder int = 9999
DECLARE @EffectiveDate DATE = '2023-07-01'

/*
Adam Smith
*/
/*This this was the start OF the Privates Pricing updates report, WHERE it recorded WHERE a change IN pricing was made
	outside OF the normal increase/decrease Of pricing seasons */

/* DATE Range Product Price TABLE */
SELECT 
	'DR' PricingType,
	sph.primary_lob_code LOB ,
	sph.display_category_code ,
	sdrpp.product_header_code PHC ,
	sph.description ProductHeader,
	sph.active_ind PHC_active,
	sph.display_ind PHC_display,
	sph.display_order ,
	sdrpp.product_code PC ,
	sp.description Component ,
	sp.active_ind PC_active,
	sp.display_ind PC_display,
	'PricingSeason' AS PricingSeason ,
	CAST(sdrpp.effective_date AS DATE) effective_date ,
	CAST(sdrpp.expiration_date AS DATE) expiration_date ,
	sdrpp.price ,
	'DR' AS SaleLocation

FROM s_date_range_product_price sdrpp
	JOIN s_product sp
		ON sdrpp.product_code = sp.product_code
	JOIN s_product_header sph
		ON sdrpp.product_header_code = sph.product_header_code

WHERE
	sph.primary_lob_code IN ( SELECT VALUE FROM #LOBtable)
	AND (sph.active_ind != @ActiveInd OR sph.display_ind != @DisplayInd)
	AND sph.display_order NOT IN (@DisplayOrder)
	AND CAST(sdrpp.effective_date AS DATE) > @EffectiveDate

UNION

/* DATE Range Product Price BY Location TABLE */


SELECT
	'DRL' ,
	sph.primary_lob_code LOB ,
	sph.display_category_code ,
	sdrlpp.product_header_code PHC ,
	sph.description ProductHeader,
	sph.active_ind ,
	sph.display_ind ,
	sph.display_order ,
	sdrlpp.product_code PC ,
	sp.description Component ,
	sp.active_ind ,
	sp.display_ind ,
	'PricingSeason' ,
	CAST(sdrlpp.effective_date AS DATE) effective_date ,
	CAST(sdrlpp.expiration_date AS DATE) expiration_date ,
	sdrlpp.price ,
	CAST(sdrlpp.sale_location_code AS nvarchar) + ' - ' + sl.description 

FROM s_date_range_location_product_price sdrlpp
	JOIN s_product sp
		ON sdrlpp.product_code = sp.product_code
	JOIN s_product_header sph
		ON sdrlpp.product_header_code = sph.product_header_code
	JOIN s_location sl
		ON sdrlpp.sale_location_code = sl.location_code
		
WHERE
	sph.primary_lob_code IN ( SELECT VALUE FROM #LOBtable)
	AND (sph.active_ind != @ActiveInd OR sph.display_ind != @DisplayInd)
	AND sph.display_order NOT IN (@DisplayOrder)
	AND CAST(sdrlpp.effective_date AS DATE) > @EffectiveDate

UNION

/* Season Product Price TABLE */

SELECT
	'PS' ,
	sph.primary_lob_code LOB ,
	sph.display_category_code ,
	sspp.product_header_code PHC ,
	sph.description ProductHeader,
	sph.active_ind ,
	sph.display_ind ,
	sph.display_order ,
	sspp.product_code PC ,
	sp.description Component ,
	sp.active_ind ,
	sp.display_ind ,
	ps.Description PricingSeason,
	MIN(CAST(psd.PricingSeasonDate AS DATE)) effective_date ,
	MAX(CAST(psd.PricingSeasonDate AS DATE)) expiration_date ,
	sspp.price ,
	'PS' AS SaleLocation

FROM s_season_product_price sspp
	JOIN s_product sp
		ON sspp.product_code = sp.product_code
	JOIN s_product_header sph
		ON sspp.product_header_code = sph.product_header_code
	JOIN PricingSeasonDate psd
		ON sspp.PricingSeasonCode = psd.PricingSeasonCode
	JOIN PricingSeason ps
		ON sspp.PricingSeasonCode = ps.PricingSeasonCode
		
WHERE
	sph.primary_lob_code IN ( SELECT VALUE FROM #LOBtable)
	AND (sph.active_ind != @ActiveInd OR sph.display_ind != @DisplayInd)
	AND sph.display_order NOT IN (@DisplayOrder)
	
GROUP BY
	sph.primary_lob_code ,
	sph.display_category_code ,
	sspp.product_header_code ,
	sph.description ,
	sph.active_ind ,
	sph.display_ind ,
	sph.display_order ,
	sspp.product_code ,
	sp.description ,
	sp.active_ind ,
	sp.display_ind ,
	ps.Description ,
	sspp.price

HAVING
	MIN(CAST(psd.PricingSeasonDate AS DATE)) > @EffectiveDate


	UNION

/* Season Product Price BY Location TABLE */

SELECT
	'PSL' ,
	sph.primary_lob_code LOB ,
	sph.display_category_code ,
	sslpp.product_header_code PHC ,
	sph.description ProductHeader,
	sph.active_ind ,
	sph.display_ind ,
	sph.display_order ,
	sslpp.product_code PC ,
	sp.description Component ,
	sp.active_ind ,
	sp.display_ind ,
	ps.Description PricingSeason,
	MIN(CAST(psd.PricingSeasonDate AS DATE)) effective_date ,
	MAX(CAST(psd.PricingSeasonDate AS DATE)) expiration_date ,
	sslpp.price ,
	CAST(sslpp.sale_location_code AS nvarchar) + ' - ' + sl.description


FROM s_season_location_product_price sslpp
	JOIN s_product sp
		ON sslpp.product_code = sp.product_code
	JOIN s_product_header sph
		ON sslpp.product_header_code = sph.product_header_code
	JOIN PricingSeasonDate psd
		ON sslpp.PricingSeasonCode = psd.PricingSeasonCode
	JOIN  s_location sl
		ON sslpp.sale_location_code = sl.location_code
	JOIN PricingSeason ps
		ON sslpp.PricingSeasonCode = ps.PricingSeasonCode
		
WHERE
	sph.primary_lob_code IN ( SELECT VALUE FROM #LOBtable)
	AND (sph.active_ind != @ActiveInd OR sph.display_ind != @DisplayInd)
	AND sph.display_order NOT IN (@DisplayOrder)
	
	

GROUP BY
	sph.primary_lob_code ,
	sph.display_category_code ,
	sslpp.product_header_code ,
	sph.description ,
	sph.active_ind ,
	sph.display_ind ,
	sph.display_order ,
	sslpp.product_code ,
	sp.description ,
	sp.active_ind ,
	sp.display_ind ,
	ps.Description ,
	sslpp.price ,
	CAST(sslpp.sale_location_code AS nvarchar) + ' - ' + sl.description

HAVING
	MIN(CAST(psd.PricingSeasonDate AS DATE)) > @EffectiveDate


ORDER BY
	1 , /* PricingType , */
	3, /* sph.display_category_code , */
	8, /* sph.display_order , */
	9,/* sslpp.product_code , */
	12, /* effective_date , */
	15 /* CAST(sslpp.sale_location_code AS nvarchar) + ' - ' + sl.description */


DROP TABLE #LOBtable