Use Projects
-- Data Preview
-- Retrieves all columns and rows from the American_Bankruptcy_Data table to get an overview of the dataset.
SELECT * FROM American_Bankruptcy_Data;

-- What is the company's solvency position (Debt-to-Equity Ratio) for each year?

--------EXPLANATION--------
-- Calculates the Debt-to-Equity Ratio by dividing Total Long-Term Debt by Retained Earnings. 
-- Filters out rows where Retained Earnings are zero or negative to avoid division by zero or irrelevant data.
-- Rounds the result to 2 decimal places for readability.

SELECT 
    year,
    company_name,
    Total_Long_Term_Debt,
    Retained_Earnings,
    ROUND(Total_Long_Term_Debt / Retained_Earnings, 2) AS debt_to_equity_ratio
FROM 
    American_Bankruptcy_Data
WHERE 
    Retained_Earnings > 0
ORDER BY 
    year, company_name;

-- How efficiently is the company collecting its receivables (Receivables Turnover Ratio) for each year?

--------EXPLANATION--------
-- Calculates the Receivables Turnover Ratio by dividing Net Sales by Total Receivables.
-- Filters out rows where Total Receivables are zero or negative to avoid division by zero or irrelevant data.
-- Rounds the result to 2 decimal places for readability.

SELECT 
    year,
    company_name,
    Net_Sales AS net_sales,
    Total_Receivables AS total_receivables,
    ROUND(Net_Sales / Total_Receivables, 2) AS receivables_turnover_ratio
FROM 
    American_Bankruptcy_Data
WHERE 
    Total_Receivables > 0
ORDER BY 
    year, company_name;

-- What is the company's cash flow position (Operating Cash Flow) relative to its debt for each year?

--------EXPLANATION--------
-- Calculates the ratio of EBITDA to Total Long-Term Debt to assess how much cash flow is available relative to debt levels.
-- Filters out rows where Total Long-Term Debt is zero or negative to avoid division by zero or irrelevant data.
-- Rounds the result to 2 decimal places for readability.

SELECT 
    year,
    company_name,
    EBITDA,
    Total_Long_Term_Debt,
    ROUND(EBITDA / Total_Long_Term_Debt, 2) AS operating_cash_flow_to_debt
FROM 
    American_Bankruptcy_Data
WHERE 
    Total_Long_Term_Debt > 0
ORDER BY 
    year, company_name;

-- What are the top 3 companies each year with the highest profitability?

--------EXPLANATION--------
-- Calculates Profit Margin by dividing Net Income by Total Revenue.
-- Uses RANK() window function to rank companies by Profit Margin within each year in descending order.
-- Selects the top 3 companies (ranks < 4) for each year based on their Profit Margin.

WITH profits AS (
    SELECT 
        company_name, 
        year, 
        ROUND(Net_Income / Total_Revenue, 2) AS profit_margin, 
        RANK() OVER (PARTITION BY year ORDER BY Net_Income / Total_Revenue DESC) AS ranks
    FROM 
        American_Bankruptcy_Data
)
SELECT 
    year, 
    company_name, 
    profit_margin
FROM 
    profits
WHERE 
    ranks < 4
ORDER BY 
    year DESC, ranks;

-- Revenue Vs Expense Trend

--------EXPLANATION--------
-- Calculates Net Profit as Total Revenue minus Total Operating Expenses.
-- Orders results by year and company_name for trend analysis.

SELECT 
    year, 
    company_name, 
    Total_Revenue, 
    Total_Operating_Expenses, 
    (Total_Revenue - Total_Operating_Expenses) AS Net_Profit
FROM 
    American_Bankruptcy_Data
ORDER BY 
    year, company_name;

-- Bankruptcy Indication

--------EXPLANATION--------
-- Calculates the Altman Z-Score, a composite score used to predict bankruptcy risk.
-- The Z-Score formula combines multiple financial ratios to assess financial health.
-- Classifies the result into zones (Distress, Caution, Safe) based on the Z-Score value.

