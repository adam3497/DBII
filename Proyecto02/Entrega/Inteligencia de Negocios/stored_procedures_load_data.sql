-- Prodecimiento almacenado que alimenta con datos la dimensión Date_dim

DROP PROCEDURE IF EXISTS cargar_datos_datedim();
TRUNCATE date_dim;

CREATE OR REPLACE PROCEDURE cargar_datos_datedim()
LANGUAGE PLPGSQL
AS $cargar_datos_datedim$
DECLARE
	-- record que va ir almacenado cada fila del cursor
	rec_date record;
	-- cursor que contiene todos los datos necesarios para alimentar la dimensión date_dim
	cur_dates CURSOR
					FOR SELECT rental_date::date AS date_key
						FROM rental
						GROUP BY date_key
						ORDER BY date_key;
BEGIN
	-- Abrimos el cursor
	OPEN cur_dates;
	
	LOOP
		-- Extraemos la fila en rec_date
		FETCH cur_dates INTO rec_date;
		-- Salimos cuando no se encuentre más filas
		EXIT WHEN NOT FOUND;
		-- Insertamos cada fila dentro de la dimensión date_dim
		INSERT INTO date_dim(date_key)
		VALUES(rec_date.date_key);
	END LOOP;
	-- Cerramos el cursor
	CLOSE cur_dates;
	-- Commit cambios
	COMMIT;
	
END; $cargar_datos_datedim$

-- CALL public.cargar_datos_datedim();
-- select * from date_dim;

-- Prodecimiento almacenado que alimenta con datos la dimensión Film_dim

DROP PROCEDURE IF EXISTS cargar_datos_filmdim();
TRUNCATE TABLE film_dim CASCADE;

CREATE OR REPLACE PROCEDURE cargar_datos_filmdim()
LANGUAGE PLPGSQL
AS $cargar_datos_filmdim$
DECLARE
	-- record que va ir almacenado cada fila del cursor
	rec_film record;
	-- cursor que contiene todos los datos necesarios para alimentar la dimensión film_dim
	cur_films CURSOR
					FOR SELECT f.film_id, f.title, c.name AS category, string_agg(CONCAT (a.first_name, ' ', a.last_name), ', ') AS actors   
						FROM actor a
						RIGHT JOIN film_actor fa 
						ON fa.actor_id = a.actor_id
						RIGHT JOIN film f
						ON f.film_id = fa.film_id
						RIGHT JOIN film_category fc
						ON fc.film_id = f.film_id
						RIGHT JOIN category c
						ON c.category_id = fc.category_id
						GROUP BY f.film_id, c.name
						Order by f.title;
BEGIN
	-- Abrimos el cursor
	OPEN cur_films;
	
	LOOP
		-- Extraemos la fila en rec_film
		FETCH cur_films INTO rec_film;
		-- Salimos cuando no se encuentre más filas
		EXIT WHEN NOT FOUND;
		-- Insertamos cada fila dentro de la dimensión film_dim
		INSERT INTO film_dim(film_id, title, category, actors)
		VALUES(rec_film.film_id, rec_film.title, rec_film.category, rec_film.actors);
	END LOOP;
	-- Cerramos el cursor
	CLOSE cur_films;
	-- Commit cambios
	COMMIT;
	
END; $cargar_datos_filmdim$

-- CALL public.cargar_datos_filmdim();
-- select * from film_dim

-- Prodecimiento almacenado que alimenta con datos dimensión Address_dim

DROP PROCEDURE IF EXISTS cargar_datos_addressdim();
TRUNCATE address_dim;

CREATE OR REPLACE PROCEDURE cargar_datos_addressdim()
LANGUAGE PLPGSQL
AS $cargar_datos_addressdim$
DECLARE
	-- record que va ir almacenado cada fila del cursor
	rec_address record;
	-- cursor que contiene todos los datos necesarios para alimentar la dimensión address_dim
	cur_addresses CURSOR
					FOR SELECT a.address_id, c.city, k.country 
						FROM address a
						INNER JOIN city c
						ON a.city_id = c.city_id
						INNER JOIN country k
						ON c.country_id = k.country_id;
