/*
=======================================
Create Database and Schemas
=======================================
Script Purpose:
  This script creates a new database and named 'DataWarehouse2025' after checking if it already exists.
If the databse exists, it is dropped and recreated. Additionally, the script sets up three screams 
within the databse: 'bronze', 'silver', 'gold'.

WARNING:
Running this script will drop the entire 'DataWarehouse2025' database if it exists.
All data in the databse will be permanently deleted. Proceed tih caution and 
ensure you have proper backips before running this script.
*/
 -- master - A system database to create other databases
USE master;
GO

-- Drop and recreate the 'DataWarehouse2025' databse
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse2025')
BEGIN
	ALTER DATABASE DataWarehouse2025 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse2025;
END
GO

-- create the 'DataWarehouse2025' database
CREATE DATABASE DataWarehouse2025;

-- switch to new database
USE DataWarehouse2025;

/*creating schemas - a placeholder for database tables.
         Bronze Layer,Silver Layer, Gold Layer
*/
CREATE SCHEMA bronze;

GO
CREATE SCHEMA silver;

GO 
CREATE SCHEMA gold;
