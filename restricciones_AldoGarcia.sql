
-- =============================================
--Actividad 1 pt1.
-- =============================================

DROP TABLE IF EXISTS Ventas;
DROP TABLE IF EXISTS Productos;

CREATE TABLE Productos (
    id_producto INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0)
);

CREATE TABLE Ventas (
    id_venta INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    fecha DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_venta_producto
        FOREIGN KEY (id_producto)
        REFERENCES Productos(id_producto)
);

-- =============================================
-- Actividad 1 pt2. Insertar datos
-- =============================================

INSERT INTO Productos (nombre, precio)
VALUES
    ('Laptop', 1200.50),
    ('Mouse', 25.75),
    ('Teclado', 45.00),
    ('Monitor', 300.00),
    ('Impresora', 150.00);

INSERT INTO Ventas (id_producto, cantidad, fecha)
VALUES
    (5, 1, '2025-02-01'),
    (2, 3, '2025-01-28'),
    (3, 4, '2025-02-06'),
    (4, 3, '2025-01-24'),
    (4, 4, '2025-02-11'),
    (2, 5, '2025-02-11'),
    (3, 4, '2025-02-15'),
    (3, 4, '2025-01-25'),
    (2, 2, '2025-02-03'),
    (1, 3, '2025-02-03');

SELECT * FROM Productos;
SELECT * FROM Ventas;

-- =============================================
-- Actividad 1 pt3. Consultas
-- =============================================

-- 1. Obtener el total de ventas registradas
SELECT COUNT(*) AS total_ventas
FROM Ventas;

-- 2. Calcular la cantidad total de productos vendidos
SELECT SUM(cantidad) AS cantidad_total_vendida
FROM Ventas;

-- 3. Determinar el precio máximo, mínimo y promedio de los productos
SELECT
    MAX(precio) AS precio_maximo,
    MIN(precio) AS precio_minimo,
    ROUND(AVG(precio), 2) AS precio_promedio
FROM Productos;

-- 4. Obtener la cantidad total de productos vendidos por cada producto
SELECT id_producto, SUM(cantidad) AS cantidad_total
FROM Ventas
GROUP BY id_producto
ORDER BY id_producto;
