create database inventory_management;
use inventory_management;

CREATE TABLE inventory_supplychain (
    id INT NOT NULL AUTO_INCREMENT,
	order_Date	date,
    Region	varchar(50),
    Category varchar(50),
	Supplier varchar(50),	
    Warehouse	varchar(50),
    Order_Status varchar(50),
	Units_Sold int ,
	Inventory_Level int ,
	Transportation_Cost	decimal(10,6),
    Order_Accuracy varchar(50),	
    Lead_Time_Days int,
    Backorder	varchar(50),
    Cost_of_Goods_Sold 	decimal(12,2),
    Average_Inventory decimal(10,4),
    Warehouse_Capacity int ,
    PRIMARY KEY (id)
);
LOAD DATA LOCAL INFILE 'C:/Users/Home/Downloads/Inventory_SupplyChain_Dataset.csv'
INTO TABLE inventory_supplychain
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_date,
    Region,
    Category,
    Supplier,
    Warehouse,
    Order_Status,
    Units_Sold,
    Inventory_Level,
    Transportation_Cost,
    Order_Accuracy,
    Lead_Time_Days,
    Backorder,
    Cost_of_Goods_Sold,
    Average_Inventory,
    Warehouse_Capacity
);

drop table inventory_supplychain;
select * from inventory_supplychain;

select count(*) from inventory_supplychain;

select min(order_date) as start_date ,
max(order_date) as end_date,
datediff( max(order_date),min(order_date) ) as range_day 
from inventory_supplychain;

select count(distinct region) as distinct_region,
count(distinct category) as distinct_category,
count(distinct supplier) as distinct_supplier,
count(distinct warehouse) as distinct_warehouse,
count(distinct order_status) as distinct_order_status
from inventory_supplychain;


select 
sum(case when order_date is null then 1 else 0 end) as order_date,
sum(case when region is null then 1 else 0 end) as region,
sum(case when category is null then 1 else 0 end) as category,
sum(case when supplier is null then 1 else 0 end) as supplier,
sum(case when warehouse is null then 1 else 0 end) as warehouse,
sum(case when order_status is null then 1 else 0 end) as order_status,
sum(case when transportation_cost is null then 1 else 0 end) as transportation_cost,
sum(case when order_accuracy is null then 1 else 0 end) as order_accuracy,
sum(case when lead_time_days is null then 1 else 0 end) as lead_time_days,
sum(case when backorder is null then 1 else 0 end) as backorder,
sum(case when cost_of_goods_sold is null then 1 else 0 end) as cost_of_goods_sold,
sum(case when average_inventory is null then 1 else 0 end) as average_inventory,
sum(case when warehouse_capacity is null then 1 else 0 end) as warehouse_capacity
from inventory_supplychain;

select order_date,category,supplier,warehouse,order_status,units_sold,inventory_level
,count(*) as duplicate_count
from inventory_supplychain
group by order_date,region,category,supplier ,warehouse,order_status,
units_sold,inventory_level having count(*)>1 ;

select * from inventory_supplychain;

select 
max(units_sold) as max_units_sold,
min(units_sold) as min_units_sold,
avg(units_sold) as avg_units_sold,

max(inventory_level) as max_inventory_level,
min(inventory_level) as min_inventory_level,
avg(inventory_level) as avg_inventory_level,

max(transportation_cost) as max_transportation_cost,
min(transportation_cost) as min_transportation_cost,
avg(transportation_cost) as avg_transportation_cost,

max(lead_time_days) as max_lead_time_days,
min(lead_time_days) as min_lead_time_days,
avg(lead_time_days) as avg_lead_time_days,
max(cost_of_goods_sold) as max_cost_of_goods_sold,
min(cost_of_goods_sold) as min_cost_of_goods_sold,
avg(cost_of_goods_sold) as avg_cost_of_goods_sold

from inventory_supplychain;

