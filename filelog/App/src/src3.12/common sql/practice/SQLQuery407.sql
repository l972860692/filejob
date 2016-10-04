create table #Student  --学生成绩表
(
id int,  --主键
Grade int, --班级
Score int --分数
)

insert #Student 
          select 1,1,88
union all select 2,1,66
union all select 3,1,75
union all select 4,2,30
union all select 5,2,70
union all select 6,2,99
union all select 7,2,60
union all select 8,3,90
union all select 9,3,70
union all select 10,3,60

go


select * from #student


select *,ROW_NUMBER() over(order by Score ) as Sequence from #Student


select  * ,row_number() over(order by grade) as line from #student


select * ,row_number() over(partition by grade order by grade) as line from #student
select * from #student


select * ,row_number() over(partition by grade order by Score desc) as line from #student
select * from #student


SELECT *,MIN (Score) OVER (PARTITION BY Grade ) Score, Grade    
FROM #Student 


select * from #student


