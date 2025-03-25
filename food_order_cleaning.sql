select * from food_orders;


--DATA CLEANING

--Are there any missing values in key columns, such as timestamps or financial metrics,
-- and how should they be handled?
select fo."Delivery Date and Time" dv , fo."Order Date and Time" as od  
	from food_orders fo 
	where fo."Delivery Date and Time" is not null and fo."Order Date and Time" is not null ;

select count(*) as disticnt_count
	from (select fo."Delivery Date and Time" dv , fo."Order Date and Time" as od  
from food_orders fo
where fo."Delivery Date and Time"  is null and fo."Order Date and Time"  is null);

select fo."Order Value" 
, fo."Delivery Fee" 
, fo."Payment Method" 
, fo."Commission Fee" 
,fo."Payment Processing Fee" 
, fo."Refunds/Chargebacks" 
	from food_orders fo ;
--With the #No missing values detected

--How can timestamp errors (e.g., delivery times earlier than order times) be identified and
-- corrected systematically?

select fo."Order Date and Time" ,	
substring(fo."Delivery Date and Time", 12, 8) as time_taken_for_the_delivery,
	fo."Delivery Date and Time"  ,
	substring(fo."Order Date and Time" , 12, 8) as time_taken_for_the_order
from food_orders fo 


/*
 * SELECT 
    fo."Delivery Date and Time", 
    COALESCE(fo."Delivery Date and Time" , fo."Order Date and Time" ) AS 
FROM 
    food_orders fo ;
*/

select  AGE("Delivery Date and Time"::timestamp , "Order Date and Time"::timestamp) AS difference 
from food_orders fo 
--There seems to be a perfect time difference between order date and delivery date


/*
 * How can unstructured discount data (e.g., text formats like "20% off" or "$5 discount") 
 * be standardized for consistent analysis?*/

select fo."Discounts and Offers" as discount_offer, 
RIGHT(fo."Discounts and Offers", 4) as offer_per,
substring(fo."Discounts and Offers", 1,2) as Discount_per
from food_orders fo 
where fo."Discounts and Offers" = (select ("Discount_per" /100.0) as standardized);


select 
  case 
    when "Discounts and Offers" LIKE '%%' then CAST(SUBSTRING("Discounts and Offers" 
    from '([0-9]+)%') AS DECIMAL) / 100.0
    when "Discounts and Offers" LIKE '$%' then CAST(SUBSTRING("Discounts and Offers" 
    from '\$([0-9]+)') AS DECIMAL)
    else null
  end as standardized_value
from 
  food_orders;

--
alter table food_orders add standardized_value decimal(3,2);
select * from food_orders


update food_orders fo  
set standardized_value = case 
    when "Discounts and Offers" like '%%' then CAST(SUBSTRING("Discounts and Offers" 
    from '([0-9]+)%') AS DECIMAL) / 100.0
    when "Discounts and Offers" like '$%' then CAST(SUBSTRING("Discounts and Offers" 
    from '\$([0-9]+)') AS DECIMAL)
    else null
  end
--the column with mixed text and numerical has been standardized
  
 
--  Is the sum of costs (e.g., delivery fees, commissions) consistent with the order value in every record?
select fo."Customer ID" ,fo."Delivery Fee" , fo."Order Value" , fo."Commission Fee" 
from food_orders fo 


select 
	case 
		when fo."Delivery Fee" = 0 then 20
		when fo."Delivery Fee" = 20 then 20
		when fo."Delivery Fee" = 30 then 30
		when fo."Delivery Fee" = 40 then 40
		when fo."Delivery Fee" = 50 then 50
	else 0
	end cool_per
from food_orders fo 

alter table food_orders add standardized_delivery_cost int;

update  food_orders fo 
set standardized_delivery_cost = case 
		when fo."Delivery Fee" = 0 then 20
		when fo."Delivery Fee" = 20 then 20
		when fo."Delivery Fee" = 30 then 30
		when fo."Delivery Fee" = 40 then 40
		when fo."Delivery Fee" = 50 then 50
	else 0
	end




--Are there any inconsistencies in categorical fields, like restaurant 
--names or payment methods, that require standardization?
select distinct(fo."Restaurant ID") , count(* ) as occurences
	from food_orders fo 