select 
case when lead_time_days between 1 and 7 then '01-07 days (fast)' 
 when lead_time_days between 8 and 14 then '08-14 days (fast)'
 when lead_time_days between 15 and 21 then '15-21 days (fast)'
 else '22+ days (slow)'
 end as lead_time_bucket,
 count(*) as record_count,
 round(count(*)*100/(select count(*) from inventory_supplychain),2) as pct_to_total
 from inventory_supplychain
 group by lead_time_bucket 
 order by count(*) desc;
 
 select distinct units_sold from inventory_supplychain order by units_sold desc;
 select 
 case when units_sold <250 then "Q1: Below 250"
 when units_sold between 250 and 500 then "Q2: Below 250-500"
 when units_sold between 500 and  750 then "Q3: Below 500-750"
 when units_sold between 750 and 1000 then "Q4: Below 750-1000"
 end as units_sold_bucket,
 count(*) as record_count,
 round(count(*)*100/(select count(*) from inventory_supplychain),2) as pct_unit_sold
 from inventory_supplychain
 group by units_sold_bucket order by pct_unit_sold;
 
 
 select region ,count(*) as region_count,
 round(count(*)*100/(Select count(*) from inventory_supplychain),2) as pct
 from inventory_supplychain group by region order by region_count;
 
 
 select category ,count(*) as category_count,
 round(count(*)*100/(select count(*) from inventory_supplychain),2) as pct
 from inventory_supplychain group by category order by category_count;
 
  select supplier ,count(*) as supplier_count,
 round(count(*)*100/(select count(*) from inventory_supplychain),2) as pct
 from inventory_supplychain group by supplier order by supplier_count;
 
   select order_status ,count(*) as order_status_count,
 round(count(*)*100/(select count(*) from inventory_supplychain),2) as pct
 from inventory_supplychain group by order_status order by order_status_count;
 
select if(order_accuracy ="TRUE" ,"Accurate" ,"INAccurate")  as label,
count(*) as cnt ,
round(100*count(*)/(Select count(*) from inventory_supplychain),2) as pct
from inventory_supplychain
group by order_accuracy;

select * from inventory_supplychain;
select if(backorder = "False" ,"In backroder" ,"not in backorder") as label,
count(*) as cnt,
round(count(*)*100/(Select count(*) from inventory_supplychain),2) as pct from
inventory_supplychain group by backorder;

select * from inventory_supplychain;
select region ,
round(sum(cost_of_goods_sold),2) as total_cogs,
round(sum(units_sold),2) as total_units_sold
from inventory_supplychain
group by region order by total_cogs desc ,total_units_sold desc;

select category , 
round(Sum(cost_of_goods_sold),2) as total_cogs
from inventory_supplychain
group by category order by total_cogs desc;

select supplier ,
round(sum(cost_of_goods_sold),2) as total_cogs,
round(avg(cost_of_goods_sold),2) as avg_cogs,
sum(units_sold) as total_units
from inventory_supplychain
group by supplier order by total_cogs;

select warehouse,
sum(units_sold) as total_units_sold,
round(sum(cost_of_goods_sold) ,2) as total_cogs,
round(avg(transportation_cost),2) as avg_transport_cost
from inventory_supplychain group by warehouse
order by total_units_sold;

select date_format(order_date , "%Y-%m") as year_months,
sum(units_sold) as total_units_sold,
sum(cost_of_goods_sold) as total_cogs
from inventory_supplychain group by year_months order by year(year_months) desc;

