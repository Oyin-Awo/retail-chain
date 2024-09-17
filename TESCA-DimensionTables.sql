--TESCA OLTP - Daily transactions at the store are stored in this database.
--TESCAStaging - Staging area for temporary storage of daily transactions


				-- PRODUCT DATA
USE TescaOLTP
/*Count source data from OLTP to ensure that the correct number of rows are moved from OLTP to Staging*/
--Source count from OLTP table
SELECT Count (*) AS SourceCount from Product p
INNER JOIN Department D ON P.DepartmentID = D.DepartmentID

--Selected columns From OLTP Product table to Staging Product table
SELECT P.ProductID, P.Product, P.ProductNumber, P.UnitPrice, D.Department FROM dbo.Product P
INNER JOIN Department D ON P.DepartmentID = D.DepartmentID

--Create Product table in staging environment
USE TescaStaging
CREATE TABLE staging.product (
	ProductID int,
	Product nvarchar(50),
	ProductNumber nvarchar(50),
	UnitPrice float, 
	Department nvarchar(50),
	LoadDate datetime default getdate(),
	constraint staging_product_pk primary key (productid)
)

--Destination count from staging table
SELECT COUNT(*) as DesCount FROM Staging.product 
TRUNCATE TABLE Staging.Product 

--Select the following data from the Staging to the EDW
SELECT Productid, product, productnumber, unitprice, department FROM Staging.Product

--Create Product dimension table in EDW
USE TescaEDW
SELECT COUNT(*) AS PreCount from EDW.DimProduct

CREATE TABLE EDW.DimProduct (
	ProductSK int Identity(1,1),
	ProductID int,
	Product nvarchar(50),
	ProductNumber nvarchar(50),
	UnitPrice float, 
	Department nvarchar(50),
	EffectiveStartDate datetime,
	EffectiveEndDate datetime
	constraint edw_dimproduct_sk primary key (productsk)
)

SELECT * FROM EDW.DimProduct





				-- PROMOTION DATA
USE TescaOLTP
/*Count source data from OLTP to ensure that the correct number of rows are moved from OLTP to Staging*/
--Source count from OLTP table
select count (*) as SourceCount from promotion p
inner join PromotionType t on p.PromotionTypeID=t.PromotionTYPEID

--Selected columns From OLTP Promotion table to Staging Promotion table
SELECT p.PromotionID, T.Promotion, P.Startdate, p.EndDate, p.DiscountPercent, getdate() LoadDate from promotion p
inner join promotiontype t on p.promotiontypeid = t.PromotionTypeID

--Create Promotion table in staging environment
use TescaStaging
Create Table Staging.promotion
(
	PromotionID int,
	Promotion nvarchar(50),
	StartDate date,
	EndDate date,
	DiscountPercent float,
	Loaddate datetime default getdate(),
	constraint staging_promotion_sk primary key (promotionID)
)

--Destination count from staging table
SELECT count (*) DesCount from staging.promotion
truncate table staging.promotion

--Select the following data from the Staging to the EDW
Select  PromotionID, Promotion, StartDate, EndDate, discountpercent FROM STAGING.PROMOTION

--Create Promotion dimension table in EDW
USE TescaEDW
Create Table EDW.DimPromotion 
(
	PromotionSK int identity(1,1),
	PromotionID int,
	Promotion nvarchar(50),
	StartDate date,
	EndDate date,
	DiscountPercent float,
	EffectiveStartDate datetime,
	constraint edw_promotion_sk primary key (promotionsk)
)

SELECT * FROM EDW.DimPromotion
SELECT COUNT(*) PreCount FROM EDW.DimPromotion
SELECT COUNT(*) PostCount FROM EDW.DimPromotion





				--STORE DATA
USE TescaOLTP
/*Count source data from OLTP to ensure that the correct number of rows are moved from OLTP to Staging*/
--Source count from OLTP table
select count (*) as SourceCount from Store S
Inner join city c on s.CityID = c.CityID
inner join state st on s.StateID = st.StateID

