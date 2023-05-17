-------------CREACIÓN DE TABLAS CON SUS LLAVES PRIMARIAS------------------------

CREATE TABLE HOSPITAL
(
ID INTEGER CONSTRAINT ID_HOS_NN NOT NULL,
NOMBRE VARCHAR(30) CONSTRAINT NOMBRE_HOS_NN NOT NULL,
PROVINCIA VARCHAR(10) CONSTRAINT PROVINCIA_NN NOT NULL, 
CONSTRAINT PK_HOSPITAL PRIMARY KEY(ID)
);

CREATE TABLE MEDICO
(
ID INTEGER CONSTRAINT ID_MED_NN NOT NULL,
CEDULA CHAR(11) CONSTRAINT CEDULA_NN NOT NULL,
NOMBRE VARCHAR(15) CONSTRAINT NOMBRE_MED_NN NOT NULL,
PRIMER_APELLIDO VARCHAR(15) CONSTRAINT PRIMER_APELLIDO_NN NOT NULL,
DIRECCION_PROVINCIA VARCHAR(10) CONSTRAINT DIRECCION_PROVINCIA_NN NOT NULL,
CONSTRAINT PK_MEDICO PRIMARY KEY(ID)
);

CREATE TABLE ESPECIALIDAD(
ID INTEGER CONSTRAINT ID_ESP_NN NOT NULL,
NOMBRE VARCHAR(15) CONSTRAINT NOMBRE_ESP_NN NOT NULL,
CONSTRAINT PK_ESPECIALIDAD PRIMARY KEY(ID)
);

CREATE TABLE MEDICO_HOSPITAL
(
MEDICO_ID INTEGER CONSTRAINT MH_ID_MED_NN NOT NULL,
HOSPITAL_ID INTEGER CONSTRAINT MH_ID_HOS_NN NOT NULL,
CONSTRAINT PK_MEDICO_HOSPITAL PRIMARY KEY(MEDICO_ID, HOSPITAL_ID)
);

CREATE TABLE MEDICO_ESPECIALIDAD
(
MEDICO_ID INTEGER CONSTRAINT ME_ID_MED_NN NOT NULL,
ESPECIALIDAD_ID INTEGER CONSTRAINT ME_ID_HOS_NN NOT NULL,
CONSTRAINT PK_MEDICO_ESPECIALIDAD PRIMARY KEY(MEDICO_ID, ESPECIALIDAD_ID)
);



-------------LLAVES FORÁNEAS----------------------------------------------------

ALTER TABLE MEDICO_HOSPITAL
ADD CONSTRAINT FK_MH_MED_ID FOREIGN KEY
(MEDICO_ID) REFERENCES MEDICO(ID);

ALTER TABLE MEDICO_HOSPITAL
ADD CONSTRAINT FK_MH_HOS_ID FOREIGN KEY
(HOSPITAL_ID) REFERENCES HOSPITAL(ID);

ALTER TABLE MEDICO_ESPECIALIDAD
ADD CONSTRAINT FK_ME_MED_ID FOREIGN KEY
(MEDICO_ID) REFERENCES MEDICO(ID);

ALTER TABLE MEDICO_ESPECIALIDAD
ADD CONSTRAINT FK_ME_ESP_ID FOREIGN KEY
(ESPECIALIDAD_ID) REFERENCES ESPECIALIDAD(ID);

---------------SECUENCIAS-------------------------------------------------------

CREATE SEQUENCE s_hospital
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 10000000
NO CYCLE;

CREATE SEQUENCE s_medico
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 10000000
NO CYCLE;

CREATE SEQUENCE s_especialidad
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 10000000
NO CYCLE;

--------INSERCIÓN DE DATOS------------------------------------------------------

INSERT INTO HOSPITAL VALUES
(nextval('s_hospital'), 'Hospital Max Peralta', 'Cartago');

INSERT INTO HOSPITAL VALUES
(nextval('s_hospital'), 'Hospital San Rafael', 'Alajuela');

INSERT INTO HOSPITAL VALUES
(nextval('s_hospital'), 'Hospital San Vicente de Paul', 'Heredia');

INSERT INTO MEDICO VALUES
(nextval('s_medico'), '4-0071-0076', 'Gloria', 'Morales', 'Alajuela');

INSERT INTO MEDICO VALUES
(nextval('s_medico'), '1-0651-0656', 'Andrea', 'Porras', 'Heredia');

INSERT INTO MEDICO VALUES
(nextval('s_medico'), '4-9876-6535', 'Aurelio', 'Sanabria', 'Alajuela');

