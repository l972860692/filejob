--ftthmh--
select * into   dcPegFTOrdersMP_PRD_0926 from openrowset('sqloledb','10.54.14.193';'scoredb';'scDB@sn05',Score.dbo.dcPegFTOrdersMP)   
 select *into  dcPegFTOrdersXI_PRD_0926 from openrowset('sqloledb','10.54.14.193';'scoredb';'scDB@sn05',Score.dbo.dcPegFTOrdersXI)
select *into   dcPegMHOrdersMP_PRD_0926 from openrowset('sqloledb','10.54.14.193';'scoredb';'scDB@sn05',Score.dbo.dcPegMHOrdersMP) 
 select *into  dcPegMHOrdersXI_PRD_0926 from openrowset('sqloledb','10.54.14.193';'scoredb';'scDB@sn05',Score.dbo.dcPegMHOrdersXI)
select *into   dcPegMHOrdersRej_PRD_0926 from openrowset('sqloledb','10.54.14.193';'scoredb';'scDB@sn05',Score.dbo.dcPegMHOrdersRej) 

--pt--
select *into  dcPegPTOrdersMP_PRD_0926 from openrowset('sqloledb','10.54.14.193';'scoredb';'scDB@sn05',Score.dbo.dcPegPTOrdersMP)
select *into  dcPegPTOrdersCV_PRD_0826 from openrowset('sqloledb','10.54.14.193';'scoredb';'scDB@sn05',Score.dbo.dcPegPTOrdersCV) 