BEGIN
	-- Abrimos el cursor
	OPEN cur_addresses;
	
	LOOP
		-- Extraemos la fila en rec_address
		FETCH cur_addresses INTO rec_address;
		-- Salimos cuando no se encuentre más filas
		EXIT WHEN NOT FOUND;
		-- Insertamos cada fila dentro de la dimensión address_dim
		INSERT INTO address_dim(address_id, city, country)
		VALUES(rec_address.address_id, rec_address.city, rec_address.country);
	END LOOP;
	-- Cerramos el cursor
	CLOSE cur_addresses;
	-- Commit cambios
	COMMIT;
	
END; $cargar_datos_addressdim$

-- CALL public.cargar_datos_addressdim();
-- select * from address_dim;

-- Procedimiento almacenado para alimentar la Dimensión Store_dim
DROP PROCEDURE IF EXISTS load_store_dim_date();
TRUNCATE store_dim;

CREATE OR REPLACE PROCEDURE load_store_dim_data() 
LANGUAGE PLPGSQL
AS 
$store_dim_data$
DECLARE
	--record para almacenar los datos extraidos
	rec_store RECORD;
	--cursor que extrae los datos de la tabla store
	cur_store CURSOR
		FOR SELECT store_id::NUMERIC AS store_id
		FROM store 
		GROUP BY store_id
		ORDER BY store_id;
BEGIN 
	--abrimos el cursor
	OPEN cur_store;
	LOOP 
		--guardar los registros en el record
		FETCH cur_store INTO rec_store;	
		--salimos cuando no encuentre más datos
		EXIT WHEN NOT FOUND;
		--insertamos los datos dentro de la tabla de la dimensión
		INSERT INTO store_dim(store_id)
		VALUES(rec_store.store_id);
	END LOOP;
	--cerramos el cursor
	CLOSE cur_store;
	--guardamos los cambios
	COMMIT;
END; 
$store_dim_data$

-- CALL public.load_store_dim_data();
-- SELECT * FROM store_dim;

-- Procedimiento almacenado que alimenta la tabla de hechos
DROP PROCEDURE IF EXISTS cargar_datos_tabla_hechos();
TRUNCATE TABLE rental_facts;

CREATE OR REPLACE PROCEDURE cargar_datos_tabla_hechos()
LANGUAGE PLPGSQL
AS $cargar_datos_tablahechos$
DECLARE
	-- Declaración de variables locales
	v_film_id NUMERIC(10);
	v_store_id NUMERIC(10);
	v_address_id NUMERIC(10);
	v_amount NUMERIC(5,2);
	rec_inventory RECORD;
	rec_rent RECORD;
	-- Cursor que colsulta todos los alquileres
	cur_rents CURSOR
				FOR SELECT rental_id, rental_date, inventory_id, customer_id
					FROM rental;
BEGIN
	-- Abrimos el cursor de rental
	OPEN cur_rents;
	
	-- Extraemos los registros obtenidos
	LOOP
		FETCH cur_rents into rec_rent;
		EXIT WHEN NOT FOUND;
		
		-- Obtenemos el film_id y store_id por medio del inventory_id
		SELECT film_id, store_id
		FROM inventory
		INTO rec_inventory
		WHERE inventory_id = rec_rent.inventory_id;
		
		-- Guardamos los ids en las variables correspondientes
		v_film_id := rec_inventory.film_id;
		v_store_id := rec_inventory.store_id;
		
		-- Obtenemos el address_id por medio del customer_id
		SELECT address_id
		FROM customer
		INTO v_address_id
		WHERE customer_id = rec_rent.customer_id;
		
		-- Obtenemos el payment amount por medio del rental_id
		SELECT amount
		FROM payment
		INTO v_amount
		WHERE rental_id = rec_rent.rental_id;
		
		-- Insertamos los datos en la tabla de hechos
		INSERT INTO rental_facts(rental_id, address_id, film_id, date_key, store_id, payment_amount) 
		VALUES(rec_rent.rental_id, v_address_id, v_film_id, rec_rent.rental_date::date, v_store_id, v_amount);
	END LOOP;
	-- Cerramos el cursor
	CLOSE cur_rents;
	-- Guardamos los cambios
	COMMIT;
END; $cargar_datos_tablahechos$

CALL cargar_datos_tabla_hechos();
TRUNCATE TABLE rental_facts;

select * from rental_facts;


