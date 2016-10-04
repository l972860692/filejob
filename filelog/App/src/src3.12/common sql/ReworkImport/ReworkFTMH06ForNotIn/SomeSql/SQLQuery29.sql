USE [Score]
GO
/****** Object:  StoredProcedure [dbo].[DCSNEW_DTS_ProcessRawMHOrders_193_06]    Script Date: 07/10/2015 15:44:02 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[DCSNEW_DTS_ProcessRawMHOrders_193_06] 

AS
/**********************************************************************************************************
   Author	:	ZHONGDE
   Date		:	14 JAN 2009
   Version	:	1.0
   Description	:	Process Uploaded MH Orders AS follows:
			1.  Reject Orders with blank ServiceNo
			2.  Reject Orders with unknown vendor code
			3.  Reject Orders with Mapped Component ServicePlanType is NA
			4.  Reject Orders with Duplicate OrderNumber
			
			Methods: Will upload all orders to their respective table in order to perform the
			following checking

			
			5.  Reject Orders that ceASed on the same month
			6.  Choose orders with more than one recon or provistion bASed on order closed date
			
	Revision History
	============
	Author		: Nelson Ku
	Date		: 10 JAN 2010
	Version		: 1.1
	Description	: Include code to identify FTTH Bundle Orders from MioHome Orders and segregate them into
				different raw table. Execute DCSNEW_DTS_ProcessRawFTOrder to process the FTTH Orders.
				
	Author		: Nelson Ku
	Date		: 03 May 2010
	Version		: 1.2
	Description	: 1. Modify the order data processing for the new updated dcPegMHOrdersTemp table structure
			  2. Identify FTTH orders by a new bundle indicator

	Author		: Chew Mee
	Date		: 08 Jul 2010
	Version		: 1.3
	Description	: Include time for order creation date and order close date to faciliate rejection of multiple orders.

	Author		: Zhenyu
	Date		: 20 Oct 2011
	Version		: 1.4
	Description	: Include new filed of identification of snbb for Consumer Sales and miotv for DGH
	
	Author		: Zhenyu
	Date		: 28 May 2012
	Version		: 1.5
	Description	: Interim solution of mapping the FTTH order under FTTH complist

***********************************************************************************************************/
DECLARE 
	@JobName AS NVARCHAR(10),
	@BatchNo AS INT,
	@BatchDate AS Datetime,
	--COUNTERS
	@RecTotal AS INT,
	@RecProv AS INT,
	@RecChange AS INT,
	@RecCeASe AS INT,
	@RecRej AS INT,
	@RecTakenOut AS INT,
	@RecRead AS bigINT,
	@RecCnt AS INT,
	--Other Information
	@ProcessDate AS Datetime,
	@ProcessStatus AS Char(1),
	@Remarks AS NVARCHAR(200),
	@HeaderData AS NVARCHAR(200),
	@TrailerData AS NVARCHAR(200)
BEGIN
	--SET ALL DEFAULT VALUE
	SET  @ProcessStatus = 'P'
	SET  @RecTotal 	    = 0
	SET  @RecProv 	    = 0
	SET  @RecChange     = 0
	SET  @RecCeASe 	    = 0
	SET  @RecRej 	    = 0
	SET  @RecTakenOut	= 0
	SET  @RecRead       = 0
	SET  @Remarks       = ''
	SET @ProcessDate = GETDATE()

	-- GATHER INFORMATION TO CHECK THE HEADER
	-- v1.2
	SELECT @HeaderData = RecordType+BundleInd+OrderNo+ServiceNo FROM  dcPegMHOrdersTemp WHERE RecordType = 'H'
	SELECT @TrailerData = RecordType+BundleInd+OrderNo+ServiceNo FROM  dcPegMHOrdersTemp WHERE RecordType = 'T'
	SELECT @JobName = SUBSTRING(@HeaderData,2,10)
	SELECT @BatchNo = CONVERT(INT,SUBSTRING(@HeaderData,12,4))
	SELECT @BatchDate = Convert(Datetime,Substring(@HeaderData,16,4) + '/'+Substring(@HeaderData,22,2) + '/' + Substring(@HeaderData,20,2) ,103)
	SELECT @RecTotal = Count(*) from dcPegMHOrdersTemp where RecordType = 'D'
	SELECT @RecRead = CONVERT(INT,SUBSTRING(@TrailerData,2,10))

	
	-- START TO CHECK THE HEADER
	-- =========== Repeated Execution ==============
	IF EXISTS(Select * from rdPegProcessLog where BatchNo = @BatchNo And JobName = @JobName And BatchDate = @BatchDate AND ProcessStatus = 'P')
		BEGIN
			SET @ProcessStatus = 'F'
			SET @Remarks = 'Repeated execution of  File with same Batch number Found.'
		END
	-- =========== JOB NAME IS NULL ==============
	ELSE IF @JobName IS null
		BEGIN
			SET @ProcessStatus = 'F'
			SET @Remarks =  'Header Record Not Found.'
		END
	-- =========== RecordNo IS NULL ==============
	ELSE IF @RecRead is null
		BEGIN
			SET @ProcessStatus = 'F'
			SET @Remarks =  (@Remarks + ' Trailer Record Not Found.')
		END
	-- =========== RecTotal IS NULL ==============
	ELSE IF @RecTotal <> @RecRead 
		BEGIN
			SET @ProcessStatus = 'F'
			SET @Remarks = 'Count Total Records different from provided trailer count records.'
		END
	/******End of check header trailer and records*****/
	
	
	/*******Process continues on status pASs after check header trailer and records*******/
	IF (@ProcessStatus = 'P' AND @RecTotal <> 0)
	BEGIN
		
		/*getting FTTH and MioHome product*/
		SELECT * INTO #rfSPCProductMasterFT FROM rfSPCProductMaster WHERE productfamily LIKE '%miohome%' AND servicetype = 'FTTH'
		SELECT * INTO #rfSPCProductMasterMH FROM rfSPCProductMaster WHERE productfamily LIKE '%miohome%' AND servicetype = 'ADSL'
	------------------------------find Miss orders-----------------------------------------------------------