--Selected columns From OLTP Store table to Staging Store table
Select s.storeID, S.StoreName, s.StreetAddress, c.CityName, st.State, getdate() as LoadDate from store S
Inner join city c on s.CityID = c.CityID
inner join state st on s.StateID = st.StateID

--Create Store table in staging environment
USE TescaStaging
Create Table Staging.store 
(
	StoreID int,
	StoreName nvarchar(50),
	StreetAddress nvarchar(50),
	CityName nvarchar(50),
	State nvarchar(50),
	LoadDate datetime default getdate(),
	constraint staging_store_pk primary key (StoreId)
)

--Destination count from staging table
select count (*) as Descount from Staging.store 
truncate table Staging.Store

--Select the following data from the Staging to the EDW
SELECT StoreID, StoreName, StreetAddress, CityName, State from staging.store

--Create Store dimension table in EDW
use TescaEDW
select count (*) as PreCount from EDW.DimStore

CREATE TABLE EDW.DimStore
(
	StoreSK int identity (1,1),
	StoreID int,
	StoreName nvarchar(50),
	StreetAddress nvarchar(50),
	CityName nvarchar(50),
	State nvarchar(50),
	EfectiveStartDate datetime,
	constraint edw_dimstore_sk primary key (StoreSK)
)
SELECT Count(*) as PostCount from EDW.DimStore
SELECT * FROM EDW.DimStore




				--CUSTOMER DATA
USE TescaOLTP
/*Count source data from OLTP to ensure that the correct number of rows are moved from OLTP to Staging*/
--Source count from OLTP table
SELECT Count(*) as SourceCount from Customer c
inner join city ct on c.CityID=ct.CityID
inner join state s on ct.StateID = s.StateID

--Selected columns From OLTP Customer table to Staging Customer table
Select c.CustomerID, CONCAT(Upper(c.LastName),',',c.FirstName) as Customer, c.CustomerAddress, ct.CityName as City, s.State, getdate() as LoadDate
from Customer c
inner join city ct on c.CityID=ct.CityID
inner join state s on ct.StateID = s.StateID

--Create Customer table in staging environment
USE TescaStaging  
CREATE TABLE Staging.Customer
(
	CustomerID int, 
	Customer nvarchar(250), 
	CustomerAddress nvarchar(50), 
	City nvarchar(50),
	State nvarchar (50),
	LoadDate datetime default getdate(),
	constraint staging_customer_pk primary key (CustomerID)
)

--Destination count from staging table
SELECT COUNT(*) as DesCount from Staging.Customer
Truncate table 

--Select the following data from the Staging to the EDW
select CustomerID, Customer, CustomerAddress, City, State from Staging.Customer

--Create Customer dimension table in EDW
USE TescaEDW
SELECT COUNT (*) as PreCount from EDW.DimCustomer

Create Table EDW.DimCustomer 
(
	CustomerSK int identity (1,1),
	CustomerID int, 
	Customer nvarchar(250), 
	CustomerAddress nvarchar(50), 
	City nvarchar(50),
	State nvarchar (50),
	EffectiveStartDate datetime,
	constraint EDW_dimcustomer_sk primary key (CustomerSK)
	)


SELECT Count (*) as PostCount from EDW.DimCustomer
SELECT * FROM EDW.DimCustomer




				--POSChannel DATA
USE TESCAOLTP
/*Count source data from OLTP to ensure that the correct number of rows are moved from OLTP to Staging*/
--Source count from OLTP table
Select count(*) as SourceCount from POSChannel p

--Selected columns From OLTP POSChannel to Staging POSChannel
Select P.ChannelID, P.ChannelNo, p.DeviceModel, p.SerialNo, p.InstallationDate, getdate() as LoadDate from POSChannel P

--Create POSChannel table in staging environment
USE TescaStaging
CREATE TABLE Staging.POSChannel
(
	ChannelID int, 
	ChannelNo nvarchar(50), 
	DeviceModel nvarchar (50), 
	SerialNo nvarchar (50), 
	InstallationDate date,
	LoadDate datetime default getdate(),
	Constraint staging_posChannel_pk primary key (ChannelID)
)

