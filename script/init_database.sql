/* 
===============================================================================
Create Database and Schemas
===============================================================================
Script pupose: 
           This script crates a new database named 'DataWarehouse' after checking if it is already exists.
           If the database exists , it is dropped and recreated . Additionaly the script set up three schemas 
           within the database : 'bronze', 'silver' , 'gold'.

WARNING:
        Running this script will drop the entire 'DataWarehouse' databsae if it exists.
        All data in the database wilkl be permanently deleted . proceed with caution 
        and ensure you have proper backups before running the scripts.
*/

DROP DATABASE IF EXISTS datawarehouse;
CREATE DATABASE datawarehouse;

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
