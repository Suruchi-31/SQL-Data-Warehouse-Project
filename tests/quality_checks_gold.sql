/*
=========================================================================================================================
Quality Checks
=========================================================================================================================
Script Purpose: 
          This script performs quality checks to validate the integrity, consistency ,
          and accuracy of the Gold Layer. These checks ensures:
          - Uniqueness of surrogate keys in dimension tables.
          - Referential integrity between fact and dimension tables.
          - validation of relationships in the data model for analytical purposes.

Usage Notes:  
         - Run these checks after data loading Silver Layer
         - Investigate and resolve any discrepancies found during the checks
========================================================================================================================
*/

--=====================================================================================================================
--checking 'gold.dim_customers'
--=====================================================================================================================
--Checking for the Uniqueness of Customer Key
-- Expectation: No results 
SELECT 
customer_key,
COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

--======================================================================================================================
--checking 'gold.dim_products'
--=====================================================================================================================
--checking the uniqueness of product_key
-- Expectation: No results 
SELECT 
product_key,
COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;
--====================================================================================================================
--checking 'gold.fact_sales'
--===================================================================================================================
---- Checking the data model connectivity between fact and dimensions
select * from gold.fact_sales f
LEFT JOIN gold.dim_customers cu
ON cu.customer_key = f.customer_key
LEFT JOIN gold.dim_products pr
ON pr.product_key = f.product_key
where pr.product_key IS NULL OR cu.customer_key is NULL ;
