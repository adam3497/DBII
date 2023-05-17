-- Database: dvdrental

-- DROP DATABASE IF EXISTS dvdrental;

CREATE DATABASE dvdrental
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Costa Rica.1252'
    LC_CTYPE = 'Spanish_Costa Rica.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;
	
--esta función permite la inserción de un nuevo registro en la tabla "customer"

--DROP FUNCTION IF EXISTS insertCustomer( SMALLINT,VARCHAR,VARCHAR,VARCHAR,SMALLINT,BOOLEAN,DATE,INT);

CREATE OR REPLACE FUNCTION insertCustomer(s_id SMALLINT,f_name VARCHAR, 
                                l_name VARCHAR,email VARCHAR,add_id SMALLINT,
                                a_bool BOOLEAN,
                                act INT)
RETURNS VARCHAR

LANGUAGE plpgsql

AS

$insertCustomer$

DECLARE c_result PUBLIC.customer%rowtype;

BEGIN

	SELECT * FROM PUBLIC.customer c 
	INTO c_result
	WHERE c.first_name = f_name AND c.last_name = l_name;
	
    IF c_result IS NOT NULL THEN
	
		RETURN 'EL CLIENTE YA EXISTE';
	
	ELSE
		
		INSERT INTO PUBLIC.customer(customer_id,store_id,first_name,last_name,email,
                         address_id,activebool,create_date,active)
                         
    	VALUES(NEXTVAL('customer_customer_id_seq'),s_id,f_name,l_name,email,add_id,a_bool,('now'::text)::date,act);  
    
    	RETURN 'INSERTADO CORRECTAMENTE';
	
	END IF;
    
END;

$insertCustomer$

SELECT PUBLIC.insertCustomer(1::SMALLINT,'Andrea','Mora','amora@gmail.com',22::SMALLINT,true,123::INT);


/*
Procedimiento encargado de registrar las devoluciones de una película, esto anota los datos asociados en la tabla payment. 
-rental_id = número de id de la renta por la cuál se está realizando la devolución
-v_username = nombre del usuario del empleado que está llevando a cabo el proceso de devolución 
*/
CREATE OR REPLACE PROCEDURE devolucion(v_rental_id integer, v_username varchar) 
	LANGUAGE plpgsql															
	AS $$ 
	DECLARE ---definimos variables que nos ayudarán más adelante
	v_customer_id INTEGER;
	v_staff_id INTEGER;
	v_rental_date DATE;
	BEGIN
	
	--- seleccionamos el id del cliente perteneciente a la renta y se lo pasamos a la variable v_customer_id
		select customer_id into v_customer_id
		from rental
		where v_rental_id = rental_id;
		
	--- seleccionamos el id del empleado encargado de la devolución y se lo pasamos a la variable v_staff_id
		select staff_id into v_staff_id
		from staff
		where v_username = username;
		
	--- seleccionamos la fecha en la que se realizó la renta y se lo pasamos a la variable v_rental_date
		select rental_date into v_rental_date
		from rental
		where v_rental_id = rental_id;
		
	--- comenzamos con el proceso de inserción en la tabla payment
	insert into payment VALUES
		(nextval('payment_payment_id_seq'), v_customer_id, v_staff_id, v_rental_id, 
		(select extract(day from localtimestamp - v_rental_date))*500, localtimestamp);
	COMMIT;
	/*
	Datos que tal vez no se entiendan en el insert:
	-nextval('payment_payment_id_seq') : valor que sigue en la secuencia hecha de la tabla payment.
	-(select extract(day from localtimestamp - v_rental_date))*500 : fórmula que calcula lo que se tiene que 
	 pagar al devolver la película, el localtimestamp - v_rental_date devolvía un intervalo de tiempo, por lo 
	 que se extraen los días del intervalo y el número de días se multiplica por 500.
	-localtimestamp: timestamp without timezone, se usó esta para que fuera igual al tipo de datos de las fechas 
	 que ya venían ingresados en la base de datos.
	*/
END;
$$;

--drop procedure if exists registrar_alquiler(varchar, varchar, varchar, varchar);

-- Este procedimiento almacenado registra el alquiler de una película 
create or replace procedure registrar_alquiler(
	customer_first_name varchar,
	customer_last_name varchar,
	staff_username varchar,
	movie_name varchar
)
language plpgsql
as $$
declare
	customerid int;
	staffid int;
	rent_duration int;
	today_time timestamp(0) without time zone := now();
	var_inventory_id int := -1;
	store_id int;
	film_id int;
	customer_results public.customer%rowtype;
	film_results public.film%rowtype;
	inventories_rec record;
	-- variables para el manejo de excepciones
	v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
