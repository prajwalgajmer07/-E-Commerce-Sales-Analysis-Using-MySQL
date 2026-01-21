use ecommerce_project;
-- 1. General Sales Insights 
-- 1.1 What is the total revenue generated over the entire period? 
SELECT sum(OD.quantity*P.price) AS total_revenue 
From Orderdetails OD 
JOIN products p on p.ProductID = OD.productID;

-- 1.2 Revenue Excluding Returned Orders
SELECT sum(OD.quantity*P.price) AS Revenue_Excluding_Returns 
From Orders O 
JOIN orderdetails OD on O.orderId = OD.OrderID
JOIN Products P on P.productId = OD.ProductID
where O.IsReturned = False;
 
-- 1.3 Total Revenue per Year / Month 
SELECT year(OrderDate)AS "Year",
		month(Orderdate) AS "Month",
        SUM(OD.Quantity*P.Price) AS MonthlyRevenue
FROM orders O
JOIN Orderdetails OD on OD.OrderID = O.OrderID
JOIN products P on P.ProductID = OD.ProductID
GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY YEAR(O.OrderDate), MONTH(O.OrderDate);

-- 1.4 Revenue by Product / Category 
SELECT ProductName,Category,SUM(OD.Quantity * P.Price) AS ProductRevenue
FROM Products P
JOIN orderdetails OD on OD.ProductID = OD.ProductID
GROUP BY ProductName,category
ORDER BY category,ProductRevenue DESC;

-- 1.5 What is the average order value (AOV) across all orders? (AOV = Total Revenue/numbers of orders
SELECT AVG(TotalOrderValue) AS AverageOrderValue 
FROM (SELECt O.orderId,SUM(OD.quantity*p.price) AS TotalOrderValue 
FROM Orders O 
JOIN orderdetails OD on OD.orderId = O.OrderID
JOIN products P on P.ProductID = OD.productID
GROUP BY o.orderID) T;

-- 1.6 AOV per Year / Month 
SELECT YEAR(OrderDate) AS 'year',
		MONTH(orderDate) AS 'month',
        AVG(TotalOrderValue) AS AverageOrderValue
From (SELECt O.orderId,O.OrderDate, SUM(OD.quantity*p.price) AS TotalOrderValue 
		FROM Orders O 
		JOIN orderdetails OD on OD.orderId = O.OrderID
		JOIN products P on P.ProductID = OD.productID
		GROUP BY o.orderID) AS T
GROUP BY YEAR(T.OrderDate), MONTH(T.OrderDate)
ORDER BY YEAR(T.OrderDate), MONTH(T.OrderDate);

-- 1.7 What is the average order size by region? 
SELECT RegionName,AVG(Total_order_size) AS average_order_size
FROM(SELECT O.orderID,C.regionID,SUM(OD.Quantity) As total_order_size
		FROM orders O
		JOIN customers C on C.customerId = O.customerId
		JOIN orderdetails OD on OD.OrderID = O.OrderID
		GROUP BY O.OrderID,C.RegionID) AS OrderSize 
JOIN Regions R on R.RegionId = OrderSize.RegionId
Group by RegionName
ORDER BY average_Order_size DESC;

-- 2. Customer Insights 
-- 2.1 Who are the top 10 customers by total revenue spent? 
SELECT C.customerId, CustomerName, SUM(OD.Quantity * P.price) AS TotalRevenue
FROM customers C 
JOIN orders O ON O.CustomerID = C.CustomerID
JOIN orderdetails OD ON OD.OrderID = O.OrderID
JOIN Products P ON P.productID = OD.ProductID
GROUP BY C.CustomerID,CustomerName
ORDER BY TotalRevenue DESC
LIMIT 10;

-- 2.2 What is the repeat customer rate? 
-- [Repeat Customers Rate = Customer with more than 1 order/Customer with atleast 1 order)]
SELECT ROUND(COUNT(DISTINCT CASE WHEN OrderCount > 1 THEN CustomerId END)/COUNT(DISTINCT CustomerID),2) AS repeat_customer_rate
FROM (SELECT CustomerID, COUNT(OrderId) AS OrderCount
	FROM orders
    GROUP BY CustomerID) AS T;

-- 2.3 What is the average time between two consecutive orders for the same customer Region-wise?
WITH RankedOrders AS(
	SELECT O.customerId, O.OrderDate,C.regionID,
		ROW_NUMBER() OVER (PARTITION BY O.customerId ORDER BY O.orderdate) As rn
	FROM Orders O 
    JOIN Customers C on C.CustomerID = o.customerId
),
OrderPairs AS(
	SELECT curr.customerId, Curr.RegionId, datediff(curr.orderdate, Prev.OrderDate) AS DaysBetween
    FROM RankedOrders Curr
    JOIN RankedOrders Prev ON curr.customerId = prev.customerId AND curr.rn = Prev.rn + 1
),
Region AS(
	SELECT CustomerId,RegionName,DaysBetween
    FROM OrderPairs OP
    JOIN Regions R ON R.RegionId = OP.RegionId
)
SELECT RegionName,ROUND(AVG(DaysBetween),2) AS AvgDaysBetween
FROM Region
GROUP BY RegionName
ORDER BY AvgDaysBetween;

