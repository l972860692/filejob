
create proc testNsql_tablename
as
begin
DECLARE @sql NVARCHAR(max)				
DECLARE @paramlist nvarchar(1000)

DECLARE	@TBName VARCHAR(20)
DECLARE	@orderno VARCHAR(20)
       
       set @TBName='dcPegPTOrdersMP'
       set @orderno='PXD8931001'
SET @sql=N' select * from  '+@TBName +' where OrderNo =@orderno'					

SET @paramlist=N'@TBName VARCHAR(20),@orderno VARCHAR(20)'
					
EXEC sp_executesql @sql, @paramlist,@TBName,@orderno

end
--table不能当参数放在sql string 中 只能拼接起来传入table 其它参数可以直接写入
--sql拼接 1.可以使用param 2.也可以使用直接拼接 使用1时注意上面的