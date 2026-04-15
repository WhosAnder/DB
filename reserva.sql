
-- =============================================
-- Parte A — Crear base de datos y tablas (DDL)
-- =============================================

DROP TABLE IF EXISTS ReservaAuto;
DROP TABLE IF EXISTS Reserva;
DROP TABLE IF EXISTS Auto;
DROP TABLE IF EXISTS Cliente;

CREATE TABLE Cliente (
    id_cliente INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ine VARCHAR(18) NOT NULL UNIQUE,
    nombre VARCHAR(60) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    direccion VARCHAR(80) NOT NULL
);

CREATE TABLE Auto (
    id_auto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    placas VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(30) NOT NULL,
    modelo VARCHAR(30) NOT NULL,
    año SMALLINT NOT NULL CHECK (año >= 0),
    color VARCHAR(20) NOT NULL
);

CREATE TABLE Reserva (
    id_reserva INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estatus VARCHAR(10) NOT NULL DEFAULT 'ACTIVA',
    CONSTRAINT fk_reserva_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES Cliente(id_cliente),
    CONSTRAINT chk_fechas
        CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE ReservaAuto (
    id_reserva INT NOT NULL,
    id_auto INT NOT NULL,
    precio_dia DECIMAL(8,2) NOT NULL CHECK (precio_dia >= 0),
    PRIMARY KEY (id_reserva, id_auto),
    CONSTRAINT fk_reservaauto_reserva
        FOREIGN KEY (id_reserva)
        REFERENCES Reserva(id_reserva),
    CONSTRAINT fk_reservaauto_auto
        FOREIGN KEY (id_auto)
        REFERENCES Auto(id_auto)
);

-- ==================================
-- Parte A.1 — Verificación de tablas
-- ==================================

-- Equivalente a SHOW TABLES en PostgreSQL
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- Equivalente a DESCRIBE en PostgreSQL

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'cliente';

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'auto';

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'reserva';

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'reservaauto';

-- ===============================
-- Parte B — Insertar datos (DML)
-- ===============================

INSERT INTO Cliente (ine, nombre, telefono, direccion)
VALUES
('INE111111111111111', 'Ana López', '2221111111', 'Cholula'),
('INE222222222222222', 'Bruno Reyes', '2222222222', 'Puebla'),
('INE333333333333333', 'Carla Méndez', '2223333333', 'Atlixco');

INSERT INTO Auto (placas, marca, modelo, año, color)
VALUES
('TLX-1010', 'Nissan', 'Versa', 2022, 'Gris'),
('TLX-2020', 'Toyota', 'Corolla', 2021, 'Blanco'),
('TLX-3030', 'VW', 'Jetta', 2020, 'Rojo'),
('TLX-4040', 'Mazda', '2', 2023, 'Azul');

INSERT INTO Reserva (id_cliente, fecha_inicio, fecha_fin)
VALUES
(1, '2026-03-10', '2026-03-12'),
(2, '2026-03-11', '2026-03-11');

INSERT INTO Reserva (id_cliente, fecha_inicio, fecha_fin, estatus)
VALUES
(1, '2026-03-20', '2026-03-22', 'ACTIVA');

UPDATE Reserva
SET estatus = 'CERRADA'
WHERE id_reserva = 2;

INSERT INTO ReservaAuto (id_reserva, id_auto, precio_dia)
VALUES
(1, 1, 650.00),
(1, 3, 800.00),
(2, 2, 750.00),
(3, 4, 700.00);

-- =========================
-- VERIFICACIÓN DE REGISTROS
-- =========================

SELECT * FROM Cliente;
SELECT * FROM Auto;
SELECT * FROM Reserva;
SELECT * FROM ReservaAuto;

-- =========================
-- PARTE C — CONSULTAS (DQL)
-- =========================

-- Q1. Lista todos los clientes ordenados por nombre (ascendente).
SELECT *
FROM Cliente
ORDER BY nombre ASC;
-- Resultado esperado: 3 filas, en orden Ana López, Bruno Reyes, Carla Méndez.

-- Q2. Muestra cada reserva con: id_reserva, nombre del cliente, fecha_inicio, fecha_fin, estatus.
SELECT r.id_reserva, c.nombre, r.fecha_inicio, r.fecha_fin, r.estatus
FROM Reserva r
JOIN Cliente c ON r.id_cliente = c.id_cliente
ORDER BY r.id_reserva;
-- Resultado esperado: 3 filas; reservas 1 y 3 de Ana López, reserva 2 de Bruno Reyes.

-- Q3. Muestra por reserva: id_reserva, cuántos autos tiene (conteo).
SELECT r.id_reserva, COUNT(ra.id_auto) AS cantidad_autos
FROM Reserva r
JOIN ReservaAuto ra ON r.id_reserva = ra.id_reserva
GROUP BY r.id_reserva
ORDER BY r.id_reserva;
-- Resultado esperado: 3 filas. Reserva 1 = 2 autos, Reserva 2 = 1 auto, Reserva 3 = 1 auto.

-- Q4. Muestra el costo total por reserva, considerando días * (suma de precios por día).
-- En PostgreSQL, días = (fecha_fin - fecha_inicio) + 1
SELECT
    r.id_reserva,
    ((r.fecha_fin - r.fecha_inicio) + 1) AS dias,
    SUM(ra.precio_dia) AS suma_precios_dia,
    ((r.fecha_fin - r.fecha_inicio) + 1) * SUM(ra.precio_dia) AS costo_total
FROM Reserva r
JOIN ReservaAuto ra ON r.id_reserva = ra.id_reserva
GROUP BY r.id_reserva, r.fecha_inicio, r.fecha_fin
ORDER BY r.id_reserva;
-- Resultado esperado: 3 filas.
-- Reserva 1: 3 días * (650 + 800) = 4350.00
-- Reserva 2: 1 día  * 750 = 750.00
-- Reserva 3: 3 días * 700 = 2100.00

-- Q5. Muestra las reservas ACTIVAS solamente.
SELECT * FROM Reserva
WHERE estatus = 'ACTIVA'
ORDER BY id_reserva;
-- Resultado esperado: 2 filas, reservas 1 y 3.

-- ==================================
-- PARTE D — CAMBIOS Y TRANSACCIONES
-- ==================================

-- --------------------------------------------
-- UPDATE
-- Cambia el color del auto con placas TLX-3030 a Negro
-- Evidencia: SELECT antes y después
-- --------------------------------------------

SELECT * FROM Auto WHERE placas = 'TLX-3030';

UPDATE Auto
SET color = 'Negro'
WHERE placas = 'TLX-3030';

SELECT * FROM Auto WHERE placas = 'TLX-3030';

-- --------------------------------------------
-- DELETE
-- Intentar borrar el Auto con placas TLX-1010
-- Debe fallar porque sigue referenciado en ReservaAuto
-- --------------------------------------------

-- Este DELETE falla por clave foránea (se comenta para que el script corra completo):
-- DELETE FROM Auto WHERE placas = 'TLX-1010';
-- Error obtenido al ejecutarlo manualmente:
--   ERROR: update or delete on table "auto" violates foreign key constraint
--   "fk_reservaauto_auto" on table "reservaauto"
--   Detail: Key (id_auto)=(1) is still referenced from table "reservaauto".
-- Conclusión: No se puede borrar el auto porque aún tiene registros en ReservaAuto.

-- Ahora borrar primero en ReservaAuto y luego en Auto (esto sí funciona):
DELETE FROM ReservaAuto
WHERE id_auto = (
    SELECT id_auto
    FROM Auto
    WHERE placas = 'TLX-1010'
);

DELETE FROM Auto
WHERE placas = 'TLX-1010';

-- Evidencia
SELECT * FROM ReservaAuto;
SELECT * FROM Auto;

-- --------------------------------------------
-- TRANSACCIÓN CON ROLLBACK
-- Nueva reserva para Carla y luego revertir
-- --------------------------------------------

SELECT * FROM Reserva WHERE id_cliente = 3;

START TRANSACTION;

INSERT INTO Reserva (id_cliente, fecha_inicio, fecha_fin)
VALUES (3, '2026-04-01', '2026-04-03');

SELECT * FROM Reserva WHERE id_cliente = 3;

ROLLBACK;

SELECT * FROM Reserva WHERE id_cliente = 3;

-- Resultado esperado:
-- Después del ROLLBACK, la nueva reserva de Carla no debe existir.

-- --------------------------------------------
-- TRANSACCIÓN CON COMMIT
-- Nueva reserva para Carla y guardar
-- --------------------------------------------

START TRANSACTION;

INSERT INTO Reserva (id_cliente, fecha_inicio, fecha_fin)
VALUES (3, '2026-04-10', '2026-04-12');

COMMIT;

SELECT * FROM Reserva WHERE id_cliente = 3;

-- Resultado esperado:
-- Después del COMMIT, sí debe aparecer la nueva reserva de Carla.