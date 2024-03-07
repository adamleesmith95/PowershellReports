SELECT DISTINCT
				sdc.display_order ,
				sdc.description AS 'DispCat',
				sph.product_header_code ,
				sph.description AS 'PHC',
				sph.active_ind AS 'PH_Status',
				sph.display_ind AS 'PH_Disp',
				sp.product_code ,
				sp.description AS 'Component',
				sp.active_ind AS 'PC_Status',
				sp.display_ind 'PC_Disp',
				sp.deferral_pattern_code AS 'DP_Code',
				sdp.description AS 'DefPattern',
				pdc.DeferralCalendarCode AS 'DefCalCode',
				dc.description AS 'DefCal',
				sp.operator_id AS 'operator' , 
				sp.update_date AS 'update_date'
				
				

FROM s_display_category sdc
JOIN s_product_header sph
ON sph.display_category_code = sdc.display_category_code
JOIN s_product_header_location sphl
ON sphl.product_header_code = sph.product_header_code
JOIN s_product sp
ON sp.product_code = sphl.product_code
JOIN s_deferral_pattern sdp
ON sp.deferral_pattern_code = sdp.deferral_pattern_code AND sp.deferral_pattern_code = 4

LEFT JOIN ProductDeferralCalendar pdc
JOIN DeferralCalendar dc
ON pdc.DeferralCalendarCode = dc.DeferralCalendarCode
ON sp.product_code = pdc.ProductCode


WHERE

pdc.DeferralCalendarCode IS NULL


ORDER BY
		sdc.display_order ,
		sph.product_header_code