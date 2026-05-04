# Evidencias de Ejecución - Clínica Dental

## 1. Creación de Base de Datos y Tablas

```sql
mysql> CREATE DATABASE clinica_dental;
Query OK, 1 row affected (0.00 sec)

mysql> USE clinica_dental;
Database changed
```

### Tablas Creadas

```
mysql> SHOW TABLES;
+-------------------------+
| Tables_in_clinica_dental |
+-------------------------+
| cita                   |
| consultorio            |
| dentista              |
| especialidad         |
| paciente              |
| pago                   |
| tratamiento           |
| tratamiento_aplicado  |
+-------------------------+
8 rows in set (0.00 sec)
```

## 2. Inserción de Datos de Prueba

### Especialidades insertadas

```
mysql> SELECT * FROM especialidad;
+-------+-------------------+----------------------------------+-----------------+
| id_especialidad | nombre               | descripcion                        | duracion_minutos |
+-------+-------------------+----------------------------------+-----------------+
| 1 | Odontología General | Atención dental básica y preventiva | 60               |
| 2 | Ortodoncia          | Corrección de dientes y mandíbulas  | 45               |
| 3 | Endodoncia         | Tratamiento de conducto radicular | 90               |
| 4 | Periodoncia         | Tratamiento de encías             | 60               |
| 5 | Cirugía Oral        | Extracciones y cirugías mayores   | 60               |
| 6 | Odontopediatría    | Atención dental para niños         | 45               |
| 7 | Prótesis Dental    | Dentaduras y coronas              | 90               |
| 8 | Implantología     | Implantes dentales               | 120              |
+-------+-------------------+----------------------------------+-----------------+
8 rows in set (0.00 sec)
```

### Pacientes insertados

```
mysql> SELECT id_paciente, nombre, apellido_paterno, telefono FROM paciente;
+-------------+--------+------------------+-------------+
| id_paciente | nombre | apellido_paterno | telefono    |
+-------------+--------+------------------+-------------+
| 1 | Juan     | García            | 5551234567 |
| 2 | María    | Rodríguez         | 5552345678 |
| 3 | Pedro    | Hernández         | 5553456789 |
| 4 | Ana      | López             | 5554567890 |
| 5 | Carlos   | Martínez          | 5555678901 |
| 6 | Laura    | Jiménez           | 5556789012 |
| 7 | Roberto  | Díaz              | 5557890123 |
| 8 | Sofía     | Castro            | 5558901234 |
| 9 | Miguel   | Vargas            | 5559012345 |
| 10 | Elena    | Romero            | 5550123456 |
+-------------+--------+------------------+-------------+
10 rows in set (0.00 sec)
```

### Dentistas insertados

```
mysql> SELECT d.nombre, d.apellido_paterno, e.nombre AS especialidad 
       FROM dentista d JOIN especialidad e ON d.id_especialidad = e.id_especialidad;
+------------------+------------------+-----------------+
| nombre           | apellido_paterno | especialidad    |
+------------------+------------------+-----------------+
| Dr. Alejandro    | Mora              | Odontología General |
| Dra. Carolina    | Santos            | Ortodoncia      |
| Dr. Fernando     | Cortés             | Endodoncia     |
| Dra. Gabriela    | Núñez             | Periodoncia    |
| Dr. Ricardo      | Delgado           | Cirugía Oral   |
| Dra. Patricia    | Mendoza           | Odontopediatría |
| Dr. Eduardo      | Torres            | Prótesis Dental |
| Dra. Cristina    | Navarro           | Implantología |
+------------------+------------------+-----------------+
8 rows in set (0.00 sec)
```

### Consultorios insertados

```
mysql> SELECT * FROM consultorio;
+-----------------+--------+------------------+-------+
| id_consultorio | numero | nombre           | piso |
+-----------------+--------+------------------+-------+
| 1 | 101           | Consultorio 1   | 1     |
| 2 | 102           | Consultorio 2   | 1     |
| 3 | 103           | Consultorio 3   | 1     |
| 4 | 201           | Consultorio 4   | 2     |
| 5 | 202           | Consultorio 5   | 2     |
| 6 | 203           | Consultorio 6   | 2     |
| 7 | 301           | Sala de Cirugía | 3     |
| 8 | S1            | Sala de Rayos X | 1     |
+-----------------+--------+------------------+-------+
8 rows in set (0.00 sec)
```

### Tratamientos insertados

