						--CREATE ANALYSIS TABLES BASED ON THE BUSINESS PROCESS THAT APPLIES
				
				
				--Sales Analysis
/*Check if there are any records in the EDW table. If no data has been entered, then account for all data from before today, else, 
move only n-1 data (from yesterday)*/
USE TescaOLTP
IF (SELECT COUNT(*) FROM TescaEDW.EDW.Fact_SalesAnalysis) <= 0
	SELECT 
		s.TransactionID,
		s.TransactionNO,
		DATEPART(HOUR, TransDate) TransHour,
		Convert(date, s.transdate) TransDate,
		Convert(date, s.orderdate) OrderDate,
		Datepart(HOUR, OrderDate) OrderHour,
		convert(Date, s.DeliveryDate) DeliveryDate,
		s.ChannelID,
		s.Customerid,
		S.EmployeeID, 
		S.ProductID, 
		S.StoreID, 
		S.PromotionID, 
		S.Quantity, 
		S.TaxAmount, 
		S.LineAmount, 
		s.linediscountamount,
		getdate() as LoadDate
		FROM SalesTransaction S WHERE convert(Date, TransDate) <= DATEADD(day, -1, convert(date, getdate())) 
ELSE
	SELECT 
		s.TransactionID,
		s.TransactionNO,
		DATEPART(HOUR, TransDate) TransHour,
		Convert(date, s.transdate) TransDate,
		Convert(date, s.orderdate) OrderDate,
		Datepart(HOUR, OrderDate) OrderHour,
		convert(Date, s.DeliveryDate) DeliveryDate,
		s.ChannelID,
		s.Customerid,
		S.EmployeeID, 
		S.ProductID, 
		S.StoreID, 
		S.PromotionID, 
		S.Quantity, 
		S.TaxAmount, 
		S.LineAmount, 
		s.linediscountamount,
		getdate() as LoadDate
	FROM SalesTransaction S WHERE convert(Date, TransDate) = DATEADD(day, -1, convert(date, getdate())) 

--Source count
IF (select count(*) FROM TescaEDW.EDW.FactSalesAnalysis) <=  0 
	SELECT count (*) as SourceCount FROM SalesTransaction WHERE convert(Date, TransDate) <= DATEADD(day, -1, convert(date, getdate()))
ELSE
	SELECT count (*) as SourceCount FROM SalesTransaction WHERE convert(Date, TransDate) = DATEADD(day, -1, convert(date, getdate()))

--Create SalesAnalysis table in staging environment	
USE TescaStaging
CREATE TABLE staging.SalesAnalysis(
	TransactionID int,
	TransactionNo nvarchar(50),
	TransDate date,
	TransHour int,
	OrderDate date,
	OrderHour int,
	DeliveryDate date,
	ChannelID int,
	CustomerID int,
	EmployeeID int,
	ProductID int,
	StoreID int,
	PromotionID int,
	Quantity float,
	TaxAmount float,
	LineAmount float,
	LineDiscountAmount float,
	LoadDate datetime default getdate(),
	constraint staging_SalesAnalysis_pk primary key (TransactionID)
)

--Destination count from staging table
select count (*) as DesCount from staging.SalesAnalysis
Truncate Table staging.SalesAnalysis

--Select the following data from the Staging to the EDW
SELECT 	TransactionID,TransactionNo,TransDate,TransHour,OrderDate,OrderHour,DeliveryDate,ChannelID,CustomerID,
EmployeeID,ProductID,StoreID,PromotionID,Quantity,TaxAmount,LineAmount,LineDiscountAmount, getdate() as LoadDate FROM Staging.SalesAnalysis

-- Create SalesAnalysis Fact Table in the EDW
select count (*) as CurrentCount from staging.SalesAnalysis

USE TescaEDW
SELECT COUNT (*) AS PreCount from EDW.factSalesAnalysis

