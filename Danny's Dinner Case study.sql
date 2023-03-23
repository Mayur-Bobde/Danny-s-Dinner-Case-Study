
/*1. What is the total amount each customer spent at the restaurant?*/
select s.customer_id, sum(m.price) as total_spent from sales s join menu m on m.product_id = s.product_id
group by s.customer_id
order by s.customer_id;


/*2. How many days has each customer visited the restaurant?*/
with CTE as (select customer_id,month(order_date) as month, day(order_date) as Date from sales
group by customer_id,month(order_date),day(order_date)
order by month,Date)
select customer_id, count(Date) as day_visited from CTE
group by customer_id 
order by customer_id;


/*3.What was the first item from the menu purchased by each customer?*/
with CTE as (select * , dense_rank() over(partition by customer_id order by product_name)as rnk from (SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM sales
  GROUP BY customer_id
) f ON s.customer_id = f.customer_id AND s.order_date = f.first_order_date)s1)
select * from CTE where rnk=1;


/*4. What is the most purchased item on the menu and how many times was it purchased by all customers?*/
select s.product_id, count(s.product_id) as total_qty_purchase, m.product_name from sales s
join menu m on m.product_id = s.product_id
group by s.product_id, m.product_name
order by 2 desc
limit 1;


/*5. Which item was the most popular for each customer?*/
select * from ( with CTE as (
select s.customer_id,s.product_id, m.product_name,count(s.product_id) as cnt from sales s 
join menu m on m.product_id = s.product_id
group by 1,2,3
order by 1,4 desc)
select customer_id,product_id,product_name,cnt, rank() over(partition by customer_id order by cnt desc) rnk from CTE) a
where rnk=1;


/*6. Which item was purchased first by the customer after they became a member?*/
select * from (select *, dense_rank() over (partition by sales_customer_id order by order_date asc) as rnk from 
(with CTE as (
    select sales.customer_id as sales_customer_id, sales.product_id,order_date, members.join_date
    from sales 
    join members on members.customer_id = sales.customer_id 
    where sales.customer_id in (select members.customer_id from members)
)
select sales_customer_id, product_id,order_date
from CTE 
where order_date >= join_date
order by sales_customer_id,order_date asc)x)y
where rnk=1;


