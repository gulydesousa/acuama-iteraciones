--DROP TABLE apis
CREATE TABLE apis (
    apiNombre VARCHAR(25),
    apiURL VARCHAR(255),
    apiDescripcion TEXT,
    apiAuthenticationMethod VARCHAR(255),
    apiAuthenticationDetails TEXT,
	apiClientId VARCHAR(250),
	apiTokenExpireMinutes INT,
	CONSTRAINT PK_APIs PRIMARY KEY (apiNombre)
);
