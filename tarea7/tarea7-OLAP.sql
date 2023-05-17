CREATE TABLE ventas (
    sucursal_id NUMBER NOT NULL,
    linea_distribucion_id NUMBER NOT NULL,
    producto_id NUMBER NOT NULL,
    cantidad_producto NUMBER NOT NULL,
    monto NUMBER(10,2) NOT NULL
);

INSERT INTO ventas SELECT
    TRUNC(DBMS_RANDOM.value(low => 1, high => 3)) ,
    TRUNC(DBMS_RANDOM.value(low => 1, high => 6)) ,
    TRUNC(DBMS_RANDOM.value(low => 1, high => 11)) ,
    TRUNC(DBMS_RANDOM.value(low => 1, high => 7)) ,
    ROUND(DBMS_RANDOM.value(low => 1000, high => 10000), 2)
    FROM dual CONNECT BY level <= 1000;

select * from ventas;

-- 1.1. Sume las ventas por sucursal y productos
select sucursal_id, producto_id, count(cantidad_producto) as cant_productos, sum(monto) as monto
from ventas 
group by sucursal_id, producto_id
order by 1,2;


-- 1.2 Usando SQL ROLLUP calcule el total de ventas por sucursal y producto. Además, las ventas totales y el total de productos vendidos.
select sucursal_id, producto_id, count(cantidad_producto) as filas, sum(monto) as monto
from ventas
group by rollup (sucursal_id, producto_id)
order by 1,2;

-- 1.2.1 Muestre cuál es la cantidad de productos vendidos por la sucursal 1
select sucursal_id as numero_sucursal, count(cantidad_producto) as productos_vendidos
from ventas
group by ROLLUP(sucursal_id)
having ventas.sucursal_id = 1 
order by 1,2;

-- 1.2.2 Muestre cuál es el monto total vendido del artículo 5 en la sucursal 2.
select sucursal_id as numero_sucursal, producto_id as articulo, sum(monto) as monto_total
from ventas
group by ROLLUP(sucursal_id,producto_id)
having ventas.sucursal_id = 2 and producto_id = 5
order by 1,2;

-- 1.2.3 Muestre cuál es el monto total de todas las ventas.


-- 1.3 Usando SQL cube calcule:

-- El total de ventas por sucursal y producto.
-- Las ventas totales y el total de productos vendidos.
-- El total de venta por producto
select sucursal_id, producto_id, count(cantidad_producto) as filas, sum(monto) as monto
from ventas
group by cube (sucursal_id, producto_id)
order by 1,2;

-- 1.3.1 Muestre cuál es la cantidad total vendida para el artículo 2
select producto_id, count(cantidad_producto) as filas, sum(monto) as monto
from ventas
group by cube (producto_id)
having producto_id = 2;

-- 1.3.2 Muestre cuál es el monto generado por las ventas del artículo 9.
select producto_id, count(cantidad_producto) as filas, sum(monto) as monto
from ventas
group by cube (producto_id)
having producto_id = 9;

-- 1.4 Utilice las funciones DECODE y GROUPING para sustituir los nulos en las columnas 
select  decode(grouping(sucursal_id), 1, 'Todos', sucursal_id) as sucursal, 
        decode(grouping(producto_id), 1, 'Todos', producto_id) as producto, 
        count(cantidad_producto) as filas, 
        sum(monto) as monto
from ventas
group by cube (sucursal_id, producto_id)
order by sucursal_id,producto_id asc;