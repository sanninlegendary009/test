USE CONTROLPROD;
GO

CREATE TRIGGER DelSeccion ON Produccion
INSTEAD OF DELETE 
AS 
DECLARE @orden AS CHAR(10)
SET @orden =(select Orden from deleted )

ALTER TABLE CodigoSC DISABLE TRIGGER ALL
--Activa todos los trigger de la tabla PRUEBAS
ALTER TABLE CodigoPC DISABLE TRIGGER ALL
ALTER TABLE CodigoSP DISABLE TRIGGER ALL
 ALTER TABLE CodigoPP DISABLE TRIGGER ALL
 ALTER TABLE CodigoS DISABLE TRIGGER ALL
 ALTER TABLE CodigoP DISABLE TRIGGER ALL
 ALTER TABLE Saco DISABLE TRIGGER ALL
 ALTER TABLE Pantalon DISABLE TRIGGER ALL
 DELETE FROM CodigoS WHERE Orden=@orden
 DELETE FROM CodigoP WHERE Orden=@orden
 delete from CORTE WHERE Orden=@orden
delete from Saco where id_s=@orden
delete from Pantalon where id_p=@orden
delete from Manda where id_m=@orden
delete from Maquila where id_m=@orden
delete from CodigoSC where Orden=@orden
delete from CodigoSP where Orden=@orden
delete from CodigoPC where Orden=@orden
delete from CodigoPP where Orden=@orden
delete from CONSACO where Orden=@orden
delete from CONPANT where Orden=@orden
delete from PLANPANT where Orden=@orden
delete from PLANSACO where Orden=@orden
delete from Produccion where Orden=@orden
 ALTER TABLE CodigoS ENABLE TRIGGER ALL
 ALTER TABLE CodigoP ENABLE TRIGGER ALL
ALTER TABLE CodigoSC ENABLE TRIGGER ALL
ALTER TABLE CodigoPC ENABLE TRIGGER ALL
ALTER TABLE CodigoSP ENABLE TRIGGER ALL
 ALTER TABLE CodigoPP ENABLE TRIGGER ALL
 ALTER TABLE Saco ENABLE TRIGGER ALL
 ALTER TABLE Pantalon ENABLE TRIGGER ALL

GO
---------------------------------------------
cREATE TRIGGER DELMAQ ON Maquila
INSTEAD OF DELETE 
AS 
DECLARE @ID AS CHAR(10)
SET @ID=(SELECT id_m FROM deleted)
 DELETE FROM Manda WHERE id_m=@ID
 DELETE FROM Maquila WHERE id_m=@ID
---------------------------------------------
GO

CREATE TRIGGER cREAL ON Produccion
AFTER  UPDATE 
AS
declare @ID CHAR(10)
declare @real INT
declare @lis CHAR(7)

set @ID=(SELECT Orden FROM inserted)
SET @real=(SELECT RalCortado FROM inserted)
SET @lis=(SELECT Aprovacion FROM inserted)

UPDATE Saco
SET RalCortado=@real
WHERE id_s=@ID

UPDATE Pantalon
SET RalCortado=@real
WHERE id_p=@ID

UPDATE Maquila
SET RalCortado=@real
WHERE id_m=@ID

UPDATE CORTE
SET RalCortado=@real, Estado=@lis
WHERE Orden=@ID

UPDATE CONSACO
SET Cantidad=@real
WHERE Orden=@ID

UPDATE CONPANT
SET Cantidad=@real
WHERE Orden=@ID

UPDATE PLANSACO
SET Cantidad=@real
WHERE Orden=@ID

UPDATE PLANPANT
SET Cantidad=@real
WHERE Orden=@ID

---------------------------------------------------
GO
CREATE TRIGGER cFECHA ON Produccion
AFTER  UPDATE 
AS
declare @ID CHAR(10)
declare @INI DATE
declare @COM DATE

set @ID=(SELECT Orden FROM inserted)
SET @INI=(SELECT Inicio FROM inserted)
SET @COM=(SELECT Compromiso FROM inserted)
 
UPDATE CORTE
SET Inicio=@INI , Compromiso=@COM
WHERE Orden=@ID

--UPDATE CONPANT
--SET Inicio=@INI, Entrega=@COM
--WHERE Orden=@ID

--UPDATE CONSACO
--SET Inicio=@INI, Entrega=@COM
--WHERE Orden=@ID

--UPDATE PLANPANT
--SET Inicio=@INI, Entrega=@COM
--WHERE Orden=@ID

