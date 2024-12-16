
----------------------------------SUB QUERY-----------------------------------------------------------------
-- drop table shop
create table shop(id int,name varchar(20), sales int);

INSERT INTO shop (id, name, sales) VALUES
(1, 'Laptop', 100),
(1, 'Mobile', 300),
(3, 'Tablet', 800),
(3, 'Monitor', 500),
(4, 'Headphones',400),
(5, 'book', 750),
(6, 'bag', 350),
(9, 'Bottle', 600);

select * from shop;
----------------------------------------Q1. find the average sale -----------------------------------------------------------
-------- XX 1. WRONG ANS

select avg(sales)  --475 bcz it divide the value by 5 
from shop


---- 2 RIGHT ANS USING SUBQUERY 
select avg(total_sum)   --633
from
(select id, sum(sales) as total_sum   -- alias is neccessary when outer query use the inner query
from shop 
group by id ) AS ord_aggregate;


-----------------------------------Q2. find that order id whose total sales is  greater than average--------------------------------------------------

----------------------------1.using having clause

select id           --subQ 3
from shop 
group by id
having sum(sales) > (
select avg(total_sum) AS avg_ord   ----subQ 2
from
(select id ,sum(sales) as total_sum  --subQ 1
from shop                            
group by id) as ord_aggregate) 

--OR

-------------------------------------- 2.using WHERE clause
sELECT id   --subQ 4         --#4
FROM                         --#4
( SELECT id, SUM(sales) AS total_sales    --subQ 3 -- ||3
FROM shop                                          -- ||3
GROUP BY id) AS ord_aggregate                      -- ||3
WHERE total_sales >          --#4
(SELECT AVG(total_sales)       ----subQ 2      --*2
 FROM                                          --*2
(SELECT SUM(sales) AS total_sales   --subQ 1           --+1
FROM shop                                              --+1
 GROUP BY id) AS avg_sales);                           --+1


 -------- ----------------------------3.USING JOIN 
 /* basic structure of JOIN 
 select A.*, B.* 
 from Atable A
inner join Btable B on 1=1  */ 
  
 select A.*,B.*   --A.* give the id and totalSale1 col and B.* give  AggVal
 from 
 (select id,sum(sales) TotalSale1  --TABLE A 
 from shop 
 group by id) A 
 inner join 
 (select avg(TotalSale2) AS AggVal   --TABLE B
 from (select sum(sales) as TotalSale2
 from shop 
 group by id) as TotalAgg
 ) B
 ON 1=1         --join but not such any common colunm
 where TotalSale1 > AggVal;     --inner joins so that all the row of table of A is join with single row of table B 


 ------------------------------other way instead of using INNER JOIN 

  select A.*,B.*   --A.* give the id and totalSale1 col and B.* give  AggVal
 from 
 (select id,sum(sales) TotalSale1  
 from shop 
 group by id) A ,                          --TABLE A 
 (select avg(TotalSale2) AS AggVal   
 from (select sum(sales) as TotalSale2
 from shop 
 group by id) as TotalAgg
 )  B                                   --TABLE B
 where TotalSale1 > AggVal; 


 ------------------------------------Q3:- avg salary of each dept  with emp table ------------------------------------------
 
 select E.* , D.Avg_Salary
 from emp E
 inner join   
 (select dept_id, avg(salary) as Avg_Salary
 from emp 
 group by dept_id ) D
 ON E.dept_id = D.dept_id
 order by dept_id
 
-------------------------------------Q4 find the dept id from emp which are not present in dept ------------------------------------

select *
from emp 
where dept_id  NOT IN (select dept_id from dept) --list of dept_id from dept

-------------------------------------------------------------------------------------------------------------------------------------
select *
from emp 
where dept_id  > (select min(dept_id) from dept); -- compare with single value 

select avg(salary) from emp                        --61000 avg_Salary with 400 dept_id 

select avg(salary) from emp where dept_id != 400   --61818 avg_Salary without 400 dept_id

