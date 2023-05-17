---------------Creación de table_space------------------------------------------ 

CREATE TABLESPACE PR_Data
   DATAFILE 'D:\app\andyx\oradata\DBPRUEBA\prdata01.dbf' -- Cambiar por su direccion de ordata pero no subir el archivo al git.
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;
CREATE TABLESPACE PR_Ind
   DATAFILE 'D:\app\andyx\oradata\DBPRUEBA\prind01.dbf' -- Cambiar por su direccion de ordata pero no subir el archivo al git.
   SIZE 10M
   REUSE
   AUTOEXTEND ON
   NEXT 512k
   MAXSIZE 200M;

-----------------Creación del esquema-------------------------------------------

CREATE USER PR 
    IDENTIFIED BY PR
    DEFAULT TABLESPACE PR_data 
    QUOTA 10M ON PR_data 
    TEMPORARY TABLESPACE temp
    QUOTA 5M ON system ;
    --PROFILE PR 
    --PASSWORD PR;
GRANT connect TO PR;
--------------------------------------------------
GRANT create session to PR;
--------------------------------------------------
GRANT create table to PR;
--------------------------------------------------
GRANT create view to PR;
GRANT CREATE ANY INDEX to PR;
GRANT DROP PUBLIC SYNONYM to PR;
GRANT UNLIMITED TABLESPACE TO PR;
GRANT CREATE PROCEDURE TO PR;
GRANT CREATE ANY SEQUENCE TO PR;
GRANT ALTER ANY SEQUENCE TO PR;
GRANT CREATE ANY TRIGGER TO PR;


----------Creación de las tablas con sus llaves primarias-----------------------

CREATE TABLE Persona
(
    id_persona NUMBER(3) CONSTRAINT id_persona_nn NOT NULL,
    cedula NUMBER(9) CONSTRAINT cedula_nn NOT NULL,
    nombre_persona VARCHAR2(30) CONSTRAINT nombre_nn NOT NULL,
    apellidos VARCHAR2(30) CONSTRAINT apellidos_nn NOT NULL, 
    telefono NUMBER(8), 
    correo_electronico Varchar2(30 BYTE),
    CONSTRAINT pk_Persona PRIMARY KEY(id_persona)
);

CREATE TABLE Categoria
(
    id_categoria NUMBER(3) CONSTRAINT id_categoria_nn NOT NULL,
    nombre_categoria VARCHAR2(30) CONSTRAINT nombre_categoria_nn NOT NULL,
    CONSTRAINT pk_Categoria PRIMARY KEY(id_categoria)
);

DROP TABLE categoria;

CREATE TABLE Puesto
(
    id_puesto NUMBER(3) CONSTRAINT id_puesto_nn NOT NULL,
    nombre_puesto VARCHAR2(30) CONSTRAINT nombre_puesto_nn NOT NULL,
    descripcion VARCHAR2(50 BYTE) CONSTRAINT descripcion_nn  NOT NULL,
    CONSTRAINT pk_Puesto PRIMARY KEY(id_puesto)
);

DROP TABLE puesto;

CREATE TABLE Empleado
(
    id_persona_emp NUMBER(3) CONSTRAINT id_persona_emp_nn NOT NULL,
    id_puesto_emp NUMBER(3) CONSTRAINT nombre_puesto_emp_nn NOT NULL,
    CONSTRAINT pk_Empleado PRIMARY KEY(id_persona_emp)
);

DROP TABLE empleado;

CREATE TABLE Cliente
(
    id_persona_cli NUMBER(3) CONSTRAINT id_persona_cli_nn NOT NULL,
    direccion VARCHAR2(50 BYTE) CONSTRAINT direccion_nn  NOT NULL,
    CONSTRAINT pk_Cliente PRIMARY KEY(id_persona_cli)
);

DROP TABLE cliente;

CREATE TABLE Factura
(
    id_factura NUMBER(3) CONSTRAINT id_factura_nn NOT NULL,
    id_persona_emp_fac NUMBER(3) CONSTRAINT id_persona_emp_fac_nn NOT NULL,
    id_persona_cli_fac NUMBER(3) CONSTRAINT id_persona_cli_fac_nn NOT NULL,
    fecha_factura DATE CONSTRAINT fecha_factura_nn NOT NULL, 
    CONSTRAINT pk_Factura PRIMARY KEY(id_factura)
);

DROP TABLE factura;

