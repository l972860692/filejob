

declare @sqlexc varchar(1000)
declare @tabelName varchar(20)
declare @orderno varchar(20)

set  @tabelName='dcPegPTOrdersMP'
set  @orderno='PXD8931001'
set  @sqlexc=N'select * from '+@tabelName +' where OrderNo ='+''''+@orderno+''''
select @sqlexc
EXEC (@sqlexc)




select * from  dcPegPTOrdersMP where OrderNo='PXD8931001'