select *, (select avg(salary) from emp )           --61000 with 400 dept_id (this shows that select avg(salary) run first 
from emp 
where dept_id not in (select dept_id from dept)



----------------------------------------Q5---------------------------------------------------------------------------------
--DROP table icc_world_cup

create table icc_world_cup(
team_1 Varchar(20),
team_2 Varchar(20),
winner Varchar(20) 
);

INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India'); 

/* 1- write a query to produce below output from icc_world_cup table.
team_name, no_of_matches_played , no_of_wins , no_of_losses 
eg:-India, 2,2,0
*/

select * from icc_world_cup

select team_name , COUNT(*) as no_of_matches_played , sum(win_flag) as no_of_wins, count(1)-sum(win_flag) as no_of_losses
from
(select team_1 as team_name, case when team_1=winner then 1 else 0 end as win_flag
from icc_world_cup
union all
select team_2 as team_name, case when team_2 =winner then 1 else 0 end as  win_flag
from icc_world_cup) as combine
group by team_name 

------------------------------------------------CTE (COMMON TABLE EXPRESION) ------------------------------------------------------
 /*
 CTEs are used to simplify complex queries by breaking them into smaller, manageable parts.
 They enhance readability, reusability, and maintainability  */

 --cte

 with combine as 
(select team_1 as team_name, case when team_1=winner then 1 else 0 end as win_flag
from icc_world_cup
union all
select team_2 as team_name, case when team_2 =winner then 1 else 0 end as  win_flag
from icc_world_cup)


select team_name , COUNT(*) as no_of_matches_played , sum(win_flag) as no_of_wins, count(1)-sum(win_flag) as no_of_losses
from combine
group by team_name 


---------------------------------------------------------------------------------------1. sub query 
select E.* , D.Avg_Salary
 from emp E
 inner join   
 (select dept_id, avg(salary) as Avg_Salary
 from emp 
 group by dept_id ) D
 ON E.dept_id = D.dept_id
 order by dept_id

 ----------------------------------------------------------------------------------------1. CTE for 1st sub query 

 with D as
 (select dept_id, avg(salary) as Avg_Salary
 from emp 
 group by dept_id ) 


 select E.* , D.Avg_Salary
 from emp E
 inner join D ON E.dept_id = D.dept_id
 order by dept_id


 -----------------------------------------------------------------------------------2. sub query

  select A.*,B.*   --A.* give the id and totalSale1 col and B.* give  AggVal
 from 
 (select id,sum(sales) TotalSale1  --TABLE A 
 from shop 
 group by id) A 
 inner join 
 (select avg(TotalSale2) AS AggVal   --TABLE A 
 from (select sum(sales) as TotalSale2
 from shop 
 group by id) as TotalAgg
 ) B
 ON 1=1         --join but not such any common colunm
 where TotalSale1 > AggVal; 

 -----------------------------------------------------------------------------------2(i) CTE
 with SaleFunc as                              --taking sum(Sale) as cte 1
 (select id, sum(sales) as SumOFSale
 from shop 
 group by id )

 select id, A.*,B.*   
 from 
 SaleFunc A 
 inner join 
 (select avg(SumOFSale) AS AggVal  
 from SaleFunc ) 
 B
 ON 1=1        
 where SumOFSale > AggVal; 

 -----------------------------------------------------------------------------------2(ii) CTE using for 2 subqueries

  with SaleFunc as                              --taking sum(Sale) as cte 1
 (select id, sum(sales) as SumOFSale
 from shop 
 group by id ),
 Agg_fun as  (select avg(SumOFSale) AS AggVal   --taking avg(SumOFSale) as as cte 2  
 from SaleFunc ) 

 select id, A.*,B.*   
 from 
 SaleFunc A               --cte 1
 inner join 
 Agg_fun B                --cte 2
 ON 1=1        
 where SumOFSale > AggVal; 

 --ABOUT THE ALIAS:- Subquery aliases are only allowed immediately after their respective subquery and not for nested subqueries.

 ----------------------------------------------------------------QUESTIONS ---------------------------------------------------------------------------
 select * from shop

 /*Q1. - write a query to find premium customers from orders data.
 Premium customers are those who have done more orders than average no of orders per customer.*/

Select  id
From shop
Group by id 
having count(id) >
(Select  avg(orderPerCust) as avgOrder
from
(Select  id, Count(id) as orderPerCust
From shop 
Group by id) as combine ) 


/*Q2- write a query to find employees whose salary is more than average salary of employees in their department */

select * from emp
 
with  AvgPerDept as       --CTE
(select dept_id,avg(salary) as avgS
from emp
group by dept_id)

select name ,salary,  avgS, e.dept_id  --Main query
from emp e
left join AvgPerDept ON  e.dept_id = AvgPerDept.dept_id
where  salary > avgS
order by e.dept_id

--Q3- write a query to find employees whose age is more than average age of all the employees.

/* --XXXX WRONG ANS

with A as
( select avg(age) as AVGage
from emp)

select name 
from emp
where age> AVGage ;  --instead of AVGage use this (SELECT AVGage FROM A) --THEN WILL BE ROGHT

The WHERE clause does not recognize the alias AVGage directly from the CTE because it isn't directly joined or accessible 
in the scope of the main query.
What fixes the issue?
By adding a subquery (SELECT AVGage FROM A), the value of AVGage is explicitly retrieved and compared with the age column in the WHERE clause.
 */ 

 --ONE MORE EASY AND RIGHT WAY 

 select name,age 
 from emp
 where age> (select avg(age) from emp)

 --Q4- write a query to print emp name, salary and dep id of highest salaried employee in each department

 with M as
 (select dept_id, max(salary) as MaxSalary
 from emp
 group by dept_id)

 select name, salary , e.dept_id
 from emp e
 left join M on e.dept_id = M.dept_id
 where salary = MaxSalary

--Q5- write a query to print emp name, salary and dep id of highest salaried overall

select name, salary , dept_id
from emp
where salary = (select max(salary) from emp)


--Q6- write a query to print product id and total sales of highest selling products (by no of units sold) in each category

