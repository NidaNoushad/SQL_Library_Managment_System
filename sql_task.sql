SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

-- PROJECT TASK
/*Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird',
'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"*/
INSERT INTO books
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird',
'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address='123 MainTurn St'
WHERE member_id='C106';

/*Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.*/
DELETE FROM issued_status
WHERE issued_id = 'IS121';

/*Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.*/
SELECT *
FROM issued_status
WHERE issued_emp_id='E101';

/*Task 5: List Members Who Have Issued More Than One Book -- 
Objective: Use GROUP BY to find members who have issued more than one book.*/
SELECT * FROM issued_status 
select issued_member_id,count(*) AS number_of_books
FROM issued_status 
GROUP BY 1
HAVING count(*)>1
ORDER BY count(*) ASC;

/*Task 6: Create Summary Tables: Used CTAS to generate new tables based on
query results - each book and total book_issued_cnt** */

CREATE TABLE book_counts
AS
SELECT b.isbn,b.book_title,count(ist.issued_id) FROM books AS b
JOIN issued_status as ist
ON b.isbn=ist.issued_book_isbn
GROUP BY b.isbn,b.book_title;

SELECT * FROM book_counts;

-- Task 7. Retrieve All Books in a Specific Category:
select * from books
where category='Fiction';

-- Task 8: Find Total Rental Income by Category:

select b.category,SUM(b.rental_price) AS Total_rental_price,COUNT(*) from books as b
join issued_status as ist
on b.isbn=ist.issued_book_isbn
GROUP BY b.category
ORDER BY  Total_rental_price DESC;

-- TASK 9: List Members Who Registered in the Last 180 Days:
INSERT INTO members 
VALUES
('C111','Sam Altman','234 oak st','2025-01-01'),
('C112','menha','22 main st','2025-01-01'),
('C113','julie','489 Oak st','2025-02-02');

SELECT * FROM members
WHERE reg_date>CURRENT_DATE-INTERVAL'180 days';

-- TASK 10 List Employees with Their Branch Manager's Name and their branch details:

SELECT e1.emp_name,e1.position,e1.salary,b.*,e2.emp_name as manager FROM employees as e1
JOIN branch as b
on e1.branch_id=b.branch_id
JOIN employees as e2
ON e2.emp_id=b.manager_id;

-- TASK 11 List Create table of books with Rental PRICE above a certain THRESHOLD:
CREATE TABLE budget_friendly_books
AS
SELECT * FROM books
WHERE rental_price<6;
SELECT * FROM budget_friendly_books;

-- TASK 12 retrieve the list of books not yet returned and the members details :
SELECT * FROM (SELECT ist.issued_book_name,ist.issued_id,ist.issued_member_id from issued_status as ist
FULL join return_status as rst
on rst.issued_id=ist.issued_id
WHERE return_id IS NULL) AS t1
left join members as m
on m.member_id=t1.issued_member_id;




