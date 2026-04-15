CREATE TABLE artistas (
    a_id INTEGER,
    nombre VARCHAR(100)
);

CREATE TABLE productoras (
    pro_id INTEGER,
    nombre VARCHAR(100)
);

CREATE TABLE cd (
    artista INTEGER,
    cd_id INTEGER,
    title VARCHAR(100),
    price NUMERIC(5,2),
    year INTEGER,
    productora INTEGER
);

CREATE TABLE track (
    cd_id INTEGER,
    num INTEGER,
    title VARCHAR(150),
    time INTEGER,
    a_id INTEGER
);


