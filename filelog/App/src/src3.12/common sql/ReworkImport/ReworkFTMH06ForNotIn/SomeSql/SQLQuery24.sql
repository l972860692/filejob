dbo.dcPegMHOrdersTemp_bk20150608

dbo.dcPegMHOrdersTemp

SELECT 
MP.COLUMN_NAME+',' as COLUMN_NAME,MP.dATA_TYPE ,TP.COLUMN_NAME ,TP.dATA_TYPE 
FROM
( SELECT COLUMN_NAME,dATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='dcPegMHOrdersTemp') 
MP --1¾ä
LEFT JOIN  
( SELECT COLUMN_NAME,dATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='dcPegMHOrdersTemp_bk20150608') 
TP ON MP.COLUMN_NAME=TP.COLUMN_NAME  

select * into dcPegMHOrdersTemp from dcPegMHOrdersTemp_bk20150608
--drop table dcPegMHOrdersTemp

--delete dcPegMHOrdersTemp_bk20150608

-------------------------------

select * from dcPegMHOrdersTemp




	 	delete  from   dcPegFTOrdersMP where BatchNo='1821' and  OrderCloseDate between '2015-06-01' and  '2015-06-30'
	delete from   dcPegFTOrdersXI where BatchNo='1821' and OrderCloseDate between '2015-06-01' and  '2015-06-30'
		delete  from   dcPegMHOrdersMP where BatchNo='1821' and OrderCloseDate between '2015-06-01' and  '2015-06-30'
		delete from   dcPegMHOrdersXI where BatchNo='1821' and OrderCloseDate between '2015-06-01' and  '2015-06-30'
	      delete  from  dcPegMHOrdersRej where BatchNo='1821' and OrderCloseDate between '2015-06-01' and  '2015-06-30'




SELECT @HeaderData = RecordType+BundleInd+OrderNo+ServiceNo FROM  dcPegMHOrdersTemp WHERE RecordType = 'H'
	SELECT @TrailerData = RecordType+BundleInd+OrderNo+ServiceNo FROM  dcPegMHOrdersTemp WHERE RecordType = 'T'
	SELECT @JobName = SUBSTRING(@HeaderData,2,10)
	SELECT @BatchNo = CONVERT(INT,SUBSTRING(@HeaderData,12,4))
	
	
	
	