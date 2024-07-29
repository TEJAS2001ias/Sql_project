select * from locations; 
select * from make_details;
select * from stolen_vehicles;
#data cleaning
alter table locations change ï»¿location_id location_id int;
alter table make_details change ï»¿make_id make_id int;
alter table stolen_vehicles change ï»¿vehicle_id vehicle_id int;
alter table stolen_vehicles modify date_stolen varchar(255);
update stolen_vehicles set date_stolen=str_to_date(date_stolen,'%m/%d/%Y');
alter table locations modify population varchar(255);
UPDATE locations
SET population = REPLACE(population, ',', '');
ALTER TABLE locations
MODIFY COLUMN population INT;

# 1. average theft in new_zealand as per  given years of theft mentioned
select round(avg(region_count_theft),2) as avg_theft from (select count(vehicle_id) as region_count_theft,region from
(select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id) as g
 group by region order by region_count_theft desc) as j;
 
 # 2. region and count of theft.
select count(vehicle_id) as region_count_theft,region from
(select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id) as g   
 group by region order by region_count_theft desc;
 
 # 3. thef of colorswise bike.
select count(color) as color_theft_count,color from
 (select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id)
 as g group by color;
 
# 4. regions above avg population of country.
select population,region from locations group by region,population having population>=(
select avg(population) as avg_population from locations); 

 # 5. count of model_year wise theft.
 select count(model_year) as model_wise_theft,model_year from
 (select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id)
 as g group by model_year order by model_wise_theft desc;

# 6. count of different colored bike stolen from region.   
select count(ranking) as colorcount,color,region from 
(select region,color,row_number() over (partition by region) as ranking from 
(select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id) as g)as 
 k group by color,region order by colorcount desc;
 
# 7. company wise vehicle theft.
select count(make_name) company_wise_theft,make_name from(select vehicle_id,make_name 
from(select m.make_name,m.make_type,s.vehicle_id,s.model_year,s.color,s.date_stolen,s.vehicle_type 
 from make_details as m join stolen_vehicles as s on s.make_id=m.make_id) as k)
 as h group by make_name order by company_wise_theft desc ;
 
 # 8. company and make_type vehicle theft.
 select make_name,make_type,count(vehicle_id) as vehicle_count ,row_number() over (partition by make_name,make_type) as t  from
 (select m.make_name,m.make_type,s.vehicle_id,s.model_year,s.color,s.date_stolen,s.vehicle_type 
 from make_details as m join stolen_vehicles as s on s.make_id=m.make_id) as g group by make_name,make_type order by vehicle_count desc;
 
 # 9. vehicle theft count on basis on vehicle_type
select count(vehicle_id) as vehicle_count,vehicle_type from
(select m.make_name,m.make_type,s.vehicle_id,s.model_year,s.color,s.date_stolen,s.vehicle_type 
 from make_details as m join stolen_vehicles as s on s.make_id=m.make_id) as j group by vehicle_type order by vehicle_count desc;
 
 # 10. number of vehicle theft in monthwise and yearwise 
select count(vehicle_id) as vehicle_count,month(date_stolen)as month,year(date_stolen) as year_ 
from stolen_vehicles group by month(date_stolen),year(date_stolen) order by year_ desc;
 
 # 11. tottal theft on basis of vehicle make_type
 select count(make_type) total_vehicle,make_type from 
 (select m.make_name,m.make_type,s.vehicle_id,s.model_year,s.color,s.date_stolen,s.vehicle_type 
 from make_details as m join stolen_vehicles as s on s.make_id=m.make_id) b group by make_type;
 
 # 12. model year and its respective make_type vehicle_theft count
 select model_year,make_type,total_vehicle from(select  model_year,make_type,total_vehicle,
 row_number() over (partition by model_year) different_years from
 (select count(make_type) total_vehicle,make_type,model_year from 
 (select m.make_name,m.make_type,s.vehicle_id,s.model_year,s.color,s.date_stolen,s.vehicle_type 
 from make_details as m join stolen_vehicles as s on s.make_id=m.make_id)
 b group by make_type,model_year) as h order by model_year desc) as j;
 
 # 13. year wise vehicle theft
