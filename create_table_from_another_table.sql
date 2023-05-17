-- Primera forma

-- Crear tabla con pasos
create table emp as
select * from employees;

alter table emp add vacunas number default 0;

select * from emp;

update emp
set vacunas = 2;

update emp 
set vacunas = 4
where employee_id in (105, 123, 147, 200);

-- ver la forma de ejecución de una consulta

-- Consulta no recomendada
explain plan for 
select * from emp
where vacunas <> 2;

select * from table(dbms_xplan.display);


-- consulta recomendada
explain plan for 
select * from emp
where vacunas > 2 or vacunas < 2;

select * from table(dbms_xplan.display);

-- crear índice para la tabla emp
create index emp_vacunas_idx on emp(vacunas);

-- segunda forma 
drop table emp;

-- Una sola sentencia para crear tabla con la columna
create table emp as
select e.*, 0 vacunas from employees e;

-- Ver las columnas de una tabla específica 
SELECT * FROM user_tab_columns WHERE table_name = 'EMP';


(select e.* from employees e where job_id = 'FI_ACCOUNT'
UNION ALL
select e.* from employees e where salary < 7000)
order by employee_id;

insert into admin.temp_notas values('Adrian', 100);
insert into admin.notas values('Adrian', 100);