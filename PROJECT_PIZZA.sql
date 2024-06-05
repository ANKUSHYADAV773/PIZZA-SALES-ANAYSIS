create database pizzahut;
select * from pizzas; 
USE PIZZAHUT;
create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
QUANTITY INT not null,
primary key(order_details_id)
);

-- Retrieve the total number of orders placed.
select count(order_id) from orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            1) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
    
    
-- Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
 from 
 pizzas
 join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id
 order by pizzas.price  desc limit 1;   
 
 -- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as ordered 
from pizzas
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizzas.size
order by ordered desc limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name , sum(order_details.QUANTITY) as total_quantity 
from pizza_types
join pizzas
 on pizza_types.pizza_type_id =pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by total_quantity desc limit 5
;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.QUANTITY) as category_quantity
from pizza_types
join
pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on pizzas.pizza_id= order_details.pizza_id
group by pizza_types.category ;

-- Determine the distribution of orders by hour of the day. 
select hour(orders.order_time)as orders_inHrs, count(orders.order_id) as order_count 
from orders

group by orders_inHrs 
order by orders_inHrs asc
;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name )
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(total_sale_day),2) from
(select orders.order_date as order_byDAY, sum(order_details.QUANTITY) as total_sale_day
from orders
join 
order_details on orders.order_id= order_details.order_id 
group by order_byDAY) as order_quantity_aDAY
; 

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum( pizzas.price * order_details.QUANTITY )as revenue
from pizza_types
join
pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
join 
order_details on order_details.pizza_id=pizzas.pizza_id
group by  pizza_types.name
order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category , round((sum(order_details.QUANTITY*pizzas.price)/(SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            1) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id )) *100,2) as category_revenue_percent
from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category 
order by category_revenue_percent desc;

-- Analyze the cumulative revenue generated over time.
-- #note- use of windows functions
select order_date, sum(revenue) over(order by order_date) as cummulative_revenue
from

(  select orders.order_date, round(sum(order_details.QUANTITY*pizzas.price),2)as revenue
 from order_details
 join pizzas on order_details.pizza_id=pizzas.pizza_id
 join orders on orders.order_id=order_details.order_id
 group by orders.order_date 
 order by orders.order_date asc ) as daily_sales
 ;
 
 -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
-- note- use windows function or CTE or sub query
select category, name, revenue
from
(select category,name, revenue,
rank() over(partition by category order by revenue desc ) as categorical_revenue_ranks
from 
(select pizza_types.category,pizza_types.name,
sum(order_details.QUANTITY*pizzas.price) as revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as categorical_revenue) as 
top3_categorical_revenue_ranks
where  categorical_revenue_ranks <=3;
;
    