--------------FT-----------------
--select * into dcPegMHOrdersRej_testFor20150629 from dcPegMHOrdersRej where 1=2
--select * into dcPegMHOrdersTemp_testFor20150630 from dcPegMHOrdersTemp where 1=2

insert into dcPegMHOrdersTemp select * from  dcPegMHOrdersTemp_testFor20150630


insert into dcPegMHOrdersTemp_testFor20150630 select * from  dcPegMHOrdersTemp

delete dcPegMHOrdersTemp_testFor20150630


select * from dcPegMHOrdersTemp_testFor20150630 where orderno='QHG1004001'

delete	rdPegProcessLog
			DECLARE @nowtime datetime =getdate()

            DECLARE @nowmonth  datetime =cast (year(@nowtime) as varchar(4))+'-'+cast( month(@nowtime) as varchar(2))+'-'+'01'
			select @nowtime
			select @nowmonth

set @nowmonth='2015-08-01'
select * into #missFTorders from  dcPegMHOrdersRej
		 where OrderCloseDate >= @nowmonth
		 and Remarks like '%non mio Home Orders%'
		 and  CompID not in (
		select ProductID from  #rfSPCProductMasterFT
		 )
		 
insert into dcPegFTOrdersMP(
RecordNo,
BANumber,
OrderNo,
ServiceNo,
ServiceType,
CustomerName,
CustomerID,
AddressPremiseNo,
AddressStreetNm,
AddressUnitNo,
AddressBuildingNo,
AddressDevelopNo,
AddressCountry,
AddressPostalCode,
CRD,
OrderCreationDate,
OrderCloseDate,
CompID,
CompDesc,
OrderAction,
PackageID,
PackageDesc,
Penalty,
MioContentCompID,
MioContentCompDesc,
SchemeID,
VendorCode,
DealerCode,
SalesmanCode,
OrderType,
CustClass,
Remarks,
BatchNo,
DateCreated,
SGOrderNo,
SGSvcType,
SGTxnType,
PTOrderNo,
PTSvcType,
PTTxnType)
select RecordNo,
BANumber,
OrderNo,
ServiceNo,
ServiceType,
CustomerName,
CustomerID,
AddressPremiseNo,
AddressStreetNm,
AddressUnitNo,
AddressBuildingNo,
AddressDevelopNo,
AddressCountry,
AddressPostalCode,
CRD,
OrderCreationDate,
OrderCloseDate,
CompID,
CompDesc,
OrderAction,
PackageID,
PackageDesc,
Penalty,
MioContentCompID,
MioContentCompDesc,
SchemeID,
VendorCode,
DealerCode,
SalesmanCode,
OrderType,
CustClass,
'becauseofmisscompid',
BatchNo,
DateCreated,
SGOrderNo,
SGSvcType,
SGTxnType,
PTOrderNo,
PTSvcType,
PTTxnType
from 
#missFTorders

delete  from  dcPegMHOrdersRej
		 where OrderCloseDate >= @nowmonth
		 and Remarks like '%non mio Home Orders%'
		 and  CompID not in (
		select ProductID from  #rfSPCProductMasterFT
		 )

drop table #missFTorders
---------------MH--------------
select * into #missMHorders from  dcPegMHOrdersRej
		 where OrderCloseDate >=@nowmonth
		 and Remarks like '%non mio Home Orders%'
		 and  CompID not in (
		select ProductID from  #rfSPCProductMasterMH
		 
		 )
		 
insert into dcPegMHOrdersMP
(RecordNo,
BANumber,
OrderNo,
ServiceNo,
ServiceType,
CustomerName,
CustomerID,
AddressPremiseNo,
AddressStreetNm,
AddressUnitNo,
AddressBuildingNo,
AddressDevelopNo,
AddressCountry,
AddressPostalCode,
CRD,
OrderCreationDate,
OrderCloseDate,
CompID,
CompDesc,
OrderAction,
PackageID,
PackageDesc,
Penalty,
MioContentCompID,
MioContentCompDesc,
SchemeID,
VendorCode,
DealerCode,
SalesmanCode,
OrderType,
CustClass,
ProcessStatus,
ProcessMonth,
ProcessYear,
AIPaid,
Remarks,
BatchNo,
DateCreated,
OrderCloseDt,
SGOrderNo,
SGSvcType,
SGTxnType,
PTOrderNo,
PTSvcType,
PTTxnType)
select 
RecordNo,
BANumber,
OrderNo,
ServiceNo,
ServiceType,
CustomerName,
CustomerID,
AddressPremiseNo,
AddressStreetNm,
AddressUnitNo,
AddressBuildingNo,
AddressDevelopNo,
AddressCountry,
AddressPostalCode,
CRD,
OrderCreationDate,
OrderCloseDate,
CompID,
CompDesc,
OrderAction,
PackageID,
PackageDesc,
Penalty,
MioContentCompID,
MioContentCompDesc,
SchemeID,
VendorCode,
DealerCode,
SalesmanCode,
OrderType,
CustClass,
NULL,
NULL,
NULL,
NULL,
'becauseofmisscompid',
BatchNo,
DateCreated,
OrderCloseDt,
SGOrderNo,
SGSvcType,
SGTxnType,
PTOrderNo,
PTSvcType,
PTTxnType
 from 
 #missMHorders


 delete from  dcPegMHOrdersRej
		 where OrderCloseDate >=@nowmonth
		 and Remarks like '%non mio Home Orders%'
		 and  CompID not in (
		select ProductID from  #rfSPCProductMasterMH
		 
		 )     
	        
