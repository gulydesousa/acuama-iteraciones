CREATE TABLE apiEndPoints (
    aepApiNombre VARCHAR(25),
	aepTipo VARCHAR(10),	
	aepUrl VARCHAR(250)
    CONSTRAINT FK_apiEndPoints_Apis FOREIGN KEY (aepApiNombre) REFERENCES apis(apiNombre),
	CONSTRAINT PK_apiEndPoints PRIMARY KEY (aepApiNombre, aepTipo)
);