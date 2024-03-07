SELECT

	tth.pos_transaction_id ,
	CAST(tth.sale_date AS DATE) sale_date ,
	sl.description + ' (' + CAST(tth.sale_location_code AS VARCHAR) + ')' SaleLocation,
	tth.pos_code ,
	sptt.description ,
	ttd.transaction_line_number tran_line ,
	ttdi.ip_number ,
	i.DisplayName ,
	ttd.product_header_code PHC ,
	sph.description ,
	CAST(ttd.product_date AS DATE) product_date ,
	ttd.quantity ,
	tad.access_code ,
	CAST(tad.effective_date AS DATE) effective_date ,
	CAST(tad.expiration_date AS DATE) expiration_date ,
	CONVERT(VARCHAR(50), CONCAT('*',tad.access_code, '*')) AS barcode

FROM t_transaction_header tth
	JOIN t_transaction_detail ttd
		ON tth.mr_transaction_id = ttd.mr_transaction_id
	JOIN t_product_detail tpd
		ON tth.mr_transaction_id = tpd.mr_transaction_id AND ttd.transaction_line_number = tpd.transaction_line_number
	JOIN t_access_detail tad
		ON tth.mr_transaction_id = tad.mr_transaction_id AND ttd.transaction_line_number = tad.transaction_line_number AND tpd.product_line_number = tad.product_line_number
	JOIN s_product_header sph
		ON ttd.product_header_code = sph.product_header_code
	JOIN t_transaction_detail_ip ttdi
		ON ttd.mr_transaction_id = ttdi.mr_transaction_id AND ttd.transaction_line_number = ttdi.transaction_line_number
	JOIN ip i
		ON ttdi.ip_number = i.IPCode
	JOIN s_location sl
		ON tth.sale_location_code = sl.location_code
	JOIN s_pos_transaction_type sptt
		ON ttd.pos_transaction_type_code = sptt.pos_transaction_type_code
	JOIN s_product_prompt spp
		ON sph.product_header_code = spp.product_header_code AND spp.prompt_code NOT IN (555,888,3001)
	JOIN s_product sp
		ON tpd.product_code = sp.product_code
	JOIN s_lift_product_profile slpp
		ON tpd.product_code = slpp.product_code AND slpp.load_to_media_ind = 'N'
	JOIN s_scan_type sst
		ON LEFT(tad.access_code,3) = sst.scan_type_code AND sst.scan_category_code NOT IN (325,120)


	
WHERE CAST(ttd.product_date AS DATE) >= CAST(GETDATE() -1 AS DATE)
AND
	NOT EXISTS (
		SELECT * FROM t_transaction_return TR
		WHERE TR.orig_mr_transaction_id = ttd.mr_transaction_id
		AND TR.orig_transaction_line_number = ttd.transaction_line_number
		)
AND sph.CurrencyCode = '2'
AND ttd.pos_transaction_type_code != 3

ORDER BY tth.pos_transaction_id
