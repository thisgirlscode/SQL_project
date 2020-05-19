/*PART 1*/
/*Question 1
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.
NOTE: I am filtering by the family categories only*/
select f.title as title,c.name as category_name, count(r.rental_id) as count_rentals
from film f
join Film_Category fc
on f.film_id =fc.film_id
join inventory i
on f.film_id = i.film_id
join category c
on fc.category_id = c.category_id
join rental r
on i.inventory_id = r.inventory_id
where c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
group by f.title,c.name
order by c.name,f.title



/*Question 2
Provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) 
based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories?*/
select f.title as title,
c.name as name,
f.rental_duration as rental_duration,
NTILE(4) OVER (order by f.rental_duration) as standard_quartile
from film f
join Film_Category fc
on f.film_id =fc.film_id
join category c
on fc.category_id = c.category_id
where c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
order by standard_quartile


/*Question 3
Provide a table with the family-friendly film category, each of the quartiles,
and the corresponding count of movies within each combination of film category for each corresponding rental duration category*/
select category, standard_quartile, count(film_id)
from
(select c.name as category,
NTILE(4) OVER (order by f.rental_duration) as standard_quartile,f.film_id
from film f
join Film_Category fc
on f.film_id =fc.film_id
join category c
on fc.category_id = c.category_id
where c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
order by category,standard_quartile
) category_quartiles
group by category,standard_quartile


/*PART 2:*/
/*Question 1
store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.*/

select date_part('month', r.rental_date) rental_month, date_part('year',r.rental_date) rental_year,
sa.store_id Store_ID,
count(r.rental_id) rental_count
from rental r
join staff sa
on r.staff_id = sa.staff_id
group by rental_year, rental_month, Store_ID
order by rental_count desc

/*Question 2
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers?*/

select payment_month, name, count(payment_month), sum(amount)
from
(
    SELECT date_trunc('month',p.payment_date) payment_month,
    CONCAT(c.first_name,' ', c.last_name) as name,
    p.amount amount
    FROM customer c
    JOIN payment p
    ON c.customer_id = p.customer_id
    WHERE date_part('year',p.payment_date)='2007'
    and c.customer_id in (select customer_id
    from
        (select customer_id, sum(amount) total from
        payment
        where date_part ('year',payment_date)='2007'
        group by customer_id
        order by total desc
        limit 10) top10
    )
  ) payments_2007
group by payments_2007.payment_month,payments_2007.name
order by payments_2007.name

/*Question 3
Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly payments during 2007. Please go ahead and write a query to compare the payment amounts in each successive month. Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments.*/

select payment_month, name, total_amount,
LEAD (total_amount) OVER (order by payment_month) as lead,
LEAD (total_amount) OVER (order by payment_month) - total_amount as difference
from
(select payment_month, name, count(payment_month) monthly_count, sum(amount) total_amount
from
(
    SELECT date_trunc('month',p.payment_date) payment_month,
    CONCAT(c.first_name,' ', c.last_name) as name,
    p.amount amount
    FROM customer c
    JOIN payment p
    ON c.customer_id = p.customer_id
    WHERE date_part('year',p.payment_date)='2007'
    and c.customer_id in (select customer_id
    from
        (select customer_id, sum(amount) total from
        payment
        where date_part ('year',payment_date)='2007'
        group by customer_id
        order by total desc
        limit 10) top10
    )
  ) payments_2007
group by payments_2007.payment_month,payments_2007.name
order by payments_2007.name
) top10_2007
order by difference
