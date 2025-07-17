-- View first 5 customers
SELECT 
	* 
FROM 
	Customer 
LIMIT 5;

-- View first 5 orders
SELECT
	*
FROM 
	OrderDetail
LIMIT 5;

-- View first 5 products
SELECT 
	* 
FROM 
	Product 
LIMIT 5;

-- View first 5 employees
SELECT 
	* 
FROM 
	Employee
LIMIT 5;

-- What countries do customers come from?
SELECT DISTINCT 
	Country 
FROM 
	Customer;

-- Number of customers per country
SELECT 
	Country, COUNT(*) AS CustomerCount
FROM 
	Customer
GROUP BY 
	Country
ORDER BY 
	CustomerCount DESC;

-- Total number of orders
SELECT 
	COUNT(*) 
FROM 
	Orders;

SELECT 
	CategoryID, COUNT(*) AS ProductCount
FROM 
	Product
GROUP BY 
	CategoryID;


