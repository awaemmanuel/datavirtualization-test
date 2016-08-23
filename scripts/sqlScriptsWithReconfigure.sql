

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'S0me!nfo';

CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
WITH IDENTITY = 'emawa060716', Secret = '2fo5F8Jy42swqlSbhRO8qMbZLt1vc3XJ93ohfhYIOfRIr+Px+3WYtq6IU506pPHO063xDrTC9M6XnU4D/VATOg==' ;


CREATE EXTERNAL DATA SOURCE AzureStorage WITH (
	TYPE = HADOOP,
	LOCATION = 'wasb://onpremtoblob@emawa060716.blob.core.windows.net/',
	CREDENTIAL = AzureStorageCredential	
);

CREATE EXTERNAL FILE FORMAT TextFileFormat WITH (
	FORMAT_TYPE = DELIMITEDTEXT,
	FORMAT_OPTIONS (FIELD_TERMINATOR = ',',
					USE_TYPE_DEFAULT = TRUE)
);

--- Create the empty product table to project the results
DROP EXTERNAL TABLE Product;
CREATE EXTERNAL TABLE Product(
	ProductID INT,
	Name NVARCHAR(50),
	ProductNumber nvarchar(25),
	MakeFlag BIT,
	FinishedGoodsFlag BIT,
	Color NVARCHAR(15),
	SafetyStockLevel smallint,
	ReorderPoint smallint,
	StandardCost money,
	ListPrice money,
	Size NVARCHAR(5) ,
	SizeUnitMeasureCode NCHAR(3) ,
	WeightUnitMeasureCode NCHAR(3),
	Weight decimal(8, 2),
	DaysToManufacture int,
	ProductLine NCHAR(2),
	Class NCHAR(2),
	Style NCHAR(2),
	ProductSubcategoryID int,
	ProductModelID int,
	SellStartDate datetime,
	SellEndDate datetime ,
	DiscontinuedDate datetime,
	rowguid NVARCHAR (255),
	ModifiedDate datetime
)
WITH (LOCATION='/',
	  DATA_SOURCE = AzureStorage,
	  FILE_FORMAT = TextFileFormat
);

CREATE EXTERNAL TABLE WorkOrder (
	WorkOrderID int,
	ProductID int,
	OrderQty int,
	StockedQty  int,
	ScrappedQty smallint,
	StartDate datetime,
	EndDate datetime,
	DueDate datetime,
	ScrapReasonID smallint,
	ModifiedDate datetime
)
WITH (LOCATION='/work_order',
	  DATA_SOURCE = AzureStorage,
	  FILE_FORMAT = TextFileFormat
);

sp_configure 'allow polybase export', 1;
reconfigure
--- Move OnPrem data to HDI via Blob using Polybase
-- insert into external table select * Fro
INSERT INTO dbo.WorkOrder SELECT * FROM AdventureWorks2012.Production.WorkOrder;


SELECT  name, value  
    FROM  sys.database_scoped_configurations  
    WHERE name = 'LEGACY_CARDINALITY_ESTIMATION';  


SELECT    d.name, d.compatibility_level  
    FROM  sys.databases AS d;


SELECT ServerProperty('ProductVersion');  
go  
  
ALTER DATABASE AdventureWorks2012  
    SET COMPATIBILITY_LEVEL = 130;  
go  
  
SELECT    d.name, d.compatibility_level  
    FROM  sys.databases AS d  
    WHERE d.name = 'AdventureWorks2012';  
go  

