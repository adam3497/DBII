CREATE TABLE fact_table(
    payment_date DATE REFERENCES date_dim(payment_date),
    customer_id NUMBER(10) REFERENCES customer_dim(customer_id),
    film_id NUMBER(10) REFERENCES film_dim(film_id),
    store_id NUMBER(10) REFERENCES store_dim(store_id),
    total_films_rental NUMBER(10),
    total_payment_amount NUMBER(10, 2)
);