group by fo."Restaurant ID" 
order by occurences desc;

select distinct(fo."Payment Method") , count(*) as occurences_2
	from
	food_orders fo 
group by fo."Payment Method" 
order by occurences_2 desc ;
	

--How can refunds and chargebacks be accurately tracked and analyzed within the dataset?

select fo."Payment Method",
	count(fo."Order ID"  ) as total_refunds,
	sum(fo."Order Value" ) as total_value,
	avg(fo."Order Value" ) as total_value,
	min(fo."Order Date and Time"  ) as first_refunds,
	max(fo."Order Date and Time"  ) as last_refunds
from 
	food_orders fo 
--where fo."Payment Method" in (fo."Refunds/Chargebacks")
group by fo."Payment Method"
order by fo."Payment Method" ;


--
select fo."Payment Processing Fee" , fo."Commission Fee" , 
	(( fo."Commission Fee" / fo."Payment Processing Fee"  ) * 0.015) as avg_percent
from 
	food_orders fo
group by "Payment Processing Fee" , fo."Commission Fee" 
order by avg_percent desc




-- Analysis stage

--Identifying the major cost components associated with delivering food orders, 
--including direct costs like delivery fees and indirect costs like discounts 
--and payment processing fees.


--What are the major cost components associated with delivering food orders?

select sum(fo."Order Value" ) as total_order_cost, fo.standardized_delivery_cost
from food_orders fo 
group by  standardized_delivery_cost 
order by total_order_cost  desc
--from the perpective it is believe that the delivery charge of 20(amount) 
--has alwaays been missing due to various reasons which also accumulate huge sum of money



--Profitability Evaluation: Calculating the profitability of individual orders and 
--aggregating this data to assess overall profitability. 
--This involves examining how revenue generated from commission fees measures against the total costs.

select fo."Customer ID"  ,(fo."Payment Processing Fee" * fo."Order Value"  )  as profit_margin
from food_orders fo
group by fo."Customer ID" , profit_margin 
order by profit_margin desc


select fo."Customer ID" ,
	(fo."Commission Fee")
	- (fo.standardized_delivery_cost + fo.standardized_value  + fo."Payment Processing Fee" )
	as profit
from food_orders fo 

select 
	sum(fo."Commission Fee" ) as total_commission,
	sum(fo.standardized_delivery_cost + fo.standardized_value  + fo."Payment Processing Fee" )
	as total_cost,
	sum(fo."Commission Fee")
	- (fo.standardized_delivery_cost + fo.standardized_value  + fo."Payment Processing Fee" )
	as profit
from food_orders fo
group by fo.standardized_delivery_cost , fo.standardized_value , fo."Payment Processing Fee" 

--adding new column as profit
alter table food_orders add profits numeric(5,2);

--laod the column with values
UPDATE  food_orders fo 
SET profits = fo."Commission Fee" 
	- 
fo.standardized_delivery_cost + fo.standardized_value  + fo."Payment Processing Fee"; 
 




select * from food_orders fo 


ALTER TABLE food_orders 
ADD COLUMN adjusted_commission_fee FLOAT,
ADD COLUMN adjusted_discount FLOAT,
ADD COLUMN adjusted_profit FLOAT;

update food_orders fo 
set adjusted_commission_fee =  fo."Commission Fee"  * 1.02
;

update food_orders fo 
set adjusted_discount = fo.standardized_value * 0.99;

UPDATE food_orders fo 
SET adjusted_profit = 
(adjusted_commission_fee - (fo.delivery_fee + fo.adjusted_discount + fo.payment_processing_fee));
 
update food_orders fo 
set adjusted_profit = adjusted_commission_fee - 
fo.standardized_delivery_cost + fo.standardized_value  + fo."Payment Processing Fee"; 



select 
    SUM(adjusted_commission_fee) AS total_adjusted_revenue,
    SUM(fo.standardized_delivery_cost  ) AS total_adjusted_costs,
    SUM(adjusted_profit + fo.standardized_value  + fo."Payment Processing Fee") AS total_adjusted_profit
from 
    food_orders fo ;

select * from food_orders fo 

 

