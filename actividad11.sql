-- Actividad 11
-- Tablas: Productoras, Artistas, CD, Track

CREATE TABLE Productoras (
    Pro_ID  INT PRIMARY KEY,
    Nombre  VARCHAR(100) NOT NULL
);

CREATE TABLE Artistas (
    A_ID    INT PRIMARY KEY,
    Nombre  VARCHAR(100) NOT NULL
);

CREATE TABLE CD (
    Cd_ID       INT PRIMARY KEY,
    Title       VARCHAR(200) NOT NULL,
    Price       NUMERIC(10, 2),
    Year        INT,
    Artista     INT REFERENCES Artistas(A_ID),
    Productora  INT REFERENCES Productoras(Pro_ID)
);

CREATE TABLE Track (
    Cd_ID   INT REFERENCES CD(Cd_ID),
    Num     INT,
    Title   VARCHAR(200) NOT NULL,
    Time    INT,
    A_ID    INT REFERENCES Artistas(A_ID),
    PRIMARY KEY (Cd_ID, Num)
);