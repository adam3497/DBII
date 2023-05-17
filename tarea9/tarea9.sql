-- Tipo de dato Cliente_typ y su secuencia
-- DROP TYPE Cliente_typ;
CREATE TYPE Cliente_typ AS OBJECT (
    id NUMBER,
    nombre VARCHAR2(20),
    apellido VARCHAR2(20),
    direccion VARCHAR2(50)
);

-- Secuencia para la tabla cliente_
-- DROP SEQUENCE s_cliente;
CREATE SEQUENCE s_cliente
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;

-- Se crea la tabla cliente_ a partir del tipo Cliente_typ
-- DROP TABLE cliente_;
CREATE TABLE cliente_ OF Cliente_typ;
    
-- Tipo de dato Producto_typ y su secuencia
-- DROP TYPE Producto_typ;
CREATE TYPE Producto_typ AS OBJECT (
    id NUMBER,
    nombre VARCHAR2(20),
    costo Integer
);

-- Secuencia para la tabla producto_
-- DROP SEQUENCE s_producto;
CREATE SEQUENCE s_producto
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;

-- Se crea la tabla producto_ a partir del tipo Producto_typ
-- DROP TABLE producto_;
CREATE TABLE producto_ OF Producto_typ;

-- Tipo de dato Orden_compra_typ y su secuencia
-- DROP TYPE Orden_compra_typ;
CREATE OR REPLACE TYPE Orden_compra_typ AS OBJECT (
    id NUMBER,
    fecha DATE,
    comprador REF Cliente_typ,
    MEMBER FUNCTION despliega_orden_compra(idno NUMBER) RETURN VARCHAR2
) FINAL;

-- Body de la función del tipo Orden_compra_typ
-- DROP TYPE BODY Orden_compra_typ;
CREATE OR REPLACE TYPE BODY Orden_compra_typ AS 
    MEMBER FUNCTION despliega_orden_compra (idno NUMBER) RETURN VARCHAR2 IS
        v_nombre_comprador VARCHAR2(20);
        v_apellido_comprador VARCHAR2(20);
        v_fecha_orden_compra DATE;
        -- declaración de variables locales
        var_productos VARCHAR2(500) := '';
        -- Variable que va a contener toda la información de la orden de compra y sus líneas
        var_detalles VARCHAR2(500);
        -- Cursor para obtener la orden de compra especificada por el id de la función 
        CURSOR c_orden_compra IS
                SELECT fecha, DEREF(comprador).nombre AS "nombre_comprador", DEREF(comprador).apellido AS "apellido_comprador"
                FROM Orden_compra 
                WHERE Orden_compra.id = idno;
        -- Cursor para obtener las lineas de la orden de compra especificada por el id de la función
        CURSOR c_lineas IS
                SELECT DEREF(producto_comprado).nombre AS "nombre_producto", DEREF(producto_comprado).costo AS "precio_producto", 
                       cantidad
                FROM Lineas
                WHERE DEREF(orden_compra_id).id = idno;
        BEGIN
            -- Abrimos el cursor de la orden de compra
            OPEN c_orden_compra;
            -- Extraemos el resultado en la variable r_orden_compra para poder acceder a sus datos
            FETCH c_orden_compra INTO v_fecha_orden_compra, v_nombre_comprador, v_apellido_comprador;
            -- Abrimos el cursor de las lineas asociadas a la orden de compra
            -- Extraemos todas las lineas y las guardamos como strings 
            FOR r_lineas IN c_lineas 
            LOOP    
                var_productos := var_productos || 'Producto: ' || r_lineas."nombre_producto" || ', ' 
                                                || 'Precio: ' || r_lineas."precio_producto" || ', '
                                                || 'Cantidad: ' || r_lineas.cantidad || chr(13) || chr(10);
            END LOOP;
            
            -- Concatenamos toda la información para retornarla 
            var_detalles := '---------------------------------------------------------' ||chr(13) || chr(10);
            var_detalles := var_detalles || 'Fecha: ' || TO_CHAR(v_fecha_orden_compra) ||chr(13) || chr(10) || 'Nombre cliente: ' || v_nombre_comprador 
                            || ' ' || v_apellido_comprador ||chr(13) || chr(10) || var_productos;
            var_detalles := var_detalles || '---------------------------------------------------------' || chr(13) || chr(10);
            -- Cerramos el cursor de la orden de compra
            CLOSE c_orden_compra;
            RETURN var_detalles;
        END;
END;

-- Secuencia para la tabla Orden_compra
-- DROP SEQUENCE s_orden_compra;
CREATE SEQUENCE s_orden_compra
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;

-- Se crea la tabla Orden_compra a partir del tipo Orden_compra_typ
-- DROP TABLE Orden_compra;
CREATE TABLE Orden_compra of Orden_compra_typ;
-- Se arega el scope para la referencia de la tabla Orden_compra
ALTER TABLE Orden_compra ADD SCOPE FOR (comprador) IS cliente_;

-- Tipo de dato Lineas_typ y su secuencia
-- DROP TYPE Lineas_typ;
CREATE TYPE Lineas_typ AS OBJECT (
    id NUMBER,
    orden_compra_id REF Orden_compra_typ,
    producto_comprado REF Producto_typ,
    cantidad NUMBER
);