--UPDATE PLANSACO
--SET Inicio=@INI, Entrega=@COM
--WHERE Orden=@ID
-------------------------------------------------------
GO
create TRIGGER QUITARSA ON CodigoSC
INSTEAD OF DELETE
AS 
DECLARE @COD char(20)
DECLARE @ORD CHAR(10)
DECLARE @VAL INT
DECLARE @AP CHAR(2)

SET @COD =(select codigos from deleted )
SET @ORD=(select Orden from deleted )
SET @AP=(SELECT Aprobado FROM CONSACO WHERE Orden=@ORD)
UPDATE CodigoS SET ESTADO='Plancha', Movimiento = getdate() WHERE codigos=@COD
delete from CodigoSC where codigos=@COD
SET @VAL=(SELECT COUNT(@COD) FROM CodigoSC WHERE Orden=@ORD)
UPDATE Saco SET Producido=@VAL WHERE id_s=@ORD

IF (@VAL = 0 AND @AP= 'SI')
BEGIN
UPDATE Saco SET Proceso='RevisióTerminada' WHERE id_s=@ORD 
DELETE FROM CONSACO WHERE Orden=@ORD
END

IF (@VAL = 0 AND @AP = 'NO' )
begin
UPDATE Saco SET Proceso='Revisión/Compostura' WHERE id_s=@ORD 
end

GO 
CREATE TRIGGER UPCOMP ON CONSACO
AFTER UPDATE
AS 
DECLARE @ORD CHAR(10)
DECLARE @COMP INT

SET @ORD=(SELECT Orden FROM inserted)
SET @COMP=(SELECT Compostura FROM inserted)

IF (@COMP =0 )
BEGIN
UPDATE CONSACO SET Aprobado='SI' WHERE Orden=@ORD
END

GO

create TRIGGER ADCOMPSACO ON COMPSACO
AFTER INSERT 
AS 
DECLARE @COD AS CHAR(20)
DECLARE @ORD AS CHAR(10)
SET @COD =(SELECT Codigo from inserted)
SET @ORD=(SELECT Orden From inserted)
UPDATE CodigoS SET ESTADO ='Comp-Conf'	WHERE codigos=@COD
UPDATE CONSACO SET Compostura=(select Compostura from CONSACO where Orden=@ORD)+1 WHERE Orden=@ORD
UPDATE CONSACO SET Aprobado='NO' WHERE Orden=@ORD
GO

CREATE TRIGGER DESCOMPSACO ON COMPSACO
INSTEAD OF DELETE 
AS 
DECLARE @ORD AS CHAR(10)
DECLARE @COD AS CHAR(20)
SET @ORD=(SELECT Orden From deleted)
SET @COD=(SELECT Codigo FROM deleted)
UPDATE CodigoS SET ESTADO ='Confección'	WHERE codigos=@COD
UPDATE CONSACO SET Compostura=(select Compostura from CONSACO where Orden=@ORD)-1 WHERE Orden=@ORD
BEGIN
INSERT INTO CodigoSC (codigos, Orden) VALUES(@COD, @ORD)
END
DELETE FROM COMPSACO WHERE Codigo=@COD
--------------------------------------------------------------
GO

CREATE TRIGGER QUITARPA ON CodigoPC
INSTEAD OF DELETE
AS 
DECLARE @COD char(20)
DECLARE @ORD CHAR(10)
DECLARE @VAL INT
DECLARE @AP CHAR(2)

SET @COD =(select codigos from deleted )
SET @ORD=(select Orden from deleted )
SET @AP=(SELECT  Aprobado FROM CONPANT WHERE Orden=@ORD )
UPDATE CodigoP SET ESTADO='Plancha', Movimiento = GETDATE() WHERE codigos=@COD
delete from CodigoPC where codigos=@COD
SET @VAL=(SELECT COUNT(@COD) FROM CodigoPC WHERE Orden=@ORD)
UPDATE Pantalon SET Producido=@VAL WHERE id_p=@ORD

IF (@VAL =0 AND @AP= 'SI')
begin
UPDATE Pantalon SET Proceso='RevisiónTerminada' WHERE id_p=@ORD
DELETE FROM CONPANT WHERE Orden=@ORD
end

IF (@VAL = 0 AND @AP = 'NO' )
begin
UPDATE Pantalon SET Proceso='Revisión/Compostura' WHERE id_p=@ORD 
end
---------------------------------------------------------------
GO

CREATE TRIGGER UPCOMP2 ON CONPANT
AFTER UPDATE
AS 
DECLARE @ORD CHAR(10)
DECLARE @COMP INT

SET @ORD=(SELECT Orden FROM inserted)
SET @COMP=(SELECT Compostura FROM inserted)

