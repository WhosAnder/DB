DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;

CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0)
);

CREATE TABLE ventas (
    id_venta SERIAL PRIMARY KEY,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    fecha DATE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

INSERT INTO productos (nombre, precio) VALUES
('Laptop', 15000.00),
('Mouse', 250.00),
('Teclado', 700.00),
('Monitor', 3500.00),
('Impresora', 2800.00);

INSERT INTO ventas (id_producto, cantidad, fecha) VALUES
(1, 1, '2025-04-01'),
(1, 5, '2025-04-02'),
(2, 3, '2025-04-03'),
(2, 6, NULL),
(3, 2, '2025-04-04'),
(3, 4, '2025-04-05'),
(4, 1, '2025-04-06'),
(4, 7, NULL),
(5, 3, '2025-04-07'),
(5, 8, '2025-04-08');

-- 1. Cantidad mayor a 2 y producto menor o igual a 3
SELECT *
FROM ventas
WHERE cantidad > 2
AND id_producto <= 3;

-- 2. Producto 1 o cantidad mayor a 4
SELECT *
FROM ventas
WHERE id_producto = 1
OR cantidad > 4;

-- 3. Solo una condición verdadera
SELECT *
FROM ventas
WHERE (cantidad > 2) <> (id_producto < 3);

-- 4. Ventas sin fecha asignada
SELECT *
FROM ventas
WHERE fecha IS NULL;

-- 5. Cantidad diferente de 3
SELECT *
FROM ventas
WHERE cantidad <> 3;