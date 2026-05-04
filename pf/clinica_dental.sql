-- ============================================
-- SISTEMA DE GESTIÓN PARA CLÍNICA DENTAL
-- Script SQL Completo
-- ============================================

-- ============================================
-- 1. CREACIÓN DE LA BASE DE DATOS
-- ============================================

DROP DATABASE IF EXISTS clinica_dental;
CREATE DATABASE clinica_dental;
USE clinica_dental;

-- ============================================
-- 2. CREACIÓN DE TABLAS
-- ============================================

-- --------------------------------------------
-- Tabla: Especialidad
-- --------------------------------------------
CREATE TABLE especialidad (
    id_especialidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    duracion_minutos INT DEFAULT 60,
    CONSTRAINT chk_duracion_esp CHECK (duracion_minutos > 0)
) ENGINE=InnoDB;

-- --------------------------------------------
-- Tabla: Paciente
-- --------------------------------------------
CREATE TABLE paciente (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL CHECK (genero IN ('M', 'F', 'O')),
    telefono VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    direccion TEXT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_fecha_nac CHECK (fecha_nacimiento <= CURDATE())
) ENGINE=InnoDB;

-- --------------------------------------------
-- Tabla: Dentista
-- --------------------------------------------
CREATE TABLE dentista (
    id_dentista INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    cedula_profesional VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(15),
    email VARCHAR(100),
    id_especialidad INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------
-- Tabla: Consultorio
-- --------------------------------------------
CREATE TABLE consultorio (
    id_consultorio INT PRIMARY KEY AUTO_INCREMENT,
    numero VARCHAR(10) NOT NULL UNIQUE,
    nombre VARCHAR(100),
    piso INT DEFAULT 1,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_piso CHECK (piso >= 1 AND piso <= 10)
) ENGINE=InnoDB;

-- --------------------------------------------
-- Tabla: Cita
-- --------------------------------------------
CREATE TABLE cita (
    id_cita INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT NOT NULL,
    id_dentista INT NOT NULL,
    id_consultorio INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    duracion_minutos INT DEFAULT 60,
    estado ENUM('programada', 'en_atencion', 'completada', 'cancelada', 'liquidada') DEFAULT 'programada',
    observaciones TEXT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_dentista) REFERENCES dentista(id_dentista)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_duracion_cita CHECK (duracion_minutos > 0),
    CONSTRAINT chk_fecha_cita CHECK (fecha_hora >= NOW() - INTERVAL 1 DAY)
) ENGINE=InnoDB;

-- --------------------------------------------
-- Tabla: Tratamiento
-- --------------------------------------------
CREATE TABLE tratamiento (
    id_tratamiento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    costo_base DECIMAL(10,2) NOT NULL CHECK (costo_base >= 0),
    duracion_minutos INT DEFAULT 60,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_duracion_trat CHECK (duracion_minutos > 0)
) ENGINE=InnoDB;

-- --------------------------------------------
-- Tabla: TratamientoAplicado
-- --------------------------------------------
CREATE TABLE tratamiento_aplicado (
    id_tratamiento_aplicado INT PRIMARY KEY AUTO_INCREMENT,
    id_cita INT NOT NULL,
    id_tratamiento INT NOT NULL,
    cantidad INT DEFAULT 1 CHECK (cantidad >= 1),
    subtotal DECIMAL(10,2) NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_tratamiento) REFERENCES tratamiento(id_tratamiento)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_cantidad CHECK (cantidad >= 1),
    CONSTRAINT chk_subtotal CHECK (subtotal >= 0)
) ENGINE=InnoDB;

-- --------------------------------------------
-- Tabla: Pago
-- --------------------------------------------
CREATE TABLE pago (
    id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_cita INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('efectivo', 'tarjeta_credito', 'tarjeta_debito', 'transferencia', 'seguro') DEFAULT 'efectivo',
    observaciones TEXT,
    FOREIGN KEY (id_cita) REFERENCES cita(id_cita)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_monto CHECK (monto > 0)
) ENGINE=InnoDB;

-- ============================================
-- 3. ÍNDICES PARA MEJORAR RENDIMIENTO
-- ============================================

CREATE INDEX idx_cita_fecha ON cita(fecha_hora);
CREATE INDEX idx_cita_estado ON cita(estado);
CREATE INDEX idx_cita_paciente ON cita(id_paciente);
CREATE INDEX idx_cita_dentista ON cita(id_dentista);
CREATE INDEX idx_tratamiento_aplicado_cita ON tratamiento_aplicado(id_cita);
CREATE INDEX idx_pago_cita ON pago(id_cita);