IF (@COMP =0 )
BEGIN
UPDATE CONPANT SET Aprobado='SI' WHERE Orden=@ORD
END

GO

create TRIGGER ADCOMPPANT ON COMPPANT
AFTER INSERT 
AS 
DECLARE @CODS AS CHAR(20)
DECLARE @ORD AS CHAR(10)
set @CODS =(SELECT Codigo FROM inserted)
SET @ORD=(SELECT Orden From inserted)

UPDATE CONPANT SET Compostura=(select Compostura from CONPANT where Orden=@ORD)+1 WHERE Orden=@ORD
UPDATE CONPANT SET Aprobado='NO' WHERE Orden=@ORD
UPDATE CodigoP SET ESTADO ='Comp-Conf'	WHERE codigos=@CODS
GO

CREATE TRIGGER DESCOMPPANT ON COMPPANT
INSTEAD OF DELETE 
AS 
DECLARE @ORD AS CHAR(10)
DECLARE @COD AS CHAR(20)
SET @ORD=(SELECT Orden From deleted)
SET @COD=(SELECT Codigo FROM deleted)
UPDATE CONPANT SET Compostura=(select Compostura from CONPANT where Orden=@ORD)-1 WHERE Orden=@ORD
UPDATE CodigoP SET ESTADO ='Confección'	WHERE codigos=@COD
BEGIN
INSERT INTO CodigoPC (codigos, Orden) VALUES(@COD, @ORD)
END
DELETE FROM COMPPANT WHERE Codigo=@COD
-------------------------------------------------------
GO
CREATE TRIGGER QUITARSP ON CodigoSP
INSTEAD OF DELETE
AS 
DECLARE @COD char(20)
DECLARE @ORD CHAR(10)
DECLARE @VAL INT
DECLARE @AP CHAR(2)

SET @COD =(select codigos from deleted )
SET @ORD=(select Orden from deleted )
SET @AP=(SELECT Aprobado FROM PLANSACO WHERE Orden=@ORD)
UPDATE CodigoS SET ESTADO ='Almacen', Movimiento = GETDATE() WHERE codigos=@COD
delete from CodigoSP where codigos=@COD
SET @VAL=(SELECT COUNT(@COD) FROM CodigoSP WHERE Orden=@ORD)

IF (@VAL = 0 AND @AP = 'NO' )
begin
UPDATE Saco SET Proceso='Revisión/Compostura' WHERE id_s=@ORD 
end

IF (@VAL =0 AND  @AP= 'SI')
begin
UPDATE Saco SET Proceso='ALMACEN', Observaciones='ORDEN SACO TERMINADA EN PLANCHA' WHERE id_s=@ORD
UPDATE Produccion SET Asignado = 'CERRAR' WHERE Orden=@ORD
DELETE FROM PLANSACO WHERE Orden=@ORD
end

GO

CREATE TRIGGER UPCOMP11 ON PLANSACO
AFTER UPDATE
AS 
DECLARE @ORD CHAR(10)
DECLARE @COMP INT

SET @ORD=(SELECT Orden FROM inserted)
SET @COMP=(SELECT Compostura FROM inserted)

IF (@COMP =0 )
BEGIN
UPDATE PLANSACO SET Aprobado='SI' WHERE Orden=@ORD
END

GO

CREATE TRIGGER ADCOMPSACOPLAN ON COMPSACOPLAN
AFTER INSERT 
AS 
DECLARE @COD AS CHAR(20)
DECLARE @ORD AS CHAR(20)
SET @COD =(SELECT Codigo FROM inserted)
SET @ORD=(SELECT Orden From inserted)
UPDATE CodigoS SET ESTADO ='Comp-Plan'	WHERE codigos=@COD
UPDATE PLANSACO SET Compostura=(select Compostura from PLANSACO where Orden=@ORD)+1 WHERE Orden=@ORD
UPDATE PLANSACO SET Aprobado='NO' WHERE Orden=@ORD

GO
CREATE TRIGGER DESCOMPSACOPLAN ON COMPSACOPLAN
INSTEAD OF DELETE 
AS 
DECLARE @ORD AS CHAR(10)
DECLARE @COD AS CHAR(20)
SET @ORD=(SELECT Orden From deleted)
SET @COD=(SELECT Codigo FROM deleted)
UPDATE CodigoS SET ESTADO ='Plancha' WHERE codigos=@COD
UPDATE PLANSACO SET Compostura=(select Compostura from PLANSACO where Orden=@ORD)-1 WHERE Orden=@ORD
BEGIN
INSERT INTO CodigoSP (codigos, Orden) VALUES(@COD, @ORD)
END
DELETE FROM COMPSACOPLAN WHERE Codigo=@COD
---------------------------------------------------------
GO
CREATE TRIGGER QUITARPP ON CodigoPP
INSTEAD OF DELETE
AS 
DECLARE @COD char(20)
DECLARE @ORD CHAR(10)
DECLARE @VAL INT
DECLARE @AP CHAR(2)

