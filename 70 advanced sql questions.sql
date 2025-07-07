use vcube;


--1.How to select 2nd highest salary from emp table?

select max(salary) from emp where salary< (select max(b.salary) from emp b);


--2. how to get the nth rank 
select * from  (
select empname, salary, dense_rank() over (order by salary desc) ranks from emp)a where ranks=2;

--3.Select employee salary more than avg salary

select * from emp where salary >( select avg(Salary)from emp)

--4.Write query to display current date and time.

select CURRENT_TIMESTAMP;

--5.how to find duplicate records in the table
select *,count(*) rownum from emp group by empid,empname,gender,salary,doj,deptid having count(*) >1

--6.delete duplicate records in a table

with cte as (select *,ROW_NUMBER() over(partition by empid,empname,gender,salary,doj,deptid order by empid) rownum from emp)

delete from cte where rownum>1;


--7. how to get common records from two tables;

--delete from emp where salary > 80000
set identity_insert emp on;

select * from emp_inter intersect select * from emp;

--8.how to retrieve last 10 records from table

select top 10 * from emp order by empid desc;

--9.How do you fetch top 5 emp with salary
select top 5 * from emp order by salary desc;

--10.How to calculate total salary of emp

select sum(salary) from emp;

--11. how to find all the emp who joined in 1998

select  * from emp where year(doj) =1998;

--12.Write emp name starts with 'A'

select * from emp where empname like ('a%');

--13.how can you find the employee who donot have deptid

select * from emp where deptid is null;

--14.How to find which dept have highest no of emp

select top 1 deptid,count(*) highe from emp group by deptid order by highe desc;

--15.how to get total emp count of deptid

select deptid,count(*) highe from emp group by deptid order by highe desc;

--16. write a query to fetch highest salaried emp from each dept
select * from (
select empname,salary,deptid,dense_rank() over(partition by deptid order by salary desc) ranks 
from emp group by deptid,empname,salary) a
where ranks=1;

--17.how to wrte query to update all emp salary to 10% high

update emp set salary= salary*0.05+salary

--18. find employee whose salry between 50000 to 100000

select * from emp where salary between 50000 and 100000;

--19.select the last joined emp in organization
select top 1 * from emp order by doj desc;

--20. how to fetch first and last record of a table

select * from (select top 1 * from emp order by empid asc) a

union all

select * from (select top 1 * from emp order by empid desc)b

--21.wq to find emp who are in same dept

declare @ab int
begin 
select * from emp where deptid= @ab
end

--22. how to find total no of dept in company;
select count (distinct deptid) from emp

--23.how to find dept with lowest avg salary
select top 1 deptid, avg(salary) average from emp group by deptid order by average asc;

--24.how delete all employees in a dept in one query
delete from emp where deptid=?

--25.How to display all emp who are more than 5 months exp

select * from emp where doj < DATEADD(month,-5,getdate());

--26.how to find second largest values from table
select max(salary) from emp where salary<( select max(Salary) from emp);

--27.how to write a query to delete all data but not schema
truncate emp;

--28.wq to get output in xml

select * from emp for xml auto;

--29.how to get the current month name?
select DATENAME(month,getdate())

--30.how to convert a string to lower case?

select lower('PRASANTHRAJ') 

--31.how to select emp who didnot have subordinates.
select * from emp where empid not in (select empid from emp); --like this

--32.WQ to calculate sales per customer

use AdventureWorks2019

select customerid, count(storeid) from sales.Customer group by customerid;

--33.how to write a query to check table is empty.
use vcube;
select case when 
exists (Select count(1) from emp) then 'Not null'
else 'Table is empty'
end

--34.highest 2nd salary for each department
select * from(
	select deptid,salary,dense_Rank() over(partition by deptid order by salary desc) ranks from emp
)a where ranks=2

--35.Write a querty to get the emp who salary is multiple of 10000

select * from emp where salary%10000 =0

--36.how fetch a records where a column has a null values

select * from emp where deptid is null;

--37.WQ to find employee in each dept

select deptid ,count(empid) from emp group by deptid;

--38.wq to fetch all employee whose name end with 'a'
select * from emp where empname like '%a'

--39.how to find emp who work in both 10 and 20
select * from emp where deptid in ('10','20');

--40.select emp whose salary is same
with cte as (select salary,dense_rank() over (partition by salary order by empname asc) ranks from emp)

select * from emp where salary in (select salary from cte where ranks>1)

--41. how to update salary based on their department

update emp set salary= case when deptid=10 then salary+salary*0.1
							when deptid=20 then salary+salary*0.2
							else salary+salary*0.3
							end ;

rollback;

--42.wq to list all emp without dept
select * from emp where deptid is null;

--43.write query to find maximum and minimum salary of each dept.

