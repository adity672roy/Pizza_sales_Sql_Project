use dominos ;
-- Basic:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id)
FROM
    dominos.orders;



-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;



-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size order by order_count desc limit 1;




-- List the top 5 most ordered pizza types along 
-- with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;






-- Intermediate:
-- Join the necessary tables to find the total quantity of each 
-- pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id) AS order_hour
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY order_hour DESC;



-- Join relevant tables to find the category-wise distribution 
-- of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;




-- Group the orders by date and calculate the average number of 
-- pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity)) AS avg_pizza_ordered
FROM
    (SELECT 
        orders.order_data, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_data) AS order_quantity;




-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;




-- Advanced:
-- Calculate the percentage contribution of each pizza
-- type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            2) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category 
ORDER BY revenue DESC;





-- Analyze the cumulative revenue generated over time.
select order_data , sum(revenue) over
(order by order_data) 
as cumulative_revenue
from (select orders.order_data,
sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas on 
order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.order_data) as sales;



-- Determine the top 3 most ordered pizza types based 
-- on revenue for each pizza category.
select name  ,revenue from 
(select name ,category ,revenue, rank() 
over (partition by category order by revenue desc) 
as rn 
from 
(SELECT 
     pizza_types.name, pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name, pizza_types.category 
ORDER BY revenue DESC
) as a)as b 
where rn <= 3;




