/*Task 1: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.*/

select * from books;
select * from members;
select * from issued_status;
select * from return_status;

select m.member_id,
m.member_name,
b.book_title,
ist.issued_date,
current_date-ist.issued_date as overdue_days
from issued_status as ist
join members as m
on ist.issued_member_id=m.member_id
join books as b
on ist.issued_book_isbn=b.isbn
left join return_status as rst
on rst.issued_id=ist.issued_id
where rst.return_id is null
and (current_date-ist.issued_date) > 30 
order by 1;

/*Task 2: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes"
when they are returned (based on entries in the return_status table).*/

-- manually can do as well as  using storage procedure


-- storage procedures
/*CREATE OR REPLACE PROCEDURES add_return_records()
LANGUAGE plpgsql
AS $$
DECLARE

BEGIN
   RAISE NOTICE 
END;
$$
*/

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id varchar(15),p_issued_id varchar(15))
LANGUAGE plpgsql
AS $$
DECLARE
v_isbn varchar(25);
v_title varchar(80);
BEGIN
-- insering into returns based on user input
	INSERT INTO return_status (return_id ,issued_id,return_date)
	VALUES (p_return_id,p_issued_id,current_date);
	
	select issued_book_isbn,issued_book_name
	INTO v_isbn,v_title
	from issued_status
	where issued_id=p_issued_id;
	
	update books
	set status='yes'
	where isbn=v_isbn;

	RAISE NOTICE 'Thankyou for returning the book %',v_title;
	
END;
$$


-- TESTING FUNCTION
issued_id='IS136'

select *
from books
where isbn='978-0-7432-7357-1';

select * 
from issued_status
where issued_book_isbn='978-0-7432-7357-1';

select * 
from return_status
where issued_id='IS136';

-- calling functions
CALL add_return_records('RS103','IS136');

/*Task 3: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued,
the number of books returned, and the total revenue generated from book rentals*/

CREATE TABLE Branch_Report
AS
select
	b.branch_id,b.manager_id,
	count(ist.issued_book_isbn) as total_number_books_issued,
	count(rst.return_id) as total_number_books_returned,
	SUM(bk.rental_price) AS total_revenue
from 
	employees as e
join 
	branch as b
on e.branch_id=b.branch_id
join 
	issued_status as ist
on ist.issued_emp_id=e.emp_id
left join 
	return_status as rst
on rst.issued_id=ist.issued_id
join
	books as bk
on bk.isbn=ist.issued_book_isbn
group by b.branch_id
order by 1;

select * from branch_report;


/*Task 4: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing 
members who have issued at least one book in the last 12 months. */

create table active_member
as
select * from members
where member_id in(
	SELECT DISTINCT issued_member_id 
	FROM issued_status
	WHERE issued_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '10 months') );

select * from active_member;

/*Task 5: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed 
the most book issues. Display the employee name, number of books processed, and their branch*/

select ist.issued_emp_id,e.emp_name,
count(ist.issued_emp_id) as books_processed,
b.*
from issued_status as ist
join employees as e
on ist.issued_emp_id=e.emp_id
join branch as b
on e.branch_id=b.branch_id
group by ist.issued_emp_id,e.emp_name,b.branch_id
order by books_processed desc
limit 3;


/*Task 6: Stored Procedure Objective: Create a stored procedure to manage the status of books 
in a library system. Description: Write a stored procedure that updates the status of a book in
the library based on its issuance. The procedure should function as follows: The stored procedure
should take the book_id as an input parameter. The procedure should first check if the book is 
available (status = 'yes'). If the book is available, it should be issued, and the status in the 
books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure
should return an error message indicating that the book is currently not available. */


CREATE OR REPLACE PROCEDURE managing_book_status(p_issued_id VARCHAR(15),p_issued_member_id VARCHAR(15),
		p_issued_book_isbn VARCHAR(55),p_issued_emp_id VARCHAR(15))
LANGUAGE plpgsql
AS $$
DECLARE
v_status varchar(20);
BEGIN
	select status
	into v_status
	from books
    where isbn=	p_issued_book_isbn;

	IF v_status='yes' THEN
		insert into issued_status(issued_id,issued_member_id,
		issued_date,issued_book_isbn,issued_emp_id) 
		values(p_issued_id ,p_issued_member_id,current_date,
		p_issued_book_isbn,p_issued_emp_id);
		update books 
		set status='no'
		where isbn=p_issued_book_isbn;
		RAISE NOTICE  'books record added successfully for books isbn : %',p_issued_book_isbn;
	ELSE
		RAISE NOTICE  'Sorry to inform you the book you have requested is not available at the moment';
	END IF;
END;
$$
-- checking

select * from books;
 -- "978-1-60129-456-2"---yes
 -- "978-0-375-41398-8"---no
 select * from issued_status;
 
CALL managing_book_status('IS141','C108',
		'978-1-60129-456-2','E104');

CALL managing_book_status('IS142','C106',
		'978-0-375-41398-8','E105');


/*Task 7: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select)
query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books
they have issued but not returned within 30 days. The table should include: The number of overdue 
books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each
member. The resulting table should show: Member ID Number of overdue books Total fines*/

select * from issued_status;
select * from members;
select * from return_status;
select * from books;

CREATE TABLE overdue_fine_list
AS
select ist.issued_member_id,
m.member_name,
count(ist.issued_book_isbn) as number_of_books,
(current_date-MIN(ist.issued_date)) as overdue,
((current_date-MIN(ist.issued_date))-30) * 0.50 as Total_fine
from issued_status as ist
join members as m
on m.member_id=ist.issued_member_id
join books as b
on b.isbn=ist.issued_book_isbn
left join return_status as rst
on rst.issued_id = ist.issued_id
where (current_date-issued_date)>30 and rst.return_id is null
group by 1,2
order by total_fine desc;






