USE rtpx2
GO

/*
Adam Smith
*/

SELECT
	/* tsas.access_code ,
	tsas.days ,
	tsdc.scan_date ,
	tsdc.scan_location_code ,
	slob.description LOB , */

	CASE WHEN slob.description LIKE 'Pass: Epic%DAY' THEN 'Pass: Epic'
	WHEN slob.description LIKE 'Pass: Epic%DAY LOCAL' THEN 'Pass: Epic Local' 
	ELSE slob.description END AS LOB ,

	sr.description Resort ,
	sph.primary_lob_code ,

	COUNT(CASE WHEN YEAR(tsdc.scan_DATE) = 2021 THEN 1 ELSE NULL END) AS '2020/21' ,
	COUNT(CASE WHEN YEAR(tsdc.scan_DATE) = 2022 THEN 1 ELSE NULL END) AS '2021/22' ,
	COUNT(CASE WHEN YEAR(tsdc.scan_DATE) = 2023 THEN 1 ELSE NULL END) AS '2022/23'

--,*
FROM t_scan_access_summary tsas
	JOIN t_scan_daily_summary tsdc
		ON tsas.access_code = tsdc.access_code
	JOIN t_access_detail tad
		ON tsas.access_code = tad.access_code AND tsdc.access_code = tad.access_code
	JOIN t_transaction_detail ttd
		ON tad.mr_transaction_id = ttd.mr_transaction_id AND tad.transaction_line_number = ttd.transaction_line_number AND ttd.pos_transaction_type_code NOT IN (2, 3, 99)
	JOIN s_product_header sph
		ON ttd.product_header_code = sph.product_header_code
	JOIN s_lob slob
		ON sph.primary_lob_code = slob.lob_code AND (slob.lob_summary_code IN (570,580,113) OR slob.lob_code IN (130,198,133,199,201,202,134,391,905,505)) AND slob.lob_code NOT IN (135,264) AND slob.description NOT LIKE 'Pass: epic%day%'	
	JOIN s_scan_location ssl
		ON tsdc.scan_location_code = ssl.scan_location_code
	JOIN s_resort sr
		ON ssl.resort_code = sr.resort_code
	WHERE 
		/* tsas.days > 0
		AND */
		 YEAR(tsdc.scan_date) >= 2021
    AND (
        (MONTH(tsdc.scan_date) = 6 AND DAY(tsdc.scan_date) >= 1)
        OR 
        (MONTH(tsdc.scan_date) > 6 AND MONTH(tsdc.scan_date) < 9)
        OR 
        (MONTH(tsdc.scan_date) = 9 AND DAY(tsdc.scan_date) <= 30)
    )

	--AND
	--NOT EXISTS (
	--	SELECT * FROM t_transaction_return TR
	--	WHERE TR.orig_mr_transaction_id = ttd.mr_transaction_id
	--	AND TR.orig_transaction_line_number = ttd.transaction_line_number
	--)

GROUP BY
	/* tsas.access_code ,
	tsas.days ,
	tsdc.scan_date ,
	tsdc.scan_location_code , */
	slob.description ,
	sr.description ,
	sph.primary_lob_code

ORDER BY
	sr.description ,
	slob.description 