-- Secuancia para la tabla Lineas
-- DROP SEQUENCE s_lineas;
CREATE SEQUENCE s_lineas
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;

-- Se crea la table Lineas a partir del tipo Lineas_typ
-- DROP TABLE Lineas;
CREATE TABLE Lineas of Lineas_typ;
-- Se agrega el scope para las referencias de la table Lineas
ALTER TABLE Lineas ADD SCOPE FOR (orden_compra_id) IS Orden_compra;
ALTER TABLE Lineas ADD SCOPE FOR (producto_comprado) IS producto_;

-- Agregamos datos a las tablas
-- 3 productos
INSERT INTO producto_(id, nombre, costo) VALUES(s_producto.NEXTVAL, 'Jabón', 550);
INSERT INTO producto_(id, nombre, costo) VALUES(s_producto.NEXTVAL, 'Arroz', 1350);
INSERT INTO producto_(id, nombre, costo) VALUES(s_producto.NEXTVAL, 'Leche', 655);

-- TRUNCATE TABLE producto_;

-- 2 clientes
INSERT INTO cliente_(id, nombre, apellido, direccion) VALUES(s_cliente.NEXTVAL, 'José', 'Madrigal', 'Calle Vargas, Alajuela, Costa Rica');
INSERT INTO cliente_(id, nombre, apellido, direccion) VALUES(s_cliente.NEXTVAL, 'Angie', 'Ortiz', 'Barrio Amón, San José, Costa Rica');

-- TRUNCATE TABLE cliente_;

-- 2 ordenes de compra
INSERT INTO Orden_compra(id, fecha, comprador) VALUES(s_orden_compra.NEXTVAL, TO_DATE('02-MAY-2023', 'DD-MON-YYYY'), NULL);
INSERT INTO Orden_compra(id, fecha, comprador) VALUES(s_orden_compra.NEXTVAL, TO_DATE('01-MAY-2023', 'DD-MON-YYYY'), NULL);

SELECT * FROM Orden_compra;

UPDATE Orden_compra 
    SET comprador = (SELECT REF(a) FROM cliente_ a WHERE id = 1)
    WHERE id = 1;
    
UPDATE Orden_compra 
    SET comprador = (SELECT REF(a) FROM cliente_ a WHERE id = 2)
    WHERE id = 2;


-- TRUNCATE TABLE Orden_compra;

-- 2 líneas para la primer orden de compra
INSERT INTO Lineas(id, orden_compra_id, producto_comprado, cantidad)
                VALUES(s_lineas.NEXTVAL, null, null, 3);
INSERT INTO Lineas(id, orden_compra_id, producto_comprado, cantidad)
                VALUES(s_lineas.NEXTVAL, null, null, 4);


UPDATE Lineas
    SET orden_compra_id = (SELECT REF(a) FROM Orden_compra a WHERE id = 1),
        producto_comprado = (SELECT REF(a) FROM producto_ a WHERE id = 1)
    WHERE id = 1;

UPDATE Lineas
    SET orden_compra_id = (SELECT REF(a) FROM Orden_compra a WHERE id = 1),
        producto_comprado = (SELECT REF(a) FROM producto_ a WHERE id = 2)
    WHERE id = 2;


-- 3 líneas para la segunda orden de compra
INSERT INTO Lineas(id, orden_compra_id, producto_comprado, cantidad)
                VALUES(s_lineas.NEXTVAL, null, null, 2);
INSERT INTO Lineas(id, orden_compra_id, producto_comprado, cantidad)
                VALUES(s_lineas.NEXTVAL, null, null, 2);
INSERT INTO Lineas(id, orden_compra_id, producto_comprado, cantidad)
                VALUES(s_lineas.NEXTVAL, null, null, 5);

SELECT * FROM Lineas;

UPDATE Lineas
    SET orden_compra_id = (SELECT REF(a) FROM Orden_compra a WHERE id = 2),
        producto_comprado = (SELECT REF(a) FROM producto_ a WHERE id = 1)
    WHERE id = 3;

UPDATE Lineas
    SET orden_compra_id = (SELECT REF(a) FROM Orden_compra a WHERE id = 2),
        producto_comprado = (SELECT REF(a) FROM producto_ a WHERE id = 2)
    WHERE id = 4;
    
UPDATE Lineas
    SET orden_compra_id = (SELECT REF(a) FROM Orden_compra a WHERE id = 2),
        producto_comprado = (SELECT REF(a) FROM producto_ a WHERE id = 3)
    WHERE id = 5;
    
    
-- TRUNCATE TABLE Lineas;

-- Pruebas de la función despliega_orden_compra()

SELECT a.despliega_orden_compra(1) FROM Orden_compra a;

-- Pruebas para desplegar los datos de las tablas
    
SELECT id AS LINEA, DEREF(orden_compra_id).id AS "orden_compra", DEREF(producto_comprado).id,
                    DEREF(producto_comprado).nombre, DEREF(producto_comprado).costo, cantidad
FROM Lineas;


SELECT id, fecha, DEREF(comprador).id, DEREF(comprador).nombre, DEREF(comprador).apellido, DEREF(comprador).direccion
FROM Orden_compra;

SELECT DEREF(producto_comprado).nombre AS "nombre_producto", DEREF(producto_comprado).costo AS "precio_producto", 
                       cantidad
                FROM Lineas
                WHERE DEREF(orden_compra_id).id = 1;
          