Create Table EDW.factSalesAnalysis (
	SalesSk bigint identity (1,1),
	TransactionNo nvarchar (50), --degenerate dimension
	TransDateSk int,
	TransHourSk int,
	OrderDateSk int,
	OrderHourSk int,
	DeliverySk int,
	ChannelSk int,
	CustomerSK int,
	EmployeeSk int,
	ProductSk int,
	StoreSk int,
	PromotionSk int,
	Quantity float,
	TaxAmount float,
	LineAmount float,
	LineDiscountAmount float,
	LoadDate datetime default getdate(),
	constraint EDW_salesAnalysis_SlesSk primary key (SalesSk),
	-- lookup the business keys for each of the dimensions, to return the Surrogate keys
	constraint EDW_sales_Transdatesk foreign key (TransDateSk) references EDW.DimDate(DateSk),
	constraint EDW_sales_Transhoursk foreign key (TransHourSk) references EDW.DimTime(TimeSk),
	constraint EDW_sales_Orderdatesk foreign key (OrderDateSk) references EDW.DimDate(DateSk),
	constraint EDW_sales_Orderhoursk foreign key (OrderHourSk) references EDW.DimTime(TimeSk),
	constraint EDW_sales_Deliverysk foreign key (DeliverySk) references EDW.DimDate(DateSk),
	constraint EDW_sales_ChannelSk foreign key (ChannelSk) references EDW.DimPOSChannel(ChannelSk),
	constraint EDW_sales_Customersk foreign key (CustomerSk) references EDW.DimCustomer(CustomerSk),
	constraint EDW_sales_Employeesk foreign key (EmployeeSk) references EDW.DimEmployee(EmployeeSk),
	constraint EDW_sales_Productsk foreign key (ProductSk) references EDW.DimProduct(ProductSk),
	constraint EDW_sales_Storesk foreign key (StoreSk) references EDW.DimStore(StoreSk),
	constraint EDW_sales_Promotionsk foreign key (PromotionSk) references EDW.DimPromotion(PromotionSk),
)
SELECT COUNT (*) AS PostCount from EDW.factSalesAnalysis





				--Purchase Analysis
	USE TescaOLTP
	--Run data for all-time or n-1 data.
IF (SELECT count(*) from TescaEDW.EDW.Fact_PurchaseAnalysis) <= 0
	SELECT 
	P.TransactionID, 
	P.TransactionNo, 
	convert(date, P.TransDate) TransDate, 
	Convert(date, OrderDate) OrderDate, 
	Convert(date, DeliveryDate) DeliveryDate, 
	DATEDIFF(DAY, P.orderdate, P.deliverydate) + 1 as DifferentialDays,
	P.VendorID, 
	P.EmployeeID, 
	P.ProductID,
	P.StoreID,
	P.Quantity,
	P.TaxAmount,
	P.LineAmount,
	getdate() as LoadDate
	FROM PurchaseTransaction P
	WHERE Convert(date, p.TransDate) <= dateadd(day, -1, convert(date,getdate()))
ELSE
	SELECT 
	P.TransactionID, 
	P.TransactionNo, 
	convert(date, P.TransDate) TransDate, 
	Convert(date, OrderDate) OrderDate, 
	Convert(date, DeliveryDate) DeliveryDate, 
	DATEDIFF(DAY, P.orderdate, P.deliverydate) + 1 as DifferentialDays,
	P.VendorID, 
	P.EmployeeID, 
	P.ProductID,
	P.StoreID,
	P.Quantity,
	P.TaxAmount,
	P.LineAmount,
	getdate() as LoadDate
	FROM PurchaseTransaction P
	WHERE Convert(date, p.TransDate) = dateadd(day, -1, convert(date,getdate()))

--SourceCount from OLTP 
IF (SELECT COUNT (*) FROM TESCA.EDW.Fact_PurchaseAnalysis) <= 0
SELECT COUNT(*) AS SourceCount from PurchaseTransaction p
WHERE Convert(date, p.TransDate) <= dateadd(day, -1, convert(date,getdate()))
ELSE
SELECT COUNT(*) AS SourceCount from PurchaseTransaction p
WHERE Convert(date, p.TransDate) = dateadd(day, -1, convert(date,getdate()))


--Create PurchaseAnalysis table in staging environment	
Use TescaStaging
Create Table Staging.PurchaseAnalysis (
	TransactionID int,
	TransactionNo nvarchar(50),
	TransDate Date,
	OrderDate Date,
	DeliveryDate Date,
	VendorID int,
	EmployeeID int,
	ProductID int,
	StoreID int,
	DifferentialDays int,
	Quantity float,
	TaxAmount float,
	LineAmount float,
	LoadDate datetime default getdate(),
	constraint staging_purchaseabalysis_pk primary key (TransactionID)
	)

--Destination count from staging table
select count(*) as DesCount from staging.PurchaseAnalysis
Truncate Table Staging.PurchaseAnalysis 

SELECT COUNT(*) as CurrentCount from Staging.PurchaseAnalysis

--Select the following data from the Staging to the EDW
USE TescaStaging
SELECT P.TransactionID, P.TransactionNo, P.TransDate, P.OrderDate, P.DeliveryDate, P.VendorID, P.EmployeeID, P.ProductID,
P.StoreID, P.DifferentialDays, P.Quantity, P.TaxAmount, P.LineAmount, getdate() as LoadDate FROM Staging.PurchaseAnalysis P

