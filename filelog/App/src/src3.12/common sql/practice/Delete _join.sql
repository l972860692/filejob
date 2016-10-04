delete #missFTorders from #missFTorders r INNER JOIN dcPegMHOrdersXI m ON r.OrderNo = m.OrderNo	

create table  #abc (id int, name varchar(50))

create table cbd (id int, name varchar(50))
insert into #abc select 1 ,'1111'
insert into #abc select 2 ,'2222'
insert into #abc select 3 ,'333'
insert into #abc select 4 ,'4444'
insert into #abc select 5 ,'555'
insert into #abc select 6 ,'66666'


insert into cbd select 4 ,'1111'
insert into cbd select 5 ,'2222'
insert into cbd select 6 ,'333'
insert into cbd select 7 ,'4444'
insert into cbd select 8 ,'555'
insert into cbd select 9 ,'66666'

select * from #abc
delete #abc from #abc r INNER JOIN cbd m ON r.id = m.id	
select * from #abc