select t.year_,
t.qtr,
sum(units_sold) as total_units_sold,
sum(cost_of_goods_sold) as total_cogs
from (Select units_sold ,cost_of_goods_sold,year(order_date) as year_ ,
ntile(4) over(order by month(order_date)) as qtr from
inventory_supplychain) t  group by year_,qtr
 order by qtr,year_;
 
 select year(order_date) as year_,month(order_date) as month_,
 avg(units_sold) as avg_units_sold,
 avg(cost_of_goods_sold) as avg_cogs
 from inventory_supplychain group by month(order_date), year(order_date)
 order by month_ , year_;
 
 select region ,category , sum(cost_of_goods_sold) as total_cogs,
 sum(units_sold) as total_units_sold
 from inventory_supplychain group by region ,category 
 order by total_cogs desc; 
 
 select region ,round(avg(inventory_level),2) as  avg_inventory_level,
 max(inventory_level) as max_inventory_level,
 min(inventory_level) as min_inventory_level 
 from inventory_supplychain group by region order by  avg_inventory_level desc;
 
 select category , (sum(cost_of_goods_sold) / sum(average_inventory) )
 as turnover_inventory from inventory_supplychain group by category;
 
 select warehouse , 
 round(avg(inventory_level) ,2) as avg_inventory_level,
 round(avg(warehouse_capacity),2) as avg_inventory_capacity,
 (avg(inventory_level)/avg(warehouse_capacity)) as utilization_rate
 from inventory_supplychain group by warehouse order by utilization_rate desc;
 
 
 select * from inventory_supplychain where inventory_level<200
 order by inventory_level desc;
 
 select * from inventory_supplychain where units_sold>inventory_level;
 
 select category,
 avg(inventory_level) as avg_inventory_level,
 avg(units_sold) as avg_units_sold,
 (avg(inventory_level)-avg(units_sold)) as stock_surplus
 from inventory_supplychain group by category;
 
 select region,supplier,
 (sum(cost_of_goods_sold) / sum(average_inventory)) as inventory_turnover_ratio
 from inventory_supplychain group by region,supplier;
 
 select count(*),
 sum(Case when order_status ="Fulfilled" then 1 else 0 end) as fulfilled_orders,
 round(sum(case when order_status ="Fulfilled" then 1 else 0 end)*100/count(*),2) as fulfillment_rate
 from inventory_supplychain;
 
 select region ,count(*)as cnt,
 sum(case when order_status ="Canceled" then 1 else 0 end) as canceled_orders,
 round(sum(case when order_status="Canceled" then 1 else 0 end)/count(*),2) as cancellation_rate
 from inventory_supplychain group by region;
 
 select order_status ,category,
 count(*) as total_orders, 
 round(count(*)*100/sum(count(*)) over(partition by category),2) as pct_within_category
 from inventory_supplychain group by order_status, category ;
 

 select supplier ,count(*),
 sum(case when order_accuracy= "TRUE" then 1 else 0 end) as order_accuracy,
 (sum(case when order_accuracy="TRUE" then 1 else 0 end)*100 / count(*)) as pct_accuracy
 from inventory_supplychain group by supplier;
 
 select order_status,
 avg(units_sold) as avg_sold,
 avg(cost_of_goods_sold) as avg_cogr
 from inventory_supplychain group by order_status;
 
 select count(*)as count_orders,
 sum(case when backorder="TRUE" then 1 else 0 end) as total_backorder,
 sum(case when backorder+"TRUE" then 1 else 0 end)/count(*) as pct_backorder
 from inventory_supplychain ;
 
 select category , count(*) as count_orders,
 sum(case when backorder="TRUE" then 1 else 0 end) as total_backorder,
sum(case when backorder="TRUE" then 1 else 0 end)*100/count(*) as pct_backorder
 from inventory_supplychain  group by category;
 
  select supplier , count(*) as count_orders,
 sum(case when backorder="TRUE" then 1 else 0 end) as total_backorder,
sum(case when backorder="TRUE" then 1 else 0 end)*100/count(*) as pct_backorder
 from inventory_supplychain  group by supplier;
 
 select if(backorder="TRUE" ,"IN backorder" ,"NOT in bacorder") as backorder_label,
 round(avg(inventory_level),2) as avg_inventory_level,
 round(avg(units_sold),2) as avg_units_sold,
 round(avg(lead_time_days),2) as avg_lead_time_days
 from inventory_supplychain group by backorder ;
 
 select * from inventory_supplychain;
 select case
 when lead_time_days<=7 then "01-07 days"
  when lead_time_days<=14 then "08-14 days"
   when  lead_time_days<=21 then "15-21 days"
