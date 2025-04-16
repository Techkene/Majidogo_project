/*1. 
Which product categories drive the biggest profits? Is this the same across store 
locations?
*/
-- Modifying the datatype that should be numerically represented from text to numbers
-- use REPLACE function to remoe the dollar sign in the Produt_price and Product_cost column
UPDATE products_products
SET Product_Price = REPLACE(Product_Price, '$', '');

UPDATE products_products
SET Product_Cost = REPLACE(Product_Cost, '$', '');

-- Modifying the datatype of the Produt_price and Product_cost column
ALTER TABLE products_products
MODIFY COLUMN Product_Price INTEGER;

ALTER TABLE products_products
MODIFY COLUMN Product_Cost INTEGER;


-- Ten product categories drive the biggest profits
SELECT 
	Product_Name,
    Product_Category,
    Product_Price,
    Units,
    ((Product_Price * Units) - Product_Cost) as Profit
FROM products_products p
JOIN sales s
ON p.Product_ID = s.Product_ID
ORDER BY Profit DESC
LIMIT 10;

-- Is this the same across store locations?
SELECT 
    Product_Category,
    SUM((Product_Price * Units) - Product_Cost) AS Total_Profit,
    Store_Location
FROM products_products p
JOIN sales s
ON p.Product_ID = s.Product_ID
JOIN stores st
ON s.Store_ID = st.Store_ID
GROUP BY Store_Location, Product_Category
ORDER BY Total_Profit DESC;

-- from the result of the query total profit across store locations are different

/*2.
How much money is tied up in inventory at the toy stores? 
How long will it last?
*/

/*
"How much money is tied up in inventory at the toy stores?" 
– Is the total value of the inventory (quantity of items in stock × cost per item).
"How long will it last?" 
– Is the inventory turnover or the estimated time the inventory will last, 
which can be calculated by comparing the current stock to the sales rate over a period.
*/

SELECT 
    Store_Name,
    SUM(Stock_On_Hand * p.Product_Cost) AS Total_Inventory_Value
FROM products_products p
JOIN sales s
ON p.Product_ID = s.Product_ID
JOIN stores st
ON s.Store_ID = st.Store_ID
JOIN inventory i
ON i.Store_ID = st.Store_ID
GROUP BY Store_Name
ORDER BY Total_Inventory_Value DESC;

-- How long will it last?

-- first will modify the datatype of th 
UPDATE stores
SET Store_Open_Date = STR_TO_DATE(Store_Open_Date, '%Y-%m-%d');

SELECT     
    p.Product_Name,     
    st.Store_Name,     
    ROUND(SUM(s.Units) / DATEDIFF(MAX(s.Date), MIN(s.Date)), 2) AS Avg_Daily_Sales,     
    ROUND(i.Stock_On_Hand / (SUM(s.Units) / DATEDIFF(MAX(s.Date), MIN(s.Date))), 2) AS Inventory_Duration_Days
FROM products_products p 
JOIN sales s ON p.Product_ID = s.Product_ID 
JOIN stores st ON s.Store_ID = st.Store_ID 
JOIN inventory i ON i.Store_ID = st.Store_ID AND i.Product_ID = p.Product_ID
GROUP BY p.Product_Name, st.Store_Name, i.Stock_On_Hand
ORDER BY Inventory_Duration_Days DESC;

/* 3. 
Are sales being lost with out-of-stock products at certain locations?
*/


/*
Find Out-of-Stock Products: Identify products that have 0 stock at a location.
Check Recent Sales: Verify whether those products had sales activity in the past (suggesting demand).
Estimate Lost Sales: Use average daily sales to estimate potential lost sales.
*/

-- Calculates total units sold, average daily sales, and stock level.
WITH Stock_Status AS (
    SELECT 
        p.Product_Name,
        st.Store_Name,
        i.Stock_On_Hand,
        SUM(s.Units) AS Total_Units_Sold,
        DATEDIFF(MAX(s.Date), MIN(s.Date)) AS Sales_Duration_Days,
        ROUND(SUM(s.Units) / NULLIF(DATEDIFF(MAX(s.Date), MIN(s.Date)), 0), 2) AS Avg_Daily_Sales
    FROM products_products p
    JOIN sales s ON p.Product_ID = s.Product_ID
    JOIN stores st ON s.Store_ID = st.Store_ID
    JOIN inventory i ON i.Store_ID = st.Store_ID AND i.Product_ID = p.Product_ID
    GROUP BY p.Product_Name, st.Store_Name, i.Stock_On_Hand
),
-- Identify out-of-stock products with recent sales
Lost_Sales AS (
    SELECT 
        Product_Name,
        Store_Name,
        Stock_On_Hand,
        Total_Units_Sold,
        Avg_Daily_Sales,
        ROUND(Avg_Daily_Sales * 7, 2) AS Estimated_Weekly_Lost_Sales
    FROM Stock_Status
    WHERE Stock_On_Hand = 0 AND Avg_Daily_Sales > 0
)
SELECT * FROM Lost_Sales
ORDER BY Estimated_Weekly_Lost_Sales DESC;