SET @COD =(select codigos from deleted )
SET @ORD=(select Orden from deleted )
SET @AP=(SELECT Aprobado FROM PLANPANT WHERE Orden=@ORD)
UPDATE CodigoP SET ESTADO ='Almacen', Movimiento = GETDATE() WHERE codigos=@COD
delete from CodigoPP where codigos=@COD
SET @VAL=(SELECT COUNT(@COD) FROM CodigoPP WHERE Orden=@ORD)

IF (@VAL =0 AND @AP= 'SI')
begin
UPDATE Pantalon SET Proceso='ALMACEN', Observaciones='ORDEN PANTALON TERMINADA EN PLANCHA' WHERE id_p=@ORD
UPDATE Produccion SET Asignado = 'CERRAR' WHERE Orden=@ORD
DELETE FROM PLANPANT WHERE Orden=@ORD
end

IF (@VAL=0 AND @AP= 'NO')
BEGIN
UPDATE Pantalon SET Proceso='Revisión/Compostura' WHERE id_p=@ORD
END

GO
CREATE TRIGGER UPCOMP22 ON PLANPANT
AFTER UPDATE
AS 
DECLARE @ORD CHAR(10)
DECLARE @COMP INT

SET @ORD=(SELECT Orden FROM inserted)
SET @COMP=(SELECT Compostura FROM inserted)

IF (@COMP =0 )
BEGIN
UPDATE PLANPANT SET Aprobado='SI' WHERE Orden=@ORD
END

GO

create TRIGGER ADCOMPPANTPLAN ON COMPPANTPLAN
AFTER INSERT 
AS 
DECLARE @COD AS CHAR(20)
DECLARE @ORD AS CHAR(10)
SET @COD=(SELECT Codigo FROM inserted)
SET @ORD=(SELECT Orden From inserted)
UPDATE CodigoP SET ESTADO ='Comp-Plan'	WHERE codigos=@COD
UPDATE PLANPANT SET Compostura=(select Compostura from PLANPANT where Orden=@ORD)+1 WHERE Orden=@ORD
UPDATE PLANPANT SET Aprobado='NO' WHERE Orden=@ORD
GO

create TRIGGER DESCOMPPANTPLAN ON COMPPANTPLAN
INSTEAD OF DELETE 
AS 
DECLARE @ORD AS CHAR(10)
DECLARE @COD AS CHAR(20)
SET @ORD=(SELECT Orden From deleted)
SET @COD=(SELECT Codigo FROM deleted)
UPDATE CodigoP SET ESTADO ='Plancha'	WHERE codigos=@COD
UPDATE PLANPANT SET Compostura=(select Compostura from PLANPANT where Orden=@ORD)-1 WHERE Orden=@ORD
BEGIN
INSERT INTO CodigoPP (codigos, Orden) VALUES(@COD, @ORD)
END
DELETE FROM COMPPANTPLAN WHERE Codigo=@COD

GO 
-------------------------------------------------------
CREATE TRIGGER ANEXARCODS ON CodigoS
AFTER INSERT 
AS 
DECLARE @COD CHAR(20)
DECLARE @ORD CHAR(10)

SET @COD =(SELECT codigos FROM inserted)
SET @ORD =(SELECT Orden FROM inserted)

BEGIN 
INSERT INTO CodigoSC (codigos, Orden) VALUES(@COD, @ORD)
INSERT INTO CodigoSP (codigos, Orden) VALUES(@COD, @ORD)
END
--------------------------------------------------------
GO
CREATE TRIGGER ANEXARCODP ON CodigoP
AFTER INSERT 
AS 
DECLARE @COD CHAR(20)
DECLARE @ORD CHAR(10)

SET @COD =(SELECT codigos FROM inserted)
SET @ORD =(SELECT Orden FROM inserted)

BEGIN 
INSERT INTO CodigoPC (codigos, Orden) VALUES(@COD, @ORD)
INSERT INTO CodigoPP (codigos, Orden) VALUES(@COD, @ORD)
END
---------------------------------------------------------
GO
CREATE TRIGGER DCONSACO ON CONSACO
INSTEAD OF DELETE 
AS 
DECLARE @ORD AS CHAR(20)