INSERT INTO MEDICO VALUES
(nextval('s_medico'), '3-7879-8765', 'Jaime', 'Vargas', 'Cartago');

INSERT INTO ESPECIALIDAD VALUES
(nextval('s_especialidad'), 'Cardiologo');

INSERT INTO ESPECIALIDAD VALUES
(nextval('s_especialidad'), 'Alergologo');

INSERT INTO ESPECIALIDAD VALUES
(nextval('s_especialidad'), 'Pediatra');

INSERT INTO ESPECIALIDAD VALUES
(nextval('s_especialidad'), 'Nutricionista');

INSERT INTO MEDICO_HOSPITAL VALUES
(1, 2);

INSERT INTO MEDICO_HOSPITAL VALUES
(1, 3);

INSERT INTO MEDICO_HOSPITAL VALUES
(4, 3);

INSERT INTO MEDICO_ESPECIALIDAD VALUES
(1, 1);

INSERT INTO MEDICO_ESPECIALIDAD VALUES
(1, 2);

INSERT INTO MEDICO_ESPECIALIDAD VALUES
(2, 3);

INSERT INTO MEDICO_ESPECIALIDAD VALUES
(2, 4);

INSERT INTO MEDICO_ESPECIALIDAD VALUES
(3, 4);

INSERT INTO MEDICO_ESPECIALIDAD VALUES
(4, 4);

-------------------función-----------------------

CREATE OR REPLACE FUNCTION lista_especialidades (v_cedula TEXT)
    RETURNS VARCHAR AS $$
    DECLARE
    arow record;
    v_id INTEGER;
    v_nombres TEXT;
BEGIN
    SELECT id INTO v_id
    FROM medico
    WHERE cedula = v_cedula;  --acá ya tengo el id del médico
    for arow in(SELECT E.nombre 
    into v_nombres
        FROM ESPECIALIDAD E
        INNER JOIN MEDICO_ESPECIALIDAD ME
        ON E.ID = ME.ESPECIALIDAD_ID
        WHERE MEDICO_ID = v_id 
        ORDER BY E.NOMBRE ASC)
        loop
        v_nombres:=v_nombres||arow.nombre||',';
        end loop;
        v_nombres:=rtrim(v_nombres, ',');
       -- dbms_output.put_line (v_nombres);--
    return v_nombres;
END;
$$ LANGUAGE plpgsql;

-----------------pruebaFunción-------------------

select lista_especialidades('4-0071-0076');

-------------- Ejercicio 4 ------------------

-- Ejercicio 4 Procesamiento de la tabla Temporal para una base de datos PostgreSQL

-- Función para verificar si la especialidad dentro de la relación Temporal existe dentro de la base de 
-- datos o se debe crear
CREATE OR REPLACE FUNCTION 
    verificar_especialidad (nombre_especialidad TEXT)
    RETURNS INTEGER AS $$
        -- Espacio de declaración de variables
        DECLARE 
            is_found BOOLEAN := FALSE;
            espec_id INTEGER;
            -- Cursor para extraer el id de la especialidad que se pasa por parámetro
            c_espec_cursor CURSOR (v_nombre TEXT) FOR 
                SELECT id
                FROM especialidad
                WHERE nombre = v_nombre; 
        BEGIN
            -- Verificamos si el cursor encuentra alguna especialidad que ya este dentro de la tabla Especialidad 
            FOR result_espec IN c_espec_cursor (nombre_especialidad) loop
                is_found := TRUE;
                espec_id := result_espec.id;
            end loop;

            -- Si se encuentra un registro ya existente entonces se retorna el id correspondiente
            IF is_found THEN
                RETURN espec_id;
            ELSE 
                -- En caso de no encontrar un registro existente entonces lo procede a crear
                INSERT INTO especialidad
                VALUES (nextval('s_especialidad'), nombre_especialidad);
                -- Obtenemos el id generado automáticamente usando el cursor y luego lo retornamos 
                OPEN c_espec_cursor (nombre_especialidad);
                FETCH c_espec_cursor INTO espec_id;
                CLOSE c_espec_cursor;
                RETURN espec_id;
            END IF;
        END;
    $$ LANGUAGE plpgsql;

