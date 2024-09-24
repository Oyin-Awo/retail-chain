-- Total number of Products sold in each store
SELECT FSA.StoreSK, DS.StoreName, SUM(Quantity) QuantityOfProductsSold
FROM EDW.factSalesAnalysis FSA 
JOIN EDW.DimStore DS ON FSA.StoreSk = DS.StoreID
group by FSA.StoreSk, StoreName
order by StoreName


--Total sales made per month, per year, in each store.
SELECT 
	DS.StoreName
	, SUM(FSA.LineAmount) TotalSales 
	, YEAR(DD.BusinessDate) AS SalesYear
	, DD.EnglishMonth AS SalesMonth
FROM TescaEDW.EDW.factSalesAnalysis FSA 
JOIN TescaEDW.EDW.DimDate DD ON FSA.TransDateSk = DD.dateSk
JOIN EDW.DimStore DS ON FSA.StoreSk = DS.StoreSK
GROUP BY DS.StoreName, YEAR(DD.BusinessDate), DD.EnglishMonth
ORDER BY ds.StoreName, SalesYear, DD.EnglishMonth


--What are the most ordered products from each vendor in each store.
	--Total quantity of products ordered from each vendor in each store.
SELECT 
	DP.ProductSK
	, DS.StoreName
	, DV.Vendor
	, DP.Product
	, SUM(Quantity) QuantityOrdered
FROM EDW.FactPurchaseAnalysis FPA
JOIN EDW.DimStore DS ON FPA.StoreSk = DS.StoreSK
JOIN EDW.DimVendor DV ON FPA.VendorSk = DV.VendorSK
JOIN EDW.DimProduct DP ON FPA.ProductSk = DP.ProductSK
GROUP BY DP.ProductSK, DS.StoreName, DV.Vendor, DP.Product
ORDER BY DS.StoreName, DV.Vendor


--Most efficient vendors based on their delivery times
Select FPA.VendorSK, DV.Vendor VendorName
, FLOOR(AVG(DifferentialDays)) AverageDeliveryTime
FROM EDW.FactPurchaseAnalysis FPA
JOIN EDW.DimVendor DV ON FPA.VendorSk = DV.VendorSK
GROUP BY FPA.VendorSk, DV.Vendor
ORDER BY AverageDeliveryTime


