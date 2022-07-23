CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_names TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_names)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  


  -- Ques | How many pizzas were ordered?
  
SELECT count(order_id) AS total_pizza_ordered FROM customer_orders;
  
  -- Ques | How many unique customer orders were made?
  
  -- for this we need to clean the data because it contain too
  -- many missing values
  
  select * from customer_orders;
  
  DROP TABLE IF EXISTS updated_customer_orders;
CREATE  TABLE updated_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE 
      WHEN exclusions IS NULL 
        OR exclusions LIKE 'null' THEN ''
      ELSE exclusions 
    END AS exclusions,
    CASE 
      WHEN extras IS NULL
        OR extras LIKE 'null' THEN ''
      ELSE extras 
    END AS extras,
    order_time
  FROM pizza_runner.customer_orders
);
select * from updated_customer_orders;

UPDATE customer_orders SET exclusions = '' WHERE exclusions like 'null';
UPDATE customer_orders SET extras = '' WHERE extras like 'null' or extras IS NULL;

select * from customer_orders;

select count(distinct(c.order_id)) as unique_orders from customer_orders c;

-- ques | How many successful orders were delivered by each runner?
  
  select * from runner_orders;
  
  -- (DROP TABLE IF EXISTS updated_runner_orders;
-- CREATE  TABLE updated_runner_orders AS (
 -- SELECT
  --  order_id,
  --  runner_id,
  --   CASE WHEN pickup_time LIKE 'null' THEN null ELSE pickup_time END :: timestamp AS pickup_time,
   -- case when cancellation  NULLIF(regexp_replace(distance, '[^0-9.]','','g'), '')::numeric AS distance,
   -- NULLIF(regexp_replace(duration, '[^0-9.]','','g'), '')::numeric AS duration,
   -- CASE WHEN cancellation IN ('null', 'NaN', '') THEN null ELSE cancellation END AS cancellation
 -- FROM pizza_runner.runner_orders);)
  
UPDATE runner_orders SET distance = '' WHERE distance like 'null';
UPDATE runner_orders SET pickup_time = '' WHERE pickup_time like 'null';
UPDATE runner_orders SET duration = '' WHERE duration like 'null';
UPDATE runner_orders SET cancellation = '' WHERE cancellation like 'null' OR cancellation IS NULL;

select * from runner_orders;

select runner_id, count(order_id) as sucessful_orders
from runner_orders WHERE cancellation = '' group by runner_id;

-- Ques | How many of each type of pizza was delivered?

select pizza_runner.customer_orders.pizza_id, 
count(customer_orders.order_id) as order_count,
pizza_runner.pizza_names.pizza_names
from pizza_runner.customer_orders 
join pizza_runner.pizza_names
on pizza_runner.customer_orders.pizza_id = pizza_runner.pizza_names.pizza_id
Join pizza_runner.runner_orders 
On pizza_runner.customer_orders.order_id = pizza_runner.runner_orders.order_id
WHERE cancellation = ''
group by pizza_runner.pizza_names.pizza_id;

SELECT 
  pizza_runner.pizza_names.pizza_names,
  COUNT(pizza_runner.customer_orders.pizza_id) AS successful_pizza_delivered
FROM pizza_runner.customer_orders
Join pizza_runner.runner_orders 
On pizza_runner.customer_orders.order_id = pizza_runner.runner_orders.order_id
Join pizza_runner.pizza_names
On pizza_runner.customer_orders.pizza_id = pizza_runner.pizza_names.pizza_id
WHERE pizza_runner.runner_orders.duration != ''
GROUP BY pizza_runner.pizza_names.pizza_names;

-- Ques | How many Vegetarian and Meatlovers were ordered by each customer

select pizza_runner.customer_orders.customer_id, 
count(customer_orders.pizza_id) as pizza_count,
pizza_runner.pizza_names.pizza_names
from pizza_runner.customer_orders 
join pizza_runner.pizza_names
on pizza_runner.customer_orders.pizza_id = pizza_runner.pizza_names.pizza_id
group by pizza_runner.customer_orders.customer_id, pizza_runner.pizza_names.pizza_names;

SELECT
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meat_lovers,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian
FROM updated_customer_orders
GROUP BY customer_id;

-- 6.What was the maximum number of pizzas delivered in a single order?
-- what is maximun number of pizza ordered by single customer

select order_id, max(max_order) as max_order from (SELECT 
  c.order_id 
  ,COUNT(c.order_id) AS max_order
FROM customer_orders as c
join runner_orders as ro 
on c.order_id= ro.order_id
WHERE ro.cancellation = ''
GROUP BY c.order_id) as ed ;

SELECT MAX(pizza_count) AS max_count
FROM (
  SELECT
    co.order_id,
    COUNT(co.pizza_id) AS pizza_count
  FROM updated_customer_orders AS co
  INNER JOIN updated_runner_orders AS ro
    ON co.order_id = ro.order_id
  WHERE 
    ro.cancellation IS NULL
    OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
  GROUP BY co.order_id) AS mycount;
  
  WITH number_pizza_per_order_cte AS
 (
 SELECT 
  c.order_id 
  ,COUNT(c.pizza_id) AS pizza_delivered_per_order
FROM customer_orders as c
join runner_orders as ro 
on c.order_id= ro.order_id
WHERE ro.duration != ''
GROUP BY c.order_id
)

SELECT
 order_id,
 MAX(pizza_delivered_per_order) AS maximum_pizza_delivered
FROM number_pizza_per_order_cte;

-- Que | For each customer, how many delivered pizzas had
-- at least 1 change and how many had no changes?

select c.customer_id, order_id, pizza_ordered,c , l from (SELECT 
  c.order_id,
  sum(case when c.pizza_id = 1 then 1 else 0 end ) as c,
  sum(case when c.pizza_id = 2 then 1 else 0 end ) as l
  ,COUNT(c.pizza_id) AS pizza_ordered
FROM customer_orders as c
join runner_orders as ro 
on c.order_id= ro.order_id
WHERE ro.cancellation = ''
GROUP BY c.order_id) as ed ;

SELECT 
  co.customer_id,
  SUM(CASE WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 1 ELSE 0 END) AS changes,
  SUM(CASE WHEN co.exclusions IS NULL OR co.extras IS NULL THEN 1 ELSE 0 END) AS no_change
FROM updated_customer_orders AS co
INNER JOIN updated_runner_orders AS ro
  ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
  OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY co.customer_id
ORDER BY co.customer_id;

-- Ques | How many pizzas were delivered that had both exclusions and extras?
select * from runner_orders; 
select * from customer_orders c join runner_orders r on c.order_id = r.order_id;
select count(pizza_id) from customer_orders c 
join runner_orders r on c.order_id = r.order_id
where r.cancellation = '' and  c.exclusions != '' and c.extras != '';

-- Ques | What was the total volume of pizzas ordered for each hour of the day

Select 
   hour(order_time)As hour,
   COUNT(order_id) AS pizza_count
from customer_orders
group by hour(order_time) order by hour desc;

-- Ques | What was the volume of orders for each day of the week

Select 
   weekday(order_time)As day,
   COUNT(order_id) AS pizza_count
from customer_orders
group by hour(order_time) order by pizza_count desc;
