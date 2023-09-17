--To start with, I decided to combine all 6 files into 1 common file, the "master" table
-- this should simplify queries for this project and the Pewlett Hackard (a fictional company) in the future

--My personal filepaths were removed for privacy purposes, so you will have to manually add the 6 filepaths to the corresponding tables in the SQL code. 
--was not sure If I was supposed to add pictures to this homework, or if I am just being judged on the code produced. 



----------------------------PART 1 create 6 tables, then populate them with the corresponding csv's

--employees
CREATE TABLE employees (
    emp_no int not null,
emp_title_id varchar (5) not null,
birth_date varchar (10) not null,
first_name varchar (30) not null,
last_name varchar (30) not null,
sex Varchar (1) not null,
hire_date varchar (10) not null
);

select * from employees;

copy employees from '/gitlab/02-Homework/09-SQL/Starter_Code/data/employees.csv' delimiter ',' CSV HEADER;

select * from employees;
-- titles
CREATE TABLE titles (
    title_id varchar (9) not null,
title varchar (18) not null);

copy titles from '/gitlab/02-Homework/09-SQL/Starter_Code/data/titles.csv' delimiter ',' CSV HEADER;

select * from titles;

-- salaries
CREATE TABLE salaries (
    emp_no int not null,
salary int not null);

copy salaries from '/gitlab/02-Homework/09-SQL/Starter_Code/data/salaries.csv' delimiter ',' CSV HEADER;

select * from salaries;

--dept_manager
CREATE TABLE dept_manager (
    dept_no varchar (4) not null,
emp_no int not null);

copy dept_manager from '/gitlab/02-Homework/09-SQL/Starter_Code/data/dept_manager.csv' delimiter ',' CSV HEADER;

select * from dept_manager;

--dept_emp
CREATE TABLE dept_emp (
	emp_no int not null,
    dept_no varchar (5) not null
);

copy dept_emp from '/gitlab/02-Homework/09-SQL/Starter_Code/data/dept_emp.csv' delimiter ',' CSV HEADER;

select * from dept_emp;

--departments
CREATE TABLE departments (
	dept_no varchar (4) not null,
dept_name varchar (18) not null
);

copy departments from '/gitlab/02-Homework/09-SQL/Starter_Code/data/departments.csv' delimiter ',' CSV HEADER;

select * from departments;





----------------------------- PART 2 combine all 6 tables





--make the master table with all relevant data columns as outlined in the tables above

CREATE TABLE master (
	emp_no int not null,
emp_title_id varchar (5) not null,
birth_date varchar (10) not null,
first_name varchar (30) not null,
last_name varchar (30) not null,
sex Varchar (1) not null,
hire_date varchar (10) not null,
title_id varchar (9) not null,
title varchar (18) not null,
salary int not null,
dept_no varchar (5) not null,
dept_name varchar (18) not null);

select * from master;

--populate the "master" table using the exsisting information using aliases to lessen typing time
-- start by populating from the "employees" table
INSERT INTO master (emp_no, emp_title_id, birth_date, first_name, last_name, sex, hire_date, title_id, title, salary, dept_no, dept_name)
SELECT 
    e.emp_no,
    e.emp_title_id,
    e.birth_date,
    e.first_name,
    e.last_name,
    e.sex,
    e.hire_date,
    t.title_id,
    t.title,
    s.salary,
    d.dept_no,
    d.dept_name
FROM employees e
JOIN titles t ON e.emp_title_id = t.title_id
JOIN salaries s ON e.emp_no = s.emp_no
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no;


select * from master;

-- join the salaries table on the emp_no column contained in the master table
SELECT master.emp_no, master.salary, salaries.salary
FROM master
JOIN salaries ON master.emp_no = salaries.emp_no;

select * from master;

-- do the same by joining the dept_emp table on the common column named "emp_no"
SELECT master.emp_no, master.dept_no, dept_emp.dept_no
FROM master
JOIN dept_emp ON master.emp_no = dept_emp.emp_no;

-- do the same by joining the dept_manager table on the common column named "emp_no"
SELECT master.emp_no, master.dept_no, dept_manager.dept_no
FROM master
JOIN dept_manager ON master.emp_no = dept_manager.emp_no;

-- (seeing a pattern?) join the the departments table on the common column named "dept_no"
SELECT master.emp_no, master.dept_no, departments.dept_name
FROM master
JOIN departments ON master.dept_no = departments.dept_no;

-- to finish the master table, join the the titles table on the column with common values named "title_id"
SELECT master.emp_no, master.emp_title_id, titles.title
FROM master
JOIN titles ON master.emp_title_id = titles.title_id;

--just realized that title_id and emp_title_id contain duplicate information,
-- I will drop the title_id column 
ALTER TABLE master
DROP COLUMN title_id;

select * from master;

-- saw that a "primary key" is required for this assignment...
ALTER TABLE master
ADD COLUMN master_id serial PRIMARY KEY;


select * from master;



----------------------------------------- PART 3 Query the master table






--List the employee number, last name, first name, sex, and salary of each employee (2 points)
SELECT emp_no, last_name, first_name, sex, salary
FROM master;


--List the first name, last name, and hire date for the employees who were hired in 1986 (2 points)
-- this was a helpful resource here https://www.ibm.com/docs/en/informix-servers/12.10?topic=dcf-date-function-1
SELECT first_name, last_name, hire_date
FROM master
WHERE EXTRACT(YEAR FROM TO_DATE(hire_date, 'MM/DD/YY')) = 1986;

--List the manager of each department along with their department number, department name, employee number, last name, and first name (2 points)
SELECT departments.dept_no, departments.dept_name, dept_manager.emp_no, master.last_name, master.first_name
FROM departments
JOIN dept_manager ON departments.dept_no = dept_manager.dept_no
JOIN master ON dept_manager.emp_no = master.emp_no;

--List the department number for each employee along with that employee’s employee number, last name, first name, and department name (2 points)
SELECT master.dept_no, master.emp_no, master.last_name, master.first_name, master.dept_name
FROM master;

--List first name, last name, and sex of each employee whose first name is Hercules and whose last name begins with the letter B (2 points)
-- this really feels like a troll-question. Funny, but...why? More impressively, there are 22 of them named Hercules in the company
SELECT master.first_name, master.last_name, master.sex
FROM master
WHERE master.first_name = 'Hercules' AND master.last_name LIKE 'B%';

--List each employee in the Sales department, including their employee number, last name, and first name (2 points)
SELECT master.emp_no, master.last_name, master.first_name
FROM master
WHERE master.dept_name = 'Sales';

--List each employee in the Sales and Development departments, including their employee number, last name, first name, and department name (4 points)
SELECT master.emp_no, master.last_name, master.first_name, master.dept_name
FROM master
WHERE master.dept_name IN ('Sales', 'Development');

--List the frequency counts, in descending order, of all the employee last names (that is, how many employees share each last name) (4 points)
-- this is an actual troll...
-- looked up "frequency counts" https://stackoverflow.com/questions/24767130/get-frequency-of-a-column-in-sql-server
--there is an employee named "Foolsday"...
SELECT last_name, COUNT(last_name) AS frequency
FROM master
GROUP BY last_name
ORDER BY frequency DESC;