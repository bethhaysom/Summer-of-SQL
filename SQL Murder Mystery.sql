-- Solving a murder that occurred sometime on Jan 15 2018 in SQL City

-- 1. Finding the correct crime scene report:

select *
from 'crime_scene_report'
where date=20180115
	and type = 'murder'
	and city = 'SQL City'

-- 2. Finding witnesses:

select *
from 'person'
where address_street_name = 'Northwestern Dr'
	or address_street_name = 'Franklin Ave' and name like '%Annabel%'
order by address_street_name asc, address_number desc

-- 3. Finding witnesses interviews:

select *
from 'interview'
where person_id in (16371, 14887)

-- 4. Find gym goer matching description:

select *
from 'get_fit_now_member' as g1
join 'get_fit_now_check_in' as g2
  on g1.id = g2.membership_id
join (
    select p.id
  		, d.plate_number
    from 'person' as p
    join 'drivers_license' as d
    	on p.license_id = d.id
) as p
	on p.id = g1.person_id
where g1.membership_status = 'gold' hair
	and g1.id like '48Z%' 
	and check_in_date = 20180109
	and p.plate_number like '%H42W%'

-- 5. Check killers interview:

select *
from 'interview'
where person_id = 67318

-- 6. Find woman who hired him:

select *
from 'person' as p
join 'drivers_license' as d
	on p.license_id = d.id
join (
    select f.person_id
		, p.name
		, f.event_name
		, count(f.date) as days
	  from 'person' as p
	  join 'facebook_event_checkin' as f
      on p.id = f.person_id
	where event_name = 'SQL Symphony Concert'
  		and f.date like '201712%'
	group by f.person_id) as f
	on f.person_id = p.id
where height between 65 and 67
	and hair_color = 'red'
	and gender = 'female'
	and car_make = 'Tesla'
	and car_model = 'Model S'
	and f.days = 3
