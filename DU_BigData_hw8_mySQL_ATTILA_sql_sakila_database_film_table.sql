 USE sakila;
-- 1a. Display the first and last names of all actors from the table `actor`. 
SELECT 
    first_name, last_name
FROM
    actor;

-- 1b. Display the first and last name of each actor in a single column in 
--     upper case letters. Name the column `Actor Name`. 
SELECT 
    first_name,
    last_name,
    UPPER(CONCAT(first_name, ' ', last_name)) AS actor_name
FROM
    actor;

select upper(concat(first_name,' ' ,last_name)) as 'actor_name'
from actor;

-- 2a.  You need to find the ID number, first name, and last name of 
--      an actor, of whom you know only the first name, "Joe." What is 
--      one query would you use to obtain this information?
desc actor;
-- actor_id, first_name, last_name, last_update
select actor_id, first_name, last_name 
        from actor
                where (
                first_name = 'Joe'
                );
-- 9	JOE	SWANK
 
select actor_id, first_name, last_name
from actor
where first_name = "Joe";
-- actor_id, first_name, last_name
-- 9			JOE			SWANK

-- 2b.  Find all actors whose last name contain the letters `GEN`
select actor_id, first_name, last_name
from actor
where last_name like '%GEN%' ;
-- actor_id, first_name, last_name
-- 14	VIVIEN	BERGEN
-- 41	JODIE	DEGENERES
-- 107	GINA	DEGENERES
-- 166	NICK	DEGENERES


-- 2c. Find all actors whose last names contain the letters `LI`. 
--     This time, order the rows by last name and first name, in that order:
select last_name, first_name, actor_id 
        from actor
                where last_name like '%li%';
-- actor_id, first_name, last_name
-- 15	OLIVIER	CUBA
-- 34	OLIVIER	AUDREY
-- 72	WILLIAMS	SEAN
-- 82	JOLIE	WOODY
-- 83	WILLIS	BEN

-- 2d. Using `IN`, display the `country_id` and `country` columns of 
--     the following countries: Afghanistan, Bangladesh, and China

-- prep 
show columns from country;
describe country;
-- Field		Type
-- country_id	        smallint(5) unsigned
-- country		varchar(50)
-- last_update	        timestamp

select country_id, country 
        from country 
                where country in ('Afghanistan', 'Bangladesh', 'China');
-- country_id, country 
-- 1	Afghanistan
-- 12	Bangladesh
-- 23	China

-- 3a. Add a middle_name column to the table actor. 
-- Position it between first_name and last_name. 
alter table actor
	add middle_name varchar(50) 
                after first_name;
              
desc actor;
-- created a null column
--  Field	Type            null
--  actor_id	smallint(5) 
--  first_name	varchar(45)
--  middle_name	varchar(50)     YES
--  last_name	varchar(45)
--  last_update	timestamp

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.

alter table actor
        modify column middle_name BLOB;
select * from actor;
-- middle_name  null
-- 1	PENELOPE [null]       GUINESS	        2006-02-15 04:34:33
-- what is blob? BLOB is the family of column type intended as high-capacity binary storage

-- 3c. Now delete the middle_name column.
alter table actor
        drop column middle_name;
-- desc actor;
-- confirm middle_name dropped

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, 
                count(*) as 'count_lastname'
                from actor 
                        group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name,
--  but only for names that are shared by at least two actors
select last_name,
        count(*) as count_lastname
                from actor
                        group by last_name
                                 having count_lastname >1;
desc actor;
-- actor_df.groupby('last name').count()
-- did not add any column to dataframe aka table 

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
-- UPDATE `sakila`.`actor`
-- SET
-- `first_name` = <{first_name}>
-- WHERE <{where_expression}>;
update actor
        set first_name = 'HARPO'
			where first_name='GROUCHO' and last_name='WILLIAMS';

-- SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'HARPO';
-- actor_id, first_name		last_name
-- 172			HARPO		WILLIAMS