CREATE TABLE Producto
(
    id_producto NUMBER(3) CONSTRAINT id_producto_nn NOT NULL,
    id_categoria_pro NUMBER(3) CONSTRAINT id_categoria_pro_nn NOT NULL,
    nombre_producto VARCHAR2(30) CONSTRAINT nombre_producto_nn NOT NULL,
    precio_producto NUMBER(5) CONSTRAINT precio_producto_nn NOT NULL,
    fecha_vencimiento DATE,
    cantidad_inventario NUMBER(4) CONSTRAINT cantidad_inventario_nn  NOT NULL,
    CONSTRAINT pk_Producto PRIMARY KEY(id_producto)
);

DROP TABLE producto;

CREATE TABLE FacturaProducto
(
    id_factura_fp NUMBER(3) CONSTRAINT id_factura_fp_nn NOT NULL,
    id_producto_fp NUMBER(3) CONSTRAINT id_producto_fp_nn NOT NULL,
    cantidad NUMBER(4) CONSTRAINT cantidad_nn  NOT NULL,
    CONSTRAINT pk_FacturaProducto PRIMARY KEY(id_factura_fp, id_producto_fp)
);

DROP TABLE FacturaProducto;

CREATE TABLE Bitacora 
(
    id_bitacora NUMBER(3) CONSTRAINT id_bitacora_nn NOT NULL,
    fecha_cambio DATE CONSTRAINT fecha_cambio_nn NOT NULL,
    usuario_cambio VARCHAR2(30) CONSTRAINT last_text_nn NOT NULL,
    valor_modificado VARCHAR2(30) CONSTRAINT change_description_nn NOT NULL,
    CONSTRAINT pk_Bitacora PRIMARY KEY(id_bitacora)
);

DROP TABLE FacturaProducto;

----------------Creación de llaves foráneas-------------------------------------

ALTER TABLE Empleado
    ADD CONSTRAINT fk_id_persona_emp FOREIGN KEY
    (id_persona_emp) REFERENCES Persona(id_persona);

ALTER TABLE Empleado
    ADD CONSTRAINT fk_id_puesto_emp FOREIGN KEY
    (id_puesto_emp) REFERENCES Puesto(id_puesto);

ALTER TABLE Cliente
    ADD CONSTRAINT fk_id_persona_cli FOREIGN KEY
    (id_persona_cli) REFERENCES Persona(id_persona);

ALTER TABLE Factura
    ADD CONSTRAINT fk_id_persona_emp_fac FOREIGN KEY
    (id_persona_emp_fac) REFERENCES Empleado(id_persona_emp);
    
ALTER TABLE Factura
    ADD CONSTRAINT fk_id_persona_cli_fac FOREIGN KEY
    (id_persona_cli_fac) REFERENCES Cliente(id_persona_cli);
    
ALTER TABLE Producto
    ADD CONSTRAINT fk_id_categoria_pro FOREIGN KEY
    (id_categoria_pro) REFERENCES Categoria(id_categoria);
    
ALTER TABLE FacturaProducto
    ADD CONSTRAINT fk_id_factura_fp FOREIGN KEY
    (id_factura_fp) REFERENCES Factura(id_factura);
    
ALTER TABLE FacturaProducto
    ADD CONSTRAINT fk_id_producto_fp FOREIGN KEY
    (id_producto_fp) REFERENCES Producto(id_producto);
    
------------------------------Creación de secuencias----------------------------

CREATE SEQUENCE s_persona
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE s_categoria
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;
    
CREATE SEQUENCE s_puesto
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE s_factura
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE s_producto
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE s_bitacora
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 10000000
    NOCACHE
    NOCYCLE;    
----------------Paquetes con sus procedimientos y funciones respectivas---------

