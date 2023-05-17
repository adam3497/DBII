-- Transaccional
CREATE TABLE clientes (
id_cliente NUMBER(10) PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
direccion VARCHAR2(100),
telefono VARCHAR2(20)
);

CREATE TABLE productos (
id_producto NUMBER(10) PRIMARY KEY,
nombre VARCHAR2(50) NOT NULL,
categoria VARCHAR2(50) NOT NULL,
precio NUMBER(10, 2) NOT NULL
);

CREATE TABLE ventas (
venta_id NUMBER(10) PRIMARY KEY,
cliente_id NUMBER(10),
fecha_venta DATE,
total_venta NUMBER(10,2),
descuento NUMBER(5,2)
);

CREATE TABLE detalle_venta (
id_venta NUMBER(3),
id_producto NUMBER(3),
cantidad NUMBER(3),
CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_producto),
CONSTRAINT fk_venta FOREIGN KEY (id_venta) REFERENCES ventas (venta_id),
CONSTRAINT fk_producto FOREIGN KEY (id_producto) REFERENCES productos (id_producto)
);

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- BI
-- Tabla de hechos
CREATE TABLE hechos_ventas (
fecha_venta DATE REFERENCES dim_fecha(fecha),
cliente_id NUMBER(10) REFERENCES dim_cliente(id_cliente),
total_venta NUMBER(10,2),
descuento NUMBER(5,2),
cantidad_ventas NUMBER(10),
cantidad_productos_vendidos NUMBER(10)
);

-- Tabla de dimensiones
CREATE TABLE dim_clientes (
id_cliente NUMBER(10) PRIMARY KEY,
nombre_cliente VARCHAR2(50) NOT NULL,
direccion_cliente VARCHAR2(100) NOT NULL,
telefono_cliente VARCHAR2(20) NOT NULL,
email_cliente VARCHAR2(50) NOT NULL
);

-- Tabla de productos
CREATE TABLE dim_productos (
id_producto NUMBER(10) PRIMARY KEY,
nombre_producto VARCHAR2(50) NOT NULL,
descripcion_producto VARCHAR2(100) NOT NULL,
categoria_producto VARCHAR2(20) NOT NULL,
precio_unitario NUMBER(10,2) NOT NULL
);

-- Tabla de dimensiones de tiempo
CREATE TABLE dimension_tiempo (
    id_tiempo NUMBER(10) PRIMARY KEY,
    fecha DATE NOT NULL,
    dia NUMBER(2) NOT NULL,
    mes NUMBER(2) NOT NULL,
    anio NUMBER(4) NOT NULL,
    trimestre NUMBER(2) NOT NULL,
    semestre NUMBER(2) NOT NULL,
    nombre_mes VARCHAR2(20) NOT NULL,
    nombre_trimestre VARCHAR2(20) NOT NULL,
    nombre_semestre VARCHAR2(20) NOT NULL
);