--Destination count from staging table
SELECT COUNT(*) as DesCount from staging.POSChannel 
Truncate Table staging.POSChannel 

--Select the following data from the Staging to the EDW
SELECT ChannelID, ChannelNo, DeviceModel, SerialNo, InstallationDate FROM STaging.POSChannel

--Create POSChannel dimension table in EDW
USE TescaEDW
CREATE TABLE EDW.DimPOSChannel
(
	ChannelSK int identity(1,1),
	ChannelID int, 
	ChannelNo nvarchar(50), 
	DeviceModel nvarchar (50), 
	SerialNo nvarchar (50), 
	InstallationDate date,
	EffectiveStartDate datetime,
	EffectiveEndDate datetime,
	Constraint EDW_DIMposChannel_pk primary key (ChannelSK)
	)
SELECT COUNT(*) as PreCount FROM EDW.DimPOSChannel
SELECT COUNT (*) as PostCount FROM EDW.DimPOSChannel





				--Time EDW
/*
0 to 23
Business hours: 0-7 Closed, 8-17 Open, 18-23 Closed
Period of Day - 
	00:00 Midnight
	1-4 Early Morning
	5-11 Morning
	12 noon 
	13-17 Afternoon
	18-21 Evening
	22-23 Night
*/

--Create Time dimension table in EDW
USE TescaEDW
CREATE TABLE EDW.DimTime
(
	TimeSK int identity(1,1),
	TimeHour int,    --- 0-23
	TimeInterval nvarchar(20) not null,   ----00:00-00:59
	BusinessHour nvarchar(20) not null,
	PeriodofDay nvarchar(20) not null,
	LoadDate datetime default getdate(),
	constraint EDW_DimTime_sk primary key(TimeSK)
	)

--SELECT RIGHT(CONCAT('0','0'), 2)+':00-' + RIGHT(CONCAT('0','0'), 2)+':59'
--SELECT RIGHT(CONCAT('0','12'), 2)+':00-' + RIGHT(CONCAT('0','12'), 2)+':59'
/*ROLLING HOURS
BEGIN
	PRINT (@CurrentHour)
	PRINT (RIGHT(CONCAT('0', @currentHour), 2)+':00-' + RIGHT(CONCAT('0',@currentHour), 2)+':59')
	SELECT @CurrentHour = @CurrentHour+1
END*/

-- Create stored procedure to create time formats
CREATE PROCEDURE EDW.DimTimeGenerator
AS
BEGIN
SET NOCOUNT ON
declare @currentHour int = 0
IF OBJECT_ID('EDW.DIMTIME') IS NOT NULL
	TRUNCATE TABLE EDW.DIMTIME

While @CurrentHour<=23
	BEGIN
		INSERT INTO EDW.DimTime (TimeHour, TimeInterval, BusinessHour, PeriodofDay, LoadDate)
		SELECT 
			@currentHour,
			(RIGHT(CONCAT('0', @currentHour), 2)+':00-' + RIGHT(CONCAT('0',@currentHour), 2)+':59'),
			CASE
				WHEN (@currentHour>=0 and @currentHour<=7  or @currentHour>=18 and @currentHour<=23) THEN 'Closed'
				WHEN (@currentHour >=8 and @currentHour<=17) THEN 'Open'
			END,
			CASE
				WHEN @currentHour = 0 THEN 'Midnight'
				WHEN @CurrentHour>= 1 and @CurrentHour <= 4 THEN 'Early Morning'
				WHEN @currentHour >= 5 and @currentHour <=11 THEN 'Morning' 
				WHEN @currentHour = 12 THEN 'Noon'
				WHEN @currentHour >= 13 and @currentHour <=17 THEN 'Afternoon' 
				WHEN @currentHour >= 18 and @currentHour <=21 THEN 'Evening' 
				ELSE 'Night'
			END, 
			getdate()
		SELECT @CurrentHour = @CurrentHour+1
	END
END 
SELECT * FROM EDW.DimTime

--execute the stored procedure
EXEC edw.DimTimeGenerator





				--EMPLOYEE DATA
