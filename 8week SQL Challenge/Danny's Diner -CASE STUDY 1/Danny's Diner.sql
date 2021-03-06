cREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  ( product_id, product_name, price )
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  ( customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09'),
  ('C', '2021-01-11');
  
  show tables;
  
SELECT 
    *
FROM
    members;
SELECT 
    *
FROM
    sales;  
SELECT 
    *
FROM
    menu;
    
    
CREATE VIEW c2 AS
SELECT sales.customer_id,sales.order_date,sales.product_id,menu.price,menu.product_name,
members.join_date
  FROM members
  INNER JOIN sales
  ON members.customer_id = sales.customer_id
  INNER JOIN menu
  ON sales.product_id = menu.product_id
  order by sales.customer_id,menu.product_id
  ;
  
select * from c2;

-- What is the total amount each customer spent at the restaurant? --
select customer_id, sum(price) as total_spending  
from c2 
group by customer_id 
ORDER BY total_spending desc;


-- How many days has each customer visited the restaurant -- 

select * from c2;

select customer_id, count(distinct(order_date)) as time_visited  
from c2 
group by customer_id 
ORDER BY time_visited desc;

 -- What was the first item from the menu purchased by each customer? --

 With Mank as
(
Select S.customer_id, 
       M.product_name, 
       S.order_date,
       DENSE_RANK() OVER (PARTITION BY S.Customer_ID Order by S.order_date) as mank
From Menu m
join Sales s
On m.product_id = s.product_id
group by S.customer_id, M.product_name,S.order_date)
select * from mank;
Select Customer_id, product_name
From Mank
Where Mank = 1;

-- What is the most purchased item on the menu --
-- and how many times it was purchased by all customer --

select * from c2;

Select *
From Menu as m
join Sales as s
On m.product_id = s.product_id
order by m.product_id;


Select  M.product_name , Count(S.product_id) as most_popular
From Menu as m
join Sales as s
On m.product_id = s.product_id
Group by M.product_name
Order by most_popular desc;

-- Which item was the most popular for each customer? --

Select *
From Menu as m
join Sales as s
On m.product_id = s.product_id
order by s.customer_id;

with cte as (select s.customer_id,s.product_id,m.product_name, count(s.product_id) as pop,
rank() over(partition by s.customer_id order by s.product_id) as rnk
from sales as s join menu as m
on s.product_id = m.product_id
group by s.customer_id,m.product_id,M.product_name)
select customer_id,product_id,product_name,pop from cte where rnk = 1;

-- 6. Which item was purchased first by the customer after they became a member?


With mank as
(
Select  S.customer_id,
        M.product_name,
	Dense_rank() OVER (Partition by S.Customer_id Order by S.Order_date) as mank
From Sales S
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
Where S.order_date >= Mem.join_date  
)
Select *
From mank
Where mank = 1;

-- 7. Which item was purchased just before the customer became a member?

with cte as (select sales.customer_id,product_name,
Dense_rank() OVER (Partition by Sales.Customer_id Order by Sales.Order_date) as tank
from Sales 
join menu on sales.product_id = menu.product_id 
join members on members.customer_id = sales.customer_id 
where members.join_date > sales.order_date)
select customer_id , menu.product_name from cte where tank = 1;

with tank as
(
Select  S.customer_id,
        M.product_name,
	Dense_rank() OVER (Partition by S.Customer_id Order by S.Order_date) as tank
From Sales S
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
Where S.order_date < Mem.join_date  
)
Select customer_ID, Product_name
From tank
Where tank = 1;

-- 8. What is the total items and amount spent for each member 
-- before they became a member?
with tank as
(
Select  S.customer_id, sum(m.price) as amount_spent ,
 count(distinct(m.product_id)) as total_item,
        M.product_name
From Sales S
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
Where S.order_date < Mem.join_date 
group by s.customer_id 
)
select customer_id , amount_spent , total_item from tank;

Select S.customer_id,count(S.product_id ) as quantity ,Sum(M.price) as total_sales
From Sales S
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = S.customer_id
Where S.order_date < Mem.join_date
Group by S.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier
--  - how many points would each customer have?

With Points as
(
Select *, Case When product_id = 1 THEN price*20
               Else price*10
	       End as Points
From Menu
)
Select S.customer_id, Sum(P.points) as Points
From Sales S
Join Points p
On p.product_id = S.product_id
Group by S.customer_id;

-- 10. In the first week after a customer joins the program (including their join date)
-- they earn 2x points on all items, not just sushi
-- - how many points do customer A and B have at the end of January


WITH dates AS 
(
   SELECT *, 
      DATEADD (DAY, 6, join_date) AS valid_date, 
      EOMONTH('2021-01-31') AS last_date
   FROM members 
)
Select S.Customer_id, 
       SUM(
	   Case 
	  When m.product_ID = 1 THEN m.price*20
	  When S.order_date between D.join_date and D.valid_date Then m.price*20
	  Else m.price*10
	  END 
	  ) as Points
From Dates D
join Sales S
On D.customer_id = S.customer_id
Join Menu M
On M.product_id = S.product_id
Where S.order_date < d.last_date
Group by S.customer_id
