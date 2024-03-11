USE sakila;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.
SELECT DISTINCT *
	FROM film;

-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".
SELECT `title`
	FROM film
	WHERE `rating` = 'PG-13';

-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.
SELECT `title`, `description`
	FROM film
	WHERE `description` LIKE '%amazing%';

-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.
SELECT `title`
	FROM film
	WHERE `length` > 120;

-- 5. Recupera los nombres de todos los actores.

-- Entiendo que el enunciado no pide los apellidos ya que solo menciona "nombre". Si buscará los nombres completos, con apellidos incluidos, habría que añadirle al select la columna "last name" pudiendo incluso unificarlas con un CONCAT().
SELECT `first_name`
	FROM actor;

-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.
SELECT `first_name`, `last_name`
	FROM actor
	WHERE `last_name` LIKE '%gibson%';

-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.

-- Suponiendo que pide ambos ids incluidos:
SELECT `first_name`
	FROM actor
	WHERE `actor_id` BETWEEN 10 AND 20;

-- 8. Encuentra el título de las películas en la tabla `film` que no sean ni "R" ni "PG-13" en cuanto a su clasificación.

SELECT `title`
	FROM film
	WHERE `rating` NOT IN ('R', 'PG-13');


-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla `film` y muestra la clasificación junto con el recuento.

SELECT COUNT(title) AS cantidad_peliculas, `rating`
	FROM film
	GROUP BY `rating`;

-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.

SELECT customer.`customer_id`, customer.`first_name`, customer.`last_name`, COUNT(rental.`rental_id`) AS cantidad_alquileres
	FROM customer
	LEFT JOIN rental
		ON rental.`customer_id` = customer.`customer_id`
	GROUP BY customer.`customer_id`;

-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.

SELECT category.`name`, COUNT(rental.`inventory_id`) AS cantidad_alquileres
	FROM category
	INNER JOIN film_category
		ON film_category.`category_id` = category.`category_id`
	INNER JOIN inventory 
		ON film_category.`film_id` = inventory.`film_id`
	LEFT JOIN rental
		ON inventory.`inventory_id` = rental.`inventory_id`
	GROUP BY category.`name`;

-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla `film` y muestra la clasificación junto con el promedio de duración.

SELECT `rating`, AVG(`length`) AS promedio_duracion
	FROM film
	GROUP BY `rating`;

-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".

SELECT actor.`first_name`, actor.`last_name`
	FROM actor
	INNER JOIN film_actor
		ON film_actor.`actor_id` = actor.`actor_id`
	INNER JOIN film
		ON film.`film_id` = film_actor.`film_id`
		WHERE `title` = "Indian Love";

-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.
SELECT `title`
	FROM film
	WHERE `description` LIKE "%dog%" or `description` LIKE "%cat%";

-- 15. Hay algún actor o actriz que no apareca en ninguna película en la tabla `film_actor`.
SELECT actor.`actor_id`
	FROM actor
	LEFT JOIN film_actor
		ON actor.`actor_id` = film_actor.`actor_id`
	WHERE film_actor.`actor_id` IS NULL;
    
-- NO HAY NINGÚN ACTOR O ACTRIZ QUE NO APAREZCA EN FILM_ACTOR

-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.
SELECT `title`
	FROM film
	WHERE `release_year` BETWEEN 2005 AND 2010;

-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".

SELECT `title`
	FROM film
	INNER JOIN film_category
		ON film.`film_id` = film_category.`film_id`
	INNER JOIN category
		ON film_category.`category_id` = category.`category_id`
	WHERE category.`name` = "Family";


-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.
SELECT `first_name`, `last_name`
	FROM actor
	INNER JOIN film_actor
		ON actor.`actor_id` = film_actor.`actor_id`
	GROUP BY film_actor.`actor_id`
		HAVING COUNT(`film_id`) > 10;

-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla `film`.
SELECT `title`
	FROM film
	WHERE `rating` = "R" AND `length` > 120;

-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.

-- Hay una vista creada que facilita mucho la query (he comprobado que el resultado sea el mismo), de todas maneras mando las soluciones para hacerlo usando la vista y sin ella por si en un futuo la vista se elimina.

-- Utilizando la vista:
SELECT `category`, AVG(`length`) as promedio_duracion
FROM film_list
GROUP BY `category`
HAVING promedio_duracion > 120;

 -- Usando solo las tablas "oficiales":
SELECT category.`name`, AVG(film.`length`) AS promedio_duracion
	FROM category
	INNER JOIN film_category
		ON category.`category_id` = film_category.`category_id`
	INNER JOIN film 
		ON film_category.`film_id` = film.`film_id`
	GROUP BY category.`name`
		HAVING promedio_duracion > 120;



-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.
SELECT `first_name`, COUNT(`film_id`) AS cantidad_peliculas
	FROM actor
	INNER JOIN film_actor
		actor.`actor_id` = film_actor.`actor_id`
	GROUP BY film_actor.`actor_id`
		HAVING cantidad_peliculas >= 5;


-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.

SELECT `title`
	FROM film
	INNER JOIN inventory
		ON film.`film_id` = inventory.`film_id`
		WHERE  inventory.`inventory_id` IN (SELECT rental.`inventory_id`
											FROM rental
											WHERE DATEDIFF(DATE(`return_date`),DATE(`rental_date`)) > 5)
	GROUP BY film.`title`;

-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.
SELECT actor.`first_name`, actor.`last_name`
	FROM actor
	WHERE `actor_id` NOT IN (SELECT actor.`actor_id`
								FROM actor
								INNER JOIN film_actor
									ON actor.`actor_id` = film_actor.`actor_id`
								INNER JOIN film_category
									ON film_actor.`film_id` = film_category.`film_id`
								INNER JOIN category
									ON film_category.`category_id` = category.`category_id`
								WHERE `name` = "Horror");
                                


## BONUS

-- 24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla `film`.

SELECT `title`, `length`
	FROM film
	WHERE `length` > 180 AND `film_id` IN (SELECT `film_id` 
										FROM film_category
										INNER JOIN category
											ON film_category.`category_id` = category.`category_id`
										WHERE category.`name` = "Comedy");


-- 25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.

SELECT CONCAT(a.`first_name`, " ", a.`last_name`) AS actor1, CONCAT(b.`first_name`, " ", b.`last_name`) AS actor2, COUNT(f2.`actor_id`) AS peliculas_juntas
FROM actor AS a
	INNER JOIN film_actor AS f1 
		ON a.`actor_id` = f1.`actor_id`
	INNER JOIN film_actor AS f2 
		ON f1.`film_id` = f2.`film_id` 
	INNER JOIN actor AS b 
		ON f2.`actor_id` = b.`actor_id`
INNER JOIN (SELECT fi1.`actor_id` AS actor1_id, fi2.`actor_id` AS actor2_id
			FROM film_actor AS fi1
			JOIN film_actor AS fi2 
				ON fi1.`film_id` = fi2.`film_id` AND fi1.`actor_id` < fi2.`actor_id`
			GROUP BY fi1.`actor_id`, fi2.`actor_id`) AS pelis 
				ON (a.`actor_id` = pelis.`actor1_id` AND b.`actor_id` = pelis.`actor2_id`) OR (a.`actor_id` = pelis.`actor2_id` AND b.`actor_id` = pelis.`actor1_id`)
GROUP BY a.`actor_id`, a.`first_name`, a.`last_name`, b.`actor_id`, b.`first_name`, b.`last_name`;