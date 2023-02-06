select distinct FLIGHTS.origin_city as origin_city, FLIGHTS.dest_city as dest_city, FLIGHTS.actual_time as time
from FLIGHTS JOIN 
(select origin_city, max(actual_time) m from FLIGHTS
Group by origin_city) c
ON c.origin_city = FLIGHTS.origin_city AND
FLIGHTS.actual_time = c.m order by FLIGHTS.origin_city, FLIGHTS.dest_city asc;


select distinct FLIGHTS.origin_city as city from FLIGHTS join
(select origin_city, max(actual_time) as time from FLIGHTS group by
origin_city) c on  c.origin_city=FLIGHTS.origin_city and 
FLIGHTS.actual_time = c.time where FLIGHTS.actual_time<180 order by FLIGHTS.origin_city asc;


SELECT f1.origin_city, COALESCE((1.0 * c/COUNT(f1.fid) * 100), 0)
    as percentage FROM FLIGHTS f1
    LEFT JOIN 
        (SELECT origin_city, COUNT(fid) as c from FLIGHTS 
        WHERE (actual_time < 180.0) OR (actual_time IS NULL)
        GROUP BY origin_city) f2
    ON f1.origin_city = f2.origin_city
	WHERE canceled = 0
    GROUP BY f1.origin_city, f2.c
    ORDER BY percentage, origin_city ASC;
    
 
select c.dest_city as city
from FLIGHTS
JOIN (select origin_city, dest_city from FLIGHTS
where dest_city != 'Seattle WA' 
AND dest_city NOT IN 
(SELECT dest_city from FLIGHTS
where origin_city = 'Seattle WA')
group by origin_city, dest_city) c
ON FLIGHTS.dest_city = c.origin_city
where FLIGHTS.origin_city = 'Seattle WA' 
group by c.dest_city
order by c.dest_city ASC;


select distinct f.dest_city as city from FLIGHTS f
where f.dest_city!='Seattle WA' and f.origin_city!='Seattle WA'
and f.dest_city not in (select f2.dest_city from FLIGHTS f1, FLIGHTS f2 
where f1.dest_city=f2.origin_city and f2.dest_city=f.dest_city and
f1.origin_city='Seattle WA') order by f.dest_city;



CREATE TABLE FLIGHTS(fid int, 
         month_id int,        -- 1-12
         day_of_month int,    -- 1-31 
         day_of_week_id int,  -- 1-7, 1 = Monday, 2 = Tuesday, etc
         carrier_id varchar(7), 
         flight_num int,
         origin_city varchar(34), 
         origin_state varchar(47), 
         dest_city varchar(34), 
         dest_state varchar(46), 
         departure_delay int, -- in mins
         taxi_out int,        -- in mins
         arrival_delay int,   -- in mins
         canceled int,        -- 1 means canceled
         actual_time int,     -- in mins
         distance int,        -- in miles
         capacity int, 
         price int            -- in $             
         );
CREATE TABLE CARRIERS(cid varchar(7), name varchar(83));
CREATE TABLE MONTHS (mid int, month varchar(9));
CREATE TABLE WEEKDAYS (did int, day_of_week varchar(9));


select 
CARRIERS.name as name,
f1.flight_num as f1_flight_num, f1.origin_city as f1_origin_city, f1.dest_city as f1_dest_city, f1.actual_time as f1_actual_time, 
f2.flight_num as f2_flight_num, f2.origin_city as f2_origin_city, f2.dest_city as f2_dest_city, f2.actual_time as f2_actual_time, 
f1.actual_time + f2.actual_time as actual_time

from FLIGHTS as f1, FLIGHTS as f2, CARRIERS, MONTHS

where MONTHS.month = "July"
and f1.day_of_month = 15
aoh nd f2.day_of_month = 15
and f1.origin_city = "Seattle WA"
and f2.dest_city = "Boston MA"
and f1.actual_time + f2.actual_time < 420
and f1.dest_city = f2.origin_city
and f1.carrier_id = f2.carrier_id
and f1.carrier_id = CARRIERS.cid
and f1.month_id = MONTHS.mid
and f2.month_id = MONTHS.mid;


SELECT CARRIERS.name as carrier, MAX(FLIGHTS.price) as max_price FROM FLIGHTS 
JOIN CARRIERS on CARRIERS.cid = FLIGHTS.carrier_id WHERE ((FLIGHTS.origin_city = "Seattle WA"
and FLIGHTS.dest_city = "New York NY") or (FLIGHTS.origin_city = "New York NY" and FLIGHTS.dest_city="Seattle WA"))
GROUP BY CARRIERS.cid;


SELECT SUM(capacity) as capacity FROM FLIGHTS WHERE FLIGHTS.month_id = 7 and FLIGHTS.day_of_month = 10 and 
((FLIGHTS.origin_city = "San Francisco CA" and FLIGHTS.dest_city="Seattle WA") or 
(FLIGHTS.origin_city = "Seattle WA" and FLIGHTS.dest_city="San Francisco CA"));


SELECT CARRIERS.name as name, AVG(FLIGHTS.canceled)*100 as percentage
FROM FLIGHTS JOIN CARRIERS on CARRIERS.cid=FLIGHTS.carrier_id
WHERE FLIGHTS.origin_city = "Seattle WA"
GROUP BY CARRIERS.cid HAVING percentage>0.5
ORDER BY percentage ASC;

SELECT DISTINCT FLIGHTS.flight_num as flight_num from FLIGHTS 
JOIN CARRIERS on CARRIERS.cid = FLIGHTS.carrier_id 
JOIN WEEKDAYS on WEEKDAYS.did = FLIGHTS.day_of_week_id 
WHERE FLIGHTS.origin_city = "Seattle WA" and 
FLIGHTS.dest_city = "Boston MA" and 
CARRIERS.name = "Alaska Airlines Inc." 
and WEEKDAYS.day_of_week = "Monday";