-- ============================================
-- 4. PROCEDIMIENTOS ALMACENADOS
-- ============================================

-- --------------------------------------------
-- Procedimiento: Registrar Nueva Cita
-- --------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_registrar_cita(
    IN p_id_paciente INT,
    IN p_id_dentista INT,
    IN p_id_consultorio INT,
    IN p_fecha_hora DATETIME,
    IN p_duracion_minutos INT,
    IN p_observaciones TEXT
)
BEGIN
    DECLARE v_disponible TINYINT DEFAULT 1;
    
    -- Verificar conflicto de horario con dentistas
    IF EXISTS (
        SELECT 1 FROM cita 
        WHERE id_dentista = p_id_dentista 
          AND estado NOT IN ('cancelada')
          AND (
            (p_fecha_hora BETWEEN fecha_hora AND DATE_ADD(fecha_hora, INTERVAL duracion_minutos MINUTE))
            OR (DATE_ADD(p_fecha_hora, INTERVAL p_duracion_minutos MINUTE) BETWEEN fecha_hora AND DATE_ADD(fecha_hora, INTERVAL duracion_minutos MINUTE))
          )
    ) THEN
        SIGNAL SET MESSAGE_TEXT = 'El dentista ya tiene una cita en ese horario';
        SET v_disponible = 0;
    END IF;
    
    -- Verificar conflicto de consultorio
    IF v_disponible = 1 AND EXISTS (
        SELECT 1 FROM cita 
        WHERE id_consultorio = p_id_consultorio 
          AND estado NOT IN ('cancelada')
          AND (
            (p_fecha_hora BETWEEN fecha_hora AND DATE_ADD(fecha_hora, INTERVAL duracion_minutos MINUTE))
            OR (DATE_ADD(p_fecha_hora, INTERVAL p_duracion_minutos MINUTE) BETWEEN fecha_hora AND DATE_ADD(fecha_hora, INTERVAL duracion_minutos MINUTE))
          )
    ) THEN
        SIGNAL SET MESSAGE_TEXT = 'El consultorio está ocupado en ese horario';
        SET v_disponible = 0;
    END IF;
    
    -- Insertar la cita
    IF v_disponible = 1 THEN
        INSERT INTO cita (id_paciente, id_dentista, id_consultorio, fecha_hora, duracion_minutos, observaciones)
        VALUES (p_id_paciente, p_id_dentista, p_id_consultorio, p_fecha_hora, p_duracion_minutos, p_observaciones);
        
        SELECT LAST_INSERT_ID() AS id_cita, 'Cita registrada correctamente' AS mensaje;
    END IF;
END //
DELIMITER ;

-- --------------------------------------------
-- Procedimiento: Registrar Pago de una Cita
-- --------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_registrar_pago(
    IN p_id_cita INT,
    IN p_monto DECIMAL(10,2),
    IN p_metodo_pago ENUM('efectivo', 'tarjeta_credito', 'tarjeta_debito', 'transferencia', 'seguro'),
    IN p_observaciones TEXT
)
BEGIN
    DECLARE v_saldo_pendiente DECIMAL(10,2);
    
    -- Calcular saldo pendiente
    SELECT fn_saldo_pendiente(p_id_cita) INTO v_saldo_pendiente;
    
    -- Verificar que el monto no exceda el saldo
    IF p_monto > v_saldo_pendiente THEN
        SIGNAL SET MESSAGE_TEXT = CONCAT('El monto excede el saldo pendiente de: ', v_saldo_pendiente);
    ELSE
        INSERT INTO pago (id_cita, monto, metodo_pago, observaciones)
        VALUES (p_id_cita, p_monto, p_metodo_pago, p_observaciones);
        
        -- Verificar si la cita queda liquidada
        IF fn_saldo_pendiente(p_id_cita) <= 0 THEN
            UPDATE cita SET estado = 'liquidada' WHERE id_cita = p_id_cita;
        END IF;
        
        SELECT LAST_INSERT_ID() AS id_pago, 'Pago registrado correctamente' AS mensaje;
    END IF;
END //
DELIMITER ;