CREATE OR REPLACE PACKAGE CRD AS 
    PROCEDURE insertar_persona(v_cedula IN VARCHAR2, v_nombre_persona VARCHAR2, 
                               v_apellidos IN VARCHAR2, v_telefono IN NUMBER, 
                               v_correo_electronico IN VARCHAR2);
    PROCEDURE actualizar_cedula_persona(v_cedula IN NUMBER, 
                                        v_id_persona IN NUMBER);
    PROCEDURE actualizar_nombre_persona(v_nombre_persona IN VARCHAR2,
                                        v_id_persona IN NUMBER);
    PROCEDURE actualizar_apellidos_persona(v_apellidos IN VARCHAR2,
                                           v_id_persona IN NUMBER);
    PROCEDURE actualizar_telefono_persona(v_telefono IN NUMBER, 
                                          v_id_persona IN NUMBER);
    PROCEDURE actualizar_correo_persona(v_correo_electronico IN VARCHAR2,
                                        v_id_persona IN NUMBER);
    --PROCEDURE eliminar_persona(v_id_persona IN NUMBER);
    
    PROCEDURE insertar_categoria(v_nombre_categoria IN VARCHAR2);
    PROCEDURE actualizar_nombre_categoria(v_nombre_categoria IN VARCHAR2,
                                          v_id_categoria IN NUMBER);
    --PROCEDURE eliminar_categoria(v_id_categoria IN NUMBER);
    
    PROCEDURE insertar_puesto(v_nombre_puesto IN VARCHAR2, 
                              v_descripcion IN VARCHAR2);
    PROCEDURE actualizar_nombre_puesto(v_nombre_puesto IN VARCHAR2,
                                       v_id_puesto IN NUMBER);
    PROCEDURE actualizar_descripcion_puesto(v_descripcion IN VARCHAR2,
                                            v_id_puesto IN NUMBER);
    --PROCEDURE eliminar_puesto(v_id_puesto IN NUMBER);

    PROCEDURE insertar_empleado(v_id_persona_emp IN NUMBER, 
                                v_id_puesto_emp IN NUMBER);
    PROCEDURE actualizar_puesto_empleado(v_id_puesto_emp IN NUMBER,
                                         v_id_persona_emp IN NUMBER);
    --PROCEDURE eliminar_empleado(v_id_persona_emp IN NUMBER);
    
    PROCEDURE insertar_cliente(v_id_persona_cli IN NUMBER, 
                               v_direccion IN VARCHAR2);
    PROCEDURE actualizar_direccion_cliente(v_direccion IN VARCHAR2, 
                                           v_id_persona_cli IN NUMBER);
    --PROCEDURE eliminar_cliente(v_id_persona_cli IN NUMBER);
    
    PROCEDURE insertar_factura(v_id_persona_emp_fac IN NUMBER,
                               v_id_persona_cli_fac IN NUMBER);
    PROCEDURE actualizar_fecha_factura(v_fecha_factura IN DATE, 
                                       v_id_factura IN NUMBER);
    --PROCEDURE eliminar_factura(v_id_factura IN NUMBER);
    
    PROCEDURE insertar_producto(v_id_categoria_pro IN NUMBER,
                                v_nombre_producto IN VARCHAR2, 
                                v_precio_producto IN NUMBER, 
                                v_fecha_vencimiento IN DATE, 
                                v_cantidad_inventario IN NUMBER);
    PROCEDURE actualizar_nombre_producto(v_nombre_producto IN VARCHAR2,
                                         v_id_producto IN NUMBER);
    PROCEDURE actualizar_precio_producto(v_precio_producto IN NUMBER,
                                         v_id_producto IN NUMBER);
    PROCEDURE actualizar_cantidad_producto(v_cantidad_inventario IN NUMBER,
                                           v_id_producto IN NUMBER);
    --PROCEDURE eliminar_producto(v_id_producto IN NUMBER);
    
    PROCEDURE insertar_facPro(v_id_factura_fp IN NUMBER, 
                                       v_id_producto_fp IN NUMBER, 
                                       v_cantidad IN NUMBER);
    PROCEDURE actualizar_cantidad_facPro(v_cantidad IN NUMBER,
                                                  v_id_factura_fp IN NUMBER,
                                                  v_id_producto_fp IN NUMBER);
    --PROCEDURE eliminar_facPro(v_id_factura_fp IN NUMBER, 
     --                                  v_id_producto_fp IN NUMBER);
    
