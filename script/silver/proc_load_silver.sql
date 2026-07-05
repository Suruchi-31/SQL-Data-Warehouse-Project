/*
=========================================================================================
Stored Procedure: Load Silver layer(Bronze-> Silver)
=========================================================================================
Script Purpose: 
            This stored procedure performed the ETL(Extract, Tranform, Load)
            process to populate the 'silver' schema tables from the 'bronze' 
            schema.
   Actions Performed: 
               - Truncate Silver Table
               - Inserts transformed and cleansed data from Bronze into Siver table.
  
   Parameters: 
         None.
         This stored procedure doesn't accept any parameters and returns any values.

  Usage Example:
          CALL silver.load_silver();
        
===================================================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
	batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
batch_start_time := clock_timestamp();
	RAISE NOTICE'===========================================================';
	RAISE NOTICE' Loading  Silver Layer';
	RAISE NOTICE'===========================================================';
	
	RAISE NOTICE'-----------------------------------------------------------';
	RAISE NOTICE' Loading CRM Tables';
	RAISE NOTICE'-----------------------------------------------------------';
--------silver.crm_cust_info--------
RAISE NOTICE  '>>Tuncating Table: silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
RAISE NOTICE '>>Inserting Data into : silver.crm_cust_info';

start_time := clock_timestamp();
INSERT INTO silver.crm_cust_info(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gender,
cst_create_date
)
---Data Standardization & Consistency---
select 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
CASE WHEN Trim(cst_marital_status)  ='M' then 'Married'
     WHEN Trim(cst_marital_status) = 'S' then 'Single'
	 ELSE 'N/A'
END cst_marital_status,

CASE WHEN Trim(cst_gender) ='F' then 'Female'
     WHEN Trim(cst_gender) = 'M' then 'Male'
	 ELSE 'N/A'
END cst_gender,
cst_create_date
from 
(select *,
row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
 from bronze.crm_cust_info
 where cst_id IS NOT NULL
 ) A where flag_last=1 ;
 end_time := clock_timestamp();

---EPOCH means:Convert the interval into the total number of seconds.
RAISE NOTICE 'Load Duration: % seconds',
EXTRACT(EPOCH FROM (end_time - start_time));
	

----------------silver.crm_prd_info--------------------
start_time := clock_timestamp();

RAISE NOTICE  '>>Tuncating Table: silver.crm_prd_info';
TRUNCATE TABLE silver.crm_prd_info;
RAISE NOTICE '>>Inserting Data into : silver.crm_prd_info';

INSERT INTO silver.crm_prd_info
(
  prd_id,
  cat_id,
  prd_key,
  prd_nm,
  prd_cost,
  prd_line,
  prd_start_dt,
  prd_end_dt
)
select 
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-', '_') AS cat_id,
SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,
prd_nm,
COALESCE(prd_cost, 0) as prd_cost,
CASE WHEN UPPER(TRIM(prd_line)) ='M' THEN 'Mountain'
     WHEN UPPER(TRIM(prd_line)) ='R' THEN 'Road'
	 WHEN UPPER(TRIM(prd_line)) ='S' THEN 'Other Sales'
	 WHEN UPPER(TRIM(prd_line)) ='T' THEN 'Touring'
	 ELSE 'N/A'
END AS prd_line,
CAST(prd_start_dt as DATE) AS prd_start_dt,
CAST(LEAD(prd_start_dt) OVER (Partition by prd_key ORDER BY prd_start_dt)-INTERVAL '1 day'
AS DATE)AS prd_end_dt
From bronze.crm_prd_info
ORDER BY prd_id, prd_start_dt;
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: % seconds',
EXTRACT(EPOCH FROM (end_time - start_time));
	

------------------silver.crm_sales_details------------------

start_time := clock_timestamp();
RAISE NOTICE  '>>Tuncating Table: silver.crm_sales_details';
TRUNCATE TABLE silver.crm_sales_details;
RAISE NOTICE '>>Inserting Data into : silver.crm_sales_details';

INSERT INTO silver.crm_sales_details
(
  sls_ord_num,
  sls_prd_key,
  sls_cust_id,
  sls_order_dt,
  sls_ship_dt,
  sls_due_dt,
  sls_sales,
  sls_quantity,
  sls_price
)
select 
 sls_ord_num ,
 sls_prd_key ,
 sls_cust_id ,
 CASE
    WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::TEXT)!= 8 THEN NULL
    ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
END AS sls_order_dt,
 CASE
    WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL
    ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
END AS sls_ship_dt,
  CASE
    WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL
    ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
END AS sls_due_dt,
CASE WHEN  sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
         THEN sls_quantity * ABS(sls_price)
         ELSE sls_sales
END AS sls_sales ,
 sls_quantity, 
 CASE WHEN sls_price IS NULL OR sls_price <= 0
             THEN sls_sales / NULLIF(sls_quantity, 0)
             ELSE sls_price
END AS sls_price 
 from bronze.crm_sales_details;
 end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: % seconds',
EXTRACT(EPOCH FROM (end_time - start_time));
	

-------------silver.erp_cust_az12 -------------------
RAISE NOTICE'-----------------------------------------------------------';
RAISE NOTICE' Loading ERP Tables';
RAISE NOTICE'-----------------------------------------------------------';

start_time := clock_timestamp();

RAISE NOTICE  '>>Tuncating Table: silver.erp_cust_az12 ';
TRUNCATE TABLE silver.erp_cust_az12;
RAISE NOTICE  '>>Inserting Data into : silver.erp_cust_az12';

INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
select
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
     ELSE cid
END as cid,
CASE WHEN bdate > CURRENT_DATE THEN NULL
     ELSE bdate
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
     ELSE 'N/A'
END AS gen
from bronze.erp_cust_az12;
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: % seconds',
EXTRACT(EPOCH FROM (end_time - start_time));
	


----------------silver. erp_loc_a101----------------------

start_time := clock_timestamp();

RAISE NOTICE  '>>Tuncating Table: silver. erp_loc_a101';
TRUNCATE TABLE silver. erp_loc_a101;
RAISE NOTICE  '>>Inserting Data into : silver. erp_loc_a101';

INSERT INTO silver.erp_loc_a101
(cid,cntry)
select
REPLACE(cid, '-', '')cid,
CASE WHEN TRIM(cntry) ='DE' THEN 'Germany' 
     WHEN TRIM(cntry) IN ('US' , 'USA') THEN 'United States'
	 WHEN TRIM(cntry)= '' OR TRIM(cntry) IS NULL THEN 'N/A'
	 ELSE TRIM(cntry)
END AS cntry
from bronze.erp_loc_a101;
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: % seconds',
EXTRACT(EPOCH FROM (end_time - start_time));
	


----------------silver.erp_px_cat_g1v2-------------------
start_time := clock_timestamp();

RAISE NOTICE  '>>Tuncating Table: silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
RAISE NOTICE  '>>Inserting Data into : silver.erp_px_cat_g1v2';

INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
select 
Id,
Cat,
Subcat,
maintenance
From bronze.erp_px_cat_g1v2;
end_time := clock_timestamp();
RAISE NOTICE'===========================================================';

RAISE NOTICE'===========================================================';
	batch_end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration of Bronze Layer: % seconds',
    EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
RAISE NOTICE'===========================================================';

	EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '=============================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        RAISE NOTICE 'ERROR CODE: %', SQLSTATE;
        RAISE NOTICE 'ERROR MESSAGE: %', SQLERRM;
        RAISE NOTICE '==============================================';
END;
$$;



