/*
Tabla de hechos de los alquileres cobrados
*/

TRUNCATE TABLE rental_facts;
DROP TABLE rental_facts;

CREATE TABLE rental_facts(
	rental_id INTEGER CONSTRAINT id_rental_rf NOT NULL,
	address_id NUMERIC(10) CONSTRAINT id_address_rf NOT NULL,
	film_id NUMERIC(10) CONSTRAINT id_film_rf NOT NULL,
	date_key DATE CONSTRAINT date_key_rf NOT NULL,
	store_id NUMERIC(10) CONSTRAINT id_store_rf NOT NULL,
	payment_amount NUMERIC(5,2),
	
	-- constraints de llaves foráneas de la tabla
	CONSTRAINT fk_rf_rental_id FOREIGN KEY(rental_id) REFERENCES rental(rental_id),
	CONSTRAINT fk_rf_address_id FOREIGN KEY(address_id) REFERENCES address_dim(address_id),
	CONSTRAINT fk_rf_film_id FOREIGN KEY(film_id) REFERENCES film_dim(film_id),
	CONSTRAINT fk_rf_store_id FOREIGN KEY(store_id) REFERENCES store_dim(store_id),
	CONSTRAINT fk_rf_date_key FOREIGN KEY(date_key) REFERENCES date_dim(date_key)
);

/* Dimensión Película (film_dim)
	- film_id numeric
	- title varchar
	- category varchar
	- actors text
*/

CREATE TABLE film_dim(
	film_id NUMERIC(10) NOT NULL,
	title VARCHAR(100) NOT NULL,
	category VARCHAR(50) NOT NULL,
	actors TEXT NOT NULL,
	-- Constraint de la llave principal de la tabla
	CONSTRAINT pk_film_dim_id PRIMARY KEY(film_id)  
);

/* Dimensión Lugar (address_dim)
	- address_id numeric
	- city varchar
	- country varchar
*/
DROP TABLE address_dim;

CREATE TABLE address_dim(
	address_id NUMERIC(10) NOT NULL,
	city VARCHAR(50) NOT NULL,
	country VARCHAR(50) NOT NULL,
	-- Constraint de la llave principal de la tabla
	CONSTRAINT pk_address_dim_id PRIMARY KEY(address_id)  
);

/* Dimensión Fecha (date_dim)
	- date_key date
	- year numeric
	- month numeric
	- day numeric
*/
CREATE TABLE date_dim(
	date_key DATE NOT NULL,
	year NUMERIC(5) NOT NULL
	GENERATED ALWAYS AS (EXTRACT(YEAR FROM date_key)) STORED,
	month NUMERIC(2) NOT NULL
	GENERATED ALWAYS AS (EXTRACT(MONTH FROM date_key)) STORED,
	day NUMERIC(2) NOT NULL
	GENERATED ALWAYS AS (EXTRACT(DAY FROM date_key)) STORED,
	-- Constraint de la llave principal de la tabla
	CONSTRAINT pk_date_dim_id PRIMARY KEY(date_key)  
);

/* Dimensión Sucursal (store_dim)
	- store_id numeric
*/
CREATE TABLE store_dim(
	store_id NUMERIC(10) NOT NULL,
	-- Constraint de la llave principal de la tabla
	CONSTRAINT pk_store_dim_id PRIMARY KEY(store_id)
);