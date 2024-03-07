/* Use this SQL first, along with 'FindOrdersWithMultipleInventoryLocations' */
CREATE TABLE #InvPoolTemp
(
	InvPool INT ,
	CountPool INT
)

INSERT INTO #InvPoolTemp

SELECT 
	a.InventoryPoolCode ,
	COUNT(DISTINCT iplip.InventoryPoolLocationCode)

	FROM
(
	SELECT DISTINCT 
		iplip.InventoryPoolCode
	FROM dbo.InventoryPoolLocationInventoryPool AS iplip  ( NOLOCK )
	JOIN dbo.InventoryPool i  ( NOLOCK )
		ON iplip.InventoryPoolCode = i.InventoryPoolCode
		AND i.StatusCode = '1'
	JOIN s_location sl ( NOLOCK )
		ON sl.location_code = iplip.InventoryPoolLocationCode
		/*WHERE i.description LIKE 'WB%'*/
		WHERE iplip.InventoryPoolCode NOT IN (105,107,1111,2790) /* Night, Paid, IT Test AND URR Locker Inv pools */
		AND sl.location_category_code NOT IN (40) /* Rental/VRR Locations*/ 
		AND i.InventoryPoolCode NOT IN (8053,8054,9998) /* KY ESK Inv Pools ARE AT BOTH bases deliberately 12/7/23 MCant + 9998 is Reservation Test */

) a

JOIN InventoryPoolLocationInventoryPool iplip ( NOLOCK )
	ON iplip.InventoryPoolCode = a.InventoryPoolCode



GROUP BY a.InventoryPoolCode
	


SELECT DISTINCT
	ivp.* ,
	i.Description InvPool
	,ipl.InventoryPoolLocationCode InvLocCode
	,sl.description Location
	,CAST(MAX(ipl.ExpirationDate) AS DATE) ExpirationDate
	,CAST(MAX(ipl.UpdateDate) AS DATE) UpdateDate
	

FROM #InvPoolTemp ivp ( NOLOCK )
	JOIN dbo.InventoryPool i
		ON ivp.InvPool = i.InventoryPoolCode
	JOIN dbo.InventoryPoolLocationInventoryPool ipl
		ON i.InventoryPoolCode = ipl.InventoryPoolCode
	JOIN s_location sl
		ON ipl.InventoryPoolLocationCode = sl.location_code 
WHERE ivp.CountPool > 1

GROUP BY
	InvPool ,
	CountPool ,
	i.Description 
	,ipl.InventoryPoolLocationCode
	,sl.description
	,sl.location_category_code



DROP TABLE #InvPoolTemp