-- --------------------------------------------
-- Procedimiento: Cancelar una Cita
-- --------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_cancelar_cita(IN p_id_cita INT)
BEGIN
    DECLARE v_estado_actual ENUM('programada', 'en_atencion', 'completada', 'cancelada', 'liquidada');
    DECLARE v_existen_pagos TINYINT DEFAULT 0;
    
    -- Obtener estado actual
    SELECT estado INTO v_estado_actual FROM cita WHERE id_cita = p_id_cita;
    
    -- Verificar si hay pagos realizados
    SELECT COUNT(*) INTO v_existen_pagos FROM pago WHERE id_cita = p_id_cita;
    
    -- Solo se pueden cancelar citas programadas o en atención
    IF v_estado_actual = 'cancelada' THEN
        SIGNAL SET MESSAGE_TEXT = 'La cita ya está cancelada';
    ELSEIF v_estado_actual = 'completada' OR v_estado_actual = 'liquidada' THEN
        SIGNAL SET MESSAGE_TEXT = 'No se puede cancelar una cita que ya ha sido completada o liquidada';
    ELSEIF v_existen_pagos > 0 THEN
        SIGNAL SET MESSAGE_TEXT = 'No se puede cancelar una cita con pagos registrados';
    ELSE
        UPDATE cita SET estado = 'cancelada' WHERE id_cita = p_id_cita;
        SELECT 'Cita cancelada correctamente' AS mensaje;
    END IF;
END //
DELIMITER ;

