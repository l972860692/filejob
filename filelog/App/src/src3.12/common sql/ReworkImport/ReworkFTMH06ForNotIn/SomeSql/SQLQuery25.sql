select COUNT(*)    from   dcPegFTOrdersMP where BatchNo='1821'
		select COUNT(*)  from   dcPegFTOrdersXI where BatchNo='1821'
		select COUNT(*)   from   dcPegMHOrdersMP where BatchNo='1821'
		select COUNT(*)  from   dcPegMHOrdersXI where BatchNo='1821'
	             select COUNT(*)  from  dcPegMHOrdersRej where BatchNo='1821'
	             
	             
	             
	           
select * from dcPegMHOrdersMPTemp193 where orderno not in(select orderno from  dcPegMHOrdersMP  where BatchNo='1821') and BatchNo='1821'
	           
	           
	    select *  from   dcPegFTOrdersMP where BatchNo='1821' and OrderNo='QCU6209001'
	       
	select *  from   dcPegFTOrdersXI where BatchNo='1821' and OrderNo='QCU6209001'
		select *   from   dcPegMHOrdersMP where BatchNo='1821' and OrderNo='QCU6209001'
		select * from   dcPegMHOrdersXI where BatchNo='1821' and OrderNo='QCU6209001'
	             select *  from  dcPegMHOrdersRej where BatchNo='1821'and OrderNo='QCU6209001'
	             
	                        
	         QCU6209001  
	           
	           
	           dcPegFTOrdersMPTemp193  
	           
	            select *  from   dcPegFTOrdersMP where BatchNo='1821' and OrderNo='QCU6209001'
	            select *  from   dcPegMHOrdersMPTemp193 where BatchNo='1821' and OrderNo='QCU6209001'
	      
	      
	       select * from rfSPCProductMaster where  ProductID='2104533'