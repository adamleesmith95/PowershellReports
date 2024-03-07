CREATE TABLE #DoubleVRR (
	DC_Code		int,
	DispCat		VARCHAR(40),
	DispOrder	int,
	PHC			VARCHAR(20),
	PHC_DESC	VARCHAR(40),
	PHC_DispOrder	int,
	Active		VARCHAR(2), 
	Displayed	VARCHAR(2),
	PC_DispOrder	INT,
	Component	VARCHAR(10), 
	PC_Desc		VARCHAR(40),
	SL_Code		int,
	SaleLoc		VARCHAR(MAX)
)

INSERT INTO #DoubleVRR 


SELECT
		sdc.display_category_code ,
		sdc.description ,
		sdc.display_order ,
		sph.product_header_code ,
		--COUNT(sph.product_header_code) AS Num_PHCs ,
		sph.description ,
		sph.display_order ,
		sph.active_ind , 
		sph.display_ind ,
		sph.display_order ,
		sp.product_code , 
		sp.description  ,
		sphl.sale_location_code ,
		sl.description


FROM s_product_header sph
	JOIN s_display_category sdc
		ON sph.display_category_code = sdc.display_category_code AND sdc.active_ind = 'Y'
		AND sdc.description NOT LIKE '%parking lot%' AND sdc.description NOT LIKE '%inactive%'
	JOIN s_product_header_location sphl
		ON sph.product_header_code = sphl.product_header_code AND sphl.sale_location_code IN (10,22)
		AND sph.display_order NOT IN (9999,99999,999999,9999999,99999999)
		AND (sph.active_ind != 'N' OR sph.display_ind != 'N')
	JOIN s_product sp
		ON sphl.product_code = sp.product_code
	JOIN s_location sl
		ON sphl.sale_location_code = sl.location_code
WHERE sp.product_code IN (

	SELECT DISTINCT vbpm.ResellerProductId
	FROM dbo.vrr_bundled_product_mapping vbpm

	)

SELECT 
	d.DC_Code				,
	d.DispCat				,
	d.DispOrder			,
	d.PHC					,
	--COUNT(d.PHC) AS NumComponents ,
	d.PHC_DESC			,
	d.PHC_DispOrder		,
	d.Active				,
	d.Displayed			,
	d.PC_DispOrder		,
	d.Component			,
	d.PC_Desc				,
	d.SL_Code				,
	d.SaleLoc				,
	v.VrrProductId ,
	v.VrrProductDescription ,
	v.LocationCode

FROM #DoubleVRR d
	JOIN vrr_bundled_product_mapping v
		ON d.Component = v.ResellerProductId

WHERE d.PHC IN (
			SELECT 
	d.PHC --,
	--COUNT(d.PHC) AS NumComponents --,
	--d.PHC_DESC

FROM #DoubleVRR d

--WHERE d.PHC = '112227'

GROUP BY
	d.PHC --,
	--d.PHC_DESC

HAVING
	COUNT(d.PHC) > 1
	
	
)

AND d.PHC NOT IN ('133041','133042','91418','91419','94620','95010','152646','152648','152647','152645') /*Park City/Canyon's multi-location components*/

DROP TABLE #DoubleVRR