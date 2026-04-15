
-- CLÍNICA DENTAL

DROP TABLE IF EXISTS pago;
DROP TABLE IF EXISTS detalle_cita_tratamiento;
DROP TABLE IF EXISTS cita;
DROP TABLE IF EXISTS tratamiento;
DROP TABLE IF EXISTS consultorio;
DROP TABLE IF EXISTS odontologo;
DROP TABLE IF EXISTS paciente;

-- TABLA paciente
CREATE TABLE paciente (
    id_paciente INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_completo VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(12) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    direccion VARCHAR(50)NOT NULL
);

-- TABLA odontologo
CREATE TABLE odontologo (
    id_odontologo INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    especialidad VARCHAR(50)NOT NULL,
    telefono VARCHAR(12) NOT NULL,
    correo VARCHAR(50) UNIQUE NOT NULL
);

-- TABLA consultorio
CREATE TABLE consultorio (
    id_consultorio INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero VARCHAR(20) NOT NULL UNIQUE,
    piso INT NOT NULL
);

-- TABLA tratamiento
CREATE TABLE tratamiento (
    id_tratamiento INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    costo_base NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (costo_base >= 0)
);

-- TABLA cita
CREATE TABLE cita (
    id_cita INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    motivo TEXT NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    id_paciente INT NOT NULL,
    id_odontologo INT NOT NULL,
    id_consultorio INT NOT NULL,

    CONSTRAINT fk_cita_paciente
        FOREIGN KEY (id_paciente)
        REFERENCES paciente(id_paciente)
        ON DELETE CASCADE,

    CONSTRAINT fk_cita_odontologo
        FOREIGN KEY (id_odontologo)
        REFERENCES odontologo(id_odontologo)
        ON DELETE CASCADE,

    CONSTRAINT fk_cita_consultorio
        FOREIGN KEY (id_consultorio)
        REFERENCES consultorio(id_consultorio)
        ON DELETE CASCADE,

    CONSTRAINT chk_estado_cita
        CHECK (estado IN ('Pendiente', 'Confirmada', 'Cancelada', 'Completada', 'Programada'))
);

-- TABLA detalle_cita_tratamiento
CREATE TABLE detalle_cita_tratamiento (
    id_detalle INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cita INT NOT NULL,
    id_tratamiento INT NOT NULL,
    observaciones TEXT,
    costo_aplicado NUMERIC(10,2) NOT NULL CHECK (costo_aplicado >= 0),

    CONSTRAINT fk_detalle_cita
        FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
        ON DELETE CASCADE,

    CONSTRAINT fk_detalle_tratamiento
        FOREIGN KEY (id_tratamiento)
        REFERENCES tratamiento(id_tratamiento)
        ON DELETE CASCADE,

    CONSTRAINT uq_cita_tratamiento
        UNIQUE (id_cita, id_tratamiento)
);

-- TABLA pago
CREATE TABLE pago (
    id_pago INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha_pago DATE NOT NULL DEFAULT CURRENT_DATE,
	monto NUMERIC(10,2) NOT NULL CHECK (monto >= 0),
    metodo_pago VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    id_cita INT NOT NULL,

    CONSTRAINT fk_pago_cita
        FOREIGN KEY (id_cita)
        REFERENCES cita(id_cita)
        ON DELETE CASCADE,

    CONSTRAINT chk_metodo_pago
        CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'Transferencia')),

    CONSTRAINT chk_estado_pago
        CHECK (estado IN ('Pendiente', 'Pagado', 'Reembolsado'))
);

-- INSERTAMOS DATOS -- 

-- PACIENTE
INSERT INTO paciente (nombre_completo, fecha_nacimiento, telefono, correo, direccion) VALUES
('Ana López García', '2002-03-14', '2223456789', 'ana.lopez@correo.com', 'Cholula, Puebla'),
('Carlos Martínez Ruiz', '2001-08-22', '2224567890', 'carlos.martinez@correo.com', 'Puebla, Puebla'),
('Diana Hernández Soto', '2003-01-10', '2225678901', 'diana.hernandez@correo.com', 'San Andrés Cholula, Puebla'),
('José Ramírez Torres', '2000-11-05', '2226789012', 'jose.ramirez@correo.com', 'Atlixco, Puebla'),
('Mariana Pérez Castillo', '2002-06-30', '2227890123', 'mariana.perez@correo.com', 'San Pedro Cholula, Puebla');