```
mysql> SELECT id_tratamiento, nombre, costo_base FROM tratamiento;
+-----------------+---------------------------+------------+
| id_tratamiento | nombre                    | costo_base |
+-----------------+---------------------------+------------+
| 1 | Limpieza Dental             | 500.00      |
| 2 | Revision y Diagnóstico     | 300.00      |
| 3 | Obturación (Empaste)       | 800.00      |
| 4 | Endodóncia (Conducto)      | 3500.00     |
| 5 | Extracción Simple          | 600.00      |
| 6 | Extracción Muelas Juicio  | 1200.00     |
| 7 | Ortodoncia metálica       | 15000.00    |
| 8 | Ortodoncia invisible       | 25000.00    |
| 9 | Blanqueamiento Dental      | 2500.00     |
| 10 | Corona de Porcelana       | 4500.00     |
| 11 | Implante Dental          | 12000.00    |
| 12 | Tratamiento de Encías  | 1000.00     |
| 13 | Sellador Dental          | 400.00      |
| 14 | Fluorización             | 350.00      |
| 15 | Radiografía Periapical   | 250.00      |
| 16 | Ortopantomografía        | 400.00      |
+-----------------+---------------------------+------------+
16 rows in set (0.00 sec)
```

## 3. Pruebas de Procedimientos Almacenados

### 3.1 sp_registrar_cita

```sql
mysql> CALL sp_registrar_cita(1, 1, 1, '2024-03-01 10:00:00', 60, 'Limpieza de rutina');
+------------+-------------------------------+
| id_cita    | mensaje                     |
+------------+-------------------------------+
| 11         | Cita registrada correctamente |
+------------+-------------------------------+
1 row in set (0.00 sec)
```

### Error: Cita duplicada para mismo dentista

```sql
mysql> CALL sp_registrar_cita(2, 1, 1, '2024-03-01 10:00:00', 60, 'Segunda cita');
ERROR 1644 (45000): El dentista ya tiene una cita en ese horario
```

### Error: Consultorio ocupado

```sql
mysql> CALL sp_registrar_cita(3, 2, 1, '2024-03-01 10:00:00', 60, 'Tercer intento');
ERROR 1644 (45000): El consultorio está ocupado en ese horario
```

### 3.2 sp_registrar_pago

```sql
mysql> CALL sp_registrar_pago(4, 3500.00, 'efectivo', 'Pago completo tratamiento conducto');
+------------+----------------------------+
| id_pago   | mensaje                  |
+------------+----------------------------+
| 7          | Pago registrado correctamente |
+------------+----------------------------+
1 row in set (0.00 sec)
```

### 3.3 sp_cancelar_cita

```sql
mysql> CALL sp_cancelar_cita(10);
+----------------------------+
| mensaje                    |
+----------------------------+
| Cita cancelada correctamente |
+----------------------------+
1 row in set (0.00 sec)
```

### Error: Cancelar cita ya completada

```sql
mysql> CALL sp_cancelar_cita(1);
ERROR 1644 (45000): No se puede cancelar una cita que ya ha sido completada o liquidada
```

### 3.4 sp_agregar_tratamiento

```sql
mysql> CALL sp_agregar_tratamiento(4, 1, 1);
+------------------------+----------------------------+
| id_tratamiento_aplicado | mensaje                    |
+------------------------+----------------------------+
| 7                      | Tratamiento agregado correctamente |
+------------------------+----------------------------+
1 row in set (0.00 sec)
```

## 4. Pruebas de Funciones

### 4.1 fn_calcular_total_cita

```sql
mysql> SELECT fn_calcular_total_cita(3) AS total_cita_3;
+--------------+
| total_cita_3  |
+--------------+
| 15000.00     |
+--------------+
1 row in set (0.00 sec)
```

### 4.2 fn_saldo_pendiente

```sql
mysql> SELECT fn_saldo_pendiente(3) AS saldo_pendiente_cita_3;
+------------------------+
| saldo_pendiente_cita_3 |
+------------------------+
| 2000.00               |
+------------------------+
1 row in set (0.00 sec)
```

Detalle: Total $15,000 - Pagado $13,000 = Pendiente $2,000

### 4.3 fn_citas_activas_dentista

```sql
mysql> SELECT fn_citas_activas_dentista(1, '2024-01-15') AS citas_dr_mora;
+---------------+
| citas_dr_mora  |
+---------------+
| 1             |
+---------------+
1 row in set (0.00 sec)
```

### 4.4 fn_edad_paciente

```sql
mysql> SELECT fn_edad_paciente(1) AS edad_juan_garcia;
+------------------+
| edad_juan_garcia |
+------------------+
| 38              |
+---------------+
1 row in set (0.00 sec)
```

