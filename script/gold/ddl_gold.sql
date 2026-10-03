/* 
=============================================================================================================================================
DDL Scripts : Create Gold Views
==============================================================================================================================================
Script Purpose: 
       This script creates view for the Gold Layer in the data warehouse.
       The Gold layer represents the final dimension and fact tables (Star Schema)

       Each view performs transformation and combines data from the Silver Layer 
       to produce a clean, enriched, and business-ready dataset.

Usage: 
    -These views can be queried directly for analytics and reporting.
=================================================================================================================================================
*/

--================================================================================================================================================
--Create Dimension: gold.dim_customers
--==================================================================================================================================================
CREATE OR REPLACE VIEW gold.dim_customers AS
select 
ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as fisrt_name,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_marital_status as marital_status,
CASE WHEN ci.cst_gender!= 'N/A' THEN ci.cst_gender
             ELSE  COALESCE(ca.gen,'N/A')
END as gender,
ca.bdate as birthdate,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca on ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la on ci.cst_key = la.cid ;
--=====================================================================================================================================================
--Create Dimensio: gold.dim_products
--====================================================================================================================================================
CREATE OR REPLACE VIEW gold.dim_products AS
select 
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) as product_key,
prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm product_name,
pn.cat_id as category_id ,
pc.cat as category,
pc.subcat as subcategory ,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date							
from silver.crm_prd_info pn
JOIN silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id 
where pn.prd_end_dt IS NULL;
--=====================================================================================================================================================
--Create Fact: gold.fact_sales
--====================================================================================================================================================
CREATE OR REPLACE VIEW gold.fact_sales AS
select 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;




















