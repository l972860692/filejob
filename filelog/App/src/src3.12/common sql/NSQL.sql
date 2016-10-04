DECLARE @SQLString nvarchar(500);
DECLARE @ParmDefinition nvarchar(500);
DECLARE @SalesOrderNumber int;
DECLARE @IntVariable varchar(20);
SET @SQLString = N'SELECT @SalesOrderOUT = count(orderno)
    FROM dcPegPTOrdersMP
    WHERE orderno = @CustomerID';
SET @ParmDefinition = N'@CustomerID varchar(20),
    @SalesOrderOUT int OUTPUT';
SET @IntVariable = 'PXD8931001';
EXECUTE sp_executesql
    @SQLString
    ,@ParmDefinition
    ,@CustomerID = @IntVariable
    ,@SalesOrderOUT = @SalesOrderNumber OUTPUT;
    
    
    select @SalesOrderNumber


