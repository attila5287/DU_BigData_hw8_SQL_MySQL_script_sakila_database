--  1a. Display the first and last names of all actors from the table `actor`.
select first_name,last_name
from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`
select first_name, last_name, upper(concat(first_name,' ',last_name)) as 'actor_name'
from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select  actor_id, first_name, last_name
from actor
where first_name = 'Joe';
-- 2b. Find all actors whose last name contain the letters `GEN`:
select  actor_id, first_name, last_name
from actor
where last_name like '%GEN%';
-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select  actor_id, last_name, first_name 
from actor
where last_name like '%LI%'
order by last_name, first_name;
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country, country_id
from country
where country in ('Afghanistan', 'Bangladesh', 'China');
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor
add description blob;
show columns from actor;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column
alter table actor
drop column description;
show columns from actor;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as lastnme_count
from actor
group by last_name;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

-- mysql documentation note: Notice that the HAVING clause applies a filter condition to each group of rows, 
-- while the WHERE clause applies the filter condition to each individual row.
--
select last_name, count(last_name) as lastnme_count
from actor
group by last_name
having lastnme_count >1;
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor 
set first_name = 'HARPO'
where (first_name = 'GROUCHO' and last_name = 'WILLIAMS');
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
    SET first_name = 'GROUCHO'
    WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';
-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show create table actor;
CREATE TABLE `actor2` (

  `actor_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(45) NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`actor_id`),
  KEY `idx_actor_last_name` (`last_name`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8;
drop table actor2;
-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select first_name, last_name, address
from staff 
    join address on staff.address_id = address.address_id;
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select first_name, last_name, sum(amount)
from staff
    join payment on staff.staff_id = payment.staff_id
group by staff.staff_id;
-- Mike	Hillyer	33489.47
-- Jon	Stephens	33927.04
--
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select title, count(film_actor.actor_id) as 'actor_count'
from film
    inner join film_actor on film_actor.film_id = film.film_id
group by title
order by actor_count desc;
-- LAMBS CINCINATTI	15
-- MUMMY CREATURES	13
--
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, count(inventory.film_id) as copy_count
from film
    inner join inventory on film.film_id = inventory.film_id
where title ='Hunchback Impossible';
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select last_name, first_name, sum(amount) as total_pay
from customer c
    join payment p on p.customer_id = c.customer_id
group by c.customer_id
order by last_name;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
--
select title
from film
where   ((title like 'K%') or (title like 'Q%'))
and language_id in (
select language_id
from language
where name = 'English'
)
;
--
-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
-- subq and two variations of join below 
-- actor a film f film_actor fa
--
-- 1 subq's nested, final output from actor, no title
select first_name, last_name
from actor
where actor_id 
in (
select actor_id 
from film_actor
where film_id
in(
select film_id
from film
where title = 'Alone Trip'
));
--
-- 2- a>fa>f
select  first_name, last_name, title
from    actor a        
    join film_actor fa on fa.actor_id = a.actor_id
    join film f on f.film_id = fa.film_id
where title = 'Alone Trip';                    
--
-- 3 f>fa>a
select title, first_name, last_name
from film f
    join film_actor fa on f.film_id = fa.film_id
    join actor a on fa.actor_id = a.actor_id
where title = 'Alone Trip';
--
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- join customer and address with address_id as foreign key to pull
-- address from table 'address'
--
select 
CONCAT(UPPER(SUBSTRING(first_name,1,1)),LOWER(SUBSTRING(first_name,2,29))) AS 'First Name', 
CONCAT(UPPER(SUBSTRING(last_name,1,1)),LOWER(SUBSTRING(last_name,2,29))) AS 'Last Name', 
lower(email) as 'Email Address', 
country as 'Country'
from customer
--
join address
    on address.address_id = customer.address_id
join city
    on city.city_id = address.city_id
join country
    on country.country_id = city.country_id
--
where country = 'Canada';
--
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.        
--
select 
CONCAT(UPPER(SUBSTRING(title
,1,1)),LOWER(SUBSTRING(title
,2,29))) 
AS 
'Film Title', 
c.name as '_family_ films'
--
from film f
--
join film_category fc 
    on fc.film_id = f.film_id
join category c
    on c.category_id = fc.category_id
--
where name = 'Family';
--
-- 7e. Display the most frequently rented movies in descending order.
-- rental_id is auto increment with every film rental
-- thus counting rental_id equals how many times rented
select
    title,
    count(rental_id) as 'Rental Count'
--
from film f
join inventory i
    on i.film_id = f.film_id
join rental r 
    on r.inventory_id = i.inventory_id 
--
group by title
order by count(rental_id) desc
;
--
-- 7f. Write a query to display how much business, in dollars, each store brought in.
--
select  store.store_id as 'Store No',
        sum(amount) as 'Revenue'
from store
--
join staff 
    on staff.store_id= store.store_id
join payment p
    on p.staff_id = staff.staff_id
--
group by store.store_id
;
--
-- 7g. Write a query to display for each store its store ID, city, and country.
--
select  store_id as 'Store No',
        city as 'City',
        country as 'Country'
from    store s
--
join    address a
    on  s.address_id = a.address_id
join    city c
    on  c.city_id = a.city_id
join    country cy
    on  cy.country_id = c.country_id
;
--
-- 7h. List the top five genres (category) in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
--
select  c.name,
        sum(amount) as '_GrossRev'
from    category c
join    film_category fc
                    on fc.category_id = c.category_id
join    inventory i on i.film_id = fc.film_id
join    rental r    on r.inventory_id = i.inventory_id
join    payment p   on p.rental_id = r.rental_id
--
group by name
order by sum(amount) desc
--
limit 5
;
-- 
/* Sports	5314.21
Sci-Fi	4756.98
Animation	4656.30
Drama	4587.39
Comedy	4383.58 
*/
--
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
--
create view 
    GenreGrossRevenue
                    as 
select  c.name,
        sum(amount) as '_GrossRev'
from    category c
join    film_category fc
                    on fc.category_id = c.category_id
join    inventory i on i.film_id = fc.film_id
join    rental r    on r.inventory_id = i.inventory_id
join    payment p   on p.rental_id = r.rental_id
--
group by name
order by sum(amount) desc
--
limit 5
;
--
--  8b. How would you display the view that you created in 8a?
--
select  * from      GenreGrossRevenue;
select  * from      sakila.GenreGrossRevenue;
desc                sakila.GenreGrossRevenue;
show columns from   sakila.GenreGrossRevenue;
--
--  8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
--
drop view sakila.GenreGrossRevenue;
-- confirm drop of above created view
desc sakila.GenreGrossRevenue;
-- Error Code: 1146. Table 'sakila.genregrossrevenue' doesn't exist
-- thus confirmed