-- --------------------------------------------
-- Procedimiento: Agregar Tratamiento a una Cita
-- --------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_agregar_tratamiento(
    IN p_id_cita INT,
    IN p_id_tratamiento INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_estado_actual ENUM('programada', 'en_atencion', 'completada', 'cancelada', 'liquidada');
    DECLARE v_costo_base DECIMAL(10,2);
    DECLARE v_subtotal DECIMAL(10,2);
    
    -- Verificar estado de la cita
    SELECT estado INTO v_estado_actual FROM cita WHERE id_cita = p_id_cita;
    
    IF v_estado_actual = 'cancelada' THEN
        SIGNAL SET MESSAGE_TEXT = 'No se puede agregar tratamiento a una cita cancelada';
    ELSEIF v_estado_actual = 'liquidada' THEN
        SIGNAL SET MESSAGE_TEXT = 'No se puede agregar tratamiento a una cita liquidada';
    ELSE
        -- Obtener costo base del tratamiento
        SELECT costo_base INTO v_costo_base FROM tratamiento WHERE id_tratamiento = p_id_tratamiento;
        
        -- Calcular subtotal
        SET v_subtotal = v_costo_base * p_cantidad;
        
        -- Insertar tratamiento aplicado
        INSERT INTO tratamiento_aplicado (id_cita, id_tratamiento, cantidad, subtotal)
        VALUES (p_id_cita, p_id_tratamiento, p_cantidad, v_subtotal);
        
        SELECT LAST_INSERT_ID() AS id_tratamiento_aplicado, 'Tratamiento agregado correctamente' AS mensaje;
    END IF;
END //
DELIMITER ;

-- ============================================
-- 5. FUNCIONES
-- ============================================

-- --------------------------------------------
-- Función: Calcular Total de una Cita
-- --------------------------------------------
DELIMITER //
CREATE FUNCTION fn_calcular_total_cita(p_id_cita INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    
    SELECT COALESCE(SUM(subtotal), 0) INTO v_total
    FROM tratamiento_aplicado
    WHERE id_cita = p_id_cita;
    
    RETURN v_total;
END //
DELIMITER ;

-- --------------------------------------------
-- Función: Calcular Saldo Pendiente de una Cita
-- --------------------------------------------
DELIMITER //
CREATE FUNCTION fn_saldo_pendiente(p_id_cita INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_pagado DECIMAL(10,2);
    DECLARE v_saldo DECIMAL(10,2);
    
    SET v_total = fn_calcular_total_cita(p_id_cita);
    
    SET v_pagado = COALESCE(
        (SELECT SUM(monto) FROM pago WHERE id_cita = p_id_cita),
        0
    );
    
    SET v_saldo = v_total - v_pagado;
    
    RETURN GREATEST(v_saldo, 0);
END //
DELIMITER ;

-- --------------------------------------------
-- Función: Contar Citas Activas de un Dentista en una Fecha
-- --------------------------------------------
DELIMITER //
CREATE FUNCTION fn_citas_activas_dentista(p_id_dentista INT, p_fecha DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_citas INT;
    
    SELECT COUNT(*) INTO v_citas
    FROM cita
    WHERE id_dentista = p_id_dentista
      AND DATE(fecha_hora) = p_fecha
      AND estado NOT IN ('cancelada');
    
    RETURN v_citas;
END //
DELIMITER ;

-- --------------------------------------------
-- Función: Obtener la Edad de un Paciente
-- --------------------------------------------
DELIMITER //
CREATE FUNCTION fn_edad_paciente(p_id_paciente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_fecha_nacimiento DATE;
    DECLARE v_edad INT;
    
    SELECT fecha_nacimiento INTO v_fecha_nacimiento
    FROM paciente
    WHERE id_paciente = p_id_paciente;
    
    SET v_edad = TIMESTAMPDIFF(YEAR, v_fecha_nacimiento, CURDATE());
    
    IF v_fecha_nacimiento > DATE_SUB(CURDATE(), INTERVAL v_edad YEAR) THEN
        SET v_edad = v_edad - 1;
    END IF;
    
    RETURN v_edad;
END //
DELIMITER ;

-- ============================================
-- 6. TRIGGERS
-- ============================================

-- --------------------------------------------
-- Trigger: Evitar pagos mayores al adeudo
-- --------------------------------------------
DELIMITER //
CREATE TRIGGER trg_validar_pago_mayor
BEFORE INSERT ON pago
FOR EACH ROW
BEGIN
    DECLARE v_saldo_pendiente DECIMAL(10,2);
    
    SET v_saldo_pendiente = fn_saldo_pendiente(NEW.id_cita);
    
    IF NEW.monto > v_saldo_pendiente AND v_saldo_pendiente > 0 THEN
        SIGNAL SET MESSAGE_TEXT = CONCAT('El monto del pago ($', NEW.monto, ') excede el saldo pendiente ($', v_saldo_pendiente, ')');
    END IF;
END //
DELIMITER ;

-- --------------------------------------------
-- Trigger: Actualizar automáticamente el subtotal de un tratamiento aplicado
-- --------------------------------------------
DELIMITER //
CREATE TRIGGER trg_actualizar_subtotal
BEFORE INSERT ON tratamiento_aplicado
FOR EACH ROW
BEGIN
    DECLARE v_costo_base DECIMAL(10,2);
    
    SELECT costo_base INTO v_costo_base
    FROM tratamiento
    WHERE id_tratamiento = NEW.id_tratamiento;
    
    SET NEW.subtotal = v_costo_base * NEW.cantidad;
END //
DELIMITER ;

-- --------------------------------------------
-- Trigger: Validar horario correcto de una cita (evitar duplicados)
-- --------------------------------------------
DELIMITER //
CREATE TRIGGER trg_validar_horario
BEFORE INSERT ON cita
FOR EACH ROW
BEGIN
    DECLARE v_hora TIME;
    DECLARE v_dia_semana INT;
    
    SET v_hora = TIME(NEW.fecha_hora);
    SET v_dia_semana = DAYOFWEEK(NEW.fecha_hora);
    
    -- Validar horario de atención (8:00 a 20:00)
    IF v_hora < '08:00:00' OR v_hora > '20:00:00' THEN
        SIGNAL SET MESSAGE_TEXT = 'Las citas solo pueden programarse entre las 8:00 y las 20:00 horas';
    END IF;
    
    -- No permitir domingos
    IF v_dia_semana = 1 THEN
        SIGNAL SET MESSAGE_TEXT = 'No se pueden agendar citas los domingos';
    END IF;
    
    -- Verificar conflicto con dentista
    IF EXISTS (
        SELECT 1 FROM cita 
        WHERE id_dentista = NEW.id_dentista
          AND estado NOT IN ('cancelada')
          AND id_cita != NEW.id_cita
          AND (
            NEW.fecha_hora BETWEEN fecha_hora AND DATE_ADD(fecha_hora, INTERVAL duracion_minutos MINUTE)
            OR DATE_ADD(NEW.fecha_hora, INTERVAL NEW.duracion_minutos MINUTE) BETWEEN fecha_hora AND DATE_ADD(fecha_hora, INTERVAL duracion_minutos MINUTE)
          )
    ) THEN
        SIGNAL SET MESSAGE_TEXT = 'El dentista ya tiene una cita programada en ese horario';
    END IF;
    
    -- Verificar conflicto con consultorio
    IF EXISTS (
        SELECT 1 FROM cita 
        WHERE id_consultorio = NEW.id_consultorio
          AND estado NOT IN ('cancelada')
          AND id_cita != NEW.id_cita
          AND (
            NEW.fecha_hora BETWEEN fecha_hora AND DATE_ADD(fecha_hora, INTERVAL duracion_minutos MINUTE)
            OR DATE_ADD(NEW.fecha_hora, INTERVAL NEW.duracion_minutos MINUTE) BETWEEN fecha_hora AND DATE_ADD(fecha_hora, INTERVAL duracion_minutos MINUTE)
          )
    ) THEN
        SIGNAL SET MESSAGE_TEXT = 'El consultorio está ocupado en ese horario';
    END IF;
END //
DELIMITER ;

-- --------------------------------------------
-- Trigger: Cambiar el estado de la cita a "liquidada" cuando saldo = 0
-- --------------------------------------------
DELIMITER //
CREATE TRIGGER trg_cita_liquidada
AFTER INSERT ON pago
FOR EACH ROW
BEGIN
    DECLARE v_saldo DECIMAL(10,2);
    DECLARE v_estado_actual ENUM('programada', 'en_atencion', 'completada', 'cancelada', 'liquidada');
    
    SET v_saldo = fn_saldo_pendiente(NEW.id_cita);
    
    IF v_saldo <= 0 THEN
        SELECT estado INTO v_estado_actual FROM cita WHERE id_cita = NEW.id_cita;
        
        IF v_estado_actual != 'liquidada' AND v_estado_actual != 'cancelada' THEN
            UPDATE cita SET estado = 'liquidada' WHERE id_cita = NEW.id_cita;
        END IF;
    END IF;
END //
DELIMITER ;

-- ============================================
-- 7. INSERCIÓN DE DATOS DE PRUEBA
-- ============================================

-- Insertar Especialidades
INSERT INTO especialidad (nombre, descripcion, duracion_minutos) VALUES
('Odontología General', 'Atención dental básica y preventiva', 60),
('Ortodoncia', 'Corrección de dientes y mandíbulas mal alineadas', 45),
('Endodoncia', 'Tratamiento de conducto radicular', 90),
('Periodoncia', 'Tratamiento de encías y huesos de soporte', 60),
('Cirugía Oral', 'Extracciones y cirugías mayores', 60),
('Odontopediatría', 'Atención dental para niños', 45),
('Prótesis Dental', 'Dentaduras y coronas', 90),
('Implantología', 'Implantes dentales', 120);

-- Insertar Pacientes
INSERT INTO paciente (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, genero, telefono, email, direccion) VALUES
('Juan', 'García', 'López', '1985-03-15', 'M', '5551234567', 'juan.garcia@email.com', 'Av. Principal 123, Col. Centro'),
('María', 'Rodríguez', 'Martínez', '1990-07-22', 'F', '5552345678', 'maria.rodriguez@email.com', 'Calle Norte 456, Col. Norte'),
('Pedro', 'Hernández', 'González', '1978-11-08', 'M', '5553456789', 'pedro.hernandez@email.com', 'Av. Oeste 789, Col. Oeste'),
('Ana', 'López', 'Fernández', '1995-01-30', 'F', '5554567890', 'ana.lopez@email.com', 'Calle Sur 321, Col. Sur'),
('Carlos', 'Martínez', 'Sánchez', '1982-09-12', 'M', '5555678901', 'carlos.martinez@email.com', 'Av. Este 654, Col. Este'),
('Laura', 'Jiménez', 'Torres', '2000-05-18', 'F', '5556789012', 'laura.jimenez@email.com', 'Calle Centro 987, Col. Centro'),
('Roberto', 'Díaz', 'Morales', '1975-12-25', 'M', '5557890123', 'roberto.diaz@email.com', 'Av. Sur 147, Col. Sur'),
('Sofía', 'Castro', 'Ruiz', '1988-08-03', 'F', '5558901234', 'sofia.castro@email.com', 'Calle Norte 258, Col. Norte'),
('Miguel', 'Vargas', 'López', '1992-04-20', 'M', '5559012345', 'miguel.vargas@email.com', 'Av. Oeste 369, Col. Oeste'),
('Elena', 'Romero', 'Herrera', '1998-10-10', 'F', '5550123456', 'elena.romero@email.com', 'Calle Este 741, Col. Este');

-- Insertar Dentistas
INSERT INTO dentista (nombre, apellido_paterno, apellido_materno, cedula_profesional, telefono, email, id_especialidad) VALUES
('Dr. Alejandro', 'Mora', 'López', 'CED123456', '5551111111', 'alejandro.mora@clinica.com', 1),
('Dra. Carolina', 'Santos', 'Pérez', 'CED234567', '5552222222', 'carolina.santos@clinica.com', 2),
('Dr. Fernando', 'Cortés', 'Gómez', 'CED345678', '5553333333', 'fernando.cortes@clinica.com', 3),
('Dra. Gabriela', 'Núñez', 'Romero', 'CED456789', '5554444444', 'gabriela.nunez@clinica.com', 4),
('Dr. Ricardo', 'Delgado', 'Ángel', 'CED567890', '5555555555', 'ricardo.delgado@clinica.com', 5),
('Dra. Patricia', 'Mendoza', 'Flores', 'CED678901', '5556666666', 'patricia.mendoza@clinica.com', 6),
('Dr. Eduardo', 'Torres', 'Reyes', 'CED789012', '5557777777', 'eduardo.torres@clinica.com', 7),
('Dra. Cristina', 'Navarro', 'Castillo', 'CED890123', '5558888888', 'cristina.navarro@clinica.com', 8);

-- Insertar Consultorios
INSERT INTO consultorio (numero, nombre, piso) VALUES
('101', 'Consultorio 1', 1),
('102', 'Consultorio 2', 1),
('103', 'Consultorio 3', 1),
('201', 'Consultorio 4', 2),
('202', 'Consultorio 5', 2),
('203', 'Consultorio 6', 2),
('301', 'Sala de Cirugía', 3),
('S1', 'Sala de Rayos X', 1);

-- Insertar Tratamientos
INSERT INTO tratamiento (nombre, descripcion, costo_base, duracion_minutos) VALUES
('Limpieza Dental', 'Limpieza profesional de dientes y encías', 500.00, 45),
('Revision y Diagnóstico', 'Exploración completa de состояние dental', 300.00, 30),
('Obturación (Empaste)', 'Resina compuesta para caries', 800.00, 60),
('Endodóncia (Conducto)', 'Tratamiento de conducto radicular', 3500.00, 90),
('Extracción Simple', 'Extracción de pieza dental', 600.00, 30),
('Extracción de Muelas del juicio', 'Extracción de terceros molares', 1200.00, 60),
('Ortodoncia metálica', 'Tratamiento de ortodoncia con brackets metálicos', 15000.00, 45),
('Ortodoncia invisible', 'Tratamiento con aligners transparentes', 25000.00, 45),
('Blanqueamiento Dental', 'Blanqueamiento profesional', 2500.00, 60),
('Corona de Porcelana', 'Corona dental de porcelana', 4500.00, 90),
('Implante Dental', 'Implante de titanio con corona', 12000.00, 120),
('Tratamiento de Encías', 'Limpieza profunda de encías', 1000.00, 60),
('Sellador Dental', 'Aplicación de selladores', 400.00, 30),
('Fluorización', 'Aplicación de flúor', 350.00, 30),
('Radiografía Periapical', 'Radiografía de zona específica', 250.00, 15),
('Ortopantomografía', 'Radiografía de toda la boca', 400.00, 15);

-- Insertar Citas (unas cuantas de ejemplo)
INSERT INTO cita (id_paciente, id_dentista, id_consultorio, fecha_hora, duracion_minutos, estado, observaciones) VALUES
(1, 1, 1, '2024-01-15 10:00:00', 60, 'completada', 'Limpieza dental'),
(1, 1, 1, '2024-01-20 11:00:00', 60, 'completada', 'Seguimiento'),
(2, 2, 2, '2024-01-18 09:00:00', 90, 'completada', 'Colocación de brackets'),
(3, 3, 3, '2024-02-01 14:00:00', 90, 'programada', 'Tratamiento de conducto'),
(4, 4, 4, '2024-02-05 10:30:00', 60, 'programada', 'Tratamiento de encías'),
(5, 5, 1, '2024-02-10 16:00:00', 60, 'programada', 'Extracción'),
(6, 1, 2, '2024-02-12 11:00:00', 45, 'programada', 'Revision'),
(7, 2, 3, '2024-02-15 09:00:00', 90, 'programada', 'Ajuste de ortodoncia'),
(8, 4, 4, '2024-02-20 15:00:00', 60, 'programada', 'Limpieza profunda'),
(9, 1, 1, '2024-02-25 10:00:00', 60, 'programada', 'Blanqueamiento');

-- Insertar Tratamientos Aplicados
INSERT INTO tratamiento_aplicado (id_cita, id_tratamiento, cantidad, subtotal) VALUES
(1, 1, 1, 500.00),
(2, 2, 1, 300.00),
(3, 7, 1, 15000.00),
(4, 4, 1, 3500.00),
(5, 12, 1, 1000.00),
(6, 5, 1, 600.00);

-- Insertar Pagos
INSERT INTO pago (id_cita, monto, metodo_pago, observaciones) VALUES
(1, 500.00, 'efectivo', 'Pago completo'),
(2, 300.00, 'tarjeta_debito', 'Pago completo'),
(3, 5000.00, 'transferencia', 'Primer abono'),
(3, 5000.00, 'transferencia', 'Segundo abono'),
(3, 3000.00, 'tarjeta_credito', 'Tercer abono'),
(5, 600.00, 'efectivo', 'Pago completo');

-- ============================================
-- 8. CONSULTAS BÁSICAS DE VALIDACIÓN
-- ============================================

-- 1. Pacientes con citas programadas
SELECT p.nombre, p.apellido_paterno, c.fecha_hora, e.nombre AS especialidad
FROM paciente p
JOIN cita c ON p.id_paciente = c.id_paciente
JOIN dentista d ON c.id_dentista = d.id_dentista
JOIN especialidad e ON d.id_especialidad = e.id_especialidad
WHERE c.estado = 'programada'
ORDER BY c.fecha_hora;

-- 2. Citas por dentist@ (ejemplo: Dr. Alejandro Mora)
SELECT c.id_cita, c.fecha_hora, c.estado, p.nombre AS paciente, con.numero AS consultorio
FROM cita c
JOIN paciente p ON c.id_paciente = p.id_paciente
JOIN consultorio con ON c.id_consultorio = con.id_consultorio
WHERE c.id_dentista = 1
ORDER BY c.fecha_hora;

-- 3. Tratamientos aplicados en una cita
SELECT t.nombre, ta.cantidad, ta.subtotal
FROM tratamiento_aplicado ta
JOIN tratamiento t ON ta.id_tratamiento = t.id_tratamiento
WHERE ta.id_cita = 3;

-- 4. Pacientes con saldo pendiente
SELECT DISTINCT p.nombre, p.apellido_paterno, c.id_cita, 
       fn_calcular_total_cita(c.id_cita) AS total,
       COALESCE(SUM(pag.monto), 0) AS pagado,
       fn_saldo_pendiente(c.id_cita) AS saldo_pendiente
FROM paciente p
JOIN cita c ON p.id_paciente = c.id_paciente
LEFT JOIN pago pag ON c.id_cita = pag.id_cita
WHERE c.estado NOT IN ('cancelada')
GROUP BY c.id_cita, p.nombre, p.apellido_paterno
HAVING fn_saldo_pendiente(c.id_cita) > 0;

-- 5. Dentistas con especialidad específica
SELECT d.nombre, d.apellido_paterno, e.nombre AS especialidad
FROM dentista d
JOIN especialidad e ON d.id_especialidad = e.id_especialidad
WHERE e.nombre = 'Ortodoncia'
ORDER BY d.apellido_paterno;

-- 6. Consultorios no utilizados en una fecha
SELECT c.numero, c.nombre
FROM consultorio c
WHERE c.activo = TRUE
  AND c.id_consultorio NOT IN (
    SELECT id_consultorio 
    FROM cita 
    WHERE DATE(fecha_hora) = '2024-02-01' 
      AND estado != 'cancelada'
  );

-- 7. Pacientes que han realizado al menos un pago
SELECT DISTINCT p.nombre, p.apellido_paterno, p.email
FROM paciente p
JOIN cita c ON p.id_paciente = c.id_paciente
JOIN pago pg ON c.id_cita = pg.id_cita
ORDER BY p.apellido_paterno;

-- 8. Citas con tratamientos de costo > $2000
SELECT c.id_cita, c.fecha_hora, t.nombre, t.costo_base
FROM cita c
JOIN tratamiento_aplicado ta ON c.id_cita = ta.id_cita
JOIN tratamiento t ON ta.id_tratamiento = t.id_tratamiento
WHERE t.costo_base > 2000;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================