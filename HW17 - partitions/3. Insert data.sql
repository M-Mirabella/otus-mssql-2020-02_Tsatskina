INSERT INTO Sales.OrderLinesArchive 
SELECT ordl.OrderLineID,
       ord.OrderID,
	   ord.OrderDate,
	   ordl.StockItemID,	   
	   ordl.Description,
	   ordl.PackageTypeID,
	   ordl.Quantity,
	   ordl.UnitPrice,
	   ordl.TaxRate,
	   ordl.PickedQuantity,
	   ordl.PickingCompletedWhen,
	   ordl.LastEditedBy,
	   ordl.LastEditedWhen
FROM Sales.OrderLines ordl
INNER JOIN Sales.Orders ord on ord.OrderID = ordl.OrderID


INSERT INTO Sales.OrdersArchive
SELECT * 
FROM Sales.Orders;
