-- Retrieve the total no.of orders placed 
SELECT 
    COUNT(*) AS Total_number_of_orders
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales.

SELECT 
    SUM(o.quantity * p.price) AS total_sales
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id; 
    
-- Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered
SELECT 
    COUNT(od.order_details_id) AS order_count, p.size
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, SUM(od.quantity) AS quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    SUM(od.quantity) AS Total_quantity, pt.category
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY Total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hours, COUNT(order_id) AS Orders_count
FROM
    orders
GROUP BY Hours;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.order_date) AS Order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(p.price * od.quantity) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- 	Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category, round(SUM(p.price * od.quantity)/(SELECT 
    round(SUM(od.quantity * p.price),0) AS total_sales
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id) * 100,2) as revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
    group by pt.category
    order by revenue desc;

-- Analyse the cumulative revenue generated over time

select order_date, sum(revenue) over(order by order_date) as Cummulative_revenue from 
(select o.order_date,sum(od.quantity * p.price) as revenue  from orders o 
join order_details od on o.order_id = od.order_id
join pizzas p on p.pizza_id = od.pizza_id
group by o.order_date) as total_revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
 select category, name, revenue, top_3 from 
 
 (select category, name, revenue, rank() over(partition by category order by revenue desc)  as Top_3 from

(select pt.category,pt.name, sum(od.quantity * p.price) as revenue from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
group by pt.category,pt.name) as Total_revenue) as rn 
where top_3 <= 3;
    
    

