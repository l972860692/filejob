
SELECT * INTO #rfSPCProductMasterFT FROM rfSPCProductMaster WHERE productfamily LIKE '%miohome%' AND servicetype = 'FTTH'
SELECT * INTO #rfSPCProductMasterMH FROM rfSPCProductMaster WHERE productfamily LIKE '%miohome%' AND servicetype = 'ADSL'


QHG1004001



select * into #missFTorders from  dcPegMHOrdersRej
		 where OrderCloseDate >= @nowmonth
		 and Remarks like '%non mio Home Orders%'
		 and  CompID not in (
		select ProductID from  #rfSPCProductMasterFT
		 )
		 
		 
		 select * from dcPegFTOrdersMPTemp193 where CompID  in (select productid from #rfSPCProductMasterMH  )
		 and OrderCloseDate  between '2015-06-01' and '2015-07-01'
		 
		 
		 
	select * from dcPegFTOrdersMPTemp193 where CompID  in (select productid from #rfSPCProductMasterMH  )
	and OrderCloseDate  between '2015-06-01' and '2015-07-01'
		 
		 
		 
		 
		  select COUNT(*) from dcPegFTOrdersMPTemp193 
		  where  --CompID  in (select productid from #rfSPCProductMasterMH)
		 -- and
		   OrderCloseDate  between '2015-06-01' and '2015-07-01'
		 
		 
		 
		  select * from dcPegFTOrdersMPTemp193 where CompID not in (select productid from #rfSPCProductMasterFT)
		 and OrderCloseDate  between '2015-06-01' and '2015-07-01'
		 
		 
		 
		 