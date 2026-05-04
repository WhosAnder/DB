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

-- =============================================
-- INSERT: Productoras
-- =============================================
INSERT INTO Productoras (Pro_ID, Nombre) VALUES
    (1, 'Sony Music'),
    (2, 'Universal Music'),
    (3, 'Warner Music G.'),
    (4, 'Emi Records');

-- =============================================
-- INSERT: Artistas
-- =============================================
INSERT INTO Artistas (A_ID, Nombre) VALUES
    (1, 'AC DC'),
    (2, 'Scorpions'),
    (3, 'Pink Floyd');

-- =============================================
-- INSERT: CD
-- =============================================
INSERT INTO CD (Artista, Cd_ID, Title, Price, Year, Productora) VALUES
    (1, 1, 'Back in Black',      15.99, 1980, 1),
    (1, 2, 'Highway to Hell',    17.54, 1979, 2),
    (3, 3, 'The Wall',           16.99, 1979, 4),
    (3, 4, 'The Division Bell',  17.00, 1994, 3),
    (2, 5, 'Love at firts sting',17.24, 1984, 4),
    (2, 6, 'Lovedrive',          17.15, 1979, 1);

-- =============================================
-- INSERT: Track
-- =============================================
INSERT INTO Track (Cd_ID, Num, Title, Time, A_ID) VALUES
    (1,  1,  'Hells Bells',              312, 1),
    (1,  6,  'Back in Black',            255, 1),
    (2,  1,  'Highway to hell',          216, 1),
    (2,  3,  'Walk all over you',        310, 1),
    (3,  3,  'Another Brick in the wall',215, 3),
    (3,  6,  'Comfortably Numb',         334, 3),
    (3,  5,  'Mother',                   334, 3),
    (4,  11, 'High Hopes',               514, 3),
    (4,  7,  'A Great Day For Freedom',  257, 3),
    (5,  14, 'Still Loving You',         346, 2),
    (5,  2,  'Rock you like a Hurricane',312, 2),
    (6,  4,  'Holiday',                  355, 2);