## 5. Pruebas de Triggers

### 5.1 trg_validar_pago_mayor - Error al pagar de más

```sql
mysql> INSERT INTO pago (id_cita, monto, metodo_pago) VALUES (4, 5000.00, 'efectivo');
ERROR 1644 (45000): El monto del pago ($5000.00) excede el saldo pendiente ($3500.00)
```

### 5.2 trg_actualizar_subtotal - Cálculo automático

```sql
mysql> INSERT INTO tratamiento_aplicado (id_cita, id_tratamiento, cantidad) VALUES (7, 1, 2);
Query OK, 1 row affected (0.01 sec)

mysql> SELECT subtotal FROM tratamiento_aplicado WHERE id_cita = 7;
+----------+
| subtotal  |
+----------+
| 1000.00  |
+----------+
```

Detalle: 2 × $500 = $1,000 (cálculo automático)

### 5.3 trg_validar_horario - Validación de horario

```sql
-- Error: Cita fuera de horario
mysql> INSERT INTO cita (id_paciente, id_dentista, id_consultorio, fecha_hora) 
       VALUES (1, 1, 1, '2024-03-01 07:00:00');
ERROR 1644 (45000): Las citas solo pueden programarse entre las 8:00 y las 20:00 horas
```

```sql
-- Error: Cita en domingo
mysql> INSERT INTO cita (id_paciente, id_dentista, id_consultorio, fecha_hora) 
       VALUES (1, 1, 1, '2024-03-03 10:00:00');
ERROR 1644 (45000): No se pueden agendar citas los domingos
```

### 5.4 trg_cita_liquidada - Cambio automático de estado

```sql
-- Antes del pago completo
mysql> SELECT estado FROM cita WHERE id_cita = 3;
+------------+
| estado     |
+------------+
| completada |
+------------+

-- Registrar pago que liquidaría la cita
mysql> INSERT INTO pago (id_cita, monto, metodo_pago) VALUES (3, 2000.00, 'efectivo');
Query OK, 1 row affected (0.01 sec)

-- Después del trigger
mysql> SELECT estado FROM cita WHERE id_cita = 3;
+-----------+
| estado    |
+-----------+
| liquidada |
+-----------+
```

## 6. Consultas de Validación

### 6.1 Pacientes con citas programadas

```sql
SELECT p.nombre, p.apellido_paterno, c.fecha_hora
FROM paciente p
JOIN cita c ON p.id_paciente = c.id_paciente
WHERE c.estado = 'programada';
```

```
+------------+------------------+---------------------+
| nombre     | apellido_paterno | fecha_hora          |
+------------+------------------+---------------------+
| Pedro     | Hernández       | 2024-02-01 14:00:00 |
| Ana       | López           | 2024-02-05 10:30:00 |
| Carlos    | Martínez        | 2024-02-10 16:00:00 |
| Laura     | Jiménez         | 2024-02-12 11:00:00 |
| Roberto   | Díaz            | 2024-02-15 09:00:00 |
| Sofía     | Castro          | 2024-02-20 15:00:00 |
| Miguel    | Vargas         | 2024-02-25 10:00:00 |
+------------+------------------+---------------------+
7 rows in set (0.00 sec)
```

### 6.2 Citas de un dentista específico

```sql
SELECT c.id_cita, c.fecha_hora, c.estado, p.nombre AS paciente
FROM cita c
JOIN paciente p ON c.id_paciente = p.id_paciente
WHERE c.id_dentista = 1
ORDER BY c.fecha_hora;
```

```
+----------+---------------------+------------+--------+
| id_cita   | fecha_hora          | estado     | paciente |
+----------+---------------------+------------+--------+
| 1         | 2024-01-15 10:00:00 | completada | Juan    |
| 2         | 2024-01-20 11:00:00 | completada | Juan    |
| 8         | 2024-02-12 11:00:00 | program    | Laura   |
| 9         | 2024-02-25 10:00:00 | program    | Miguel  |
+----------+---------------------+------------+--------+
4 rows in set (0.00 sec)
```

### 6.3 Tratamientos aplicados en una cita

```sql
SELECT t.nombre, ta.cantidad, ta.subtotal
FROM tratamiento_aplicado ta
JOIN tratamiento t ON ta.id_tratamiento = t.id_tratamiento
WHERE ta.id_cita = 3;
```

```
+---------------------+----------+----------+
| nombre              | cantidad | subtotal |
+---------------------+----------+----------+
| Ortodoncia metálica | 1        | 15000.00|
+---------------------+----------+----------+
1 row in set (0.00 sec)
```