-- 
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update actor
        set first_name = 'GROUCHO'
                where ( 
                first_name='HARPO' and last_name='WILLIAMS'
                );

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- use sakila;
show columns from address;
describe address;
--  Field		Type
-- address_id	smallint(5) unsigned
-- address	varchar(50)
-- address2	varchar(50)address_id	smallint(5) unsigned

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member
-- Use the tables staff and address:
desc staff;
-- Field	Type
-- staff_id	tinyint(3)
-- first_name	varchar(45)
-- last_name	varchar(45)
-- address_id	smallint(5)

-- same addresss data/different length
select address_id from staff;
-- two rows returned
select address_id from address;
-- 603 rows returned

# from staff left join address on staff.address_id= address.address_id;

SELECT 
    first_name,
    last_name,    
    address.address_id,
    address
FROM
    staff
        LEFT JOIN
                address 
                ON staff.address_id = address.address_id;
-- first_name	        last_name            address_id			        address
-- Mike			Hillyer			3			23 Workhaven Lane
-- Jon			Stephens		4			1411 Lillydale Drive

-- 6b. Use JOIN to display the total amount rung up by each staff member 
-- in August of 2005. Use tables staff and payment.
-- 
SELECT 
    s.first_name, s.last_name, SUM(p.amount) AS 'TOTAL'
FROM
    staff s
        LEFT JOIN
                payment p 
                ON 
                        s.staff_id = p.staff_id
                AND 
                        payment_date LIKE '%2005-08%'
        GROUP BY s.first_name , s.last_name
;

-- Jon	Stephens	12218.48
-- Mike	Hillyer	        11853.65


-- 
select staff.first_name, staff.last_name, payment.payment_date, sum(amount)
        from staff
                inner join payment on (
                                 staff.staff_id = payment.staff_id
                                        and 
                                        payment_date like '%2005-08%'
                                        );
-- staff.first_name,            staff.last_name,        sum_payment
-- Jon	Stephens	2005-08-01 08:51:04	24072.13                                
-- 
-- 
SELECT 
    first_name,
    last_name,
    SUM(amount) AS 'sum_payment'
FROM
    staff
        left outer JOIN
                payment 
                        ON staff.staff_id = payment.staff_id
                        AND payment_date LIKE '2005-08%';
-- staff.first_name,            staff.last_name,        sum_payment
-- Mike	                        Hillyer	                24072.13
-- 
SELECT 
    first_name,
    last_name,
    SUM(amount) AS 'sum_payment'
FROM
    staff
        right outer JOIN
                payment 
                        ON staff.staff_id = payment.staff_id
                        AND payment_date LIKE '2005-08%'
                        ;

-- 'Mike', 'Hillyer', '67416.51'
--
-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.
desc film_actor;
/*actor_id
film_id
last_update*/

select  title, 
        count(actor_id) as 'count_act' 
from film 
        inner join film_actor
                on 
                  film.film_id = film_actor.film_id
                        group by title
                                order by count_act desc;
/* title        count_act
LAMBS CINCINATTI	15
CHITTY LOCK	13
DRACULA CRYSTAL	13
MUMMY CREATURES	13*/

desc film;
/*film_id
title
description
release_year
language_id
original_language_id
rental_duration
rental_rate
length
replacement_cost
rating
special_features
last_update

*/
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
 SELECT 
    title,
    (SELECT 
            COUNT(*)
        FROM
            inventory
        WHERE
            film.film_id = inventory.film_id) AS 'count_inventory'
FROM
    film
WHERE
    title = 'Hunchback Impossible ';
/*-- 
        title                count_inventory
-- HUNCHBACK IMPOSSIBLE	        6
*/

SELECT 
    title,
    (SELECT 
            COUNT(*)
        FROM
            inventory
        WHERE
            film.film_id = inventory.film_id) AS 'kamil'
FROM
    film
    where title = 'Hunchback Impossible'
;


select title, (select count(*) 
                from inventory
                where film_id 
                             in(
                                select film_id
                                from film
                                where title = 'Hunchback Impossible'
                                ) ) as 'inv_count'
from film, inventory
where title = 'Hunchback Impossible'
-- where film.film_id = inventory.film_id
-- this brings all titles with 6 as inv_count
;
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total
--     paid by each customer. List the customers alphabetically by last name:
SELECT 
    c.last_name, 
    c.first_name, 
    SUM(p.amount) AS 'totalpay_cus'