-- Procedimiento almacenado para el procesamiento de la relación Temporal
CREATE OR REPLACE PROCEDURE procesa_medico()
    LANGUAGE plpgsql
    AS $$
        DECLARE
            -- Espacio para declarar variables 
            m_especialidades TEXT;
            m_espec TEXT;
            m_hospitales TEXT;
            m_hosp TEXT;
            v_medico_id INTEGER;
            v_espec_id INTEGER;
            v_hospital_id INTEGER;
            -- Variable cursor para extraer todos los datos de la tabla Temporal
            c_temporal_cursor CURSOR FOR SELECT * FROM temporal;
        
        BEGIN
            -- Recorremos todos los registros dentro de la relación Temporal
            FOR temporalRecord IN c_temporal_cursor LOOP
                -- Para cada medico en la relación, lo insertamos en la tabla Medico
                INSERT INTO medico 
                VALUES (nextval('s_medico'), temporalRecord.medico_cedula, 
                        temporalRecord.medico_nombre, 
                        temporalRecord.medico_apellido, temporalRecord.medico_provincia);
                -- Ahora obtenemos el id autogenerado del médico que acaba de ser insertado
                SELECT id INTO v_medico_id FROM medico WHERE cedula = temporalRecord.medico_cedula;
                
                -- Tomamos todas las especialidades relacionadas al médico
                m_especialidades := trim(temporalRecord.especialidades);
                
                -- Realizamos un loop de todas las especialidades dentro de la tabla para generar las relaciones necesarias
                IF length(m_especialidades) > 0 THEN
                    LOOP
                        IF POSITION(',' IN m_especialidades) > 0 THEN
                            -- seleccionar la primer especialidad
                            m_espec := SUBSTRING(m_especialidades, 1, POSITION(',' IN m_especialidades) - 1);
                            -- remover la primer especialidad
                            m_especialidades := trim(SUBSTRING(m_especialidades, POSITION(',' IN m_especialidades) + 1));
                        ELSE
                            m_espec := m_especialidades;
                            m_especialidades := '';
                        END IF;
                        -- verificar si la especialidad existe en la BD, si no la inserta y devuelve el valor del id generado
                        v_espec_id := verificar_especialidad(m_espec);
                        
                        -- Crear la relación entre el medico y la especialidad
                        INSERT INTO medico_especialidad (medico_id, especialidad_id)
                        VALUES (v_medico_id, v_espec_id);

                    EXIT WHEN m_especialidades IS NULL;
                    END LOOP;
                END IF;

                m_hospitales := trim(temporalRecord.hospitales);
                --Realizamos un loop para todos los hospitales dentro de la tabla
                IF length(m_hospitales) > 0 THEN
                    LOOP
                        IF POSITION(',' IN m_hospitales) > 0 THEN
                            --seleccionar el primer hospital
                            m_hosp := SUBSTRING(m_hospitales, 1, POSITION(',' IN m_hospitales) - 1);
                            --quitamos el primer hospital
                            m_hosp := trim(SUBSTRING(m_hospitales, POSITION(',' IN m_hospitales) + 1));
                        ELSE
                            m_hosp := m_hospitales;
                            m_hospitales := '';
                        END IF;
                        
                        -- Tomamos el id del hospital al que el medico trabaja
                        SELECT id INTO v_hospital_id FROM hospital WHERE nombre = m_hosp;
                        
                        -- creamos la relación entre el médico y el hospital
                        INSERT INTO medico_hospital (medico_id, hospital_id) 
                        VALUES (v_medico_id, v_hospital_id);
                    
                    EXIT WHEN m_hospitales IS NULL;
                    END LOOP;
                END IF;
            END LOOP;
        END;
    $$;

-- creación de la relación Temporal con datos de prueba para la función y el procedimiento creado   
                
CREATE TABLE temporal (
    medico_cedula TEXT,
    medico_nombre TEXT,
    medico_apellido TEXT,
    medico_provincia TEXT,
    especialidades TEXT,
    hospitales TEXT
);

INSERT INTO temporal VALUES('3-0098-8768', 'Marta', 'Morales', 'Cartago', 
                    'Alergologo, Pediatra, Nutricionista, Odontologo',
                    'Hospital Max Peralta');
INSERT INTO temporal VALUES('2-0876-4527', 'Flor', 'Flores', 'Heredia', 
                    'Nutricionista, Cardiologo, Medico General',
                    'Hospital San Vicente de Paul');
INSERT INTO temporal VALUES('1-9976-0442', 'Kevin', 'Moraga', 'Alajuela', 
                    'Cardiologo, Pediatra, Hepatologo',
                    'Hospital San Rafael');          
                

-- Ejecución del procedimiento almacenado
CALL procesa_medico();