--DROP TABLE apiTokens
CREATE TABLE apiTokens (
    atokApiNombre VARCHAR(25),
	atokAcuamaUser VARCHAR(10),	
	atokUser VARCHAR(255), 
	--** Encriptar ***
	atokPassword VARCHAR(255), 
    atokAccessToken VARCHAR(255),
	--***************
	atokAccessFecha DATETIME,

    CONSTRAINT FK_apiTokens_Usuarios FOREIGN KEY (atokAcuamaUser) REFERENCES usuarios(usrcod),
    CONSTRAINT FK_apiTokens_Apis FOREIGN KEY (atokApiNombre) REFERENCES apis(apiNombre),
	CONSTRAINT PK_apiTokens PRIMARY KEY (atokApiNombre, atokAcuamaUser, atokUser)
);