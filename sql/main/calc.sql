create table results
(id INT,
response TEXT
);

insert into results (id, response)
values(1, (select count(*) as pas_num
from tickets t
group by book_ref
order by pas_num desc
limit 1));

insert into results (id, response)
values(2, (select count(pas_num) from
(select count(*) as pas_num
from tickets t
group by book_ref) as v
where pas_num >
(select avg(pas_num) from
(select count(*) as pas_num
from tickets t
group by book_ref) as c)));

insert into results (id, response)
values(3, (select count(*)
from tickets t
inner join (select count(*) as c, book_ref
from tickets
group by book_ref
having count(*) = (select count(*) as pas_num
from tickets t
group by book_ref
order by pas_num desc
limit 1)) as max_r
using (book_ref)
group by passenger_id, book_ref
having count(*) > 1));

insert into results (id, response)
values(4, (select string_agg(ab, '|')
from(
select mm.book_ref::text || '|' || mm.passenger_id::text || '|' || mm.passenger_name::text || '|' || mm.contact_data::text  AS ab
from(
select t.book_ref, passenger_id, passenger_name, contact_data
from tickets t
inner join (select count(*) as c, book_ref
from tickets
group by book_ref
having count(*) = 3) as m
on t.book_ref = m.book_ref
order by t.book_ref, passenger_id, passenger_name, contact_data) as mm) as fin));

insert into results (id, response)
values(5, (select count(tf.ticket_no)
from ticket_flights tf
left join tickets t on tf.ticket_no  = t.ticket_no
left join bookings b  on t.book_ref = b.book_ref 
group by b.book_ref
order by count(tf.ticket_no) desc
limit 1));

insert into results (id, response)
values(6, (select count(*)
from ticket_flights tf
left join tickets t on tf.ticket_no  = t.ticket_no
left join bookings b  on t.book_ref = b.book_ref
group by passenger_id, b.book_ref 
order by count(*) desc
limit 1));

insert into results (id, response)
values(7, (select count(*)
from ticket_flights tf
left join tickets t on tf.ticket_no  = t.ticket_no
left join bookings b  on t.book_ref = b.book_ref
group by passenger_id
order by count(*) desc
limit 1));

insert into results (id, response)
values(8, (select string_agg(ab, '|') 
from
(select mm.passenger_id::text || '|' || mm.passenger_name::text || '|' || mm.contact_data::text || '|' || mm.final_sum::text  AS ab
from
(select passenger_id, passenger_name, contact_data, final_sum
from tickets t2 
inner join
(select passenger_id, sum(amount) as final_sum
from ticket_flights tf1
left join tickets t1 on tf1.ticket_no  = t1.ticket_no
left join bookings b1  on t1.book_ref = b1.book_ref
group by passenger_id
having sum(amount) = 
(select min(min_find.s)
from
(select passenger_id, sum(amount) as s
from ticket_flights tf
left join tickets t on tf.ticket_no  = t.ticket_no
left join bookings b  on t.book_ref = b.book_ref
group by passenger_id) as min_find)) as fin
using (passenger_id)
order by passenger_id, passenger_name, contact_data, final_sum) as mm) as fin));

insert into results (id, response)
values(9, (select string_agg(ab, '|')
from
(select mm.passenger_id::text || '|' || mm.passenger_name::text || '|' || mm.contact_data::text || '|' || mm.time_on::text  AS ab
from
(select t2.passenger_id, passenger_name, contact_data, time_on
from tickets t2
inner join
(select sum(actual_arrival - actual_departure) as time_on, t.passenger_id
from tickets t
left join ticket_flights tf on t.ticket_no = tf.ticket_no
left join flights f on tf.flight_id = f.flight_id
where actual_arrival - actual_departure is not null
group by passenger_id
having sum(actual_arrival - actual_departure) = (
select sum(actual_arrival - actual_departure) as time_o
from tickets t
left join ticket_flights tf on t.ticket_no = tf.ticket_no
left join flights f on tf.flight_id = f.flight_id
where actual_arrival - actual_departure is not null
group by passenger_id
order by time_o desc
limit 1)) as max_time 
on t2.passenger_id = max_time.passenger_id
order by t2.passenger_id, passenger_name, contact_data, time_on) as mm) as fin));

insert into results (id, response)
values(10, (select string_agg(m.city, '|')
from
(select distinct a2.city
from airports a2
inner join(
select count(*) as airport, city 
from airports a
group by city
having count(*) > 1) as agr
on a2.city = agr.city
order by a2.city) as m));

insert into results (id, response)
values(11, (select string_agg(m.departure_city, '|')
from
(select distinct r2.departure_city 
from routes r2
inner join
(select count(distinct arrival_city) as cnt, departure_city
from routes r 
group by departure_city
having count(distinct arrival_city) = (
select count(distinct arrival_city) as cnt2
from routes r3 
group by departure_city
order by cnt2
limit 1
)) as min_ar
on r2.departure_city = min_ar.departure_city
order by r2.departure_city) as m));

