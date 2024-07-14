### 								INSIGHTS ON SWIGGY DATA


### Selecting Database
use case_study_swiggy;


## First view of data
Select * from swiggy_cleaned_final;


## 1. List all the distinct food items available in Kandivali East.
Select food from swiggy_cleaned_final where location='Kandivali East';


## 2. Find the average rating for each hotel in Kandivali East.
Select hotel_name, round(avg(rating),1) AS average_rating from swiggy_cleaned_final where location = 'Kandivali East' 
group by hotel_name;


## 3. Identify the food items that have an offer upto value of 80.
Select hotel_name,food from swiggy_cleaned_final where offer_upto>=80;


## 4. Identify the hotels with the shortest delivery time in Kandivali West.
Select hotel_name, min(delivery_time) as quick_delivery from swiggy_cleaned_final where location='Kandivali West'
group by hotel_name order by quick_delivery LIMIT 5;



## 5. List the hotel , count of items offered and the avg rating gretaer than  of 4 in Borivali.
Select hotel_name,count(distinct food) as count_of_items, round(avg(rating),1) as avg_rating from swiggy_cleaned_final 
where location='Borivali' group by hotel_name having avg_rating>4 order by avg_rating desc;


## 6. Hotels with higher average offer percentage in kandivali East.
Select distinct hotel_name,round(avg(offer_percentage),1) as avg_offer_percentage from swiggy_cleaned_final
where location = 'Kandivali East'  group by hotel_name  having avg_offer_percentage>0 order by avg_offer_percentage desc;


## 7. Compare the average delivery time and rating between McDonald's and KFC in Kandivali East.
Select hotel_name,round(avg(delivery_time),1) as Avg_delivery_time,round(avg(rating),1) as Average_rating
from swiggy_cleaned_final where hotel_name in ('McDonald\'s','KFC') and location = 'Kandivali East' group by hotel_name;


## 8. List the best offer for burger with hotel name and location
Select hotel_name,location,max(offer_percentage) as best_offer from swiggy_cleaned_final where food = 'Burgers' 
group by hotel_name,location having best_offer <> 'Not Available' order by best_offer desc;


## 9. Derive Correlation coefficient between delivery_time and offer_percentage
create view df as
(select delivery_time,offer_percentage from swiggy_cleaned_final where offer_percentage not in ('Not Available','0'));
Set @avgdel=(Select avg(delivery_time) from df);
Set @avgoffer=(Select avg(offer_percentage) from df);
Set @std_over=(Select stddev_samp(delivery_time)*stddev_samp(offer_percentage) from df);

Select round((sum((delivery_time-@avgdel)*(offer_percentage-@avgoffer))) / ((count(*) -1) *
@std_over),2) as Correlation_coefiicient from df;


## 10. Identify the top 5 hotels with the best offers and shortest delivery times in Kandivali East.
Select hotel_name, avg(offer_percentage) AS avg_offer_percentage, round(avg(delivery_time),1) as avg_delivery_time
from swiggy_cleaned_final
where location = 'Kandivali East' and offer_percentage not in ('Not Available','0')
group by hotel_name
order by avg_offer_percentage desc, avg_delivery_time asc
limit 5;