drop table #missMHorders 
-------------------------------------find Miss orders  over---------------------------------------------------------------
	
	
		/*========================== SPLIT FTTH RECORDS FROM RAW ==========================*/
		--INSERT FTTH RECORDS TO TEMP TABLE FROM RAW
		SELECT	RecordType, OrderNo, ServiceNo, ServiceType, CustomerName, CustomerID, CRD, OrderCreationDate,
				OrderCloseDate, CompID, CompDesc, OrderAction, PackageID, PackageDesc, Penalty, SchemeID, VendorCode,
				DealerCode, SalesmanCode, OrderType, CustClass, SGOrderNo,SGSvcType,SGTxnType,PTOrderNo,PTSvcType,PTTxnType 
		INTO	#FTOrderRaw
		FROM	dcPegMHOrdersTemp
		WHERE	RTRIM(CompID) IN (SELECT RTRIM(ProductID) FROM #rfSPCProductMasterFT)
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecTakenOut = @RecTakenOut + @RecCnt
		
		--DELETE FTTH RECORDS FROM RAW
		DELETE dcPegMHOrdersTemp
		WHERE RTRIM(CompID) IN (SELECT RTRIM(ProductID) FROM #rfSPCProductMasterFT)
		
		--EXEC DCSNEW_DTS_ProcessRawFTOrders @Jobname, @BatchNo, @BatchDate
		/*========================== (END) Create FTTH Bundle Order Raw ==========================*/
		
		
		/*========================== MIO HOME PROCESSING ==========================*/
		
		/*========================== REJECT NON MIO HOME COMPONENT ==========================*/
		--INSERT REJECTED NON MIO HOME COMPONENT RECORDS FROM RAW
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(r.OrderNo), RTRIM(r.OrderNo), RTRIM(r.ServiceNo), RTRIM(r.ServiceType), RTRIM(r.CustomerName), 
				RTRIM(r.CustomerID), '', '', '', '', '', '', '', Convert(Datetime, left(r.CRD,8), 112),
				dbo.strToDate(r.OrderCreationDate), Convert(Datetime,left(r.OrderCloseDate,8),112), RTRIM(r.CompID),
				RTRIM(r.CompDesc), RTRIM(r.OrderAction), RTRIM(r.PackageID), RTRIM(r.PackageDesc), RTRIM(r.Penalty), '', '',
				RTRIM(r.SchemeID), RTRIM(r.VendorCode), RTRIM(r.DealerCode), RTRIM(r.SalesmanCode), RTRIM(r.OrderType),
				RTRIM(r.CustClass), 'non mio Home Orders',@BatchNo,  @ProcessDate,  dbo.strToDate(OrderCloseDate),
				RTRIM(SGOrderNo),RTRIM(SGSvcType),RTRIM(SGTxnType),RTRIM(PTOrderNo),RTRIM(PTSvcType),RTRIM(PTTxnType) 		
		FROM	dcPegMHOrdersTemp r
					LEFT JOIN (SELECT * FROM  #rfSPCProductMasterMH) c ON r.CompID = c.ProductID
		WHERE	r.RecordType = 'D' AND c.ServiceType IS NULL
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		--DELETE REJECTED NON MIO HOME COMPONENT RECORDS FROM RAW
		DELETE	dcPegMHOrdersTemp 
		FROM	dcPegMHOrdersTemp r
					LEFT JOIN (SELECT * FROM  #rfSPCProductMasterMH) c ON r.CompID = c.ProductID
		WHERE	r.RecordType = 'D' AND c.ServiceType IS NULL
		/*========================== (END) REJECT NON MIO HOME COMPONENT ==========================*/
		
		
		/*========================== REJECT DUPLICATE ORDERS ==========================*/
		--INSERT REJECTED DUPLICATE RECORDS FROM MIOHOME
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(r.OrderNo), RTRIM(r.OrderNo), RTRIM(r.ServiceNo), RTRIM(r.ServiceType), RTRIM(r.CustomerName),
				RTRIM(r.CustomerID), '', '', '', '', '', '', '', Convert(Datetime, left(r.CRD,8), 112),
				dbo.strToDate(r.OrderCreationDate),	Convert(Datetime,left(r.OrderCloseDate,8),112),	RTRIM(r.CompID),
				RTRIM(r.CompDesc), RTRIM(r.OrderAction), RTRIM(r.PackageID), RTRIM(r.PackageDesc), RTRIM(r.Penalty), '', '',
				RTRIM(r.SchemeID), RTRIM(r.VendorCode), RTRIM(r.DealerCode), RTRIM(r.SalesmanCode), RTRIM(r.OrderType),
				RTRIM(r.CustClass), 'Duplicate mio Home Orders New/Recon',@BatchNo,  @ProcessDate,
				dbo.strToDate(r.OrderCloseDate), RTRIM(r.SGOrderNo), RTRIM(r.SGSvcType), RTRIM(r.SGTxnType),
				RTRIM(r.PTOrderNo),RTRIM(r.PTSvcType),RTRIM(r.PTTxnType)
		FROM	dcPegMHOrdersTemp r INNER JOIN dcPegMHOrdersMP m ON r.OrderNo = m.OrderNo
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		--DELETE REJECTED DUPLICATE RECORDS FROM RAW (MIO HOME)
		DELETE	dcPegMHOrdersTemp
		FROM	dcPegMHOrdersTemp r INNER JOIN dcPegMHOrdersMP m ON r.OrderNo = m.OrderNo
		
		--INSERT REJECTED DUPLICATE RECORDS FROM MIO HOME CEASE
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(r.OrderNo), RTRIM(r.OrderNo), RTRIM(r.ServiceNo), RTRIM(r.ServiceType), RTRIM(r.CustomerName), 
				RTRIM(r.CustomerID), '', '', '', '', '', '', '', Convert(Datetime, left(r.CRD,8), 112), 
				dbo.strToDate(r.OrderCreationDate), Convert(Datetime,left(r.OrderCloseDate,8),112), RTRIM(r.CompID),
				RTRIM(r.CompDesc), RTRIM(r.OrderAction), RTRIM(r.PackageID), RTRIM(r.PackageDesc), RTRIM(r.Penalty), '', '',
				RTRIM(r.SchemeID), RTRIM(r.VendorCode), RTRIM(r.DealerCode), RTRIM(r.SalesmanCode), RTRIM(r.OrderType),
				RTRIM(r.CustClass), 'Duplicate mio Home Orders XI',@BatchNo,  @ProcessDate, dbo.strToDate(r.OrderCloseDate),
				RTRIM(r.SGOrderNo), RTRIM(r.SGSvcType), RTRIM(r.SGTxnType), RTRIM(r.PTOrderNo), RTRIM(r.PTSvcType),
				RTRIM(r.PTTxnType) 							
		FROM dcPegMHOrdersTemp r INNER JOIN dcPegMHOrdersXI m ON r.OrderNo = m.OrderNo
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		--DELETE REJECTED DUPLICATE RECORDS FROM RAW (FTTH)
		DELETE	dcPegMHOrdersTemp
		FROM	dcPegMHOrdersTemp r INNER JOIN dcPegMHOrdersXI m ON r.OrderNo = m.OrderNo
		/*========================== (END)REJECT DUPLICATE ORDERS ==========================*/
		
		
		/*========================== INSERT CEASE ORDERS ==========================*/
		--INSERT CEASE RECORDS FROM RAW
		INSERT	INTO dcPegMHOrdersXI
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '', Convert(Datetime, left(CRD,8), 112),
				dbo.strToDate(OrderCreationDate), Convert(Datetime,left(OrderCloseDate,8),112), RTRIM(CompID),
				RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty), '', '',
				RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), 'Cease', @BatchNo, @ProcessDate, dbo.strToDate(OrderCloseDate), RTRIM(SGOrderNo),
				RTRIM(SGSvcType),RTRIM(SGTxnType),RTRIM(PTOrderNo),RTRIM(PTSvcType),RTRIM(PTTxnType) 								
		FROM	dcPegMHOrdersTemp WHERE OrderType = 'XI' AND RecordType = 'D'
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecCease = @RecCease + @RecCnt
		
		--DELETE CEASE RECORDS FROM RAW
		DELETE	dcPegMHOrdersTemp
		WHERE OrderType = 'XI' AND RecordType = 'D'
		/*========================== (END) INSERT CEASE ORDERS ==========================*/
		
		
		/*========================== INSERT NEW AND RECON ORDERS ==========================*/
		--INSERT NEW AND RECON RECORDS FROM RAW
		INSERT INTO dcPegMHOrdersMP
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '', Convert(Datetime, left(CRD,8), 112),
				dbo.strToDate(OrderCreationDate), Convert(Datetime, left(OrderCloseDate,8),112), RTRIM(CompID),
				RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty), '', '',
				RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), NULL, NULL, NULL, NULL, NULL, @BatchNo, @ProcessDate, dbo.strToDate(OrderCloseDate),
				RTRIM(SGOrderNo), RTRIM(SGSvcType), RTRIM(SGTxnType), RTRIM(PTOrderNo), RTRIM(PTSvcType), RTRIM(PTTxnType)			
		FROM	dcPegMHOrdersTemp
		WHERE	OrderType IN ('NEW', 'RECON') AND RecordType = 'D'
		
		-- COUNT RECON
		SET @RecChange = @RecChange + 
		(
			SELECT COUNT(*) FROM dcPegMHOrdersMP WHERE OrderCloseDt IS NOT NULL AND OrderType = 'RECON'  AND BatchNo = @BatchNo
		)
		
		-- COUNT NEW
		SET @RecProv = @RecProv + 
		(
			SELECT COUNT(*) FROM dcPegMHOrdersMP WHERE OrderCloseDT IS NOT NULL AND OrderType = 'NEW'  AND BatchNo = @BatchNo
		)
		
		--DELETE NEW AND RECON RECORDS FROM RAW
		DELETE	dcPegMHOrdersTemp
		WHERE	OrderType IN ('NEW', 'RECON')  AND RecordType = 'D'
		/*========================== (END) INSERT NEW AND RECON ORDERS ==========================*/
		
		
		/*========================== REMOVE MULTIPLE NEW ORDER WITH SAME SERVICE NO ==========================*/
		--SELECT MULTIPLE NEW ORDERS EXCEPT THE LAST ORDER
		SELECT	ServiceNo, max(OrderNo) AS LastOrder
		INTO	#MHOrderLast
		FROM	dcPegMHOrdersMP 
		WHERE	OrderCloseDt IS NOT NULL AND (ProcessStatus IS NULL OR Processstatus <> 'Confirmed')
				AND ServiceNo IN (SELECT ServiceNo
									FROM dcPegMHOrdersMP
									WHERE OrderCloseDt IS NOT NULL AND  
										(ProcessStatus IS NULL or ProcessStatus <> 'Confirmed') AND
										OrderType = 'NEW'
									GROUP BY ServiceNo HAVING COUNT(ServiceNo) > 1)
		GROUP BY ServiceNo

		--REJECT MULTIPLE NEW ORDERS EXCEPT THE LAST ORDER
		INSERT INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '', CRD, OrderCreationDate, OrderCloseDate,				
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc),
				RTRIM(Penalty), '', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode),
				RTRIM(OrderType), RTRIM(CustClass), 'Multiple Order for same Service No', BatchNo, @ProcessDate,
				OrderCloseDt, RTRIM(SGOrderNo), RTRIM(SGSvcType), RTRIM(SGTxnType), RTRIM(PTOrderNo), RTRIM(PTSvcType),
				RTRIM(PTTxnType)
		FROM	dcPegMHOrdersMP
		WHERE	OrderCloseDt IS NOT NULL AND (ProcessStatus IS NULL OR ProcessStatus <> 'Confirmed') AND
				ServiceNo IN (SELECT ServiceNo FROM #MHOrderLast) AND OrderNo NOT IN (SELECT LastOrder FROM #MHOrderLast)
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		-- COUNT RECON
		SET @RecChange = @RecChange - 
		(
			SELECT	COUNT(*)
			FROM	dcPegMHOrdersRej
			WHERE	OrderCloseDt IS NOT NULL AND OrderType = 'RECON' AND BatchNo = @BatchNo AND
				ServiceNo IN (SELECT ServiceNo FROM #MHOrderLast) AND OrderNo NOT IN (SELECT LastOrder FROM #MHOrderLast)
		)
		
		-- COUNT NEW
		SET @RecProv = @RecProv - 
		(
			SELECT	COUNT(*)
			FROM	dcPegMHOrdersRej
			WHERE	OrderCloseDT IS NOT NULL AND OrderType = 'NEW' AND BatchNo = @BatchNo AND
				ServiceNo IN (SELECT ServiceNo FROM #MHOrderLast) AND OrderNo NOT IN (SELECT LastOrder FROM #MHOrderLast)
		)
		
		--DELETE MULTIPLE NEW ORDERS FROM RAW
		DELETE	dcPegMHOrdersMP
		WHERE	OrderCloseDt IS NOT NULL AND (ProcessStatus IS NULL OR ProcessStatus <> 'Confirmed') AND
				ServiceNo IN (SELECT ServiceNo FROM #MHOrderLast) AND OrderNo NOT IN (SELECT LastOrder FROM #MHOrderLast)

		DROP TABLE #MHORderLast
		/*========================== (END) REMOVE MULTIPLE NEW ORDER WITH SAME SERVICE NO ==========================*/
		

		/*========================== REMOVE ORDER THAT HAVE CEASE ON THE SAME MONTH ==========================*/
		--REJECT CEASE ORDERS WITHIN THE SAME MONTH
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(m.OrderNo), RTRIM(m.OrderNo), RTRIM(m.ServiceNo), RTRIM(m.ServiceType), RTRIM(m.CustomerName), 
				RTRIM(m.CustomerID), '', '', '', '', '', '', '', m.CRD, m.OrderCreationDate, m.OrderCloseDate,
				RTRIM(m.CompID), RTRIM(m.CompDesc), RTRIM(m.OrderAction), RTRIM(m.PackageID), RTRIM(m.PackageDesc),
				RTRIM(m.Penalty), '', '', RTRIM(m.SchemeID), RTRIM(m.VendorCode), RTRIM(m.DealerCode), RTRIM(m.SalesmanCode),
				RTRIM(m.OrderType), RTRIM(m.CustClass), 'Prov And Cease On Same Month',m.BatchNo, @ProcessDate,
				m.OrderCloseDt,	RTRIM(m.SGOrderNo), RTRIM(m.SGSvcType), RTRIM(m.SGTxnType), RTRIM(m.PTOrderNo),
				RTRIM(m.PTSvcType), RTRIM(m.PTTxnType)
		FROM	dcPegMHOrdersMP m
					INNER JOIN dcPegMHOrdersXI c ON m.ServiceNo = c.ServiceNo
						AND m.CRD <= c.CRD
						AND YEAR(m.OrderCloseDate) = YEAR(c.OrderCloseDate)
						AND MONTH(m.OrderCloseDate) = MONTH(c.OrderCloseDate)
						AND (m.ProcessStatus <> 'Confirmed' OR m.ProcessStatus IS NULL)
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		-- COUNT RECON
		SET @RecChange = @RecChange - 
		(
			SELECT	COUNT(*)
			FROM	dcPegMHOrdersRej
			WHERE	OrderCloseDt IS NOT NULL AND OrderType = 'RECON' AND BatchNo = @BatchNo AND
				Remarks LIKE 'Prov And Cease%'
		)
		
		-- COUNT NEW
		SET @RecProv = @RecProv - 
		(
			SELECT	COUNT(*)
			FROM	dcPegMHOrdersRej
			WHERE	OrderCloseDT IS NOT NULL AND OrderType = 'NEW' AND BatchNo = @BatchNo AND
				Remarks LIKE 'Prov And Cease%'
		)
		
		--DELETE CEASE ORDERS FROM RAW
		DELETE	dcPegMHOrdersMP 
		FROM	dcPegMHOrdersMP m
					INNER JOIN dcPegMHOrdersXI c ON m.ServiceNo = c.ServiceNo
						AND m.CRD <= c.CRD
						AND YEAR(m.OrderCloseDate) = YEAR(c.OrderCloseDate)
						AND MONTH(m.OrderCloseDate) = MONTH(c.OrderCloseDate)
						AND (m.ProcessStatus <> 'Confirmed' OR m.ProcessStatus IS NULL)
		/*========================== (END) REMOVE ORDER THAT HAVE CEASE ON THE SAME MONTH ==========================*/
	
		/*========================== (END) MIO HOME PROCESSING ==========================*/
		
		
		
		
		
		
		
		/*========================== FTTH PROCESSING ==========================*/
		
		/*========================== REJECT ALL ORDERS WITH ORDERTYPE = NEW and PENALTY IS EMPTY ==========================*/
		--REJECT ALL ORDERS WITH ORDERTYPE = NEW and PENALTY IS EMPTY
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '',
				CONVERT(DATETIME, SUBSTRING(CRD,7,2) + '/' + SUBSTRING(CRD,5,2) + '/' + LEFT(CRD,4), 103),
				CONVERT(DATETIME, SUBSTRING(OrderCreationDate,7,2) + '/' + SUBSTRING(OrderCreationDate,5,2) + '/' +
					LEFT(OrderCreationDate,4), 103),
				CONVERT(DATETIME, SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					LEFT(OrderCloseDate,4), 103),
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty),
				'', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), 'Penalty is Empty for New order', @BatchNo, @ProcessDate,
				CONVERT(DATETIME, SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					LEFT(OrderCloseDate,4), 103),
				SGOrderNo, SGSvcType, SGTxnType, PTOrderNo, PTSvcType, PTTxnType
		FROM	#FTOrderRaw
		WHERE	OrderType = 'NEW' AND Penalty = '' AND RecordType = 'D'
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		-- DELETE REJECTED RECORDS FROM RAW
		DELETE	#FTOrderRaw
		WHERE	OrderType = 'NEW' AND Penalty = '' AND RecordType = 'D'
		/*========================== (END) REJECT ALL ORDERS WITH ORDERTYPE = NEW and PENALTY IS EMPTY ==========================*/
		
		/*========================== REJECT NON FTTH COMPONENT ==========================*/
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '',
				CONVERT(DATETIME,SUBSTRING(CRD,7,2) + '/' + SUBSTRING(CRD,5,2) + '/' + Left(CRD,4), 103),
				CONVERT(DATETIME,SUBSTRING(OrderCreationDate,7,2) + '/' + SUBSTRING(OrderCreationDate,5,2) + '/' +
					Left(OrderCreationDate,4), 103),
				CONVERT(DATETIME,SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					Left(OrderCloseDate,4), 103),
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty),
				'', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), 'ServiceType is NA', @BatchNo, @ProcessDate,
				CONVERT(DATETIME,SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					Left(OrderCloseDate,4), 103),
				SGOrderNo, SGSvcType, SGTxnType, PTOrderNo, PTSvcType, PTTxnType 		
		FROM	#FTOrderRaw
		WHERE	OrderNo NOT IN
					(
						SELECT	OrderNo
						FROM	#FTOrderRaw aa
									INNER JOIN #rfSPCProductMasterFT bb ON aa.CompID = bb.ProductID
						WHERE	aa.RecordType = 'D'
					)
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		--DELETE REJECTED RECORDS FROM RAW
		DELETE	#FTOrderRaw
		WHERE	OrderNo NOT IN
					(
						SELECT	OrderNo
						FROM	#FTOrderRaw aa
									INNER JOIN #rfSPCProductMasterFT bb ON aa.CompID = bb.ProductID
						WHERE	aa.RecordType = 'D'
					)
		/*========================== (END) REJECT NON FTTH COMPONENT ==========================*/
		
			
		/*========================== REJECT DUPLICATE ORDERS ==========================*/
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '',
				CONVERT(DATETIME,SUBSTRING(CRD,7,2) + '/' + SUBSTRING(CRD,5,2) + '/' + Left(CRD,4), 103),
				CONVERT(DATETIME,SUBSTRING(OrderCreationDate,7,2) + '/' + SUBSTRING(OrderCreationDate,5,2) + '/' +
					Left(OrderCreationDate,4), 103),
				CONVERT(DATETIME,SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					Left(OrderCloseDate,4), 103),
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty),
				'', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), 'PAID', @BatchNo, @ProcessDate,
				CONVERT(DATETIME,SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					Left(OrderCloseDate,4), 103),
				SGOrderNo, SGSvcType, SGTxnType, PTOrderNo, PTSvcType, PTTxnType		
		FROM	#FTOrderRaw
		WHERE	OrderNo IN
					(
						SELECT OrderNo FROM dcPegFTOrdersMP 
					)
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		--DELETE REJECTED RECORDS FROM RAW
		DELETE	#FTOrderRaw
		WHERE	OrderNo IN
					(
						SELECT OrderNo FROM dcPegFTOrdersMP 
					)
		/*========================== (END) REJECT DUPLICATE ORDERS ==========================*/
		
		
		/*========================== INSERT CEASE ORDERS ==========================*/
		--INSERT CEASE RECORDS FROM RAW
		INSERT	INTO dcPegFTOrdersXI
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '',
				CONVERT(DATETIME,SUBSTRING(CRD,7,2) + '/'+SUBSTRING(CRD,5,2) + '/' + Left(CRD,4) ,103),
				CONVERT(DATETIME,SUBSTRING(OrderCreationDate,7,2) + '/' + SUBSTRING(OrderCreationDate,5,2) + '/' +
					Left(OrderCreationDate,4) ,103),
				CONVERT(DATETIME,SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					Left(OrderCloseDate,4) ,103) ,
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty),
				'', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), 'Cease', @BatchNo, @ProcessDate, SGOrderNo, SGSvcType, SGTxnType, PTOrderNo, PTSvcType, PTTxnType 		
		FROM	#FTOrderRaw
		WHERE	OrderType = 'XI' AND RecordType = 'D'
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecCease = @RecCease + @RecCnt
		
		--DELETE CEASE RECORDS FROM RAW
		DELETE	#FTOrderRaw
		WHERE	OrderType = 'XI'  AND RecordType = 'D'
		/*========================== (END) INSERT CEASE ORDERS ==========================*/
		

		/*========================== INSERT RECON ORDERS ==========================*/
		--INSERT RECON RECORDS FROM RAW
		INSERT	INTO dcPegFTOrdersMP
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '',
				CONVERT(DATETIME, SUBSTRING(CRD,7,2) + '/' + SUBSTRING(CRD,5,2) + '/' + Left(CRD,4) ,103),
				CONVERT(DATETIME, SUBSTRING(OrderCreationDate,7,2) + '/' + SUBSTRING(OrderCreationDate,5,2) + '/' +
					Left(OrderCreationDate, 4), 103),
				CONVERT(DATETIME, SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					Left(OrderCloseDate, 4), 103) ,
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty),
				'', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), NULL, NULL, NULL, NULL, NULL, @BatchNo, @ProcessDate, SGOrderNo, SGSvcType, SGTxnType,
				PTOrderNo, PTSvcType, PTTxnType 		
		FROM	#FTOrderRaw
		WHERE	OrderType = 'RECON' AND RecordType = 'D'
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecChange = @RecChange + @RecCnt
		
		--DELETE RECON RECORDS FROM RAW
		DELETE	#FTOrderRaw
		WHERE	OrderType = 'RECON' AND RecordType = 'D'
		/*========================== (END) INSERT RECON ORDERS ==========================*/
			
		
		/*========================== INSERT NEW ORDERS ==========================*/
		--INSERT NEW RECORDS FROM RAW
		INSERT	INTO dcPegFTOrdersMP
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '',
				CONVERT(DATETIME,SUBSTRING(CRD,7,2) + '/' + SUBSTRING(CRD,5,2) + '/' + Left(CRD,4) ,103),
				CONVERT(DATETIME,SUBSTRING(OrderCreationDate,7,2) + '/' + SUBSTRING(OrderCreationDate,5,2) + '/' +
					Left(OrderCreationDate, 4), 103),
				CONVERT(DATETIME,SUBSTRING(OrderCloseDate,7,2) + '/' + SUBSTRING(OrderCloseDate,5,2) + '/' +
					Left(OrderCloseDate, 4), 103) ,
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty),
				'', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), NULL, NULL, NULL, NULL, NULL, @BatchNo, @ProcessDate, SGOrderNo, SGSvcType, SGTxnType,
				PTOrderNo, PTSvcType, PTTxnType 		
		FROM	#FTOrderRaw
		WHERE	OrderType = 'NEW' AND RecordType = 'D'
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecProv = @RecProv + @RecCnt
		
		--DELETE NEW RECORDS FROM RAW
		DELETE	#FTOrderRaw
		WHERE	OrderType = 'NEW' AND RecordType = 'D'
		/*========================== (NEW) INSERT NEW ORDERS ==========================*/
		
		
		/*========================== REMOVE MULTIPLE NEW ORDER WITH SAME SERVICE NO ==========================*/
		--SELECT MULTIPLE NEW ORDERS EXCEPT THE LAST ORDER
		SELECT	r.*
		INTO	#MultiOrder
		FROM	dcPegFTOrdersMP r
		WHERE	r.ServiceNo IN
					(
						SELECT	ServiceNo
						FROM	dcPegFTOrdersMP
						GROUP BY ServiceNo
						HAVING COUNT(ServiceNo) > 1
					)
					and r.OrderCreationDate>='2015-06-01'--add by ls 
		ORDER BY r.ServiceNo
	 
		SELECT	a.*
		INTO	#FTFirstOrder
		FROM	(
					SELECT	MAX(OrderCreationDate) AS OrderCreationDate, ServiceNo
					FROM	#MultiOrder
					GROUP BY ServiceNo
				) a		
		
		--REJECT MULTIPLE NEW ORDERS EXCEPT THE LAST ORDER
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '', CRD, OrderCreationDate, OrderCloseDate,				
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty),
				'', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), 'Multiple Order', BatchNo, @ProcessDate, OrderCloseDate, SGOrderNo, SGSvcType,
				SGTxnType, PTOrderNo, PTSvcType, PTTxnType 		
		FROM	dcPegFTOrdersMP
		WHERE	OrderNo IN
					(
					/*
						SELECT	OrderNo
						FROM	#MultiOrder 
						WHERE	rtrim(ServiceNo) + rtrim(CONVERT(varchar(10),OrderCreationDate,102)) NOT IN 
								(
									SELECT	rtrim(ServiceNo) + rtrim(CONVERT(varchar(10),OrderCreationDate,102))
									FROM	#FTFirstOrder
								)
								*/

								--change by ls
								select a.OrderNo from (
						SELECT	*
						FROM	#MultiOrder 
						WHERE	rtrim(ServiceNo) + rtrim(CONVERT(varchar(10),OrderCreationDate,102)) NOT IN 
								(
									SELECT	rtrim(ServiceNo) + rtrim(CONVERT(varchar(10),OrderCreationDate,102))
									FROM	#FTFirstOrder
								)

								)a inner join  #FTFirstOrder b on a.ServiceNo=b.ServiceNo  and year(a.OrderCreationDate)=year(b.OrderCreationDate) and month(a.OrderCreationDate)=month(b.OrderCreationDate)
		



					)
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		-- COUNT RECON
		SET @RecChange = @RecChange - 
		(
			SELECT	COUNT(*)
			FROM	dcPegMHOrdersRej
			WHERE	OrderCloseDt IS NOT NULL AND OrderType = 'RECON' AND BatchNo = @BatchNo AND
				Remarks LIKE 'Multiple Order%'
		)
		
		-- COUNT NEW
		SET @RecProv = @RecProv - 
		(
			SELECT	COUNT(*)
			FROM	dcPegMHOrdersRej
			WHERE	OrderCloseDt IS NOT NULL AND OrderType = 'NEW' AND BatchNo = @BatchNo AND
				Remarks LIKE 'Multiple Order%'
		)
		
		--DELETE MULTIPLE NEW ORDERS FROM RAW
		DELETE FROM dcPegFTOrdersMP WHERE OrderNo IN
		(
		/*
			SELECT OrderNo FROM #MultiOrder 
			WHERE rtrim(ServiceNo) + rtrim(CONVERT(varchar(10),OrderCreationDate,102)) NOT IN 
			(SELECT rtrim(ServiceNo) + rtrim(CONVERT(varchar(10),OrderCreationDate,102)) FROM #FTFirstOrder)

			*/
			--add by ls
			select a.OrderNo from (
						SELECT	*
						FROM	#MultiOrder 
						WHERE	rtrim(ServiceNo) + rtrim(CONVERT(varchar(10),OrderCreationDate,102)) NOT IN 
								(
									SELECT	rtrim(ServiceNo) + rtrim(CONVERT(varchar(10),OrderCreationDate,102))
									FROM	#FTFirstOrder
								)

								)a inner join  #FTFirstOrder b on a.ServiceNo=b.ServiceNo  and year(a.OrderCreationDate)=year(b.OrderCreationDate) and month                   (a.OrderCreationDate)=month(b.OrderCreationDate)
		






		)
		/*========================== (END) REMOVE MULTIPLE NEW ORDER WITH SAME SERVICE NO ==========================*/
			

		/*========================== REMOVE ORDER THAT HAVE CEASE ON THE SAME MONTH ==========================*/
		--REJECT CEASE ORDERS WITHIN THE SAME MONTH
		INSERT	INTO dcPegMHOrdersRej
		SELECT	'', RTRIM(OrderNo), RTRIM(OrderNo), RTRIM(ServiceNo), RTRIM(ServiceType), RTRIM(CustomerName), 
				RTRIM(CustomerID), '', '', '', '', '', '', '', CRD, OrderCreationDate, OrderCloseDate,				
				RTRIM(CompID), RTRIM(CompDesc), RTRIM(OrderAction), RTRIM(PackageID), RTRIM(PackageDesc), RTRIM(Penalty),
				'', '', RTRIM(SchemeID), RTRIM(VendorCode), RTRIM(DealerCode), RTRIM(SalesmanCode), RTRIM(OrderType),
				RTRIM(CustClass), 'Prov And Cease On Same Month', BatchNo, @ProcessDate, OrderCloseDate, SGOrderNo,
				SGSvcType, SGTxnType, PTOrderNo, PTSvcType, PTTxnType 		
		FROM	dcPegFTOrdersMP
		WHERE	OrderNo IN
					(
						SELECT	aa.OrderNo
						FROM	dcPegFTOrdersMP aa
									INNER JOIN dcPegFTOrdersXI bb ON aa.ServiceNo = bb.ServiceNo
									   and aa.OrderCloseDate >='2015-06-01'--add by ls20150610
										AND MONTH(aa.OrderCloseDate) = MONTH(bb.OrderCloseDate)
										AND YEAR(aa.OrderCloseDate) = YEAR(bb.OrderCloseDate)
					)
		
		--COUNT
		SET @RecCnt =  @@ROWCOUNT
		SET @RecRej = @RecRej + @RecCnt
		
		-- COUNT RECON
		SET @RecChange = @RecChange - 
		(
			SELECT	COUNT(*)
			FROM	dcPegMHOrdersRej
			WHERE	OrderCloseDt IS NOT NULL AND OrderType = 'RECON' AND BatchNo = @BatchNo AND
				Remarks LIKE 'Prov And Cease%'
		)
		
		-- COUNT NEW
		SET @RecProv = @RecProv - 
		(
			SELECT	COUNT(*)
			FROM	dcPegMHOrdersRej
			WHERE	OrderCloseDT IS NOT NULL AND OrderType = 'NEW' AND BatchNo = @BatchNo AND
				Remarks LIKE 'Prov And Cease%'
		)
		
		--DELETE CEASE ORDERS FROM RAW
		DELETE	dcPegFTOrdersMP
		WHERE	OrderNo IN
					(
						SELECT	aa.OrderNo
						FROM	dcPegFTOrdersMP aa
									INNER JOIN dcPegFTOrdersXI bb ON aa.ServiceNo = bb.ServiceNo
										AND MONTH(aa.OrderCloseDate) = MONTH(bb.OrderCloseDate)
										AND YEAR(aa.OrderCloseDate) = YEAR(bb.OrderCloseDate)
					)
		/*========================== (END) REMOVE ORDER THAT HAVE CEASE ON THE SAME MONTH ==========================*/
		
		DROP TABLE #FTOrderRaw
		/*========================== (END) FTTH PROCESSING ==========================*/
		
		
		
		
		
		

		
	END
	
	--INSERT INTO PROCESS LOG TABLE
	INSERT INTO rdPegProcessLog(JobName, BatchNo, BatchDate, RecTotal, RecRead, RecReadP, RecReadC, RecReject,
		RecReadX, ProcessStatus, LogMsg, ProcessDate)
	VALUES (@JobName, @BatchNo, @BatchDate, @RecTotal, @RecRead, @RecProv, @RecChange, @RecRej,
		@RecCeASe, @ProcessStatus, @Remarks, @ProcessDate)

	TRUNCATE TABLE  dcPegMHOrdersTemp

End
--END OF PROCEDURE

