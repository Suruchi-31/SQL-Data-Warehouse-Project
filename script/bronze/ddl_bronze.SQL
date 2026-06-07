/* 
====================================================================
DDL Script : Create Bronze Tables
====================================================================
Script Purpose:
   This Script creates tables in the brinze schema , dropping 
   existing tables if they already exists.
   Run this script to re-define the DDL sctrucrure of 'bronze' tables
====================================================================
CREATE TABLE bronze.crm_cust_info(
 cst_id INT,
 cst_key VARCHAR(50),
 cst_firstname VARCHAR(50),
 cst_lastname VARCHAR(50),
 cst_marital_status VARCHAR(50),
 cst_gender VARCHAR(50),
cst_create_date DATE
);

CREATE TABLE bronze.crm_prd_info(
 prd_id INT,
 prd_key VARCHAR(50),
 prd_nm VARCHAR(50),
 prd_cost INT,		
 prd_line VARCHAR(50),
 prd_start_dt TIMESTAMP,
 prd_end_dt TIMESTAMP
);


CREATE TABLE bronze.crm_sales_details(
 sls_ord_num VARCHAR(50),
 sls_prd_key VARCHAR(50),
 sls_cust_id INT,
 sls_order_dt INT,
 sls_ship_dt INT,
 sls_due_dt INT,
 sls_sales INT,
 sls_quantity INT,
 sls_price INT
);


---CREATING TABLES FOR BRONZE LAYER---
CREATE Table IF NOT EXISTS bronze.erp_loc_a101(
    cid VARCHAR(50),
	cntry  VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12(
    cid VARCHAR(50),
	bdate DATE, 
	gen VARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2(
    cid VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
);

select * from bronze.crm_cust_info;
select * from bronze.crm_prd_info;
select * from bronze.crm_sales_details;