-- Create PurchaseAnalysis Fact Table in the EDW
USE TescaEDW
Create Table EDW.FactPurchaseAnalysis(
	PurchaseAnalysisSK bigint identity (1,1),
	TransactionNo nvarchar(50), --degenerate dimension
	TransDateSK int,
	OrderDateSk int,
	DeliveryDateSk int,
	VendorSk int,
	EmployeeSk int,
	ProductSk int,
	StoreSk int,
	DifferentialDays int,
	Quantity float,
	TaxAmount float,
	LineAmount float,
	LoadDate datetime default getdate(),
	constraint edw_fact_PurchaseAnalysis_sk primary key(PurchaseAnalysisSk),
	constraint EDW_Purchase_Transdatesk foreign key (TransDateSk) references EDW.DimDate(DateSk),
	constraint EDW_Purchase_Orderdatesk foreign key (OrderDateSk) references EDW.DimDate(DateSk),
	constraint EDW_Purchase_DeliveryDatesk foreign key (DeliveryDateSk) references EDW.DimDate(DateSk),
	constraint EDW_Purchase_VendorSk foreign key (VendorSk) references EDW.DimVendor(VendorSk),
	constraint EDW_Purchase_Employeesk foreign key (EmployeeSk) references EDW.DimEmployee(EmployeeSk),
	constraint EDW_Purchase_Productsk foreign key (ProductSk) references EDW.DimProduct(ProductSk),
	constraint EDW_Purchase_Storesk foreign key (StoreSk) references EDW.DimStore(StoreSk),
	)


SELECT COUNT(*) as PreCount from EDW.FactPurchaseAnalysis
SELECT COUNT(*) as PostCount from EDW.FactPurchaseAnalysis





				--OVERTIME ANALYSIS (from .csv file)
---From CSV file into Staging area 
use TescaStaging
CREATE TABLE Staging.Overtime 
(
	OvertimeID int,
	EmployeeNo nvarchar(50),
	FirstName nvarchar(50),
	LastName nvarchar(50),
	StartOvertime datetime,
	EndOvertime datetime, 
	LoadDate datetime default getdate()
)

--Destination count from staging table
SELECT COUNT(*) As Descount from Staging.Overtime
Truncate Table Staging.Overtime

--Deduplicate to select data into the EDW
SELECT Max(OvertimeID), EmployeeNo, FirstName, LastName, StartOvertime, EndOvertime from Staging.Overtime
group by EmployeeNo, FirstName, LastName, StartOvertime, EndOvertime

--Select from deduplicated data to move from Staging to EDW.
Select OvertimeID, EmployeeNo, CONVERT(date, StartOvertime) StartOvertimeDate, DATEPART(hour, StartOvertime) StartOvertimeHour,
CONVERT(Date, EndOvertime) EndOvertime, DATEPART(hour, EndOvertime) EndOvertimehour,
convert(float, DATEDIFF(Minute, StartOvertime, EndOvertime)*1.0/60)  as OvertimeHours, LoadDate
from (
	SELECT Max(OvertimeID) OvertimeID, EmployeeNo, FirstName, LastName, StartOvertime, EndOvertime, LoadDate from Staging.Overtime
	group by EmployeeNo, FirstName, LastName, StartOvertime, EndOvertime, LoadDate
	) a

--Current Count	 
Select count (*) CurrentCount from 
	(
	SELECT Max(OvertimeID) OvertimeID, EmployeeNo, FirstName, LastName, StartOvertime, EndOvertime from Staging.Overtime
	group by EmployeeNo, FirstName, LastName, StartOvertime, EndOvertime
	) s

-- Create OvertimeAnalysis Fact Table in the EDW
use TescaEDW

Create Table EDW.FactOvertimeAnalysis (
	OvertimeSk bigint identity(1,1),
	OvertimeID int,
	EmployeeSk int,
	StartDateSK int,
	StartHourSk int,
	EndDateSk int, 
	EndHourSk int,
	OvertimeHour float, -- metric
	LoadDate datetime default getdate(),
	constraint EDW_overtimeanalysis_sk primary key (OvertimeSk),
	constraint EDW_overtime_employeeSk foreign key (EmployeeSk) references EDW.dimEmployee(employeeSk),
	constraint EDW_overtime_startdateSk foreign key (StartDateSk) references EDW.dimdate(dateSk),
	constraint EDW_overtime_starthourSk foreign key (StartHourSk) references EDW.dimTime(TimeSk),
	constraint EDW_overtime_EnddateSk foreign key (EndDateSk) references EDW.dimDate(dateSk),
	constraint EDW_overtime_EndhourSk foreign key (EndHourSk) references EDW.DimTime(timeSk)
	)

Select count(*) as PreCount from EDW.factovertimeAnalysis
Select count(*) as PostCount from EDW.factovertimeAnalysis





				--ABSENCE ANALYSIS
--first entry for the day is the record to be retained. i.e min.
 USE TescaStaging
 Create Table Staging.Absent_Analysis (
	AbsentSk bigint identity(1,1),
	empid int,
	Store int,
	Absent_Date date,
	Absent_hour int,
	Absent_category int,
	LoadDate datetime default getdate(),
	constraint staging_absent_pk primary key (AbsentSk)
	)

