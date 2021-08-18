
/*select ID_FAMILIA, sum(valor) from GASTOS G, ADMINISTRADOR A where G.USUARIO_ADMIN = A.USUARIO
group by ID_FAMILIA;*/

/*Trigger que sirve para actualizar el total de gastos y la correspondiente categoria en la tabla Historial Finanzas
al momento que se ingresa un nuevo registro en la tabla Gastos, si el dato no existe en la tabla HF lo crea*/

delimiter ||
create trigger historial after insert on GASTOS for each row
Begin

set @familia = (select ID_FAMILIA from ADMINISTRADOR A where A.USUARIO = new.USUARIO_ADMIN limit 1);

set @mes =(select MES from HISTORIALFINANZAS where MES = month(new.FECHA_EMISION) and ID_FAMILIA = @famila);
set @anio =(select AÑO from HISTORIALFINANZAS where AÑO = year(new.FECHA_EMISION) and MES = @mes and ID_FAMILIA = @famila);


if(@mes is null or @anio is null) then 
	insert into HISTORIALFINANZAS(MES, AÑO, TOTAL_GASTOS, ID_FAMILIA) 
	values(month(new.FECHA_EMISION),year(new.FECHA_EMISION),new.VALOR, @familia);
	call categoria_alimentacion(new.ID_CATEGORIA, new.VALOR,month(new.FECHA_EMISION),year(new.FECHA_EMISION), @familia);
else
	update HISTORIALFINANZAS set TOTAL_GASTOS = TOTAL_GASTOS + NEW.VALOR where MES=@mes and AÑO = @anio and ID_FAMILIA=@familia;
	call categoria_alimentacion(new.ID_CATEGORIA, new.VALOR,month(new.FECHA_EMISION),year(new.FECHA_EMISION), @familia);
end if;
end ||
delimiter ;

/*Trigger que actualiza el total de Ingresos de la tabla Historial Finanzas al momento que se crea un nuevo ingreso
si el dato no existe en la tabla HF lo crea */
create trigger HISTORIAL_INGRESOS after insert on INGRESOS for each row
Begin
delimiter ||
set @familia = (select ID_FAMILIA from ADMINISTRADOR A where A.USUARIO = new.USUARIO_ADMIN limit 1);

set @mes =(select MES from HISTORIALFINANZAS where MES = month(new.FECHA_EMISION) and ID_FAMILIA = @famila);
set @anio =(select AÑO from HISTORIALFINANZAS where AÑO = year(new.FECHA_EMISION) and MES = @mes and ID_FAMILIA = @famila);
set @valor = (select VALOR from USUARIOS USU where USU.USUARIO = new.USUARIO AND USU.FAMILIA = @familia);


if(@mes is null or @anio is null) then 
	insert into HISTORIALFINANZAS(MES, AÑO, TOTAL_INGRESOS, ID_FAMILIA) 
	values(month(new.FECHA_INGRESO),year(new.FECHA_INGRESO),@valor, @familia);
else
	update HISTORIALFINANZAS set TOTAL_INGRESOS = TOTAL_INGRESOS + @valor 
    where MES=@mes and AÑO = @anio and ID_FAMILIA=@familia;
end if;
end ||
delimiter ;

