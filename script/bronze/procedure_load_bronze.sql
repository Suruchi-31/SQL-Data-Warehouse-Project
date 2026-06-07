/* 
=========================================================================
 Stored procedure : Load Bronze Layer (Source-> Bronze)
=========================================================================
Script Purpose:
       This stored procedure loads data into 'bronze' schema from external CSV files 
       It performs the following actions:-
         - Truncates the bronze tables before loading the data.
         - Uses the 'COPY' command to load data from csv files to bronze tables.

Parameters: 
     None
     This stored procedure does not accept any parameters and return any values

Usage Example:- 
          CALL bronze.load_bronze();
===============================================================================

*/




----Create Stored Procedure----

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
	RAISE NOTICE' Loading  Bronze Layer';
	RAISE NOTICE'===========================================================';
	
	RAISE NOTICE'-----------------------------------------------------------';
	RAISE NOTICE' Loading CRM Tables';
	RAISE NOTICE'-----------------------------------------------------------';
------crm_cust_info-------------
	start_time := clock_timestamp();
	RAISE NOTICE'>>>Truncating Tables: bronze.crm_cust_info>>>>';
	    TRUNCATE TABLE bronze.crm_cust_info;
	
	RAISE NOTICE'>>>Inserting Data into : bronze.crm_cust_info>>>>';
		COPY bronze.crm_cust_info
		FROM 'C:/PostgresData/cust_info.csv'
		DELIMITER ','
		CSV HEADER;
    end_time := clock_timestamp();

---EPOCH means:Convert the interval into the total number of seconds.

	RAISE NOTICE 'Load Duration: % seconds',
	EXTRACT(EPOCH FROM (end_time - start_time));
	
-------------crm_prd_info-------------------
	start_time := clock_timestamp();
	RAISE NOTICE'>>>Truncating Tables:bronze.crm_prd_info>>>>';
	    TRUNCATE TABLE bronze.crm_prd_info;
		
	RAISE NOTICE '>>>Inserting Data into : bronze.crm_prd_info>>>>';
		COPY bronze.crm_prd_info
		FROM 'C:/PostgresData/prd_info.csv'
		DELIMITER ','
		CSV HEADER;
    end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds',
    EXTRACT(EPOCH FROM (end_time - start_time));

---------crm_sales_details-------
	
	start_time := clock_timestamp();
	RAISE NOTICE'>>>Truncating Tables: bronze.crm_sales_details>>>>';
	
	    TRUNCATE TABLE bronze.crm_sales_details;
		
	RAISE NOTICE'>>>Inserting Data into :bronze.crm_sales_details>>>>';
		COPY bronze.crm_sales_details
		FROM 'C:/PostgresData/sales_details.csv'
		DELIMITER ','
		CSV HEADER;
	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds',
    EXTRACT(EPOCH FROM (end_time - start_time));

RAISE NOTICE'-----------------------------------------------------------';
RAISE NOTICE' Loading ERP Tables';
RAISE NOTICE'-----------------------------------------------------------';

-------------erp_loc_a101-----------------
	start_time := clock_timestamp();
	RAISE NOTICE'>>>Truncating Tables: bronze.erp_loc_a101>>>>';
	 TRUNCATE TABLE bronze.erp_loc_a101;
	
	RAISE NOTICE'>>>Inserting Data into : bronze.erp_loc_a101>>>>';
		COPY bronze.erp_loc_a101
		FROM 'C:/PostgresData/loc_a101.csv'
		DELIMITER ','
		CSV HEADER;
	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds',
    EXTRACT(EPOCH FROM (end_time - start_time));

-------------erp_cust_az12---------------
	start_time := clock_timestamp();
	RAISE NOTICE'>>>Truncating Tables: bronze.erp_cust_az12>>>>';
	TRUNCATE TABLE bronze.erp_cust_az12;
	
	RAISE NOTICE'>>>Inserting Data into :bronze.erp_cust_az12>>>>';
		COPY bronze.erp_cust_az12
		FROM 'C:/PostgresData/cust_az12.csv'
		DELIMITER ','
		CSV HEADER;
    end_time := clock_timestamp(); 
	RAISE NOTICE 'Load Duration: % seconds',
    EXTRACT(EPOCH FROM (end_time - start_time));

----------erp_px_cat_g1v2------------------------
	start_time := clock_timestamp();
	RAISE NOTICE'>>>Truncating Tables: bronze.erp_px_cat_g1v2>>>>';	
	
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	
	RAISE NOTICE'>>>Inserting Data into :bronze.erp_px_cat_g1v2>>>>';
			COPY bronze.erp_px_cat_g1v2
			FROM 'C:/PostgresData/px_cat_g1v2.csv'
			DELIMITER ','
			CSV HEADER;
    end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds',
    EXTRACT(EPOCH FROM (end_time - start_time));

RAISE NOTICE'===========================================================';
	batch_end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration of Bronze Layer: % seconds',
    EXTRACT(EPOCH FROM (batch_end_time - batch_start_time));
RAISE NOTICE'===========================================================';
	

	EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '=============================================';
        RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'ERROR CODE: %', SQLSTATE;
        RAISE NOTICE 'ERROR MESSAGE: %', SQLERRM;
        RAISE NOTICE '=============================================';
END;
$$;


