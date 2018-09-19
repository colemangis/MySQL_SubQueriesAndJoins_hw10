use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select UPPER(ConCAT(first_name, ' ', last_name)) as `Actor Name`
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select first_name, last_name, actor_id
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:

select first_name, last_name, actor_id
from actor
where last_name like '%GEN%';


-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

select first_name, last_name, actor_id
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- data qc
select * from actor where last_name = "WILLIAMS";


-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id, country
from country
where country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries
-- on a description, so create a column in the table `actor` named `description` and use the data type
-- `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are 
-- significant).

alter table actor
add column description blob;

-- view table, select all.
select*
from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the `description` column.

alter table actor
drop column description;

-- view table, select all to verify delete.
select*
from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(last_name) as 'last_name_frequency'
from actor
group by last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but 
-- only for names that are shared by at least two actors

select last_name, count(last_name) as 'last_name_frequency'
from actor
group by last_name
having `last_name_frequency` >= 2;


-- 4c. 4c. The actor `HARPO WILLIAMS` was accidentally
-- entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

-- see if there is an existing "Harpo'
select first_name, last_name, actor_id
from actor
where first_name = 'HARPO'
order by last_name, first_name;

-- find "groucho'
select first_name, last_name, actor_id
from actor
where first_name = 'GROUCHO'
order by last_name, first_name;

-- set Harpo
update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO'
and last_name = 'WILLIAMS';

-- verify existing "Harpo'
select first_name, last_name, actor_id
from actor
where first_name = 'HARPO'
order by last_name, first_name;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out 
-- that `GROUCHO` was the correct name after all! In a single query, if the first name 
-- of the actor is currently `HARPO`, change it to `GROUCHO`.

update actor
set first_name =
case
	when first_name = 'HARPO' then 'GROUCHO'
end;
  
select first_name, last_name, actor_id
from actor
where first_name = 'GROUCHO'
order by last_name, first_name;


-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- https://stackoverflow.com/questions/1498777/how-do-i-show-the-schema-of-a-table-in-a-mysql-database

show create table address;


-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each 
-- staff member. Use the tables `staff` and `address`:

select s.first_name, s.last_name, a.address
from staff as s
inner join address as a
on s.address_id = a.address_id;


-- 6b. Use `JOIN` to display the total amount rung up by each
-- staff member in August of 2005. Use tables `staff` and `payment`.
  
select s.first_name, s.last_name, sum(p.amount)
from staff as s
inner join payment as p
on p.staff_id = s.staff_id
where month(p.payment_date) = 08 and year(p.payment_date) = 2005
group by s.staff_id;



-- 6c. List each film and the number of actors who are listed for
-- that film. Use tables `film_actor` and `film`. Use inner join.

select film.title, count(f.actor_id) as 'ActorCount'
from film_actor as f
inner join film
on film.film_id = f.film_id
group by film.title;


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select title, count(inventory_id) as 'Total'
from film as f
inner join inventory as i
on f.film_id = i.film_id
where title = 'Hunchback Impossible'
group by title;


-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid
-- by each customer. List the customers alphabetically by last name:

select c.last_name, c.first_name, sum(p.amount) as 'TotalPaid'
from payment as p
inner join customer as c
on p.customer_id = c.customer_id
group by c.customer_id
order by c.last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an 
-- unintended consequence, films starting with the letters `K` and `Q` have also soared 
-- in popularity. Use subqueries to display the titles of movies starting with the
-- letters `K` and `Q` whose language is English.

select title, language_id
from film
where title like 'K%'
or title like 'Q%'
and language_id in
  (select language_id
   from language
   where name = 'English'
  );

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

select first_name, last_name
from actor
where actor_id in
	(select actor_id
    from film_actor
    where film_id =
		(select film_id
		from film
		where title = 'Alone Trip'
		)
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need 
-- the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name, last_name, email, country
from customer as c
inner join address as a
on c.address_id = a.address_id
	inner join city
	on a.city_id = city.city_id
		inner join country as co
		on city.country_id = co.country_id
		where co.country = 'canada';
        


-- 7d. Sales have been lagging among young families, and you wish to target all family 
-- movies for a promotion. Identify all movies categorized as family films.

select title, c.name
from film as f
inner join film_category as fc
on f.film_id = fc.film_id
	inner join category as c
	on c.category_id = fc.category_id
	where name = 'family';


-- 7e. Display the most frequently rented movies in descending order.

select title, count(title) as 'RentedCount'
from film
inner join inventory
on film.film_id = inventory.film_id
	inner join rental
	on inventory.inventory_id = rental.inventory_id
	group by title
	order by rentedcount desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

select s.store_id, sum(amount) as 'TotalAmount'
from payment as p
inner join rental as r
on p.rental_id = r.rental_id
	inner join inventory as i
	on i.inventory_id = r.inventory_id
		inner join store as s
		on s.store_id = i.store_id
		group by s.store_id;



-- 7g. Write a query to display each store ID, city, and country.

select store_id, city, country
from store as s
inner join address as a
on s.address_id = a.address_id
	inner join city
	on city.city_id = a.city_id
		inner join country co
		on city.country_id = co.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, 
-- payment, and rental.)

select sum(amount) as 'TotalSales', c.name as 'Genre'
from payment as p
inner join rental as r
on p.rental_id = r.rental_id
  inner join inventory as i
  on r.inventory_id = i.inventory_id
	inner join film_category as fc
	on i.film_id = fc.film_id
		inner join category as c
		on fc.category_id = c.category_id
		group by c.name
		order by sum(amount) desc limit 5;
        


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the
-- Top five genres by gross revenue. Use the solution from the problem above to create a 
-- view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_genres as
select sum(amount) as 'TotalSales', c.name as 'Genre'
from payment as p
inner join rental as r
on p.rental_id = r.rental_id
  inner join inventory as i
  on r.inventory_id = i.inventory_id
	inner join film_category as fc
	on i.film_id = fc.film_id
		inner join category as c
		on fc.category_id = c.category_id
		group by c.name
		order by sum(amount) desc limit 5;


-- 8b. Display view of 8a.

select * from top_five_genres;

-- 8c. drop view of 8a.

drop view top_five_genres;