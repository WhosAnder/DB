-- CONSULTAS - Clínica Dental

-- 1. Número de consultorios por piso
-- Lógica Agrupa los consultorios por piso y cuenta cuántos hay en cada uno.
SELECT piso, COUNT(*) AS num_consultorios
FROM consultorio
GROUP BY piso
ORDER BY piso;

-- 2. Costo más alto y más bajo de la tabla TRATAMIENTO
-- Lógica Usa max y min sobre costo_base para obtener los extremos.
SELECT MAX(costo_base) AS costo_mas_alto,
       MIN(costo_base) AS costo_mas_bajo
FROM tratamiento;

-- 3. Cuántas citas hay en cada estado
-- Lógica agrupa las citas por su estado y cuenta cuántas hay en cada grupo.
SELECT estado, COUNT(*) AS total_citas
FROM cita
GROUP BY estado
ORDER BY total_citas DESC;

-- 4. Cuántas citas tiene cada paciente usando el identificador del paciente
-- Lógica Agrupa por id_paciente y cuenta las citas asociadas a cada uno.
SELECT id_paciente, COUNT(*) AS total_citas
FROM cita
GROUP BY id_paciente
ORDER BY id_paciente;

-- 5. Cuántas citas atiende cada odontólogo utilizando su identificador
-- Lógica Agrupa por id_odontologo y cuenta las citas que tiene asignadas.
SELECT id_odontologo, COUNT(*) AS total_citas
FROM cita
GROUP BY id_odontologo
ORDER BY id_odontologo;

-- 6. Cuántas citas existen para cada motivo registrado
-- Lógica Agrupa por motivo y cuenta las ocurrencias de cada uno.
SELECT motivo, COUNT(*) AS total_citas
FROM cita
GROUP BY motivo
ORDER BY total_citas DESC;

-- 7. Suma total de todos los pagos registrados en la tabla PAGO
-- Lógica Usa SUM para sumar todos los montos de la tabla pago.
SELECT SUM(monto) AS suma_total_pagos
FROM pago;

-- 8. Monto total acumulado de cada método de pago
-- Lógica Agrupa por metodo_pago y suma los montos de cada grupo.
SELECT metodo_pago, SUM(monto) AS monto_total
FROM pago
GROUP BY metodo_pago
ORDER BY monto_total DESC;

-- 9. Pagos agrupados por estado donde la suma de montos sea mayor a 1000
-- Lógica Agrupa por estado, suma los montos y filtra con HAVING los grupos cuya suma supere 1000.
SELECT estado, SUM(monto) AS suma_montos
FROM pago
GROUP BY estado
HAVING SUM(monto) > 1000
ORDER BY suma_montos DESC;

-- 10. Costo promedio aplicado a cada tratamiento en DETALLE_CITA_TRATAMIENTO
-- Lógica Agrupa por id_tratamiento y calcula el promedio del costo_aplicado.
SELECT id_tratamiento, AVG(costo_aplicado) AS costo_promedio
FROM detalle_cita_tratamiento
GROUP BY id_tratamiento
ORDER BY id_tratamiento;