USE TESCAOLTP
/*Count source data from OLTP to ensure that the correct number of rows are moved from OLTP to Staging*/
--Source count from OLTP table
SELECT COUNT(*) AS SourceCount from Employee E
INNER JOIN MaritalStatus M ON E.MaritalStatus = M.MaritalStatusID

--Selected columns From OLTP Employee table to Staging Employee table
SELECT E.EmployeeID, E.EmployeeNo, CONCAT(UPPER(E.LastName),' ', E.FirstName) as Employee, E.DoB, M.MaritalStatus, getdate() as LoadDate from Employee E
INNER JOIN MaritalStatus M ON E.MaritalStatus = M.MaritalStatusID

--Create Employee table in staging environment
USE TescaStaging
CREATE TABLE Staging.Employee (
	EmployeeID int,
	EmployeeNo nvarchar(50),
	Employee nvarchar(255),
	DoB date,
	MaritalStatus nvarchar(50),
	LoadDate datetime default getdate(),
	constraint staging_employee_pk primary key (EmployeeID)
	)
select count(*) as CurrentCount from staging.employee
Truncate table Staging.employee

--Select the following data from the Staging to the EDW
select e.employeeid, e.employeeNo, e.employee, e.dob, e.maritalstatus from staging.employee e

--Create Employee dimension table in EDW
USE TescaEDW
CREATE TABLE EDW.DimEmployee
(
	EmployeeSK int identity(1,1),
	EmployeeID INT,
	EmployeeNo nvarchar(50),
	Employee nvarchar(255),
	DoB date,
	MaritalStatus nvarchar(50),
	EffectiveStartDate datetime,
	EffectiveEndDate datetime,
	constraint EDW_DimEmployee_sk primary key(EmployeeSK)
)

SELECT COUNT(*) as PreCount FROM EDW.DimEmployee
SELECT COUNT(*) as PostCount FROM EDW.DimEmployee





				--VENDOR DATA
use TescaOLTP
/*Count source data from OLTP to ensure that the correct number of rows are moved from OLTP to Staging*/
--Source count from OLTP table
SELECT COUNT (*) as SourceCount FROM Vendor V
INNER JOIN City C ON V.CityID = C.CityID
INNER JOIN STATE S ON C.StateID = S.StateID

--Selected columns From OLTP Vendor table to Staging Vendor table
SELECT V.VendorID, V.VendorNo, V.RegistrationNo, CONCAT(UPPER(V.LastName),' ', V.FirstName) AS Vendor, V.VendorAddress,
C.CityName, S.State, getdate() as LoadDate FROM Vendor V 
INNER JOIN City C ON V.CityID = C.CityID
INNER JOIN STATE S ON C.StateID = S.StateID


--Create Vedndor table in staging environment
USE TescaStaging
CREATE TABLE Staging.Vendor (
	VendorID int,
	VendorNo nvarchar(50),
	Vendor nvarchar (255),
	RegistrationNo nvarchar(50),
	VendorAddress nvarchar(50),
	City nvarchar(50),
	State nvarchar(50),
	LoadDate datetime default getdate(),
	constraint staging_vendor_pk primary key (VendorID)
	)
--Destination count from staging table
SELECT Count(*) as desCount FROM Staging.vendor
TRUNCATE TABLE staging.vendor

--Select the following data from the Staging to the EDW
select 	VendorID, VendorNo, Vendor, RegistrationNo ,VendorAddress, City, State from staging.vendor
SELECT Count(*) as CurrentCount FROM Staging.vendor

--Create Vendor dimension table in EDW
USE TescaEDW
CREATE TABLE EDW.DimVendor
(
	VendorSK int identity(1,1),
	VendorID int,
	VendorNo nvarchar(50),
	Vendor nvarchar (255),
	RegistrationNo nvarchar(50),
	VendorAddress nvarchar(50),
	City nvarchar(50),
	State nvarchar(50),
	EffectiveStartDate datetime,
	EffectiveEndDate datetime,
	constraint EDW_dimvendor_sk primary key (VendorSK)
)

