--**********************************
EXEC sp_rename 'otInspeccionesValidaciones.otivDesc', 'otivClave', 'COLUMN';
EXEC sp_rename 'otInspeccionesValidaciones.otivDescParaCartas', 'otivDescripcion', 'COLUMN';