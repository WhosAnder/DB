DROP FUNCTION IF EXISTS PrecioConDescuento(INT, NUMERIC);

CREATE FUNCTION PrecioConDescuento(
    p_Cd_ID INT,
    p_Descuento NUMERIC(5,2)
)
RETURNS NUMERIC(5,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Precio NUMERIC(5,2);
BEGIN
    SELECT Price
    INTO v_Precio
    FROM CD
    WHERE Cd_ID = p_Cd_ID;

    RETURN v_Precio - (v_Precio * p_Descuento / 100);
END;
$$;

SELECT PrecioConDescuento(1, 10.00) AS precio_con_descuento;


DROP VIEW IF EXISTS Vista_CDs_Artistas;

CREATE VIEW Vista_CDs_Artistas AS
SELECT 
    CD.Cd_ID,
    CD.Title,
    CD.Price,
    CD.Year,
    Artistas.Nombre AS Artista
FROM CD
INNER JOIN Artistas 
    ON CD.Artista = Artistas.A_ID;

SELECT *
FROM Vista_CDs_Artistas;