--Destination count from staging table
SELECT COUNT(*) DesCount from Staging.Absent_Analysis
Truncate table Staging.absent_analysis


--Deduplicate, and send data to the EDW
SELECT EmpID, Store, Absent_Date, Absent_hour, Absent_Category from staging.Absent_Analysis 
WHERE AbsentSk in
(SELECT min(AbsentSK) from staging.Absent_Analysis
group by empid, store, absent_date, absent_category)


--Current Count
	SELECT COUNT(*) CurrentCount FROM staging.Absent_Analysis 
		WHERE AbsentSk in
		(
		SELECT min(AbsentSK) from staging.Absent_Analysis
		group by empid, store, absent_date, absent_category
		 )

		 SELECT COUNT(*) AS Precount from EDW.FactAbsenceAnalysis
		 SELECT COUNT(*) AS PostCount from EDW.FactAbsenceAnalysis

-- Create AbsenceAnalysis Fact Table in the EDW
USE TescaEDW
Create Table EDW.FactAbsenceAnalysis
(
	AbsentSk bigint identity(1,1),
	employeeSk int,
	StoreSk int,
	Absent_DateSk int,
	Absent_hourSk int,
	Absent_categorySk int,
	constraint EDW_absentanalysis_sk primary key (AbsentSk),
	constraint EDW_Absent_StoreSK foreign key (StoreSk) references EDW.DimStore(StoreSk),
	constraint EDW_ABsent_EmployeeSk foreign Key (EmployeeSk) references EDW.DimEmployee(EmployeeSk),
	constraint EDW_absent_datesk foreign key (absent_datesk) references EDW.dimdate(datesk),
	constraint EDW_absent_categorysk foreign key (absent_categorysk) references EDW.dimAbsence(categorySk)
	)




				--MISCONDUCT ANALYSIS
use TescaStaging
--Create MisconductAnalysis table in staging environment	
Create Table Staging.Misconduct_Analysis(
	MisconSk bigint identity(1,1),
	Empid int,
	StoreID int,
	Misconduct_date date,
	Misconduct_id int,
	Decision_id int,
	LoadDate datetime default getdate(),
	constraint staging_misconSk_pk primary key (misconSk)
	)

	SELECT Count(*) AS PreCount from EDW.FactMisconductAnalysis
	SELECT Count(*) AS PostCount from EDW.FactMisconductAnalysis

--Destination count from staging table
SELECT Count(*) as DesCount from staging.Misconduct_Analysis
TRUNCATE TABLE Staging.Misconduct_Analysis

--Select only the most recent entry as the data to keep
		SELECT MAX(misconSk) MisconSk, EmpID, StoreId, Misconduct_date, misconduct_id, decision_id
		from staging.misconduct_analysis
		Group By EmpID, StoreId, Misconduct_date, misconduct_id, decision_id

---Select the most recent entry from staging to the EDW
		SELECT MisconSk, EmpID, StoreId, Misconduct_date, misconduct_id, decision_id, getdate() as LoadDate
		from staging.misconduct_analysis where misconsk in 
		(
		SELECT MAX(misconSk) from staging.misconduct_analysis
		Group By EmpID, StoreId, Misconduct_date, misconduct_id, decision_id
		) 

--Current count
SELECT COUNT (*) AS CURRENTCOUNT
FROM staging.misconduct_analysis where misconsk in 
(
SELECT MAX(misconSk) from staging.misconduct_analysis
Group By EmpID, StoreId, Misconduct_date, misconduct_id, decision_id
) 

-- Create MisconductAnalysis Fact Table in the EDW
USE TescaEDW
Create Table EDW.FactMisconductAnalysis (
	MisconSk bigint identity(1,1),
	EmployeeSk int,
	StoreSk int,
	Misconduct_datesk int,
	Misconductid_Sk int,
	Decisionid_sk int,
	LoadDate datetime default getdate(),
	constraint EDW_misconSk_sk primary key (misconSk),
	constraint EDW_Misconduct_employee_Sk foreign key(employeeSk) references edw.dimEmployee(employeeSk),
	constraint EDW_misconduct_store_sk foreign key(storesk) references edw.dimstore(storesk),
	constraint edw_misconduct_Date_sk foreign key(misconduct_datesk) references edw.dimdate(datesk),
	constraint edw_misconduct_misconduct_sk foreign key(misconductid_sk) references edw.dimmisconduct(MisconductSk),
	constraint edw_misconduct_decision_sk foreign key(decisionid_sk) references edw.dimDecision(DecisionSk)
	)

	DROP TABLE EDW.Fact_Misconduct_Analysis