insert into results (id, response)
values(12, (select string_agg(ab, '|')
from 
(select mm.value1::text || '|' || mm.value2::text  AS ab
from
(select distinct
    least(departure_city, arrival_city) as value1
  , greatest(departure_city, arrival_city) as value2
from
(select distinct r.departure_city, r2.arrival_city 
from routes r 
cross join routes r2
where r.departure_city <> r2.arrival_city
except
select distinct departure_city, arrival_city
from routes r3) as j
order by value1, value2) as mm) as fin));

insert into results (id, response)
values(13, (select string_agg(m.arrival_city, '|')
from
(select distinct arrival_city
from routes r3
where departure_city = 'Москва'
EXCEPT
select distinct arrival_city
from routes r3
where departure_city <> 'Москва'
order by arrival_city) as m));

insert into results (id, response)
values(14, (select string_agg(m.model, '|')
from
(select model
from aircrafts a 
inner join
(select count(*), aircraft_code
from flights_v fv 
where actual_duration is not null
group by aircraft_code
having count(*) =
(select count(*)
from flights_v fv1 
where actual_duration is not null
group by aircraft_code
order by count(*) desc
limit 1)) as max_r
on a.aircraft_code = max_r.aircraft_code) as m));

insert into results (id, response)
values(15, (select string_agg(m.model, '|')
from
(select a2.model
from aircrafts a2 
inner join
(select count(*), a.model
from ticket_flights tf 
left join flights f on tf.flight_id = f.flight_id 
left join aircrafts a on f.aircraft_code = a.aircraft_code
where actual_arrival is not null
group by a.model
having count(*) =
(select count(*)
from ticket_flights tf 
left join flights f on tf.flight_id = f.flight_id 
left join aircrafts a on f.aircraft_code = a.aircraft_code
where actual_arrival is not null
group by a.model
order by count(*) desc
limit 1)) as max_r
on a2.model = max_r.model) as m));

insert into results (id, response)
values(16, (select (extract (hour from sum((actual_arrival - actual_departure) - (scheduled_arrival-scheduled_departure)))*60 +
extract (minute from sum((actual_arrival - actual_departure) - (scheduled_arrival-scheduled_departure)))+
extract (second from sum((actual_arrival - actual_departure) - (scheduled_arrival-scheduled_departure)))/60) as in_minute
from flights f
where actual_departure is not null));

insert into results (id, response)
values(17, (select string_agg(m.arrival_city, '|')
from
(select arrival_city
from flights_v fv
where actual_duration is not null and departure_city = 'Санкт-Петербург' and date(actual_departure) = '2016-09-13' and status != 'Cancelled'
order by arrival_city) as m));

insert into results (id, response)
values(18, (select string_agg(ab, '|')
from
(select m.flight_id::text as ab
from
(select distinct tf3.flight_id
from ticket_flights tf3
inner join(
select sum(amount), tf2.flight_id 
from ticket_flights tf2
left join flights f ON tf2.flight_id = f.flight_id
where status != 'Cancelled' and actual_departure is not null
group by tf2.flight_id
having sum(amount) = (
select sum(amount)
from ticket_flights tf
left join flights f ON tf.flight_id = f.flight_id
where status != 'Cancelled' and actual_departure is not null
group by tf.flight_id
order by sum(amount) desc
limit 1)) as max_r
on tf3.flight_id = max_r.flight_id
order by tf3.flight_id) as m) as fin));

insert into results (id, response)
values(19, (select string_agg(ab, '|')
from
(select m.dn::text as ab
from
(select count(*),date(actual_departure) as dn
from flights f
where status != 'Cancelled' and actual_departure is not null
group by date(actual_departure)
having count(*) = (
select count(*)
from flights f
where status != 'Cancelled' and actual_departure is not null
group by date(actual_departure)
order by count(*) desc
limit 1)) as m) as fin));

insert into results (id, response)
values(20, (select avg(cnt) from
(select count(*) as cnt,date(actual_departure)
from flights_v fv
where actual_duration is not null and departure_city = 'Москва'and status != 'Cancelled' and 
extract (month from actual_departure) = 9 and extract (year from actual_departure) = 2016
group by date(actual_departure)) as m));

insert into results (id, response)
values(21, (select string_agg(fin.ab, '|')
from
(select mm.a::text || '|' || mm.departure_city::text  AS ab
from
(select a, departure_city
from
(select avg(actual_duration) as a,departure_city
from flights_v fv
where actual_duration is not null and status != 'Cancelled'
group by departure_city
having ((extract (hour from avg(actual_duration))*60 +
extract (minute from avg(actual_duration))+
extract (second from avg(actual_duration))/60)) > 180
order by a desc
limit 5) as m1
order by a, departure_city) as mm) as fin));