END CRD;
/
CREATE OR REPLACE PACKAGE BODY CRD AS
    
    PROCEDURE insertar_persona (v_cedula IN VARCHAR2, v_nombre_persona VARCHAR2, 
                                v_apellidos IN VARCHAR2, v_telefono in NUMBER, 
                                v_correo_electronico in VARCHAR2)
    AS
    BEGIN
        INSERT INTO Persona
        VALUES (s_persona.nextval, v_cedula, v_nombre_persona, v_apellidos, 
        v_telefono , v_correo_electronico);
    END;
    PROCEDURE actualizar_cedula_persona(v_cedula IN NUMBER, 
                                        v_id_persona IN NUMBER)
    AS
    BEGIN
        UPDATE Persona
        SET cedula = v_cedula
        WHERE id_persona = v_id_persona;
    END;
    PROCEDURE actualizar_nombre_persona(v_nombre_persona IN VARCHAR2, 
                                        v_id_persona IN NUMBER)
    AS
    BEGIN
        UPDATE Persona
        SET nombre_persona = v_nombre_persona
        WHERE id_persona = v_id_persona;
    END;
    PROCEDURE actualizar_apellidos_persona(v_apellidos IN VARCHAR2, 
                                           v_id_persona IN NUMBER)
    AS
    BEGIN
        UPDATE Persona
        SET apellidos = v_apellidos
        WHERE id_persona = v_id_persona;
    END;
    PROCEDURE actualizar_telefono_persona(v_telefono IN NUMBER,
                                          v_id_persona IN NUMBER)
    AS
    BEGIN
        UPDATE Persona
        SET telefono = v_telefono
        WHERE id_persona = v_id_persona;
    END;
    PROCEDURE actualizar_correo_persona(v_correo_electronico IN VARCHAR2,
                                        v_id_persona IN NUMBER)
    AS
    BEGIN
        UPDATE Persona
        SET correo_electronico = v_correo_electronico
        WHERE id_persona = v_id_persona;
    END;
    /*PROCEDURE eliminar_persona(v_id_persona IN NUMBER)
    AS
    BEGIN
        INSERT INTO Persona
        VALUES (s_persona.nextval, v_cedula, v_nombre_persona, v_apellidos, 
        v_telefono , v_correo_electronico);
    END;*/
    
    PROCEDURE insertar_categoria(v_nombre_categoria IN VARCHAR2)
    AS
    BEGIN
        INSERT INTO Categoria
        VALUES (s_categoria.nextval, v_nombre_categoria);
    END;  
    PROCEDURE  actualizar_nombre_categoria(v_nombre_categoria IN VARCHAR2,
                                           v_id_categoria IN NUMBER)
    AS
    BEGIN
        UPDATE Categoria
        SET nombre_categoria = v_nombre_categoria
        WHERE id_categoria = v_id_categoria;
    END; 
    /*PROCEDURE eliminar_categoria(v_id_categoria IN NUMBER)
    AS
    BEGIN
        INSERT INTO Categoria
        VALUES (s_categoria.nextval, v_nombre_categoria);
    END;*/
    
    PROCEDURE  insertar_puesto(v_nombre_puesto IN VARCHAR2, 
                               v_descripcion IN VARCHAR2)
    AS
    BEGIN
        INSERT INTO Puesto
        VALUES (s_puesto.nextval, v_nombre_puesto, v_descripcion);
    END;
     PROCEDURE  actualizar_nombre_puesto(v_nombre_puesto IN VARCHAR2,
                                         v_id_puesto IN NUMBER)
    AS
    BEGIN
        UPDATE Puesto
        SET nombre_puesto = v_nombre_puesto
        WHERE id_puesto = v_id_puesto;
    END;
     PROCEDURE  actualizar_descripcion_puesto(v_descripcion IN VARCHAR2,
                                              v_id_puesto IN NUMBER)
    AS
    BEGIN
        UPDATE Puesto
        SET descripcion = v_descripcion
        WHERE id_puesto = v_id_puesto;
    END;
    /*PROCEDURE eliminar_puesto(v_id_puesto IN NUMBER)
    AS
    BEGIN
        INSERT INTO Puesto
        VALUES (s_puesto.nextval, v_nombre_puesto, v_descripcion);
    END;*/
    
    PROCEDURE  insertar_empleado(v_id_persona_emp IN NUMBER, 
                                 v_id_puesto_emp IN NUMBER)
    AS
    BEGIN
        INSERT INTO Empleado
        VALUES (v_id_persona_emp, v_id_puesto_emp);
    END;
    PROCEDURE  actualizar_puesto_empleado(v_id_puesto_emp IN NUMBER,
                                          v_id_persona_emp IN NUMBER)
    AS
    BEGIN
        UPDATE Empleado
        SET id_puesto_emp = v_id_puesto_emp 
        WHERE id_persona_emp = v_id_persona_emp;
    END;
    /*PROCEDURE  eliminar_empleado(v_id_persona_emp IN NUMBER)
    AS
    BEGIN
        INSERT INTO Empleado
        VALUES (v_id_persona_emp, v_id_puesto_emp);
    END;*/
    
    PROCEDURE  insertar_cliente(v_id_persona_cli IN NUMBER, 
                                v_direccion IN VARCHAR2)
    AS
    BEGIN
        INSERT INTO Cliente
        VALUES (v_id_persona_cli, v_direccion);
    END;
    PROCEDURE  actualizar_direccion_cliente(v_direccion IN VARCHAR2, 
                                            v_id_persona_cli IN NUMBER)
    AS
    BEGIN
        UPDATE Cliente
        SET direccion = v_direccion 
        WHERE id_persona_cli = id_persona_cli;
    END;
    /*PROCEDURE  eliminar_cliente(v_id_persona_cli IN NUMBER)
    AS
    BEGIN
        INSERT INTO Cliente
        VALUES (v_id_persona_cli, v_direccion);
    END;*/
    
    PROCEDURE  insertar_factura(v_id_persona_emp_fac IN NUMBER,
                                v_id_persona_cli_fac IN NUMBER)
    AS
    BEGIN
        INSERT INTO Factura
        VALUES (s_factura.nextval, v_id_persona_emp_fac, v_id_persona_cli_fac, 
        SYSDATE);
    END; 
    PROCEDURE  actualizar_fecha_factura(v_fecha_factura IN DATE, 
                                        v_id_factura IN NUMBER)
    AS
    BEGIN
        UPDATE Factura
        SET fecha_factura = v_fecha_factura
        WHERE id_factura = v_id_factura;
    END; 
    /*PROCEDURE  eliminar_factura(v_id_factura IN NUMBER)
    AS
    BEGIN
        INSERT INTO Factura
        VALUES (s_factura.nextval, v_id_persona_emp_fac, v_id_persona_cli_fac, 
        SYSDATE);
    END;*/
    
    PROCEDURE  insertar_producto(v_id_categoria_pro IN NUMBER,
                                 v_nombre_producto IN VARCHAR2, 
                                 v_precio_producto IN NUMBER, 
                                 v_fecha_vencimiento IN DATE, 
                                 v_cantidad_inventario IN NUMBER)
    AS
    BEGIN
        INSERT INTO Producto
        VALUES (s_producto.nextval, v_id_categoria_pro, v_nombre_producto, 
                v_precio_producto, v_fecha_vencimiento, v_cantidad_inventario);
    END;
    PROCEDURE  actualizar_nombre_producto(v_nombre_producto IN VARCHAR2,
                                          v_id_producto IN NUMBER)
    AS
    BEGIN
        UPDATE Producto
        SET nombre_producto = v_nombre_producto
        WHERE id_producto = v_id_producto;
    END;
    PROCEDURE  actualizar_precio_producto(v_precio_producto IN NUMBER,
                                         v_id_producto IN NUMBER)
    AS
    BEGIN
        UPDATE Producto
        SET precio_producto = v_precio_producto
        WHERE id_producto = v_id_producto;
    END;
    PROCEDURE  actualizar_cantidad_producto(v_cantidad_inventario IN NUMBER,
                                            v_id_producto IN NUMBER)
    AS
    BEGIN
        UPDATE Producto
        SET cantidad_inventario = v_cantidad_inventario
        WHERE id_producto = v_id_producto;
    END;
    /*PROCEDURE  eliminar_producto(v_id_producto IN NUMBER)
    AS
    BEGIN
        INSERT INTO Producto
        VALUES (s_producto.nextval, v_id_categoria_pro, v_nombre_producto, 
                v_precio_producto, v_fecha_vencimiento, v_cantidad_inventario);
    END;*/
    
    PROCEDURE  insertar_facPro(v_id_factura_fp IN NUMBER, 
                                        v_id_producto_fp IN NUMBER, 
                                        v_cantidad IN NUMBER)
    AS
    BEGIN
        INSERT INTO FacturaProducto
        VALUES (v_id_factura_fp, v_id_producto_fp, v_cantidad);
    END;
    PROCEDURE  actualizar_cantidad_facPro(v_cantidad IN NUMBER,
                                                   v_id_factura_fp IN NUMBER,
                                                   v_id_producto_fp IN NUMBER)
    AS
    BEGIN
        UPDATE FacturaProducto
        SET cantidad = v_cantidad
        WHERE id_factura_fp = v_id_factura_fp 
        AND id_producto_fp = id_producto_fp;
    END;
    /*PROCEDURE  eliminar_facPro(v_id_factura_fp IN NUMBER, 
                                       v_id_producto_fp IN NUMBER)
    AS
    BEGIN
        INSERT INTO FacturaProducto
        VALUES (v_id_factura_fp, v_id_producto_fp, v_cantidad);
    END;*/
    