-- 2.4 Customer Segment (based on total spend)  	
-- 	Platinum: Total Spend > 1500 ,Gold: 1000–1500 ,Silver: 500–999 ,Bronze: < 500 
WITH CustomerSpend AS(
	SELECT o.customerId, SUM(OD.quantity * p.price) As TotalSpend
    FROM Orders O
    JOIN orderdetails OD ON OD.OrderID = O.orderId
    JOIN products P ON p.productId = OD.ProductID
    GROUP BY O.customerId
)
SELECT CustomerName,
		CASE
			WHEN TotalSpend > 1500 THEN "Platinum"
            WHEN TotalSpend BETWEEN 1000 AND 1500 THEN "Gold"
            WHEN TotalSpend < 500 THEN "Bronze"
		END AS segment
FROM CustomerSpend CS
JOIN customers C ON C.CustomerID = CS.customerId;

-- 2.5 What is the customer lifetime value (CLV)? 
-- [CLV(Customer Lifetime Value) = Total Revenue Per Customer]
SELECT C.customerId, C.customerName, SUM(OD.quantity * p.price) AS CLV
FROM customers C
JOIN Orders O ON O.customerId = C.CustomerID
JOIN orderdetails OD ON OD.OrderId = O.orderId 
JOIN Products P On P.productId = OD.ProductID
GROUP BY C.CustomerID , C.CustomerName
ORDER BY CLV DESC;


-- 3.	Product & Order Insights
-- 3.1.	What are the top 10 most sold products (by quantity)?
SELECT P.ProductID, P.ProductName,SUM(OD.quantity) AS TotalQuantity
From orderdetails OD
JOIN products P ON OD.ProductID = P.ProductID
GROUP BY ProductID,ProductName
ORDER BY TotalQuantity DESC
Limit 10;

-- 3.2.	What are the top 10 most sold products (by revenue)?
SELECT P.ProductID, P.ProductName,SUM(OD.quantity *P.price) AS TotalRevenue
From orderdetails OD
JOIN products P ON OD.ProductID = P.ProductID
GROUP BY ProductID,ProductName
ORDER BY TotalRevenue DESC
Limit 10;

-- 3.3.	Which products have the highest return rate?
-- [Return Rate = (Returned Quantity)/ Total Quantity]
WITH SOLD AS (
			SELECT ProductId,SUM(Quantity) AS TotalQuantity
			FROM orderdetails
			GROUP BY ProductID
),
RETURNED AS(
		SELECT ProductId,SUM(Quantity) AS TotalQuantityReturned
		FROM orderdetails OD
		JOIN orders O ON OD.OrderID = O.OrderID
		WHERE IsReturned = 1 
		GROUP BY ProductID
)
SELECT ProductName, ROUND((TotalQuantityReturned/TotalQuantity),2) AS ReturnRate
From Products P 
JOIN Sold S ON S.ProductId = P.ProductId
JOIN Returned R ON R.ProductId = P.ProductId
ORDER BY ReturnRate DESC
LIMIT 10;

-- 3.4.	Return Rate by Category
WITH SOLD AS (
			SELECT Category,SUM(Quantity) AS TotalQuantity
			FROM orderdetails OD
            JOIN products P ON OD.ProductID = P.ProductID
			GROUP BY Category
),
RETURNED AS(
		SELECT Category,SUM(Quantity) AS TotalQuantityReturned
		FROM orderdetails OD
		JOIN Products P ON p.productID = OD.productID
        JOIN products P ON OD.ProductID = P.ProductID
		WHERE IsReturned = 1 
		GROUP BY Category
)
SELECT S.Category, ROUND((TotalQuantityReturned/TotalQuantity),2) AS ReturnRate
From Sold AS S
JOIN Returned R ON R.Category = S.Category
ORDER BY ReturnRate DESC
LIMIT 10;

-- 3.5.	What is the average price of products per region?[Avg Price = Total Revenue/Total Quantity]
SELECT RegionName,ROUND(SUM(OD.quantity*P.price) / SUM(OD.quantity),2) AS AvgPrice
FROM orders O 
JOIN customers C ON C.customerID = O.customerId
JOIN Regions R ON R.RegionID = C.RegionID
JOIN orderdetails OD ON OD.OrderID = O.OrderID
JOIN Products P ON p.productId = OD.ProductID
GROUP BY RegionName
ORDER BY AvgPrice DESC;

