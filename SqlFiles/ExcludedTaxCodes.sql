SELECT
	s.tax_code ,
	s.description ,
	s.active_ind ,
	s.display_order ,
	s.receipt_label ,
	s.ExcludeCommissionFromCalculation ,
	s.operator_id ,
	s.update_date
FROM s_tax s
WHERE s.tax_code IN (12,30,50)
AND s.ExcludeCommissionFromCalculation != 1