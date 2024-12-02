select * from  Projects..ds_salaries
 --deleting the columns not needed
alter table Projects..ds_salaries drop column F1, salary_currency

alter table Projects..ds_salaries drop column salary

--replacing experience level with full forms
update Projects..ds_salaries
set experience_level= 'Senior-level'
where experience_level='SE'

update Projects..ds_salaries
set experience_level = 'Mid-level'
where experience_level='MI'

update Projects..ds_salaries
set experience_level= 'Entry-level'
where experience_level='EN'

update Projects..ds_salaries
set experience_level= 'Executive-level'
where experience_level='EX'

--replacing FT as full time employee
update Projects..ds_salaries
set employment_type= 'Full Time'
where employment_type='FT'

--maximum and minimum salary at entry level
select * from Projects..ds_salaries
where experience_level='Entry-level'and salary_in_usd=
(
select max(salary_in_usd)
from Projects..ds_salaries 
where experience_level='Entry-level')

select * from Projects..ds_salaries
where experience_level='Entry-level'and salary_in_usd=
(
select min(salary_in_usd)
from Projects..ds_salaries 
where experience_level='Entry-level')

--average salary of data analyst in INDIA
select AVG(salary_in_usd) 
from Projects..ds_salaries 
where job_title='Data Analyst' and employee_residence= 'IN'

--highest salary paying company nation for data analysts

select top 1
avg(salary_in_usd) as highest_avg_salary, company_location 
from Projects..ds_salaries 
where job_title='Data Analyst'
group by company_location
order by avg(salary_in_usd) desc 

--highest salary paying job remote
select   top 1 avg(salary_in_usd)as highest_avg_remote_salary ,job_title
from Projects..ds_salaries 
where remote_ratio=100
group by job_title
order by avg(salary_in_usd) desc

--top 10 highest paying entry level jobs

select job_title,avg(salary_in_usd)
from Projects..ds_salaries 

where experience_level='Entry-level'
group by job_title
order by avg(salary_in_usd) desc

--average salary affected by remote work or not
select round(avg(salary_in_usd),0) as avg_salary, remote_ratio
from Projects..ds_salaries 
group by remote_ratio
order by avg(salary_in_usd) desc

--average salary according to company size
select round(avg(salary_in_usd),0) as avg_salary, company_size
from Projects..ds_salaries 
group by company_size
order by avg(salary_in_usd) desc

--average salary for each profession
select round(avg(salary_in_usd),0) as avg_salary, job_title
from Projects..ds_salaries 
group by job_title
order by avg(salary_in_usd) desc

