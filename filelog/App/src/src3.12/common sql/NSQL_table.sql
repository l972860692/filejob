
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
--table���ܵ���������sql string �� ֻ��ƴ����������table ������������ֱ��д��
--sqlƴ�� 1.����ʹ��param 2.Ҳ����ʹ��ֱ��ƴ�� ʹ��1ʱע�������