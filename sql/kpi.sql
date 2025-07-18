-- 1. Company wide lifetime revenue 
SELECT 
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalRevenue
FROM   
	OrderDetail od;

-- 2. Revenue by Year‑Month 
SELECT
    substr(Orders.OrderDate, 1, 7) AS YearMonth,
    ROUND(SUM(OrderDetail.UnitPrice * OrderDetail.Quantity * (1 - OrderDetail.Discount)), 2) AS Revenue
FROM Orders
JOIN OrderDetail ON Orders.ID = OrderDetail.OrderID
GROUP BY YearMonth
ORDER BY YearMonth;

-- 3. Average revenue per order
WITH OrderTotals AS (
    SELECT
        Orders.ID                                                AS OrderID,
        SUM(OrderDetail.UnitPrice * OrderDetail.Quantity *
            (1 - OrderDetail.Discount))                          AS OrderRevenue
    FROM Orders
    JOIN OrderDetail ON Orders.ID = OrderDetail.OrderID
    GROUP BY Orders.ID
)
SELECT ROUND(AVG(OrderRevenue), 2) AS AvgOrderValue
FROM   OrderTotals;

-- 4. Which countries drive business? 
SELECT
    Customer.Country,
    COUNT(DISTINCT Orders.ID)                                    AS NumOrders,
    ROUND(SUM(OrderDetail.UnitPrice * OrderDetail.Quantity *
              (1 - OrderDetail.Discount)), 2)                    AS Revenue
FROM   Customer
JOIN   Orders      ON Customer.ID  = Orders.CustomerID
JOIN   OrderDetail ON Orders.ID     = OrderDetail.OrderID
GROUP  BY Customer.Country
ORDER  BY Revenue DESC;

-- 5. Highest‑spending customers 
SELECT
    Customer.CompanyName,
    ROUND(SUM(OrderDetail.UnitPrice * OrderDetail.Quantity *
              (1 - OrderDetail.Discount)), 2)                    AS TotalRevenue
FROM   Customer
JOIN   Orders      ON Customer.ID  = Orders.CustomerID
JOIN   OrderDetail ON Orders.ID     = OrderDetail.OrderID
GROUP  BY Customer.CompanyName
ORDER  BY TotalRevenue DESC
LIMIT  5;

-- 6. Best‑selling products 
SELECT
    Product.ProductName,
    ROUND(SUM(OrderDetail.UnitPrice * OrderDetail.Quantity *
              (1 - OrderDetail.Discount)), 2)                    AS ProductRevenue
FROM   Product
JOIN   OrderDetail ON Product.ID = OrderDetail.ProductID
GROUP  BY Product.ProductName
ORDER  BY ProductRevenue DESC
LIMIT  10;


