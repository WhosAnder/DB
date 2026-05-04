-- Elimina el procedimiento si ya existe
DROP PROCEDURE IF EXISTS InsertarCD(INT, VARCHAR, NUMERIC, INT, INT);

-- Crea el procedimiento almacenado
CREATE PROCEDURE InsertarCD(
    IN p_Artista INT,
    IN p_Title VARCHAR(255),
    IN p_Price NUMERIC(5,2),
    IN p_Year INT,
    IN p_Productora INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO CD (Artista, Title, Price, Year, Productora)
    VALUES (p_Artista, p_Title, p_Price, p_Year, p_Productora);
END;
$$;

-- Prueba del procedimiento
CALL InsertarCD(3, 'Dark Side of the Moon', 18.50, 1973, 4);

-- Verificar que se insertó el CD
SELECT *
FROM CD
WHERE Title = 'Dark Side of the Moon';