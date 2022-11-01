use world_universities
select * from  departments

--total number of departments

select count( distinct Department_ID) as number_of_departments
from departments

--the oldest estblished department

select Department_Name 
from departments
where
DOE =(select min(DOE) from departments)

--the newest estblished department

select Department_Name 
from departments
where
DOE =(select max(DOE) from departments)

--all the departments 

select Department_Name 
from departments

--total number of employees in university

select count([Employee ID]) as total_employees
from employees

--total number of students in university

select count(Student_ID) as total_employees
from student_info

--number of employees in each dept

select d.Department_ID, d.Department_Name, count(e.[Employee ID]) as number_of_employess
from departments d
join employees e
on d.Department_ID=e.Department_ID
group by d.Department_ID,d.Department_Name
order by 3 desc

--number of students in each dept

select d.Department_ID, d.Department_Name, count(s.Student_ID) as number_of_students
from departments d
join student_info s
on d.Department_ID=s.Department_Admission
group by d.Department_ID,d.Department_Name
order by 3 desc

--number of students who did not get selected in their desired department

select count(Student_ID) as students_not_in_desired_dept
from student_info 
where Department_Admission !=Department_Choices
group by Department_Choices

--count of students departmentwise who did not get selected in their chosen department 

select d.Department_Name,count(Student_ID) as students_count
from student_info s
join departments d
on s.Department_Choices=d.Department_ID
where  s.Department_Admission !=s.Department_Choices
group by d.Department_Name

--students admitted each year
select year(DOA) as year_of_admission , count(student_id) as students_admitted
from student_info
group by year(DOA)
order by year(DOA)

--average score of each students for each paper 
select student_id, avg([Paper 1]) as avg_paper1,avg([Paper 2]) as avg_paper2,
avg([Paper 3]) as avg_paper3,avg([Paper 4]) as avg_paper4,avg([Paper 5]) as avg_paper5,
avg([Paper 6]) as avg_paper6,avg([Paper 7]) as avg_paper7
from student_performance
group by student_id,Semster_Name

--average score of each paper semesterwise
select  Semster_Name, avg([Paper 1]) as avg_paper1,avg([Paper 2]) as avg_paper2,
avg([Paper 3]) as avg_paper3,avg([Paper 4]) as avg_paper4,avg([Paper 5]) as avg_paper5,
avg([Paper 6]) as avg_paper6,avg([Paper 7]) as avg_paper7
from student_performance
group by Semster_Name

--count of students who perfromed above than average for each semester
select b.Semster_Name,count(a.student_id) as above_avg_count
from
(select * from student_performance)a
join
(
select  Semster_Name, avg([Paper 1]) as avg_paper1,avg([Paper 2]) as avg_paper2,
avg([Paper 3]) as avg_paper3,avg([Paper 4]) as avg_paper4,avg([Paper 5]) as avg_paper5,
avg([Paper 6]) as avg_paper6,avg([Paper 7]) as avg_paper7
from student_performance
group by Semster_Name) b
on a.Semster_Name=b.Semster_Name
where  a.[Paper 1]>b.avg_paper1 and a.[Paper 2]>b.avg_paper2
and a.[Paper 3]>b.avg_paper3 and a.[Paper 4]>b.avg_paper4
and a.[Paper 5]>b.avg_paper5 and a.[Paper 6]>b.avg_paper6 and a.[Paper 7]>b.avg_paper7
group by b.Semster_Name
order by b.Semster_Name
