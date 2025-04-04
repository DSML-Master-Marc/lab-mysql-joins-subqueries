-- Add you solution queries below:
USE sakila;

/*1- How many copies of the film Hunchback Impossible exist in the inventory system?*/
SELECT COUNT(inventory.inventory_id)
FROM inventory
JOIN film ON inventory.film_id = film.film_id
WHERE title = "Hunchback Impossible";
 
/*2- List all films whose length is longer than the average of all the films.*/
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);
 
/*3- Use subqueries to display all actors who appear in the film Alone Trip.*/
/*SELECT actor.first_name, actor.last_name
FROM film_actor
JOIN actor ON film_actor.actor_id = actor.actor_id
JOIN film ON film_actor.film_id = film.film_id
WHERE film.title = "Alone Trip";*/
SELECT first_name, last_name 
FROM actor 
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id = (SELECT film_id FROM film WHERE title = 'Alone Trip')); 
 
/*4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.*/
SELECT film.title
FROM film
JOIN film_category ON film_category.film_id = film.film_id
JOIN category ON category.category_id = film_category.category_id
WHERE category.name = "Family";
 
/*5- Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their 
primary keys and foreign keys, that will help you get the relevant information.*/
/*With subqueries*/
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
WHERE customer.address_id IN
	(SELECT address.address_id  FROM address WHERE address.city_id IN 
		(SELECT city.city_id FROM city WHERE city.country_id =
			(SELECT country_id FROM country WHERE country.country = "Canada")));

/*With joins*/
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = "Canada";
 
/*6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the
 most prolific actor and then use that actor_id to find the different films that he/she starred.*/
SELECT *
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE film_actor.actor_id = (SELECT actor_id 
FROM film_actor 
GROUP BY actor_id 
ORDER BY COUNT(film_id) DESC 
LIMIT 1);
 
 
 
/*7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments*/
SELECT film.title
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
JOIN customer ON rental.customer_id = customer.customer_id
JOIN payment ON rental.rental_id = payment.rental_id
JOIN (
    SELECT payment.customer_id
    FROM payment
    GROUP BY payment.customer_id
    ORDER BY SUM(payment.amount) DESC
    LIMIT 1
) AS top_customer ON customer.customer_id = top_customer.customer_id;

/*8- Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.*/
SELECT customer.customer_id, SUM(payment.amount) AS total_amount_spent
FROM customer
JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
HAVING SUM(payment.amount) > (  
    SELECT AVG(customer_total)  
    FROM (  
        SELECT customer_id, SUM(amount) AS customer_total  
        FROM payment  
        GROUP BY customer_id  
    ) AS avg_table  
);
 