END CRD;
/

-----------------------Paquetes de consultas------------------------------------

CREATE OR REPLACE PACKAGE PKG_QR
AS 

FUNCTION get_employee(id_emplo IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_client(id_client IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_product(id_produc IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_bill(id_factura IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_category(id_cat IN NUMBER)
RETURN VARCHAR2;


END PKG_QR;
/

CREATE OR REPLACE PACKAGE BODY PKG_QR
AS 

FUNCTION get_employee(id_emplo IN NUMBER)
RETURN VARCHAR2
IS emp_data Empleado%ROWTYPE;

CURSOR get_emp IS 
    SELECT * FROM Empleado WHERE id_employe = id_persona_emp
    ORDER BY id;
    
BEGIN

   OPEN get_emp;
   
   LOOP
   
    FETCH get_emp INTO emp_data;
    EXIT WHEN get_emp%NOTFOUND;
    
    END LOOP;
    
    CLOSE get_emp;
    
    RETURN get_emp;
   
END get_employee;


FUNCTION get_client(id_client IN NUMBER)
RETURN VARCHAR2
IS clien_data Cliente%ROWTYPE;

CURSOR get_clien IS 
    SELECT * FROM Cliente WHERE id_client = id_persona_cli
    ORDER BY id;
    
BEGIN

   OPEN get_clien;
   
   LOOP
   
    FETCH get_clien INTO clien_data;
    EXIT WHEN get_emp%NOTFOUND;
    
    END LOOP;
    
    CLOSE get_clien;
   
     RETURN get_clien;
   
END get_client;



FUNCTION get_product(id_produc IN NUMBER)
RETURN VARCHAR2
IS produ_data PRODUCTO%ROWTYPE;

CURSOR get_produ IS 
    SELECT * FROM Producto WHERE id_produc = id_producto
    ORDER BY id;
    
BEGIN

   OPEN get_produ;
   
   LOOP
   
    FETCH get_produ INTO produ_data;
    EXIT WHEN get_emp%NOTFOUND;
    
    END LOOP;
    
    CLOSE get_produ;
   
   RETURN get_produ;
   
END get_product;


FUNCTION get_bill(id_factura IN NUMBER)
RETURN VARCHAR2
IS bil_data FacturaProducto%ROWTYPE;

CURSOR get_bil IS 
    SELECT * FROM FacturaProducto WHERE id_factura = id_factura_fp
    ORDER BY id;
    
BEGIN

    OPEN get_bil;
    
    LOOP
    
        FETCH get_bil INTO bil_data;
        EXIT WHEN get_bil%NOTFOUND;
        
    END LOOP;
    
    CLOSE get_bil;
    
    RETURN get_bil;

END get_bill;

FUNCTION get_category(id_cat IN NUMBER)
RETURN VARCHAR2
IS cat_data FacturaProducto%ROWTYPE;

CURSOR get_cat IS 
    SELECT * FROM Categoria WHERE id_cat = id_categoria
    ORDER BY id;
    
BEGIN
    
    OPEN get_cat;
    
    LOOP
    
        FETCH get_cat INTO cat_data;
        EXIT WHEN get_cat%NOTFOUND;
        
    END LOOP;
    
    CLOSE get_cat;
    
    RETURN get_cat;

END get_category;


END PKG_QR;
/
----------------------------Trigger---------------------------------------------

CREATE OR REPLACE TRIGGER actualizacion_producto
    BEFORE UPDATE
    ON Producto
    FOR EACH ROW
    BEGIN
        CASE
            WHEN UPDATING('nombre_producto') THEN
                INSERT INTO Bitacora 
                VALUES (s_bitacora.nextval, SYSDATE, USER, 'nombre_producto');
            WHEN UPDATING('precio_producto') THEN
                INSERT INTO Bitacora 
                VALUES (s_bitacora.nextval, SYSDATE, USER, 'precio_producto');
            WHEN UPDATING('cantidad_inventario') THEN
                INSERT INTO Bitacora 
                VALUES (s_bitacora.nextval, SYSDATE, USER, 'cantidad_inventario');
        END CASE;
END actualizacion_producto;

