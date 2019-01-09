-- 1a. Display the first and last names of all actors from the table actor.
USE sakila;

SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.

SELECT CONCAT (first_name, " ", last_name) AS "Actor Name"
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to 
-- obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country 
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries 
-- on a description, so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
UPDATE actor
SET first_name = "Harpo"
WHERE last_name = "Williams" 
AND first_name = "Groucho";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was 
-- the correct name after all! In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO.
UPDATE actor
SET first_name = "Groucho"
WHERE last_name = "Williams"
AND first_name = "Harpo";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff A
INNER JOIN address B
ON A.address_id = b.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.

SELECT A.first_name, A.last_name, SUM(B.amount) AS "August 2005 Sales"
FROM staff A
INNER JOIN payment B
ON A.staff_id = B.staff_id
WHERE B.payment_date LIKE "2005-08%"
GROUP BY A.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor 
-- and film. Use inner join.
SELECT A.title, COUNT(B.actor_id) AS "Number of Actors"
FROM film A
INNER JOIN film_actor B
ON A.film_id = B.film_id
GROUP BY B.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id)
FROM inventory
WHERE film_id IN
(
	SELECT film_id
    FROM film
    WHERE title = "Hunchback Impossible"
);

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT A.first_name, A.last_name, SUM(B.amount) AS "Total Paid by Customer"
FROM customer A
INNER JOIN payment B
ON A.customer_id = B.customer_id
GROUP BY B.customer_id
ORDER BY A.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended 
-- consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries
-- to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE language_id IN
(
	SELECT language_id
	FROM language
	WHERE name = "English")
AND title LIKE "K%" OR title LIKE "Q%";

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN
    (
		SELECT film_id
        FROM film
        WHERE title = "Alone Trip"
	)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
-- and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT A.first_name, A.last_name, A.email, D.country
FROM customer A
INNER JOIN address B
ON A.address_id = B.address_id
INNER JOIN city C
ON B.city_id = C.city_id
INNER JOIN country D
ON C.country_id = D.country_id
WHERE D.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for 
-- a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN
(
	SELECT film_id
    FROM film_category
    WHERE category_id IN
    (
    SELECT category_id
    FROM category
    WHERE name = "Family"
    )
);

-- 7e. Display the most frequently rented movies in descending order.
SELECT A.title, COUNT(C.inventory_id) AS "Number of Times Rented"
FROM film A
INNER JOIN inventory B
ON A.film_id = B.film_id
INNER JOIN rental C
ON B.inventory_id = C.inventory_id
GROUP BY A.title
ORDER BY COUNT(C.inventory_id) DESC;

    
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT A.store_id, SUM(B.amount)
FROM customer A
INNER JOIN payment B
ON A.customer_id = B.customer_id
GROUP BY A.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT A.store_id, C.city, D.country
FROM store A
INNER JOIN address B
ON A.address_id = B.address_id
INNER JOIN city c
ON B.city_id = C.city_id
INNER JOIN country D
ON C.country_id = D.country_id;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use 
-- the following tables: category, film_category, inventory, payment, and rental.)
SELECT A.name, SUM(E.amount) AS "Gross Revenue"
FROM category A
JOIN film_category B
ON A.category_id = B.category_id
JOIN inventory C
ON B.film_id = C.film_id
JOIN rental D
ON C.inventory_id = D.inventory_id
JOIN payment E
ON D.rental_id = E.rental_id
GROUP BY A.name
ORDER BY SUM(E.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top 
-- five genres by gross revenue. Use the solution from the problem above to create a view. If you 
-- haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_genres_by_rev AS
SELECT A.name, SUM(E.amount) AS "Gross Revenue"
FROM category A
JOIN film_category B
ON A.category_id = B.category_id
JOIN inventory C
ON B.film_id = C.film_id
JOIN rental D
ON C.inventory_id = D.inventory_id
JOIN payment E
ON D.rental_id = E.rental_id
GROUP BY A.name
ORDER BY SUM(E.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_genres_by_rev;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_genres_by_rev;