USE projects

-- Preview the data
-- This query retrieves the data from the Coffee_Chain_Sales table.
-- It helps to understand the structure and sample content of the dataset.
SELECT * 
FROM Coffee_Chain_Sales


-- Count the number of distinct product lines, product types, and products
-- This query calculates the number of unique values for Product_line, Product_type, and Product columns.
-- The COUNT(DISTINCT column_name) function counts the distinct occurrences of each column value.
SELECT 
    COUNT(DISTINCT Product_line) AS Product_lines,  -- Number of unique product lines
    COUNT(DISTINCT Product_type) AS Product_types,  -- Number of unique product types
    COUNT(DISTINCT Product) AS Products             -- Number of unique products
FROM 
    Coffee_Chain_Sales

-- Calculate the average sales, profit, COGS, and expenses
-- This query computes the average of Sales, Cogs (Cost of Goods Sold), Total_expenses, and Profit columns.
-- The ROUND function is used to round the results to 2 decimal places for readability.
SELECT 
    ROUND(AVG(Sales), 2) AS Avg_Sales,            -- Average sales amount
    ROUND(AVG(Cogs), 2) AS Avg_Cogs,              -- Average cost of goods sold
    ROUND(AVG(Total_expenses), 2) AS Avg_Expense, -- Average total expenses
    ROUND(AVG(Profit), 2) AS Avg_Profit           -- Average profit
FROM 
    Coffee_Chain_Sales

-- Analyze sales, profit, and other metrics across different market sizes and regions
-- This query aggregates sales and profit totals and calculates average margins, COGS, and inventory margins for different market sizes and regions.
-- The SUM function adds up values, and AVG calculates the average. Results are grouped by Market_size and Market.
SELECT 
    Market_size,
    Market,
    SUM(Sales) AS Total_Sales,                                -- Total sales for each market size and region
    SUM(Profit) AS Total_Profit,                              -- Total profit for each market size and region
    ROUND(AVG(Margin), 2) AS Avg_Margin,                      -- Average margin
    ROUND(AVG(Cogs), 2) AS Avg_COGS,                          -- Average cost of goods sold
    ROUND(AVG([Inventory Margin]), 2) AS Avg_Inventory_Margin -- Average inventory margin
FROM 
    Coffee_Chain_Sales
GROUP BY 
    Market_size, 
    Market
ORDER BY 
    Market_size, 
    Market

-- Identify the top 3 states each year with maximum sales
-- This query uses a Common Table Expression (CTE) to rank states based on their total sales each year.
-- ROW_NUMBER() assigns a unique rank to each state within a given year based on total sales.
-- The final SELECT statement filters to show only the top 3 states per year.
WITH RankedSales AS (
    SELECT 
        State,
        YEAR(Date) AS Year,                                                                -- Extract the year from Date
        SUM(Sales) AS Total_Sales,                                                         -- Total sales for each state per year
        ROW_NUMBER() OVER (PARTITION BY YEAR(Date) ORDER BY SUM(Sales) DESC) AS Sales_Rank -- Rank states by sales
    FROM 
        Coffee_Chain_Sales
    GROUP BY 
        State, 
        YEAR(Date)
)
SELECT 
    Year,
    State,
    Total_Sales
FROM 
    RankedSales
WHERE 
    Sales_Rank <= 3                             -- Select only the top 3 states
    AND Year IS NOT NULL
ORDER BY 
    Year, 
    Sales_Rank

-- Determine which products or product lines generate the most profit and sales
-- This query sums up sales and profit for each Product_Line and Product.
-- Results are ordered by Total_Profit and Total_Sales in descending order to identify the most profitable and highest-grossing products.
SELECT 
    Product_Line,
    Product,
    SUM(Sales) AS Total_Sales,                  -- Total sales for each product and product line
    SUM(Profit) AS Total_Profit                 -- Total profit for each product and product line
FROM 
    Coffee_Chain_Sales
GROUP BY 
    Product_Line, 
    Product
