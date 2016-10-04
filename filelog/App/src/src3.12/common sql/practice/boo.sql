set nocount on ;
create table nums(n int not null primary key);
declare @max as int ,@rc as int ;
set @max=1000000;
set @rc=1;
insert into nums(n) values(1);
while @rc*2<=@max
begin 
insert into nums(n)select n+@rc from nums;
set @rc=@rc*2;
end;
insert into nums(n)
select n+@rc from nums where n+@rc <=@max;
go
declare
@numorders as int,
@numcusts as int,
@numemps as int,
@numshippers as int,
@numyears as int,
@startdate as datetime;
select
@numorders =1000000,
@numcusts =20000,
@numemps =500,
@numshippers =5,
@numyears =4,
@startdate ='20050101';
 create table Customers( custid char(11) not null, custname nvarchar(50) not null);
 insert into Customers(custid,custname) select 'C' +RIGHT('000000000'+CAST(n as varchar(10)),10) as custid,N'Cust_'+CAST(n as varchar(10)) as custname
 from nums
 where n<=@numcusts;
 alter table customers add constraint pk_Customers primary key(custid);
  create table Employees(empid int not null, firstname nvarchar(25) not null,lastname nvarchar(25) not null);
  insert into Employees(empid,firstname,lastname) select n as empid,N'Fname_'+CAST(n as nvarchar(10)) as firstname,
  N'Lname_'+CAST(n as nvarchar(10)) as lastname
  from nums
  where n<=@numemps;
  alter table Employees 
  add constraint PK_Employees primary key (empid);
  
  create table Shippers(shipperid varchar(5) not null,shippername nvarchar(50) not null)
  insert into Shippers(shipperid,shippername) select shipperid,N'Shipper_'+shipperid as shippername
  from (select CHAR(ASCII('A')-2+2*n) as shipperid from nums where n<=@numshippers) as D;
  alter table shippers add constraint pk_shippers primary key(shipperid);
  create table orders(orderid int not null,custid char(11) not null,empid int not null,shipperid varchar(5) not null,orderdate datetime not null,filler char(155) not null default('a'));
  insert into orders(orderid,custid,empid,shipperid,orderdate)
  select n as orderid ,'C'+RIGHT('000000000'+cast(1+abs(checksum(newid()))%@numcusts as varchar(10)),10) as custid,
  1+ABS(CHECKSUM(newid()))%@numemps as empid,CHAR(ASCII('A')-2 +2*(1+abs(checksum(newid()))%@numshippers))  as shipperid,DATEADD(DAY,n/(@numorders/(@numyears * 365.5)),@startdate)
 --late arrival with earlier date
 - case when n%10=0 then 1 +abs(checksum(newid()))%30  else 0 end as orderdate
  from nums where n<=@numorders
  order by checksum(newid())
  
  create clustered index idx_cl_od on Orders(orderdate);
  create nonclustered index idx_nc_sid_i_cid
  on orders(shipperid,orderdate)
  include(custid,empid)
  
  alter table orders add constraint pk_orders primary key nonclustered(orderid),
  constraint fk_orders_customers foreign key (custid) references customers(custid),
  constraint fk_orders_employees foreign key(empid) references employees(empid),
  constraint fk_orders_shippers
  foreign key (shipperid) references shippers(shipperid);
  

select top 1000* from  orders order by orderid desc
---------------------------------------------------------
-----------------------------------------------------

select * from sys.dm_os_wait_stats