begin
	-- obtenemos el id del cliente y el id de la tienda que está realizando la renta
	select * from public.customer c
	into customer_results 
	where c.first_name = customer_first_name and c.last_name = customer_last_name;
	
	-- asignamos los valores de los ids a las variables a usar
	if customer_results is not null then
		customerid := customer_results.customer_id;
		store_id := customer_results.store_id;
		raise notice 'Id del cliente y de la tienda obtenidos';
	end if;
	
	-- obtenemos el id del empleado
	select s.staff_id into staffid from public.staff s where s.username = 'Mike';
	
	-- obtenemos la duración del préstamo de la película 
	select *
	from public.film f 
	into film_results
	where f.title = movie_name;
	
	-- asignamos los valores a las variables a usar
	if film_results is not null then
		film_id := film_results.film_id;
		rent_duration := film_results.rental_duration;
		raise notice 'Id de la película y su duración obtenidos';
	end if;
	
	-- obtenemos el id del primer inventario disponible
	for inventories_rec in select public.film_in_stock(film_id, store_id)
	loop
		var_inventory_id := inventories_rec.film_in_stock;
		raise notice 'Encontrado inventorio dispobible con la película a alquilar';
		exit;
	end loop;
	
	if var_inventory_id != -1 then
		-- insertamos los datos en un nuevo registro dentro de la tabla rental
		insert into public.rental (rental_date, inventory_id, customer_id, return_date, staff_id)
		values (today_time, var_inventory_id, customerid, 
				today_time + cast('1 day' as interval) * rent_duration, staffid);
		raise notice 'Transacción de préstamo exitosa';
	else
		raise notice 'No existen películas dispobibles en el inventario para realizar la transacción';
	end if;
	
	exception when others then
		
		get stacked diagnostics 
			v_state   = returned_sqlstate,
			v_msg     = message_text,
			v_detail  = pg_exception_detail,
			v_hint    = pg_exception_hint,
			v_context = pg_exception_context;
			
		raise notice E'Got exception:
			state  : %
			message: %
			detail : %
			hint   : %
			context: %', v_state, v_msg, v_detail, v_hint, v_context;

		raise notice E'Got exception:
			SQLSTATE: % 
			SQLERRM: %', SQLSTATE, SQLERRM;
end;$$


-- Esta función busca el lenguaje por medio del ID que es 
-- pasado como único parámetro y retorna el nombre como un varchar
create or replace function get_film_language(
	film_language_id int
)
returns varchar
language plpgsql
as $$
declare 
	language_name varchar;
begin
	select l.name into language_name from public.language l where l.language_id = film_language_id;
	return language_name;
end; $$

-- select public.get_film_language(1);
-- DROP FUNCTION get_film_language(integer);
---------------------------------------------------------------------------------------------------

-- Esta función busca las películas que coincide con el parámetro de entrada 
-- y retorna una tabla con todas las películas, además, cambia el campo 
-- language_id por el nombre del lenguaje
create or replace function buscar_pelicula(
	film_title varchar
)
returns table (film_id int, title varchar, description varchar, release_year int, film_lan varchar, 
				rental_duration int, rental_rate int, duration int, replacement_cost numeric(5,2), rating varchar)
language plpgsql
as $$
declare 
	var_record record; 
	-- variables para el manejo de excepciones
	v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
begin
	for var_record in (
		select f.film_id, f.title, f.description, f.release_year, f.language_id, f.rental_duration,
			f.rental_rate, f.length, f.replacement_cost, f.rating
		from public.film f
		where f.title like '%' || film_title || '%'
	) loop 
			film_id := var_record.film_id;
			title := upper(var_record.title);
			description := var_record.description;
			release_year := var_record.release_year;
			film_lan := public.get_film_language(var_record.language_id);
			rental_duration := var_record.rental_duration;
			rental_rate := var_record.rental_rate;
			duration := var_record.length;
			replacement_cost := var_record.replacement_cost;
			rating := var_record.rating;
	 	return next;
	  end loop;
	  
	exception when others then
		
		get stacked diagnostics 
			v_state   = returned_sqlstate,
			v_msg     = message_text,
			v_detail  = pg_exception_detail,
			v_hint    = pg_exception_hint,
			v_context = pg_exception_context;
			
		raise notice E'Got exception:
			state  : %
			message: %
			detail : %
			hint   : %
			context: %', v_state, v_msg, v_detail, v_hint, v_context;

		raise notice E'Got exception:
			SQLSTATE: % 
			SQLERRM: %', SQLSTATE, SQLERRM; 
end; $$

-- creamos el role EMP sin ninguna opción (todas las opciones están por defecto, privilegios más básicos)
create role EMP;

-- se le concede permisos para ejecutar las funciones y procedimientos almacenados de:
-- buscar_pelicula(varchar)
grant execute on function public.buscar_pelicula(varchar) to EMP;
-- registrar_alquiler(varchar, varchar, varchar, integer)
grant execute on procedure public.registrar_alquiler(varchar, varchar, varchar, varchar) to EMP;
-- registrar_devolucion() - W.I.P
grant execute on procedure public.devolucion(integer, varchar) to EMP;

CREATE ROLE ADMIN INHERIT;

GRANT EMP TO ADMIN;

GRANT EXECUTE ON PROCEDURE devolucion(integer, varchar) TO ADMIN;

-- se crean lo usuarios y se les asignan los roles correspondientes
CREATE USER video;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO video;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO video;

GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO video;

CREATE USER empleado1 WITH PASSWORD 'empleado1';

CREATE USER administrador1 WITH PASSWORD 'admin1';

GRANT EMP TO empleado1;

GRANT ADMIN TO administrador1;

CREATE USER repuser REPLICATION WITH PASSWORD '1234';

