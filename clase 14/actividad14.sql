-- ============================================================
-- Clase 14 - Triggers en PostgreSQL
-- BD: clase 11 - Actividad 01 (03.03.2025)
-- Tablas base: Productoras, Artistas, CD, Track
-- ============================================================


-- ============================================================
-- Actividad 01 - INSERT
-- Trigger: precio_minimo_cd
-- Si el precio de un nuevo CD es menor a 10.00,
-- lo ajusta automáticamente a 10.00 antes de insertar.
-- ============================================================

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

-- Prueba INSERT
INSERT INTO CD (Cd_ID, Artista, Title, Price, Year, Productora)
VALUES (10, 1, 'Nuevo Álbum Barato', 5.00, 2024, 1);

SELECT * FROM CD WHERE Cd_ID = 10;


-- ============================================================
-- Actividad 01 - UPDATE (a)
-- Tabla auxiliar: HistorialPrecios
-- Registra los cambios de precio realizados en la tabla CD.
-- ============================================================

CREATE TABLE IF NOT EXISTS HistorialPrecios (
    Cd_ID           INT,
    Titulo          VARCHAR(255),
    PrecioAnterior  DECIMAL(5,2),
    PrecioNuevo     DECIMAL(5,2),
    FechaCambio     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Actividad 01 - UPDATE (b)
-- Trigger: registrar_cambio_precio
-- Se activa AFTER UPDATE en CD cuando cambia el precio.
-- ============================================================

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

-- Prueba UPDATE
UPDATE CD SET Price = 19.99 WHERE Cd_ID = 1;

SELECT * FROM HistorialPrecios;


-- ============================================================
-- Actividad 01 - DELETE
-- Trigger: prevenir_borrado_artista
-- Impide eliminar un artista si tiene CDs registrados.
-- ============================================================

CREATE OR REPLACE FUNCTION fn_prevenir_borrado_artista()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM CD WHERE Artista = OLD.A_ID) THEN
        RAISE EXCEPTION 'No se puede eliminar el artista con A_ID = % porque tiene CDs registrados.', OLD.A_ID;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER prevenir_borrado_artista
    BEFORE DELETE ON Artistas
    FOR EACH ROW
    EXECUTE FUNCTION fn_prevenir_borrado_artista();

-- Prueba DELETE (debe lanzar error porque AC DC tiene CDs)
DELETE FROM Artistas WHERE A_ID = 1;
