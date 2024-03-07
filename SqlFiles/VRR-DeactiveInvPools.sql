SELECT
	i.InventoryPoolCode ,
	i.StatusCode ,
	i.Description ,
	i.OperatorID ,
	i.UpdateDate
FROM InventoryPool i
WHERE i.Description LIKE 'VRR%'
AND i.StatusCode = 2