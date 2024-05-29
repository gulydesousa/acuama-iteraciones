SELECT * 
--UPDATE D SET otdvValor='NO'
FROM otDatosValor AS D
WHERE otdvOdtCodigo=2001 AND (otdvValor IS NULL OR otdvValor<>'NO')


DECLARE @ReturnValue INT;
DECLARE @odtValor AS VARCHAR(25) = NULL;
DECLARE @ultimoxservicio BIT = NULL;
DECLARE @usuario VARCHAR(10)= 'gmdesousa';

EXEC @ReturnValue = otInspecciones_ActualizarOtDatosValor_Melilla  @usuario ;
SELECT @ReturnValue AS 'Return Value';