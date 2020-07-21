SELECT *
FROM Sales.OrderLinesArchive ordl_a
INNER JOIN Sales.OrdersArchive ord_a
           on ord_a.OrderID = ordl_a.OrderID and ord_a.OrderDate = ordl_a.OrderDate


SELECT *
FROM Sales.OrderLinesArchive ordl_a
INNER JOIN Sales.OrdersArchive ord_a
           on ord_a.OrderID = ordl_a.OrderID and ord_a.OrderDate = ordl_a.OrderDate
WHERE ordl_a.OrderDate between '2013-01-01' and '2013-12-31'

-- —оотношение производительности двух верхних запросов 75/25.
-- Ќо во втором запросе и данных в несколько раз меньше.

SELECT *
FROM Sales.OrderLines ordl
INNER JOIN Sales.Orders ord
           on ord.OrderID = ordl.OrderID 
WHERE ord.OrderDate between '2013-01-01' and '2013-12-31'

-- ј здесь соотношение 15 к 85 %. 
-- ѕартиционирование показало хороший результат!