SET @ORD = (SELECT Orden FROM deleted)

ALTER TABLE CodigoSC DISABLE TRIGGER all
DELETE FROM CodigoSC WHERE Orden=@ORD
DELETE FROM CONSACO WHERE Orden=@ORD
ALTER TABLE CodigoSC ENABLE TRIGGER ALL
--------------------------------------------------------
GO

CREATE TRIGGER DCONPANT ON CONPANT
INSTEAD OF DELETE 
AS 
DECLARE @ORD AS CHAR(20)

SET @ORD=(SELECT Orden FROM deleted)
ALTER TABLE CodigoPC DISABLE TRIGGER ALL
DELETE FROM CodigoPC WHERE Orden=@ORD
DELETE FROM CONPANT WHERE Orden=@ORD
ALTER TABLE CodigoPC ENABLE TRIGGER ALL
----------------------------------------------------------------
GO 

CREATE TRIGGER DPLANTPAN ON PLANPANT
INSTEAD OF DELETE 
AS 
DECLARE @ORD AS CHAR(20)

SET @ORD=(SELECT Orden FROM deleted)
ALTER TABLE CodigoPP DISABLE TRIGGER ALL
DELETE FROM CodigoPP WHERE Orden=@ORD
DELETE FROM PLANPANT WHERE Orden=@ORD
ALTER TABLE CodigoPP ENABLE TRIGGER ALL
-------------------------------------------------
GO
CREATE TRIGGER DPLANSACO ON PLANSACO
INSTEAD OF DELETE 
AS 
DECLARE @ORD AS CHAR(20)

SET @ORD=(SELECT Orden FROM deleted)
ALTER TABLE CodigoSP DISABLE TRIGGER ALL
DELETE FROM CodigoSP WHERE Orden=@ORD
DELETE FROM PLANSACO WHERE Orden=@ORD
ALTER TABLE CodigoSP ENABLE TRIGGER ALL

GO 

CREATE TRIGGER BORRARCODP ON CodigoP
INSTEAD OF DELETE
AS
DECLARE @cod AS CHAR(20)

SET @cod=(SELECT codigos FROM deleted)
ALTER TABLE CodigoPP DISABLE TRIGGER ALL
ALTER TABLE CodigoPC DISABLE TRIGGER ALL

DELETE FROM CodigoP WHERE codigos=@cod
DELETE FROM CodigoPC WHERE codigos=@cod
DELETE FROM CodigoPP WHERE codigos=@cod

ALTER TABLE CodigoPP ENABLE TRIGGER ALL
ALTER TABLE CodigoPC ENABLE TRIGGER ALL

GO

CREATE TRIGGER BORRARCODS ON CodigoS
INSTEAD OF DELETE
AS
DECLARE @cod AS CHAR(20)

SET @cod=(SELECT codigos FROM deleted)

ALTER TABLE CodigoSP DISABLE TRIGGER ALL
ALTER TABLE CodigoSC DISABLE TRIGGER ALL

DELETE FROM CodigoS WHERE codigos=@cod
DELETE FROM CodigoSC WHERE codigos=@cod
DELETE FROM CodigoSP WHERE codigos=@cod


ALTER TABLE CodigoSP ENABLE TRIGGER ALL
ALTER TABLE CodigoSC ENABLE TRIGGER ALL

GO

CREATE TRIGGER LISTO ON CORTE
AFTER INSERT
AS 
DECLARE @ORD AS CHAR(10)

SET @ORD=(SELECT Orden FROM inserted)
 
UPDATE Produccion
SET Asignado='CORTE' WHERE Orden=@ORD

GO
CREATE TRIGGER LISTOM ON Maquila
AFTER INSERT
AS 
DECLARE @ORD AS CHAR(10)

SET @ORD=(SELECT id_m FROM inserted)
 
UPDATE Produccion
SET Asignado='MAQUILA' WHERE Orden=@ORD

GO 
CREATE TRIGGER LISTOS ON Saco
AFTER INSERT
AS 
DECLARE @ORD AS CHAR(10)
SET @ORD=(SELECT id_s FROM inserted)
UPDATE Produccion
SET Asignado='PROCESO' WHERE Orden=@ORD

GO

CREATE TRIGGER LISTOPa ON Pantalon
AFTER INSERT
AS 
DECLARE @ORD AS CHAR(10)
SET @ORD=(SELECT id_p FROM inserted)
UPDATE Produccion
SET Asignado='PROCESO' WHERE Orden=@ORD