-- 3.6.	What is the sales trend for each product category?
SELECT DATE_FORMAT(OrderDate,"%Y-m%") AS Period, Category,SUM(OD.Quantity*P.Price) As Revenue
FROM orders O 
JOIN orderdetails OD ON OD.OrderID = O.OrderID
JOIN Products P ON P.ProductId = OD.ProductID
GROUP BY Period, Category
ORDER BY Period, category,Revenue Desc;



-- 4.	Temporal Trends
-- 4.1.	What are the monthly sales trends over the past year?
SELECT YEAR(OrderDate) AS 'year',
		MONTH(orderDate) AS 'Month',
        SUM(OD.Quantity *P.Price) AS Revenue
FROM orders O
JOIN orderdetails OD ON OD.orderID = O.OrderID
JOIN products P ON P.ProductId = OD.ProductID
WHERE orderdate >= CURRENT_DATE() - INTERVAL 12 MONTH
GROUP BY YEAR(O.orderdate),MONTH(O.OrderDate)
ORDER BY YEAR(O.orderdate),MONTH(O.OrderDate);


-- 4.2.	How does the average order value (AOV) change by month ?
SELECT DATE_FORMAT(OrderDate, "%Y-m%") AS Period,
		ROUND(SUM(OD.Quantity*Price) / COUNT(DISTINCT O.orderID),2) AS AOV
FROM Orders O 
JOIN orderdetails OD ON OD.orderID = O.OrderID
JOIN products P ON P.ProductId = OD.ProductID
GROUP BY Period
ORDER BY Period;

-- 5.	Regional Insights
-- 5.1.	Which regions have the highest order volume and which have the lowest?

SELECT RegionName,COUNT(OrderID) AS OrderVolume
FROM orders O 
JOIN Customers C ON C.customerId = O.CustomerID
JOIN Regions R ON R.RegionId = C.RegionID
GROUP BY RegionName
ORDER BY OrderVolume;


-- 5.2.	What is the revenue per region and how does it compare across different regions?
SELECT RegionName,SUM(OD.Quantity*Price) AS TotalRevenue
FROM orders O 
JOIN Customers C ON C.customerId = O.CustomerID
JOIN Regions R ON R.RegionId = C.RegionID
JOIN orderdetails OD ON OD.orderID = O.OrderID
JOIN products P ON P.ProductId = OD.ProductID
GROUP BY RegionName
ORDER BY TotalRevenue DESC;

-- * Comparative analysis Regionwise order volumn over total revenue 
WITH T1 AS(
	SELECT RegionName,COUNT(OrderID) AS OrderVolume
	FROM orders O 
	JOIN Customers C ON C.customerId = O.CustomerID
	JOIN Regions R ON R.RegionId = C.RegionID
	GROUP BY RegionName
	ORDER BY OrderVolume DESC
),
T2 AS(
	SELECT RegionName,SUM(OD.Quantity*Price) AS TotalRevenue
	FROM orders O 
	JOIN Customers C ON C.customerId = O.CustomerID
	JOIN Regions R ON R.RegionId = C.RegionID
	JOIN orderdetails OD ON OD.orderID = O.OrderID
	JOIN products P ON P.ProductId = OD.ProductID
	GROUP BY RegionName
	ORDER BY TotalRevenue DESC
)
SELECT T1.RegionName, OrderVolume, TotalRevenue
FROM T1
JOIN T2 On T2.RegionName = T1.RegionName;

    
-- 6.	Return & Refund Insights
-- 6.1.	What is the overall return rate by product category?
SELECT Category,
		ROUND(SUM(CASE WHEN Isreturned = 1 THEN 1 ELSE 0 END) /COUNT(O.orderID),2) AS ReturnRate
FROM orders O
	JOIN orderdetails OD ON OD.orderID = O.OrderID
	JOIN products P ON P.ProductId = OD.ProductID
	GROUP BY Category
	ORDER BY ReturnRate DESC ;
    
-- 6.2.	What is the overall return rate by region?
SELECT RegionName,
		ROUND(SUM(CASE WHEN Isreturned = 1 THEN 1 ELSE 0 END) /COUNT(O.orderID),2) AS ReturnRate
FROM orders O
	JOIN customers C ON C.CustomerID = O.CustomerID
	JOIN Regions R ON R.RegionId = C.RegionID
	GROUP BY RegionName
	ORDER BY ReturnRate DESC ;

-- 6.3.	Which customers are making frequent returns?
SELECT C.CustomerId, CustomerName, COUNT(O.orderID) AS ReturnCount
FROM Orders O
JOIN Customers C ON C.customerID = O.customerID
WHERE IsReturned = 1
GROUP BY C.customerID, CustomerName
ORDER BY ReturnCount DESC
LIMIT 10;
