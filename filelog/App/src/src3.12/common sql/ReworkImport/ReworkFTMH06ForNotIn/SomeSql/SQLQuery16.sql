

dcPegMHOrdersTemp


	 	select COUNT(*)    from   dcPegFTOrdersMP where BatchNo='1821'
		select COUNT(*)  from   dcPegFTOrdersXI where BatchNo='1821'
		select COUNT(*)   from   dcPegMHOrdersMP where BatchNo='1821'
		select COUNT(*)  from   dcPegMHOrdersXI where BatchNo='1821'
	             select COUNT(*)  from  dcPegMHOrdersRej where BatchNo='1821'
	             
	           select *   from   dcPegFTOrdersMP where orderno='qit2439001'
		select *  from   dcPegFTOrdersXI where orderno='qit2439001'
		select *   from   dcPegMHOrdersMP where orderno='qit2439001'
		select *  from   dcPegMHOrdersXI where orderno='qit2439001'
	             select *  from  dcPegMHOrdersRej where orderno='qit2439001'  
	             
	             
	             
	             
	             	select COUNT(*)  from   dcPegFTOrdersMP where BatchNo='1821' and  OrderCloseDate between '2015-06-01' and  '2015-06-30'
	select COUNT(*) from   dcPegFTOrdersXI where BatchNo='1821' and OrderCloseDate between '2015-06-01' and  '2015-06-30'
		select COUNT(*)  from   dcPegMHOrdersMP where BatchNo='1821' and OrderCloseDate between '2015-06-01' and  '2015-06-30'
		select COUNT(*) from   dcPegMHOrdersXI where BatchNo='1821' and OrderCloseDate between '2015-06-01' and  '2015-06-30'
	      select COUNT(*)  from  dcPegMHOrdersRej where BatchNo='1821' and OrderCloseDate between '2015-06-01' and  '2015-06-30'


	             
SELECT COUNT(*) FROM dcPegFTOrdersMP WHERE  BatchNo='1822'
SELECT COUNT(*) FROM dcPegFTOrdersMP WHERE  BatchNo='1821'

SELECT COUNT(*) FROM dcPegFTOrdersMP WHERE  BatchNo='1820'


	             
	             select *   from   dcPegFTOrdersMP where BatchNo='1821'