select deptid,max(Salary) maximum from emp group by deptid

union all

select deptid,min(Salary) minimum from emp group by deptid order by deptid 

--44.how list all emp who has hired in last month
select * from emp where DATEDIFF(month,doj,getdate())<2

--45.wq to display dept wise total and avg salary
select deptid,sum(salary) totalsal, avg(salary) avgsal from emp group by deptid order by deptid;

--46.how to find who has joined in the same year same month of their manager

select empname from emp a where year(doj) in (select year(doj) from emp where empid=a.managerid)

--47.wq to write whose name starts and ends with same letter

-- update emp set empname= 'ashoka' where empname='ashok'
select empname from emp where left(empname,1)=right(empname,1);

-- 48.get empname and salary in single string

select concat(empname,' ' ,salary) from emp

--49.how to find emp whose salary is greater than their manager salary
select * from emp where salary> (select salary from emp e where e.empid=A.managerid)

--50.select emp which departments emp is less than 2
--update emp set empname='Krishna' where empid=6

select * from emp where deptid in (select deptid from emp group by deptid having count(*)>3)

--51.write the query to find the employee with same first name.

select a.empid,a.empname atable from emp a inner join emp b on a.empname = b.empname and a.empid != b.empid

--52. how to write a query to delete employee who is more than 15years in a company

select *,DATEDIFF(day,doj,getdate()) expeinday from emp where DATEDIFF(year,doj,getdate())>=15;

--53.list all the employee working under same manager
select * from emp where manager_id=?

--54.How to find to 3 paid employees in each dept;
select * from
(select empname,salary,deptid,ROW_NUMBER() over(partition by deptid order by salary desc) ranks from emp group by deptid,empname,salary  ) a
where ranks<=3

--55. list all the emp with more than 50days in each dept
select empname,deptid,doj from emp where DATEDIFF(day,doj,getdate())>50 group by deptid,empname,doj;

--56.how to list all employee in dept that have not hired anyone in past 2 years.

 with b as (select * from (select deptid,max(doj) emplast from emp group by deptid) a where datediff(month, a.emplast,GETDATE())>1)

select emp.* from emp inner join b
on emp.deptid=b.deptid 

--57.Get emp who earn more than their dept avg
select * from emp inner join (
select deptid,avg(salary) average from emp group by deptid) b
on emp.deptid = b.deptid
where emp.salary> b.average

--58.how to list all the managers who have more than 5 subordinates.

--select manager_id,count(*) from emp group by manager_id having count(*)>5

--59. Write a query to display employee names and hire dates in the format "Name - MM/DD/YYYY".

select concat(empname, ' - ',format(doj,'MM/dd/yyyy')) empname  from emp

--60.how to select the top10% salary
SELECT * 
FROM emp 
WHERE salary > (
    SELECT PERCENTILE_CONT(0.9) 
    WITHIN GROUP (ORDER BY salary ASC) 
    OVER ()
);

--61. Write a query to display employees grouped by their age brackets (e.g.,20-30, 31-40, etc.).SELECT CASE
WHEN age BETWEEN 20 AND 30 THEN '20-30'
WHEN age BETWEEN 31 AND 40 THEN '31-40'
ELSE '41+'
END AS age_bracket,
COUNT(*)
FROM employees
GROUP BY age_bracket;

--62. How to find the average salary of the top 5 highest-paid employees in each department?with a as (select deptid, salary,ROW_NUMBER() over(partition by deptid order by salary desc) num from emp)select a.deptid,avg(a.salary) salaryavg from a where a.num<=2 group by a.deptid 

--63. How to calculate the percentage of employees in each department?
select deptid, count(*) *100 / (select count(*) from emp )from emp group by deptid

--64.64. Write a query to find all employees whose email contains the domain '@example.com'.select empname from emp where email like (%@example.com)--65. How to retrieve the year-to-date sales for each customer?select customer,sum(saleamount) from sales where saledates between format(date,'01-01-2025','dd-mm-yyyy') and getdate() group by customerid
--66. Write a query to display the hire date and day of the week for each employee.
select empname,doj,datename(weekday,doj)  from emp

--67. How to find all employees who are older than 30 years?
select * from emp where datediff(year,doj,getdate())>20;

--68. Write a query to display employees grouped by their salary range (e.g., 0-
20K, 20K-50K).

select empname, case when salary between 0 and 20000 then '0-20k'
					 when salary between 20001 and 50000 then '20k-50k'
					 when salary between 50001 and 1000000 then '50k-100k'
					 end as ranges from emp;

--69. How to list all employees who do not have a bonus?select * from employee where bonus is null.--70. Write a query to display the highest, lowest, and average salary for each deptid.select deptid,max(salary) highest,min(salary) lowest, avg(salary) average from emp group by deptid