create database sailors;
use sailors;

create table Sailors(
	sid int primary key,
	sname varchar(35) not null,
	rating float not null,
	age int not null
);

create table Boat(
	bid int primary key,
	bname varchar(35) not null,
	color varchar(25) not null
);

create table reserves(
	sid int not null,
	bid int not null,
	sdate date not null,
	foreign key (sid) references Sailors(sid) on delete cascade,
	foreign key (bid) references Boat(bid) on delete cascade
);

insert into Sailors values
(1,"Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "Astorm Gowda", 2, 68),
(5, "Armstormin", 7, 19);


insert into Boat values
(1,"Boat_1", "Green"),
(2,"Boat_2", "Red"),
(103,"Boat_3", "Blue");

insert into reserves values
(1,103,"2023-01-01"),
(1,2,"2023-02-01"),
(2,1,"2023-02-05"),
(3,2,"2023-03-06"),
(5,103,"2023-03-06"),
(1,1,"2023-03-06");

select * from Sailors;
select * from Boat;
select * from reserves;

-- Find the colours of the boats reserved by Albert
select color 
from Sailors s, Boat b, reserves r
where s.sid = r.sid and b.bid=r.bid and s.sname = "Albert";

-- Find all the sailor sids who have rating atleast 8 or reserved boat 103
(select sid 
from Sailors 
where rating>=8)
union
(select sid 
from reserves
where bid=103);

-- Find the names of the sailor who have not reserved a boat whose name contains the string "storm". Order the name in the ascending order
select sname 
from Sailors s
where sname not in
(select sname 
from reserves r
where s.sid=r.sid)
and sname like "%storm%"
order by sname asc;

--r Find the name of the sailors who have reserved all boats 
select sname 
from sailors s where not exists
(select * 
from boat b where not exists
(select * 
from reserves r where s.sid=r.sid and b.bid=r.bid));

-- Find the name and age of the oldest sailor
select sname, age
from sailors
where age = (select max(age) from sailors);

--r For each boat which was reserved by atleast 2 sailors with age >= 40, find the bid and average age of such sailors 
select b.bid, avg(age) as average_age
from boat b, sailors s, reserves r
where b.bid=r.bid and s.sid=r.sid and age>=40 
group by bid 
having count(r.sid)>=2;

-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
create view SailorsWithRating5 as
select distinct bname, color
from sailors s, boat b, reserves r
where r.sid=s.sid and b.bid=r.bid and s.rating=5;

select * from SailorsWithRating5;

-- Trigger that prevents boats from being deleted if they have active reservation
delimiter //
create trigger CheckandDelete
before delete on Boat
for each row
begin
  if exists (select * from reserves r where r.bid = old.bid) then
    signal sqlstate '45000' set message_text = 'Boat is reserved and hence cannot be deleted';
  end if;
end//
delimiter ;

delete from Boat where bid=103;
