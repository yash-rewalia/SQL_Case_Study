####     								CASE STUDY ON SWIGGY


### Selecting database
use case_study_swiggy;

##First look of data
Select * from swiggy_analysed;

## Create a copy of that uncleaned data
create table swiggy_copy like swiggy_analysed;
Insert into swiggy_copy (Select * from swiggy_analysed);


## Find Number of rows in a table
Select count(*) as number_of_rows from swiggy_analysed;


## Find Number of columns in a table
Select count(*) as number_of_columns from information_schema.columns
where table_schema='case_study_swiggy'
and table_name='swiggy_analysed';



## If we have N number of columns then how can we automate then copy output in value viewer as text and paste
delimiter //
create procedure count_null()
begin
		Select group_concat(
			concat('sum(case when`', column_name,'`='''' then 1 else 0 end) as `' ,column_name,'`')
			) into@df from information_schema.columns where table_name='swiggy_analysed';

		set @df=concat('Select ',@df,' from swiggy_analysed'); 
		prepare var from @df;
		execute var;
		deallocate prepare var;
	end;
//

delimiter ;

## Calling stored procedure
call count_null;

## Check data
Select * from swiggy_analysed;


## Safe mode OFF
set sql_safe_updates=0;


## Handle delivery_time having '-'
update swiggy_analysed
set delivery_time=round((cast(substring_index(ltrim(delivery_time),'-',1) as unsigned)+
cast(substring_index(ltrim(delivery_time),'-',-1) as unsigned) ) / 2,1)
where delivery_time like '%-%';



## Check after handling
Select * from swiggy_analysed;


## Replace Not Available with their location average rating
with cte as (
Select location,round(avg(rating),1) as rt from swiggy_analysed
where rating not like '%N%'
group by location) 
update swiggy_analysed join cte using(location)
set rating=rt
where rating like '%N%';


## Check after handling
Select * from swiggy_analysed
where rating like '%N%';


## Define a variable and put the mean on it
set @fillrt=(Select round(avg(rating),1) from swiggy_analysed where rating not like '%N%');

## Update rest Not Available with mean of all rating column
update swiggy_analysed
set rating=@fillrt
where rating like '%N%';


##View location
Select distinct(location) as dr from swiggy_analysed where location like '%Kandivali%';



## Update Kandivali location value
update swiggy_analysed
set location='Kandivali East'
where location like '%E%' or location like '%East%';


## Update Kandivali location value
update swiggy_analysed
set location='Kandivali West'
where location like '%W%' or location like '%West%';

##View location
Select distinct(location) as dr from swiggy_analysed where location like '%Kandivali%';





## Safe mode ON
set sql_safe_updates=0;



##Handle food_type and make a new table
create table swiggy_cleaned_final(
hotel_name text,
food text,
location text,
rating float,
delivery_time int,
offer_percentage text,
offer_upto text);
insert into swiggy_cleaned_final(hotel_name,food,location,rating,delivery_time,offer_percentage,offer_upto)(
Select hotel_name,ltrim(substring_index(substring_index(food_type,',',Np),',',-1)) as food,location,rating,
delivery_time,offer_percentage,offer_upto from(
Select * from swiggy_analysed
join
(
Select 1+n+10*n2 as Np from (
Select 0 as n union all Select 1 union all Select 2 union all Select 3 union all Select 4 union all Select 5
union all Select 6 union all Select 7 union all Select 8 union all Select 9) p
cross join
(
Select 0 as n2 union all Select 1 union all Select 2 union all Select 3 union all Select 4 union all Select 5
union all Select 6 union all Select 7 union all Select 8 union all Select 9) q) as u
on char_length(food_type)-char_length(replace(food_type,',',''))>=u.Np-1) t);

## Check after handling
Select * from swiggy_analysed;



### View Data
Select * from swiggy_cleaned_final;