-- ODONTOLOGO
INSERT INTO odontologo (nombre, especialidad, telefono, correo) VALUES
('Dra. Laura Sánchez', 'Ortodoncia', '2221112233', 'laura.sanchez@clinica.com'),
('Dr. Miguel Torres', 'Endodoncia', '2221113344', 'miguel.torres@clinica.com'),
('Dra. Fernanda Gómez', 'Odontología general', '2221114455', 'fernanda.gomez@clinica.com');

-- CONSULTORIO
INSERT INTO consultorio (numero, piso) VALUES
('101', 1),
('102', 1),
('201', 2);

-- TRATAMIENTO
INSERT INTO tratamiento (nombre, descripcion, costo_base) VALUES
('Limpieza dental', 'Eliminación de sarro y placa', 500.00),
('Resina', 'Restauración dental con material resina', 850.00),
('Extracción', 'Remoción de una pieza dental', 1200.00),
('Endodoncia', 'Tratamiento de conducto', 2500.00),
('Ortodoncia evaluación', 'Revisión y diagnóstico de ortodoncia', 700.00);

-- CITA
INSERT INTO cita (fecha, hora, motivo, estado, id_paciente, id_odontologo, id_consultorio) VALUES
('2026-04-02', '09:00:00', 'Dolor molar', 'Completada', 1, 2, 1),
('2026-04-02', '10:00:00', 'Limpieza general', 'Completada', 2, 3, 2),
('2026-04-03', '11:30:00', 'Revisión de brackets', 'Completada', 3, 1, 3),
('2026-04-03', '13:00:00', 'Caries en premolar', 'Completada', 4, 3, 1),
('2026-04-04', '09:30:00', 'Extracción dental', 'Completada', 5, 2, 2),
('2026-04-04', '12:00:00', 'Dolor e infección', 'Completada', 2, 2, 1),
('2026-04-05', '10:30:00', 'Valoración general', 'Programada', 1, 3, 3),
('2026-04-05', '12:30:00', 'Ajuste de ortodoncia', 'Programada', 3, 1, 3);

-- DETALLE_CITA_TRATAMIENTO
INSERT INTO detalle_cita_tratamiento (id_cita, id_tratamiento, observaciones, costo_aplicado) VALUES
(1, 4, 'Se realizó tratamiento de conducto', 2500.00),
(2, 1, 'Limpieza completa sin complicaciones', 500.00),
(3, 5, 'Evaluación y ajuste inicial', 700.00),
(4, 2, 'Aplicación de resina en premolar', 850.00),
(5, 3, 'Extracción de tercer molar', 1200.00),
(6, 4, 'Endodoncia por infección avanzada', 2500.00),
(7, 1, 'Limpieza sugerida en valoración', 500.00),
(8, 5, 'Revisión y ajuste de ortodoncia', 700.00);

-- PAGO
INSERT INTO pago (fecha_pago, monto, metodo_pago, estado, id_cita) VALUES
('2026-04-02', 2500.00, 'Tarjeta', 'Pagado', 1),
('2026-04-02', 500.00, 'Efectivo', 'Pagado', 2),
('2026-04-03', 700.00, 'Tarjeta', 'Pagado', 3),
('2026-04-03', 850.00, 'Transferencia', 'Pagado', 4),
('2026-04-04', 1200.00, 'Efectivo', 'Pagado', 5);

SELECT * FROM paciente;
SELECT * FROM odontologo;
SELECT * FROM consultorio;
SELECT * FROM tratamiento;
SELECT * FROM cita;
SELECT * FROM detalle_cita_tratamiento;
SELECT * FROM pago;
