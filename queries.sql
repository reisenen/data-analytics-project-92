--count total customers
select
	COUNT(c.customer_id ) as customers_count
from customers c 

--count sales and sum income
select 
	concat(e.first_name, ' ', e.last_name) as seller,
	count(s.sales_id ) as operations,
	floor(sum(s.quantity * p.price)) as income
from sales s
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller
order by income desc
limit 10;

--count seller average income less than overall average income
select 
	concat(e.first_name, ' ', e.last_name) as seller,
	floor(avg(s.quantity * p.price )) as average_income
from sales s
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller
having floor(avg(s.quantity * p.price )) < 
	(select avg(s.quantity * p.price) from sales s inner join products p on s.product_id = p.product_id)
order by average_income;

--count seller average per day of week
select 
	concat(e.first_name, ' ', e.last_name) as seller,
	trim(to_char(s.sale_date, 'day')) as day_of_week,
	floor(sum(s.quantity * p.price)) as income
from sales s
inner join products p on s.product_id = p.product_id
inner join employees e on s.sales_person_id = e.employee_id
group by seller, day_of_week, extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), seller;

--segment customers by age
select
	case
		when c.age between 16 and 25 then '16-25'
		when c.age between 26 and 40 then '26-40'
		when c.age > 40 then '40+'
	end as age_category,
	count(c.customer_id) as age_count
from customers c
group by age_category
order by age_category;

--unique customers and income per month
select 
	to_char(s.sale_date, 'yyyy-mm') as selling_month,
	count(distinct s.customer_id) as total_customers,
	floor(sum(s.quantity * p.price)) as income
from sales s
inner join products p on s.product_id = p.product_id
group by selling_month
order by selling_month;

--customers first purchase with special offer
with ranked_purchases as (
	select
		s.customer_id,
		s.sale_date,
		s.sales_person_id,
		p.price,
		row_number() over (partition by s.customer_id order by s.sale_date) as rn
	from sales s
	inner join products p on s.product_id = p.product_id
)

select
	concat(c.first_name, ' ', c.last_name) as customer,
	rp.sale_date,
	concat(e.first_name, ' ', e.last_name) as seller
from ranked_purchases rp
inner join customers c on rp.customer_id = c.customer_id
inner join employees e on rp.sales_person_id = e.employee_id
where rp.rn = 1 and rp.price = 0
order by c.customer_id;