/* Unified Sales Fact Table */
WITH Sales AS (
  SELECT
    Orders.ID                                AS OrderID,
    Orders.OrderDate,
    Customer.ID                              AS CustomerID,
    Customer.CompanyName,
    Customer.Country,
    Employee.ID                              AS EmployeeID,
    Employee.LastName || ', ' || Employee.FirstName AS SalesRep,
    Product.ID                               AS ProductID,
    Product.ProductName,
    COALESCE(Category.CategoryName, 'Unknown') AS CategoryName,
    OrderDetail.Quantity,
    OrderDetail.UnitPrice,
    OrderDetail.Discount,
    OrderDetail.Quantity * OrderDetail.UnitPrice * (1 - OrderDetail.Discount) AS LineRevenue
  FROM Orders
  JOIN OrderDetail ON Orders.ID = OrderDetail.OrderID
  JOIN Customer     ON Orders.CustomerID = Customer.ID
  JOIN Employee     ON Orders.EmployeeID = Employee.ID
  JOIN Product      ON OrderDetail.ProductID = Product.ID
  LEFT JOIN Category ON Product.CategoryID = Category.ID
)
SELECT * FROM Sales LIMIT 5;


/* Customer Segmentation */
WITH CustomerSpend AS (
    SELECT
        Customer.ID           AS CustomerID,
        Customer.CompanyName,
        Customer.Country,
        ROUND(
          SUM(OrderDetail.Quantity * OrderDetail.UnitPrice *
              (1 - OrderDetail.Discount)), 2)        AS TotalSpend
    FROM Orders
    JOIN OrderDetail ON Orders.ID = OrderDetail.OrderID
    JOIN Customer     ON Orders.CustomerID = Customer.ID
    GROUP BY Customer.ID
)
SELECT
    CompanyName,
    Country,
    TotalSpend,
    CASE
        WHEN TotalSpend >= 100000 THEN 'Platinum'
        WHEN TotalSpend >= 50000  THEN 'Gold'
        WHEN TotalSpend >= 10000  THEN 'Silver'
        ELSE                         'Bronze'
    END AS Segment
FROM CustomerSpend
ORDER BY TotalSpend DESC;

/* Top Product per Category */

WITH ProductRevenue AS (
    SELECT
        Category.CategoryName,                     
        Product.ProductName,                     
        SUM(OrderDetail.Quantity * OrderDetail.UnitPrice *
            (1 - OrderDetail.Discount)) AS Revenue 
    FROM Orders
    JOIN OrderDetail ON Orders.ID      = OrderDetail.OrderID
    JOIN Product      ON OrderDetail.ProductID = Product.ID
    LEFT JOIN Category ON Product.CategoryID   = Category.ID
    GROUP BY Category.CategoryName, Product.ProductName
),
Ranked AS (
    SELECT
        CategoryName,
        ProductName,
        Revenue,
        ROW_NUMBER() OVER (
            PARTITION BY CategoryName
            ORDER BY Revenue DESC
        ) AS rn
    FROM ProductRevenue
)
SELECT
    CategoryName,
    ProductName,
    ROUND(Revenue, 2) AS Revenue
FROM Ranked
WHERE rn = 1                          
ORDER BY Revenue DESC;  

/* Sales by employee */
SELECT
    Employee.LastName || ', ' || Employee.FirstName AS SalesRep,
    ROUND(SUM(OrderDetail.Quantity * OrderDetail.UnitPrice *
              (1 - OrderDetail.Discount)), 2)       AS Revenue
FROM Orders
JOIN OrderDetail ON Orders.ID      = OrderDetail.OrderID
JOIN Employee    ON Orders.EmployeeID = Employee.ID
GROUP BY SalesRep
ORDER BY Revenue DESC;

/* Orders with Discounts */
WITH DiscountedOrders AS (
    SELECT
        Orders.ID                                AS OrderID,
        Customer.CompanyName,
        SUM(OrderDetail.Quantity * OrderDetail.UnitPrice *
            (1 - OrderDetail.Discount))          AS NetRevenue,
         SUM(OrderDetail.Quantity * OrderDetail.UnitPrice *
            OrderDetail.Discount)                AS DiscountAmount
    FROM Orders
    JOIN OrderDetail ON Orders.ID      = OrderDetail.OrderID
    JOIN Customer     ON Orders.CustomerID = Customer.ID
    WHERE OrderDetail.Discount > 0              
    GROUP BY Orders.ID
)
SELECT
    OrderID,
    CompanyName,
    ROUND(NetRevenue,    2) AS NetRevenue,
    ROUND(DiscountAmount, 2) AS DiscountGiven
FROM DiscountedOrders
ORDER BY NetRevenue DESC              
LIMIT 10; 