select count (*) as PostCount from EDW.dimVendor
SELECT COUNT (*) as PreCount from EDW.DimVendor
SELECT * FROM EDW.DIMVENDOR




							
				--MISCONDUCT DATA (from .csv file)
--Create Misconduct table in staging environment
USE TescaStaging
CREATE TABLE Staging.Misconduct
(
misconductid int,
misconductdesc nvarchar (255),
LoadDate datetime default getdate()
)

--Destination count from staging table
select count(*) Descount from staging.misconduct
truncate table staging.misconduct

--Extract all data, including duplicates from the staging table. 
select * from staging.misconduct

--get rid of duplicates
select count(*) as CurrentCount from
	(
	Select misconductid, misconductdesc from staging.Misconduct
	group by misconductid, misconductdesc
	) M

select misconductid, misconductdesc from staging.misconduct
group by misconductid, misconductdesc

--Create Misconduct dimension table in EDW
USE TescaEDW
CREATE TABLE EDW.DimMisconduct
(
	MisconductSK int identity (1,1),
	MisconductID int,
	Misconductdesc nvarchar(255),
	EffectiveStartDate datetime,
	constraint edw_Dimmisconduct_sk primary key (MisconductSK)
)

SELECT * FROM EDW.DIMMISCONDUCT
SELECT COUNT(*) AS PreCOUNT FROM EDW.DIMMISCONDUCT
SELECT COUNT(*) AS PostCOUNT FROM EDW.DIMMISCONDUCT





				-- MISCONDUCT DECISION DATA (from .csv file)
--Create Decision table in staging environment
USE TescaStaging
Create Table Staging.decision
(
	DECISION_ID int,
	Decision nvarchar(255),
	Loaddate datetime default getdate()
)

--Destination count from staging table
SELECT count(*) DesCount from Staging.Decision
Truncate table Staging.decision

select * from staging.decision

--Count the data loaded into staging without duplicates
--1. 
SELECT COUNT(*) AS CurrentCount FROM 
	(
	SELECT Decision_id, Decision from Staging.decision
	group by decision_id, decision) d
--2. 
WITH Decision_CTE AS
(SELECT Decision_id, Decision from Staging.decision
group by decision_id, decision)
select count(*) CurrentCount from Decision_CTE

--Select the following data from the Staging to the EDW
		WITH Decision_CTE AS
		(SELECT Decision_id, Decision from Staging.decision
		group by decision_id, decision)
		select decision_id, decision, getdate() as EffectiveStartDate from Decision_CTE

		SELECT COUNT (*) as PreCount FROM STAGING.Decision

--Create Decision dimension table in EDW
USE TescaEDW
CREATE Table EDW.DimDecision
(
	DecisionSK int identity(1,1),
	Decision_id int,
	Decision nvarchar(255),
	EffectiveStartDate datetime,
	constraint edw_dimdecision_sk primary key (decisionsk)
)

select count(*) PreCount from EDW.DimDecision
SELECT Count(*) PostCount from EDW.DimDecision





				--EMPLOYEE ABSENCE DATA (from .csv file)
--Create Absence table in staging environment
USE TescaStaging
CREATE TABLE Staging.Absence 
(
	categoryid int,
	category nvarchar(255),
	LoadDate datetime default getdate()
)

--Destination count from staging table
select count (*) as descount from staging.absence
truncate table staging.absense

--Select the following UNIQUE rows from the Staging to the EDW
With Absence_CTE as (
SELECT Categoryid, category from staging.absence
group by categoryid, category
)
SELECT Categoryid, category, getdate() as EffectiveStartDate from Absence_CTE

select count(*) as currentcount from staging.absence
group by categoryid, category

--Create Absence dimension table in EDW
USE TescaEDW
CREATE TABLE EDW.DimAbsence (
	categorysk int identity (1,1),
	categoryid int,
	caegory nvarchar(255),
	EffectiveStartDate datetime,
	constraint edw_DimAbsence_sk primary key (categorysk)
	)

	select count(*) as PreCount from EDW.DIMABSENCE
	select count(*) as PostCount from EDW.DIMABSENCE

SELECT * FROM EDW.DimAbsence