ORDER BY 
    Total_Profit DESC,                          -- Order results by total profit (highest first)
    Total_Sales DESC;                           -- Order results by total sales (highest first)

-- Identify the top products in terms of profitability within each product line
-- This query calculates total sales and profit for each Product_Line and Product.
-- The RANK() window function ranks products within each product line based on total profit.
;WITH Profits AS (
    SELECT 
        Product_Line,
        Product,
        SUM(Sales) AS Total_Sales,               -- Total sales for each product within a product line
        SUM(Profit) AS Total_Profit              -- Total profit for each product within a product line
    FROM 
        Coffee_Chain_Sales
    GROUP BY 
        Product_Line, 
        Product
)
SELECT 
    Product_Line,
    Product,
    Total_Profit,
    RANK() OVER (PARTITION BY Product_Line ORDER BY Total_Profit DESC) AS Profit_Rank -- Rank products by profit within each product line
FROM 
    Profits
ORDER BY 
    Product_Line, 
    Profit_Rank

-- Compare actual performance (e.g., Profit, Sales) to target values across different dimensions (product lines, markets)
-- This query compares actual profit and sales against target values for each combination of Market_size, Market, and Product_Line.
-- Differences between actual and target values are also calculated.
SELECT 
    Market_size,
    Market,
    Product_Line,
    SUM(Profit) AS Actual_Profit,                          -- Actual profit
    SUM(Target_Profit) AS Target_Profit,                   -- Target profit
    SUM(Sales) AS Actual_Sales,                            -- Actual sales
    SUM([Target_sales ]) AS Target_Sales,                   -- Target sales
    SUM(Profit) - SUM(Target_Profit) AS Profit_Difference, -- Difference between actual and target profit
    SUM(Sales) - SUM([Target_sales ]) AS Sales_Difference   -- Difference between actual and target sales
FROM 
    Coffee_Chain_Sales
GROUP BY 
    Market_size, 
    Market, 
    Product_Line
ORDER BY 
    Market_size,
    Market,
    Profit_Difference DESC, 
    Sales_Difference DESC

-- Analyze how total expenses correlate with profit and sales across different markets and product lines
-- This query calculates total expenses and assesses their relationship with profit and sales by calculating expense ratios.
-- Profit_Expense_Ratio and Sales_Expense_Ratio show the efficiency of expenses in generating profit and sales.
SELECT 
    Product_Line,
    Market_size,
    SUM(Total_expenses) AS Total_Expenses,                                   -- Total expenses for each product line and market size
    SUM(Profit) AS Total_Profit,                                             -- Total profit
    SUM(Sales) AS Total_Sales,                                               -- Total sales
    ROUND((SUM(Profit) / SUM(Total_expenses)), 2) AS Profit_Expense_Ratio,   -- Ratio of profit to expenses
    ROUND((SUM(Sales) / SUM(Total_expenses)), 2) AS Sales_Expense_Ratio      -- Ratio of sales to expenses
FROM 
    Coffee_Chain_Sales
GROUP BY 
    Product_Line, 
    Market_size
ORDER BY 
    Profit_Expense_Ratio DESC, 
    Sales_Expense_Ratio DESC

-- Analyze sales and profitability trends over time, including potential seasonal trends
-- This query tracks total sales and profit for each product over time by month and year.
-- It helps to identify trends and potential seasonality in sales and profitability.
SELECT 
    Product,
    YEAR(Date) AS Year,                         -- Extract the year from Date
    MONTH(Date) AS Month,                       -- Extract the month from Date
    SUM(Sales) AS Total_Sales,                  -- Total sales for each product by year and month
    SUM(Profit) AS Total_Profit                 -- Total profit for each product by year and month
FROM 
    Coffee_Chain_Sales
WHERE Date IS NOT NULL
GROUP BY 
    Product, 
    YEAR(Date), 
    MONTH(Date)
ORDER BY 
    Product, 
    Year, 
    Month