FROM
    customer c
        INNER JOIN
                payment p ON c.customer_id = p.customer_id
GROUP BY c.last_name
ORDER BY c.last_name;
;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also 
-- soared in popularity. Use subqueries to display the titles of movies starting 
-- with the letters K and Q whose language is English.

select title 
from film
where title like 'K%' 
or title like 'G%'
and title in (select title from film where language_id =1)
; 
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name,
        last_name,
        actor_id        
from actor
where actor_id in(
        select actor_id
        from film_actor
        where film_id in (
select film_id
from film 
where
title = 'Alone Trip'));

--  7c. You want to run an email marketing campaign in Canada, for which you will need
--  the names and email addresses of all Canadian customers. Use joins to retrieve this information.


SELECT 
    customer.first_name, customer.last_name, lower(customer.email), city, country
  
FROM
    customer
        JOIN
    sakila.address ON customer.address_id = address.address_id
        JOIN
    sakila.city ON city.city_id = address.city_id        
    join
    sakila.country ON country.country_id = city.country_id
    where
    country.country= 'Canada'
;
-- preview below
/*
DERRICK	BOURQUE	derrick.bourque@sakilacustomer.org	Gatineau	Canada
DARRELL	POWER	darrell.power@sakilacustomer.org	Halifax	Canada
LORETTA	CARPENTER	loretta.carpenter@sakilacustomer.org	Oshawa	Canada
CURTIS	IRBY	curtis.irby@sakilacustomer.org	Richmond Hill	Canada
TROY	QUIGLEY	troy.quigley@sakilacustomer.org	Vancouver	Canada
*/        

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title
from film 
where film_id in 
(
select film_id 
from film_category
where category_id in
(
select category_id
from category
where name = 'Family'
)
)
;
-- preview titles of family movies
/*
AFRICAN EGG
APACHE DIVINE
ATLANTIS CAUSE
.............
SUPER WYOMING
VIRTUAL SPOILERS
WILLOW TRACY
*/
-- 
# 7e. Display the most frequently rented movies in descending order.

select title, count(rental_id) as 'rent_count'
from rental
        join inventory on rental.inventory_id = inventory.inventory_id
        join film on inventory.film_id = film.film_id
group by title
order by count(rental_id) desc
;
-- preview for most rented film titles
/*
BUCKET BROTHERHOOD	34
ROCKETEER MOTHER	33
GRIT CLOCKWORK	32
SCALAWAG DUCK	32
*/
# 7f. Write a query to display how much business, in dollars, each store brought in.

select store.store_id, sum(amount)
from payment
        join staff on staff.staff_id = payment.staff_id
        join store on store.store_id = staff.store_id
group by store_id
;
-- 
#7g. Write a query to display for each store its store ID, city, and country.
select  store.store_id 
        , city.city
        , country.country
from store
    join address on store.address_id = address.address_id
    join city on address.city_id = city.city_id 
    join country on country.country_id = city.country_id
;
-- preview for store-city-country result grid
/*
store.store_id /city.city /    country.country
1	Lethbridge	Canada
2	Woodridge	Australia
*/    
#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name
        ,sum(p.amount)
from category c
    join film_category fc
        on fc.category_id = c.category_id
    join  inventory i
        on i.film_id = fc.film_id
    join  rental r
        on r.inventory_id = i.inventory_id
    join payment p 
        on p.rental_id = r.rental_id
group by name
order by sum(p.amount) desc        
;
-- preview for group by name vs sum(payment.amount)
/*
Music	3417.72
Travel	3549.64
Classics	3639.59
Children	3655.55
Horror	3722.54
*/

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view rev_genre as 
select name,sum(p.amount) as 'revenue'
from category c
    join film_category fc on fc.category_id = c.category_id
    join  inventory i on i.film_id = fc.film_id
    join  rental r on r.inventory_id = i.inventory_id
    join payment p on p.rental_id = r.rental_id
group by name 
    order by sum(p.amount)
        limit 5
;
-- how to select above created view
select * from rev_genre;
#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view rev_genre;
-- run above 8b again to store created view or error message
select * from rev_genre;