-- Clase 14 - Triggers
-- Usa la BD de clase 11 (Productoras, Artistas, CD, Track)


-- --------------------------------
-- INSERT: precio mínimo de CD
-- Si el precio viene menor a 10, lo pone en 10 antes de insertar
-- --------------------------------

CREATE OR REPLACE FUNCTION fn_precio_minimo_cd()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Price < 10.00 THEN
        NEW.Price := 10.00;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER precio_minimo_cd
    BEFORE INSERT ON CD
    FOR EACH ROW
    EXECUTE FUNCTION fn_precio_minimo_cd();

-- Prueba
INSERT INTO CD (Cd_ID, Artista, Title, Price, Year, Productora)
VALUES (10, 1, 'Nuevo Álbum Barato', 5.00, 2024, 1);

SELECT * FROM CD WHERE Cd_ID = 10;


-- --------------------------------
-- UPDATE (a): tabla para el historial de precios
-- --------------------------------

CREATE TABLE IF NOT EXISTS HistorialPrecios (
    Cd_ID           INT,
    Titulo          VARCHAR(255),
    PrecioAnterior  DECIMAL(5,2),
    PrecioNuevo     DECIMAL(5,2),
    FechaCambio     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------
-- UPDATE (b): guardar cambios de precio en HistorialPrecios
-- Solo se registra si el precio realmente cambió
-- --------------------------------

CREATE OR REPLACE FUNCTION fn_registrar_cambio_precio()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Price <> NEW.Price THEN
        INSERT INTO HistorialPrecios (Cd_ID, Titulo, PrecioAnterior, PrecioNuevo)
        VALUES (OLD.Cd_ID, OLD.Title, OLD.Price, NEW.Price);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER registrar_cambio_precio
    AFTER UPDATE ON CD
    FOR EACH ROW
    EXECUTE FUNCTION fn_registrar_cambio_precio();

-- Prueba
UPDATE CD SET Price = 19.99 WHERE Cd_ID = 1;

SELECT * FROM HistorialPrecios;


-- --------------------------------
-- DELETE: no dejar borrar un artista si tiene CDs
-- --------------------------------

CREATE OR REPLACE FUNCTION fn_prevenir_borrado_artista()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM CD WHERE Artista = OLD.A_ID) THEN
        RAISE EXCEPTION 'El artista % tiene CDs registrados, no se puede eliminar.', OLD.A_ID;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER prevenir_borrado_artista
    BEFORE DELETE ON Artistas
    FOR EACH ROW
    EXECUTE FUNCTION fn_prevenir_borrado_artista();

-- Prueba (debe dar error porque AC DC tiene CDs)
DELETE FROM Artistas WHERE A_ID = 1;
