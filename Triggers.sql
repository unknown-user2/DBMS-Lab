--1
-- Create a trigger that prevents a project from being deleted if it is currently being worked by any employee.
DELIMITER //
create trigger PreventDelete
before delete on Project
for each row
BEGIN
	IF EXISTS (select * from WorksOn where p_no=old.p_no) THEN
		signal sqlstate '45000' set message_text='This project has an employee assigned';
	END IF;
END; //
DELIMITER ;

delete from Project where p_no=241563; -- Will give error 


--2
-- Create a trigger that prevents a student from enrolling in a course if the marks pre_requisit is less than the given threshold 
DELIMITER //
create or replace trigger PreventEnrollment
before insert on Enroll
for each row
BEGIN
	IF (new.marks<40) THEN
		signal sqlstate '45000' set message_text='Marks below threshold';
	END IF;
END;//
DELIMITER ;

INSERT INTO Enroll VALUES
("01HF235", 002, 5, 5); -- Gives error since marks is less than 10


--3
-- A trigger that prevents a driver from participating in more than 2 accidents in a given year.
DELIMITER //
create trigger PreventParticipation
before insert on participated
for each row
BEGIN
	IF 2<=(select count(*) from participated where driver_id=new.driver_id) THEN
		signal sqlstate '45000' set message_text='Driver has already participated in 2 accidents';
	END IF;
END;//
DELIMITER ;

INSERT INTO participated VALUES
("D222", "KA-20-AB-4223", 66666, 20000);


--4
-- A tigger that updates order_amount based on quantity and unit price of order_item
DELIMITER $$
create trigger UpdateOrderAmt
after insert on OrderItems
for each row
BEGIN
	update Orders set order_amt=(new.qty*(select distinct unitprice from Items NATURAL JOIN OrderItems where item_id=new.item_id)) where Orders.order_id=new.order_id;
END; $$
DELIMITER ;

INSERT INTO Orders VALUES
(006, "2020-12-23", 0004, 1200);

INSERT INTO OrderItems VALUES 
(006, 0001, 5); -- This will automatically update the Orders Table also


--5
-- Trigger that prevents boats from being deleted if they have active reservation
delimiter //
create trigger CheckandDelete
before delete on boat
for each row
begin
  if exists (select * from reserves r where r.bid = old.bid) then
    signal sqlstate '45000' set message_text = 'Boat is reserved and hence cannot be deleted';
  end if;
end//
delimiter ;

delete from Boat where bid=103;