WITH altman_z AS (
    SELECT  
        company_name, 
        year, 
        ROUND(
            (1.2 * ((Current_Assets - Total_Current_Liabilities) / Total_Assets)) +
            (1.4 * (Retained_Earnings / Total_Assets)) +
            (3.3 * (EBIT / Total_Assets)) +
            (0.6 * (Market_Value / Total_Liabilities)) +
            (1.0 * (Net_Sales / Total_Assets)), 
        4) AS Altman_Z_Score
    FROM 
        American_Bankruptcy_Data
)
SELECT 
    *, 
    CASE 
        WHEN Altman_Z_Score < 1.8 THEN 'Distress Zone' 
        WHEN Altman_Z_Score BETWEEN 1.8 AND 3.0 THEN 'Caution Zone' 
        WHEN Altman_Z_Score > 3.0 THEN 'Safe Zone' 
    END AS Bankruptcy_Indication
FROM 
    altman_z
ORDER BY 
    company_name, year;

-- Current Ratio & Quick Ratio Analysis

--------EXPLANATION--------
-- Calculates liquidity ratios: Current Ratio and Quick Ratio.
-- Current Ratio is calculated as Current Assets divided by Total Current Liabilities.
-- Quick Ratio is calculated as (Current Assets minus Inventory) divided by Total Current Liabilities.
-- Rounds results to 2 decimal places for readability.

SELECT 
    company_name, 
    year, 
    ROUND(Current_Assets / Total_Current_Liabilities, 2) AS Current_Ratio,
    ROUND((Current_Assets - Inventory) / Total_Current_Liabilities, 2) AS Quick_Ratio
FROM 
    American_Bankruptcy_Data;

-- Which companies are managing their working capital efficiently (high Working Capital to Total Assets ratio) for the past 2 years?

--------EXPLANATION--------
-- Calculates the Working Capital to Total Assets ratio as (Current Assets minus Total Current Liabilities) divided by Total Assets.
-- Filters records to include only the last 2 years.
-- Averages the ratio for each company over these years and selects companies with an average ratio greater than 0.2.

WITH working_capital AS (
    SELECT 
        company_name,
        year,
        (Current_Assets - Total_Current_Liabilities) / Total_Assets AS working_capital_to_total_assets
    FROM 
        American_Bankruptcy_Data
    WHERE 
        Total_Assets > 0
)
SELECT 
    company_name, 
    year,
    AVG(working_capital_to_total_assets) AS avg_working_capital_ratio
FROM 
    working_capital
WHERE 
    year >= (SELECT MAX(year) FROM American_Bankruptcy_Data) - 2
GROUP BY 
    company_name, year
HAVING 
    AVG(working_capital_to_total_assets) > 0.2
ORDER BY 
    avg_working_capital_ratio DESC;

-- Which companies have the highest Return on Equity (ROE) consistently over the last 5 years?

--------EXPLANATION--------
-- Calculates ROE as Net Income divided by Retained Earnings, multiplied by 100 to express as a percentage.
-- Averages ROE over the last 5 years for each company to find those with the highest average ROE.

WITH roe_calculation AS (
    SELECT 
        company_name,
        year,
        (Net_Income / Retained_Earnings) * 100 AS roe
    FROM 
        American_Bankruptcy_Data
    WHERE 
        Retained_Earnings > 0
)
SELECT 
    company_name,
    AVG(roe) AS avg_roe
FROM 
    roe_calculation
WHERE 
    year >= (SELECT MAX(year) FROM American_Bankruptcy_Data) - 5
GROUP BY 
    company_name
ORDER BY 
    avg_roe DESC;

-- Which companies have the most consistent profitability (low variance in Net Profit Margin) over the years?

--------EXPLANATION--------
-- Calculates Net Profit Margin as (Net Income divided by Total Revenue) multiplied by 100 to express as a percentage.
-- Computes variance of Net Profit Margin for each company to identify those with the lowest variance, indicating consistent profitability.

WITH net_profit_margin AS (
    SELECT 
        company_name, 
        year,
        (Net_Income / Total_Revenue) * 100 AS net_profit_margin
    FROM 
        American_Bankruptcy_Data
    WHERE 
        Total_Revenue > 0
),
profit_variance AS (
    SELECT 
        company_name, 
        VAR(net_profit_margin) AS profit_margin_variance
    FROM 
        net_profit_margin
    GROUP BY 
        company_name
)
SELECT 
    company_name, 
    profit_margin_variance
FROM 
    profit_variance
ORDER BY 
    profit_margin_variance ASC;
