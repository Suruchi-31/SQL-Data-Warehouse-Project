/*
===================================================================================================
Quality Checks
===================================================================================================
Script Purpose:
      This script performs various quality checks for data consistency, accuracy,
      and standardization across the 'silver' schema.
      It includes checks for:
      - Null or duplicate primary keys
      - Unwanted spaces in string field
      - Data Standardization & Consistency
      - Invalid date ranges & orders
      - Data Consistency between related fields

Usage Notes:
        - Run these checks after data loading in silver layer
        - Investigate and resolve any discrepencies found during the checks
===================================================================================================
*/
--===================================================================================================
  -- Checking for table silver.crm_cust_info
--==================================================================================================
-- 1)	Check for Null & Duplicates in Primary key
--- Rxpectations: No Result
      Select cst_id ,
      count(*)
      From silver.crn_cust_info 
      Group by count(*)
      Having count(*) >1 OR cst_id is NULL;

--2)	Checks for Unwanted Spaces
 --   Expectation: No Result
      SELECT 
      cst_key 
      FROM silver.crm_cust_info
      WHERE cst_key != TRIM(cst_key);

--3)	Data Standardization & Consistency( We aim to store clean and meaningful values rather tha abbreviated forms)
       SELECT DISTINCT 
       cst_marital_status 
       FROM silver.crm_cust_info;

--===================================================================================================
  -- Checking for table silver.crm_prd_info
--==================================================================================================
--1)	Check for duplicate or NULL Values in primary key
--- Expectations: No Result
    Select prd_id, count(*)
    From silver.crm_prd_info
    Group by prd_id
    Having count(*) > 1 OR prd_id is NULL;

--2)	Checking for any Unwanted spaces in prd_name
     select prd_nm
     from silver.crm_prd_info
     where prd_nm != TRIM(prd_nm)

--3) Checks for NULL or Negative values
  select prd_cost
  from silver.crm_prd_info
  where prd_cost < 0 OR prd_cost IS NULL

--4) -- Data Standardization & Consistency
    SELECT DISTINCT 
    prd_line 
    FROM silver.crm_prd_info;


--5)	Check for invalid date orders
    select * 
    from silver.crm_prd_info
    where prd_end_dt < prd_start_dt;
  

--===================================================================================================
  -- Checking for table silver.crm_sales_details
--==================================================================================================
--1)	Check for Invalid Date Order
--(Order_date > Shipping/Due date)
-- sls_order_dt should always be smaller than tha sls_ship_dt and sls_due_dt
	Select *
	From silver.crm_sales_details
	Where sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt ;

--2) Check Data Consistency : Between Sales, Quantity and Price
     Select DISTINCT
     sls_sales, 
      sls_quantity, 
      sls_price
      from brinze.crm_sales_details
      where sls_sales != sls_quantity * sls_price
      OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
      OR sls_sales<=  0 OR sls_quantity <= 0 OR sls_price <= 0
      ORDER by sls_sales, sls_quantity, sls_price;
    
  
--===================================================================================================
  -- Checking for table silver.erp_cust_ax12
--==================================================================================================
-- 1) Identify Out-of-Range Dates
      SELECT DISTINCT 
      bdate 
      FROM silver.erp_cust_az12
      WHERE bdate < '1924-01-01' 
      OR bdate > CURRENT_DATE ;
--2) Data Standardization & Consistency
     SELECT DISTINCT 
     gen 
    FROM silver.erp_cust_az12;
--===================================================================================================
  -- Checking for table silver.erp_loc_a101
--==================================================================================================
-- 1) Data Stanardization & Consistency
    Select DISTINCT cntry
    Form silver.erp_ loc_a101
    order by cntry ;

--===================================================================================================
  -- Checking for table silver.erp_px_cat_g1v2
--==================================================================================================
-- 1) Checking for unwanted spaces
    Select *
    From silver.erp_px_cat_g1v2
    Where cat != TRIM(cat) 
    OR subcat!= TRIM(subcat) 
    OR maintenance!= TRIM(maintenance)

-- 2) Data Standardization & Consistency
    select 
    DISTINCT
    maintenance
    From bronze.erp_px_cat_g1v2; 
  
       
