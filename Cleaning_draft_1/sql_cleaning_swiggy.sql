####                                     Data Cleaning     


## Selecting a database
use case_study_swiggy;


## First look of table
Select * from swiggy_scrap_uncleaned;


## Create a copy of that uncleaned data
create table swiggy_cleaned like swiggy_scrap_uncleaned;
Insert into swiggy_cleaned (Select * from swiggy_scrap_uncleaned);

## Check for copy
Select * from swiggy_cleaned;


## Make new columns
ALTER TABLE swiggy_cleaned ADD COLUMN rating text;
ALTER TABLE swiggy_cleaned ADD COLUMN delivery_time text;
ALTER TABLE swiggy_cleaned ADD COLUMN offer_percentage text;
ALTER TABLE swiggy_cleaned ADD COLUMN offer_upto text;


#Granting permission for updating without where
SET SQL_SAFE_UPDATES = 0;

## did manipulation on offer column
UPDATE swiggy_cleaned
SET rating = SUBSTRING_INDEX(rating_and_delivery_time, 'â€¢', 1),
    delivery_time = SUBSTRING_INDEX(rating_and_delivery_time, 'â€¢', -1);
    
## did manipulation on offer column    
UPDATE swiggy_cleaned
	SET offer_percentage = SUBSTRING(SUBSTRING_INDEX(LTRIM(offer), 'â‚¹', 1),1,2),
    offer_upto = SUBSTRING_INDEX(LTRIM(offer), 'â‚¹', -1)
	where SUBSTRING(LTRIM(offer),3,1)='%';

## did manipulation on offer column
UPDATE swiggy_cleaned
	SET offer_percentage = "Not Available",
    offer_upto = SUBSTRING_INDEX(LTRIM(offer), 'â‚¹', -1)
	where SUBSTRING(LTRIM(offer),1,1)='â';

## did manipulation on offer column
UPDATE swiggy_cleaned
	SET offer_percentage = "Not Available",
    offer_upto = SUBSTRING_INDEX(LTRIM(offer), 'â‚¹', -1)
	where SUBSTRING(LTRIM(offer),1,5) in ('ITEMS','EVERY');


## did manipulation on offer column
UPDATE swiggy_cleaned
	SET offer_percentage = "Not Available",
    offer_upto = "0"
	where SUBSTRING(LTRIM(offer),1,4) = 'FREE';

## Removing str from delivery_time
Update swiggy_cleaned
Set delivery_time=SUBSTRING_INDEX(LTRIM(delivery_time),' ',1);


## Replacing null values
Update swiggy_cleaned
Set offer_percentage='Not Available'
where offer_percentage is null;


## Replacing null values
Update swiggy_cleaned
Set offer_percentage=0
where offer_upto is null;


## Replacing null values
Update swiggy_cleaned
Set offer_upto='Not Available'
where offer_upto is null;

## In some values of rating it is equivalent to delivery time due to not availablity while splitting
Update swiggy_cleaned
Set rating='Not Available'
where substring(ltrim(rating),-1,1)='s';

## Removing rating_and_delivery time and offer column
Alter table swiggy_cleaned
drop column rating_and_delivery_time,
drop column offer;


## did manipulation on offer column    
UPDATE swiggy_cleaned
	SET offer_percentage = SUBSTRING(SUBSTRING_INDEX(LTRIM(offer_upto), 'OFF', 1),1,2),
    offer_upto = 'Not Available'
	where offer_upto like '%OFF%';

## View Data after cleaning
Select * from swiggy_cleaned;

#Revoking permission for updating without where
SET SQL_SAFE_UPDATES = 1;