else "22+ days"
end as lead_time_bucket,count(*) as cnt,
sum(case when backorder="TRUE" then 1 else 0 end) as backorder_total,
round(sum(case when backorder="TRUE" then 1 else 0 end)*100/count(*),2) as backorder_pct
from inventory_supplychain group by lead_time_bucket;

 select case
 when inventory_level < (select avg(inventory_level) from inventory_supplychain)
 then "below average inventory " else "above average inventory" end as inventory_segment	
 ,count(*) as cnt,
sum(case when backorder="TRUE" then 1 else 0 end) as backorder_total,
round(sum(case when backorder="TRUE" then 1 else 0 end)*100/count(*),2) as backorder_pct
from inventory_supplychain group by inventory_segment;

select region ,
avg(transportation_cost) as avg_transportation_cost,
sum(transportation_cost) as sum_transportation_cost
from inventory_supplychain group by region;

select supplier ,
avg(transportation_cost) as avg_transportation_cost,
sum(transportation_cost) as sum_transportation_cost
from inventory_supplychain group by supplier;

select category ,
avg(transportation_cost) as avg_transportation_cost,
avg(cost_of_goods_sold) as avg_cogr,
avg(transportation_cost)*100/avg(cost_of_goods_sold) as tranport_pct_cogs
from inventory_supplychain group by category;

select warehouse,
sum(transportation_cost)/sum(units_sold) as transport_cost_per_unit
from inventory_supplychain group by warehouse;

select order_status,
avg(transportation_cost) as avg_transportation_cost,
sum(transportation_cost) as sum_transportation_cost
from inventory_supplychain group by order_status;

select month(order_date),
round(sum(transportation_cost)/sum(units_sold),2) as transport_cost_per_unit
from inventory_supplychain group by month(order_date) order by month(order_date) desc ;

select supplier ,
avg(lead_time_days) as avg_lead_time_days,
min(lead_time_days) as min_lead_time_days,
max(lead_time_days) as max_lead_time_days
from inventory_supplychain group by supplier;

select category ,
avg(lead_time_days) as avg_lead_time_days,
min(lead_time_days) as min_lead_time_days,
max(lead_time_days) as max_lead_time_days
from inventory_supplychain group by category;

select supplier,
SUM(CASE WHEN `Order_Status` = 'Canceled' THEN 1 ELSE 0 END)  AS canceled_orders,
SUM(CASE WHEN `Order_Status` = 'Canceled' THEN 1 ELSE 0 END)*100/count(*)  AS pct_canceled_orders
from inventory_supplychain group by supplier;

select supplier,
    round(sum(case when order_accuracy = "TRUE" then 1 else 0 end) * 100.0 / count(*),2) as accuracy_rate_pct,
    round(
        sum(case when backorder = "TRUE" then 1 else 0 end) * 100.0 / count(*),2) as backorder_rate_pct,
    round(avg(lead_time_days), 2) as avg_lead_time,
    round(sum(cost_of_goods_sold), 2) as total_cogs
from inventory_supplychain
group by supplier order by accuracy_rate_pct desc;

select supplier,warehouse ,sum(units_sold) as total_units_sold,
 ROUND(AVG(Lead_Time_Days), 2)AS avg_lead_time
from inventory_supplychain group by supplier,warehouse order by total_units_sold;

select order_status,
avg(lead_time_days) as avg_lead_time_days
from inventory_supplychain group by order_status;

select supplier,count(*) as cnt,
round(sum(cost_of_goods_sold),2) as total_cogs,
rank() over (order by sum(cost_of_goods_sold) desc) as cogs_rank,
 ROUND(SUM(Cost_of_Goods_Sold) * 100.0 / sum(SUM(Cost_of_Goods_Sold)) over(), 2) AS pct_contribution
FROM inventory_supplychain
GROUP BY Supplier;


select year_month_ ,monthly_unit_sold,
round(avg(monthly_unit_sold) over(order by year_month_
rows between 2 preceding and current row),2) as rolling_3month_avg_units_sold
from (select date_format(order_date ,"%Y-%m") as year_month_,
sum(units_sold) monthly_unit_sold
from inventory_supplychain group by year_month_ ) monthly_data order by year_month_;




 
 
 
 
 
 





 
 
 



