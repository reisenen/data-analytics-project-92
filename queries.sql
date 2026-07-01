--count total customers
select
	COUNT(c.customer_id ) as customers_count
from customers c 

--count sales and sum income
select 
	concat(e.first_name, ' ', e.last_name) as seller,
	count(s.sales_id ) as operations,
	sum(s.quantity * p.price) as income
from sales s
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller
order by income desc
limit 10;

--count seller average income less than overall average income
select 
	concat(e.first_name, ' ', e.last_name) as seller,
	round(avg(s.quantity * p.price )) as average_income
from sales s
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller
having round(avg(s.quantity * p.price )) < 
	(select avg(s.quantity * p.price) from sales s inner join products p on s.product_id = p.product_id)
order by average_income;

--count seller average per day of week
select 
	concat(e.first_name, ' ', e.last_name) as seller,
	trim(to_char(s.sale_date, 'day')) as day_of_week,
	round(sum(s.quantity * p.price)) as income
from sales s
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller, day_of_week, extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), seller;