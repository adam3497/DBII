-- spec del paquete, es como los headers de las funciones y procedimientos
create or replace package mensajes_pkg as
    procedure saluda;
    function sumar(valor1 in number, valor2 in number) return number;
end mensajes_pkg;
/

-- body del package, acá se coloca toda la funcionalidad de las funciones y procedimientos
create or replace package body mensajes_pkg as
    procedure saluda
    as 
    begin
        dbms_output.put_line('Hola mundo');
    end;
    
    function sumar(valor1 in number, valor2 in number) return number as
    begin
        return valor1 + valor2;
    end;
end mensajes_pkg;
/

set SERVEROUTPUT on;
exec mensajes_pkg.saluda;
select mensajes_pkg.sumar(5,3) Suma from dual;