---1.	Create a database named employee, create 3 tables then import data_science_team.csv, 
---proj_table.csv and emp_record_table.csv into the employee database from the given resources.

---creating project table

create table if not exists project (
PROJECT_ID varchar(50) primary key,
PROJ_NAME varchar(250),
DOMAIN varchar(250),
START_DATE date,
CLOSURE_DATE date,
DEV_QTR	varchar(250),
STATUS varchar(250)
);
select*from project;

----------------------------------------------------------------------------------------------------
---creating emp_record table

create table if not exists emp_record(
EMP_ID	varchar(50) primary key,
FIRST_NAME	varchar(250),
LAST_NAME	varchar(250),
GENDER	varchar(2),
ROLE	varchar(250),
DEPT	varchar(250),
EXP	integer,
COUNTRY	varchar(250),
CONTINENT	varchar(250),
SALARY	integer,
EMP_RATING	integer,
MANAGER_ID	varchar(250) references emp_record(emp_id),
PROJ_ID varchar(250) references project(PROJECT_ID)
);
select*from emp_record;

UPDATE emp_record SET MANAGER_ID = NULL WHERE MANAGER_ID IN ('NULL', 'NA');
UPDATE emp_record SET PROJ_ID    = NULL WHERE PROJ_ID    IN ('NULL', 'NA');

----------------------------------------------------------------------------------------------
---creating data_science_team table

create table if not exists data_science_team (
EMP_ID	varchar(50) primary key references emp_record(EMP_ID),
FIRST_NAME varchar(250),
LAST_NAME varchar(250),
GENDER varchar(2),
ROLE varchar(250),
DEPT varchar(250),
EXP	integer,
COUNTRY	varchar(250),
CONTINENT varchar(250)
);

select * from data_science_team;

------------------------------------------------------------------------------------------------------

---2. Create an ER diagram for the given employee database. (Upload the image)
---done

------------------------------------------------------------------------------------------------------

---3. Write a query to return EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, 
---and make a list of employees and details of their department.

select EMP_ID , FIRST_NAME ,LAST_NAME , GENDER , DEPT 
from emp_record;


------------------------------------------------------------------------------------------------------
---4.	Write a query to return EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is: 
---less than two, greater than four, and between two and four

-- 4a) Rating less than 2
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record
where EMP_RATING < 2;

-- 4b) Rating greater than 4
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record
where EMP_RATING > 4;

-- 4c) Rating between 2 and 4 (BETWEEN includes both 2 and 4)
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
from emp_record
where EMP_RATING BETWEEN 2 AND 4;

---Task 4 (alternative): All rating groups in a single query using CASE
select EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING,
       case
          when EMP_RATING < 2 then 'less than 2'
          when EMP_RATING > 4 then 'greater than 4'
          else 'between 2 and 4'
       end as rating_group
from emp_record;


-------------------------------------------------------------------------------------------------------------
---5.	Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department 
---from the employee table and then give the resultant column alias as NAME.
select FIRST_NAME||' '||LAST_NAME as NAME,
       DEPT as Department
from emp_record
where dept='FINANCE';


---------------------------------------------------------------------------------------------------------------
---6.	Write a SQL query to retrieve the employee ID, first name, role, and department of employees who hold 
---leadership positions (Manager, President, or CEO).
select EMP_ID , FIRST_NAME ,LAST_NAME , role, DEPT 
from emp_record
where role in ('MANAGER','PRESIDENT','CEO');


---7.	Write a query to list all the employees from the healthcare and finance departments using union or union all. 
---Take data from the employee record table.
select EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT 
from emp_record
where DEPT ='HEALTHCARE'
UNION 
select EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT 
from emp_record
where DEPT ='FINANCE'
order by DEPT ;


---8.	Write a query to list employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT,
--- and EMP_RATING grouped by dept. Also include the respective employee rating along with the max emp rating for the department
select EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT , EMP_RATING ,
	   max(EMP_RATING) over (partition by DEPT ) as max_rating_for_dept
from emp_record
order by dept, EMP_RATING desc;


---9.	Write a query to calculate the minimum and the maximum salary of the employees in each role. 
---Take data from the employee record table.
select Role, max(salary) as maximum_salary, min(SALARY ) as minimum_salary
from emp_record
group by role;


---10.	Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.
select EMP_ID, FIRST_NAME, LAST_NAME, EXP,
       dense_rank() over (order by EXP desc) as exp_rank	   
from emp_record
ORDER BY exp_rank, EMP_ID;



---11.	Write a query to create a view that displays employees in various countries whose salary is more than six thousand. 
---Take data from the employee record table.
create view high_salary as
select EMP_ID, FIRST_NAME, LAST_NAME, COUNTRY , SALARY , role
from emp_record
where salary > 6000
order by salary desc;

select * from  high_salary;




---12.	Write a nested query to find employees with experience of more than ten years. 
---Take data from the employee record table.
select EMP_ID, FIRST_NAME, LAST_NAME, EXP 
from emp_record
where emp_id in (select EMP_ID
                 from emp_record
                 where exp>10)
order by exp, emp_id desc;


---13.	Write a query using stored functions in the project table to check whether the job profile 
---assigned to each employee in the data science team matches the organization’s set standard.The standard being:
--For an employee with experience less than or equal to 2 years assign 'JUNIOR DATA SCIENTIST',
--For an employee with the experience of 2 to 5 years assign 'ASSOCIATE DATA SCIENTIST',
--For an employee with the experience of 5 to 10 years assign 'SENIOR DATA SCIENTIST',
--For an employee with the experience of 10 to 12 years assign 'LEAD DATA SCIENTIST',
--For an employee with the experience of 12 to 16 years assign 'MANAGER'.

---- Note: SQLite does not support stored functions, so the same logic is written with CASE WHEN.

WITH cte as 
	(select FIRST_NAME , LAST_NAME , EXP as experience,  role,
       case
        	when exp <= 2 then 'JUNIOR DATA SCIENTIST'
    		when exp > 2  and exp <= 5   then 'ASSOCIATE DATA SCIENTIST'
    		when exp > 5  and exp <= 10  then 'SENIOR DATA SCIENTIST'
    		when exp > 10 and exp <= 12  then 'LEAD DATA SCIENTIST'
   	    	when exp > 12 and exp <= 16  then 'MANAGER'
       end as role_standard
	from data_science_team dst 
    )
select FIRST_NAME , LAST_NAME , experience, role, role_standard,
       case  
       	   when role=role_standard then 'Matches'
       	   else 'MISmatches'
       end role_standard_check
from cte
order by experience;


----------------------------------------------------------------------------------------------------------
---14.	Write a query to calculate the bonus for all the employees, based on their ratings and salaries 
---(Use the formula: 5% of salary * employee rating).
select FIRST_NAME , LAST_NAME , EMP_RATING , SALARY , 
       salary*0.05*EMP_RATING as bonus 
from emp_record;


---15.	Write a query to calculate the average salary distribution based on the continent and country. 
---Take data from the employee record table.
select CONTINENT , COUNTRY, round(avg(salary)) as Average_salary
from emp_record
group by CONTINENT , COUNTRY
order by CONTINENT;
























