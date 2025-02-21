-- Library Managment System
-- step 1 create Branch Table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(15), --FK
	branch_address VARCHAR(50),
	contact_no INT
);

ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(25);

-- step 2 create Employee table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
emp_id VARCHAR(10) PRIMARY KEY,
emp_name VARCHAR(50),
position VARCHAR(20),
salary INT,
branch_id VARCHAR(10) --FK
);

-- Step 3 Create Book Table
DROP TABLE IF EXISTS books;
CREATE TABLE books(
isbn VARCHAR(25) PRIMARY KEY,
book_title VARCHAR(80),
category VARCHAR(60),
rental_price FLOAT,
status VARCHAR(20),
author VARCHAR(50),
publisher VARCHAR(80)
);

-- Step 4 create table members
DROP TABLE IF EXISTS members;
CREATE TABLE members(
member_id VARCHAR(15) PRIMARY KEY,
member_name VARCHAR(40),
member_address VARCHAR(60),
reg_date DATE
);

-- STEP 5 CREATE ISSUE_STATUS TABLE
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
issued_id VARCHAR(15) PRIMARY KEY,
issued_member_id VARCHAR(15), --FK
issued_book_name VARCHAR(75),
issued_date DATE,
issued_book_isbn VARCHAR(55), --FK
issued_emp_id VARCHAR(15) --FK
);

-- STEP 6 CREATE RETURN_STATUS TABLE
-- DROP TABLE return_status ;
CREATE TABLE return_status(
    return_id VARCHAR(15) PRIMARY KEY,
    issued_id VARCHAR(15), --FK
    return_book_name VARCHAR(75),
    return_date DATE, 
    return_book_isbn VARCHAR(55)
);
-- adding foreign keys in issued_status
ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);


-- adding foreign keys in employee table
ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

-- -- adding foreign keys in branch table
-- ALTER TABLE branch
-- ADD CONSTRAINT fk_employee
-- FOREIGN KEY (manager_id)
-- REFERENCES employees(emp_id);

-- adding foreign keys in return_status table
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);