select count(vehicle_id) as no_of_vehicle,year(date_stolen) as 'year' from (select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id) as v group by year;
 
 # 14. yearwise vehicle theft in each region region and vehicle_count(increse in theft in each region from previous year)
 select region ,year_,vehicle_count from (select region,year(date_stolen) as year_,count(vehicle_id) as vehicle_count, row_number() 
 over(partition by region order by count(vehicle_id) desc)as subsequent_status  from
 (select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id) as h group by year_,region) as k;

# 15. theft count in respective years and make_type
select year(date_stolen) year_,count(make_type) as theft_count,make_type from
(select m.make_name,m.make_type,s.vehicle_id,s.model_year,s.color,s.date_stolen,s.vehicle_type 
 from make_details as m join stolen_vehicles as s on s.make_id=m.make_id) as b group by year(date_stolen),make_type;
 
 # 16. region, population,density and theft incidents .
 select region,population,count(vehicle_id) total_theft,density from
 (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,s.date_stolen,s.model_year from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id) as b group by region,population,density order by total_theft desc;

# 17. regionwise trend in density and theft
select region,density,total_theft from(select region,population,count(vehicle_id) total_theft,density from
 (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,s.date_stolen,s.model_year from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id) as b group by region,population,density order by total_theft desc)as n order by density desc;
 
 # 18. regions where theft incidents lower than country average theft incidents
 select region,count(vehicle_id) as theft_incidents from 
 (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,s.date_stolen,s.model_year from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id) as p group by region having count(vehicle_id)<=(
 select round(avg(region_count_theft),2) as avg_theft from (select count(vehicle_id) as region_count_theft,region from
(select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id) as g
 group by region order by region_count_theft desc) as j);
 
 # 19. regions where theft incidents higher than country average theft incidents
  select region,count(vehicle_id) as theft_incidents from 
  (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,s.date_stolen,s.model_year from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id) as p group by region having count(vehicle_id)>=(
 select round(avg(region_count_theft),2) as avg_theft from (select count(vehicle_id) as region_count_theft,region from
(select l.location_id,l.region,s.vehicle_id,s.date_stolen,s.color,s.model_year
 from locations as l inner join stolen_vehicles as s on s.location_id=l.location_id) as g
 group by region order by region_count_theft desc) as j);
 
 # 20. theft count of different vehicle type all over the country.
 select count(vehicle_id) as theft_incidents,vehicle_type from
 (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,s.date_stolen,s.model_year from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id) as b group by vehicle_type order by theft_incidents desc;
 
 # 21. number of vehicle theft in each vehicle type from each region
 select region,vehicle_type,count(vehicle_id) as theft_incidents,row_number() over(partition by region order by count(vehicle_id) desc ) as subsequent_position from
 (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,s.date_stolen,s.model_year from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id) as j where vehicle_type<>"" group by region,vehicle_type;
 
 # 22. top vehicle type theft from each region.
  select region,vehicle_type,theft_incidents from(select region,vehicle_type,count(vehicle_id) as theft_incidents,
  row_number() over(partition by region order by count(vehicle_id) desc ) as subsequent_position from
 (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,s.date_stolen,s.model_year from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id) as j where vehicle_type<>"" group by region,vehicle_type) as v where subsequent_position=1;
 
 # 23. top numbers of vehicle theft in color in each company
 select make_name,color,color_count from(select count(color) color_count ,color,make_name, row_number() over (partition by make_name order by count(color) desc) as d  
 from (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,
 s.date_stolen,s.model_year,s.make_id,m.make_name,m.make_type from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id 
 join make_details m on m.make_id=s.make_id) as e group by make_name ,color) as k where d=1 order by color_count desc;
  
# 24. percentage of regional population to total population of newzealand
SELECT Region,Population,ROUND((Population / SUM(Population) OVER ()) * 100, 2) AS PopulationPercentage
FROM locations;

# 25. percentage of population and theft contribution from respective regions of newzealand
select region,population,population_percent,theft_incident,
round((theft_incident/sum(theft_incident) over())*100,2) as theft_percent from
 (SELECT Region,Population,theft_incident,ROUND((Population / SUM(Population) OVER ()) * 100, 2) AS Population_Percent from
(select population,region,count(vehicle_id) as theft_incident from
 (select s.location_id,l.region,l.population,l.density,s.vehicle_id,s.vehicle_type,s.color,
 s.date_stolen,s.model_year,s.make_id,m.make_name,m.make_type from locations
 as l join stolen_vehicles as s on l.location_id=s.location_id 
 join make_details m on m.make_id=s.make_id) as k group by population,region) as v) as t;
 
 