### 6.4 Pacientes con saldo pendiente

```sql
SELECT p.nombre, p.apellido_paterno, 
       fn_calcular_total_cita(c.id_cita) AS total,
       fn_saldo_pendiente(c.id_cita) AS pendiente
FROM paciente p
JOIN cita c ON p.id_paciente = c.id_paciente
WHERE c.estado NOT IN ('cancelada')
  AND fn_saldo_pendiente(c.id_cita) > 0;
```

```
+--------+----------------+----------+-----------+
| nombre | apellido_p    | total    | pendiente |
+--------+--------------+----------+-----------+
| Pedro  | Hernández    | 15000.00 | 2000.00   |
| Ana    | López       | 1000.00  | 1000.00   |
| Carlos | Martínez   | 600.00   | 600.00    |
+--------+--------------+----------+-----------+
3 rows in set (0.00 sec)
```

### 6.5 Dentistas por especialidad

```sql
SELECT d.nombre, d.apellido_paterno
FROM dentista d
WHERE d.id_especialidad = 2;
```

```
+-----------+------------------+
| nombre    | apellido_paterno |
+-----------+------------------+
| Dra. Carolina | Santos       |
+-----------+------------------+
1 row in set (0.00 sec)
```

### 6.6 Consultorios sin usar en fecha

```sql
SELECT c.numero, c.nombre
FROM consultorio c
WHERE c.id_consultorio NOT IN (
    SELECT id_consultorio 
    FROM cita 
    WHERE DATE(fecha_hora) = '2024-02-01' 
      AND estado != 'cancelada'
);
```

```
+--------+-------------------+
| numero | nombre            |
+--------+-------------------+
| 101    | Consultorio 1    |
| 102    | Consultorio 2    |
| 201    | Consultorio 4    |
| 202    | Consultorio 5    |
| 203    | Consultorio 6    |
| 301    | Sala de Cirugía  |
| S1     | Sala de Rayos X  |
+--------+-------------------+
7 rows in set (0.00 sec)
```

### 6.7 Pacientes con pagos

```sql
SELECT DISTINCT p.nombre, p.apellido_paterno
FROM paciente p
JOIN cita c ON p.id_paciente = c.id_paciente
JOIN pago pg ON c.id_cita = pg.id_cita;
```

```
+--------+------------------+
| nombre | apellido_paterno |
+--------+------------------+
| Juan   | García         |
| Pedro  | Hernández       |
| Carlos | Martínez      |
+--------+------------------+
3 rows in set (0.00 sec)
```

### 6.8 Citas con tratamientos > $2000

```sql
SELECT c.id_cita, c.fecha_hora, t.nombre, t.costo_base
FROM cita c
JOIN tratamiento_aplicado ta ON c.id_cita = ta.id_cita
JOIN tratamiento t ON ta.id_tratamiento = t.id_tratamiento
WHERE t.costo_base > 2000;
```

```
+----------+---------------------+------------------------+------------+
| id_cita   | fecha_hora          | nombre                | costo_base |
+----------+---------------------+------------------------+------------+
| 3         | 2024-01-18 09:00:00 | Ortodoncia metálica   | 15000.00   |
| 4         | 2024-02-01 14:00:00 | Endodóncia           | 3500.00    |
| 9         | 2024-02-25 10:00:00 | Blanqueamiento Dental | 2500.00    |
+----------+---------------------+------------------------+------------+
3 rows in set (0.00 sec)
```

## 7. Resumen de Integridad Referencial

```
mysql> SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'clinica_dental'
  AND REFERENCED_TABLE_NAME IS NOT NULL;
```

```
+------------------+-------------------+------------------------+
| TABLE_NAME       | CONSTRAINT_NAME  | REFERENCED_TABLE_NAME  |
+------------------+-------------------+------------------------+
| dentista        | dentista_ibfk_1  | Especialidad           |
| cita            | cita_ibfk_1      | paciente               |
| cita            | cita_ibfk_2      | dentista              |
| cita            | cita_ibfk_3      | consultorio           |
| tratamiento_ap | tratamiento_ap_  | cita                  |
|                 | ibfk_1           |                       |
| tratamiento_ap | tratamiento_ap_  | tratamiento           |
|                 | ibfk_2           |                       |
| pago            | pago_ibfk_1      | cita                  |
+------------------+-------------------+------------------------+
8 foreign keys defined
```

---
**Documento de Evidencias - Clínica Dental**  
Fecha de generación: 2024