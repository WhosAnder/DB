# Sistema de Gestión para Clínica Dental

## Documento Técnico

---

## Fase 1: Análisis del Problema

### 1.1 Entidades Principales

| Entidad | Descripción |
|--------|-------------|
| Paciente | Personas que recibe atención dental |
| Dentista | Profesionales que atienden a los pacientes |
| Especialidad | Rama de la odontología que practica un dentista |
| Consultorio | Espacio físico donde se atienden citas |
| Cita | Programación de atención médica |
| Tratamiento | Procedimiento dental disponible y su costo |
| TratamientoAplicado | Tratamiento realizado en una cita específica |
| Pago | Movimiento económico por servicios |

### 1.2 Atributos por Entidad

#### Paciente
| Atributo | Tipo | Restricciones |
|---------|------|--------------|
| id_paciente | INT | PK, AUTO_INCREMENT |
| nombre | VARCHAR(100) | NOT NULL |
| apellido_paterno | VARCHAR(100) | NOT NULL |
| apellido_materno | VARCHAR(100) | |
| fecha_nacimiento | DATE | NOT NULL |
| genero | CHAR(1) | CHECK (M/F/O) |
| telefono | VARCHAR(15) | NOT NULL |
| email | VARCHAR(100) | UNIQUE |
| direccion | TEXT | |
| fecha_registro | DATETIME | DEFAULT CURRENT_TIMESTAMP |
| activo | BOOLEAN | DEFAULT TRUE |

#### Dentista
| Atributo | Tipo | Restricciones |
|---------|------|--------------|
| id_dentista | INT | PK, AUTO_INCREMENT |
| nombre | VARCHAR(100) | NOT NULL |
| apellido_paterno | VARCHAR(100) | NOT NULL |
| apellido_materno | VARCHAR(100) | |
| cedula_profesional | VARCHAR(20) | UNIQUE, NOT NULL |
| telefono | VARCHAR(15) | |
| email | VARCHAR(100) | |
| id_especialidad | INT | FK, NOT NULL |
| activo | BOOLEAN | DEFAULT TRUE |

#### Especialidad
| Atributo | Tipo | Restricciones |
|---------|------|--------------|
| id_especialidad | INT | PK, AUTO_INCREMENT |
| nombre | VARCHAR(100) | UNIQUE, NOT NULL |
| descripcion | TEXT | |
| duracion_minutos | INT | DEFAULT 60 |

#### Consultorio
| Atributo | Tipo | Restricciones |
|---------|------|--------------|
| id_consultorio | INT | PK, AUTO_INCREMENT |
| numero | VARCHAR(10) | UNIQUE, NOT NULL |
| nombre | VARCHAR(100) | |
| piso | INT | DEFAULT 1 |
| activo | BOOLEAN | DEFAULT TRUE |

#### Cita
| Atributo | Tipo | Restricciones |
|---------|------|--------------|
| id_cita | INT | PK, AUTO_INCREMENT |
| id_paciente | INT | FK, NOT NULL |
| id_dentista | INT | FK, NOT NULL |
| id_consultorio | INT | FK, NOT NULL |
| fecha_hora | DATETIME | NOT NULL |
| duracion_minutos | INT | DEFAULT 60 |
| estado | ENUM | DEFAULT 'programada' |
| observaciones | TEXT | |
| fecha_registro | DATETIME | DEFAULT CURRENT_TIMESTAMP |

#### Tratamiento
| Atributo | Tipo | Restricciones |
|---------|------|--------------|
| id_tratamiento | INT | PK, AUTO_INCREMENT |
| nombre | VARCHAR(200) | NOT NULL |
| descripcion | TEXT | |
| costo_base | DECIMAL(10,2) | NOT NULL, >= 0 |
| duracion_minutos | INT | DEFAULT 60 |
| activo | BOOLEAN | DEFAULT TRUE |

#### TratamientoAplicado
| Atributo | Tipo | Restricciones |
|---------|------|--------------|
| id_tratamiento_aplicado | INT | PK, AUTO_INCREMENT |
| id_cita | INT | FK, NOT NULL |
| id_tratamiento | INT | FK, NOT NULL |
| cantidad | INT | DEFAULT 1, >= 1 |
| subtotal | DECIMAL(10,2) | NOT NULL |
| fecha_registro | DATETIME | DEFAULT CURRENT_TIMESTAMP |

#### Pago
| Atributo | Tipo | Restricciones |
|---------|------|--------------|
| id_pago | INT | PK, AUTO_INCREMENT |
| id_cita | INT | FK, NOT NULL |
| monto | DECIMAL(10,2) | NOT NULL, > 0 |
| fecha_pago | DATETIME | DEFAULT CURRENT_TIMESTAMP |
| metodo_pago | ENUM | DEFAULT 'efectivo' |
| observaciones | TEXT | |

### 1.3 Llaves Primarias y Foráneas

| Entidad | PK | FK |
|--------|----|----|
| Paciente | id_paciente | - |
| Dentista | id_dentista | id_especialidad |
| Especialidad | id_especialidad | - |
| Consultorio | id_consultorio | - |
| Cita | id_cita | id_paciente, id_dentista, id_consultorio |
| Tratamiento | id_tratamiento | - |
| TratamientoAplicado | id_tratamiento_aplicado | id_cita, id_tratamiento |
| Pago | id_pago | id_cita |

### 1.4 Relaciones y Cardinalidades

| Relación | Entidad A | Entidad B | Cardinalidad |
|-----------|-----------|----------|--------------|
| Tiene | Dentista | Especialidad | N:1 |
| Asigna | Cita | Paciente | N:1 |
| Atiende | Cita | Dentista | N:1 |
| Se realiza en | Cita | Consultorio | N:1 |
| Tiene | TratamientoAplicado | Cita | N:1 |
| Corresponde a | TratamientoAplicado | Tratamiento | N:1 |
| Registra | Pago | Cita | N:1 |

### 1.5 Restricciones de Integridad

- **NOT NULL**: Obligatorios: nombre_paciente, fecha_nacimiento, telefono, etc.
- **UNIQUE**: email_paciente, cedula_profesional_dentista, numero_consultorio
- **CHECK**: genero IN ('M','F','O'), monto > 0, costo_base >= 0
- **DEFAULT**: activos=TRUE, estado='programada', fecha_hora=CURRENT_TIMESTAMP
- **FOREIGN KEY**: Integridad referencial entre tablas

---

## Fase 2: Modelo Entidad-Relación

```
┌─────────────────┐       ┌─────────────────┐
│    ESPECIALIDAD │       │     DENTISTA    │
├─────────────────┤       ├─────────────────┤
│ id_especialidad │◄──────│ id_dentista     │
│ nombre (U)      │  N:1  │ nombre          │
│ descripcion     │       │ apellido_p     │
│ duracion_min    │       │ cedula_pro (U)  │
└─────────────────┘       │ telefono       │
                          │ email          │
         ▲                 │ id_especialidad│────┐
         │                 │ activo         │    │
         │                 └─────────────────┘    │
         │                          ▲            │
         │                          │            │
┌────────┴────────┐       ┌───────┴────────┐    │
│   CONSULTORIO   │       │      CITA       │    │
├─────────────────┤       ├─────────────────┤    │
│ id_consultorio  │       │ id_cita         │    │
│ numero (U)      │  N:1 │ id_paciente  ───┼────┤
│ nombre          │       │ id_dentista ────┘    │
│ piso            │       │ id_consultorio◄────┘
│ activo          │       │ fecha_hora      │
└─────────────────┘       │ estado         │
                ▲        │ observaciones  │
                │        └─────────────────┘
                │               ▲
                │               │
         ┌──────┴────────┐    │
         │    PACIENTE    │  N:1
         ├────────────────┤    │
         │ id_paciente   │◄───┘
         │ nombre        │
         │ apellido_p    │
         │ apellido_m    │
         │ fecha_nac     │
         │ genero        │
         │ telefono      │
         │ email (U)     │
         │ direccion     │
         │ fecha_reg     │
         │ activo       │
         └───────────────┘

┌───────────────────────┐    ┌─────────────────────┐
│    TRATAMIENTO        │    │ TRATAMIENTO APLICADO │
├───────────────────────┤    ├─────────────────────┤
│ id_tratamiento        │    │ id_tratamiento_ap   │
│ nombre                │N:1 │ id_cita          ◄──┼───┐
│ descripcion           │────│ id_tratamiento ─────┘   │
│ costo_base (>=0)      │    │ cantidad         │
│ duracion_min          │    │ subtotal          │
│ activo               │    │ fecha_reg         │
└───────────────────────┘    └─────────────────────┘

         ▲
         │
         │  N:1
┌────────┴────────┐
│      PAGO       │
├────────────────┤
│ id_pago        │
│ id_cita     ◄──┼───┐
│ monto (>0)     │   │
│ fecha_pago     │   │
│ metodo_pago     │   │
│ observaciones  │   │
└────────────────┘   │
                     │
                     └──┘

```

---

## Fase 3: Normalización (3FN)

### 3.1 Primera Forma Normal (1FN)

**Cumplimiento:** ✓

Cada tabla tiene atomicidad de atributos:
- No hay grupos repetidos (cada campo contiene un solo valor)
- No hay atributos multivaluados
- Ejemplo: El paciente tiene campos individuales para nombre, apellido_paterno, apellido_materno en lugar de un campo "nombres" con valores separados

### 3.2 Segunda Forma Normal (2FN)

**Cumplimiento:** ✓

Todas las tablas tienen llaves simples (no hay claves compuestas), por lo tanto:
- No existen dependencias parciales respecto a claves compuestas
- Cada atributo depende completamente de su llave primaria

### 3.3 Tercera Forma Normal (3FN)

**Cumplimiento:** ✓

No existen dependencias transitivas:
- El costo_base del tratamiento es un valor atómico
- Los atributos de cada entidad dependen directamente de su PK
- No hay atributos que dependan de atributos no clave
- Ejemplo: El subtotal en TratamientoAplicado se calcula, pero también se almacena para auditoría

### 3.4 Justificación de Integridad Referencial

- Todas las FK tienen restricciones ON DELETE RESTRICT o ON DELETE CASCADE
- No se permite eliminar dentistas con citas activas
- Los pagos impedirán eliminación de citas relacionadas

---

## Fase 4: Implementación SQL

### 4.1 Creación de Base de Datos

Consultar script SQL separado: `clinica_dental.sql`

### 4.2 Datos de Prueba

Consultar script SQL separado: `clinica_dental.sql`

---

## Fase 5: Lógica de Negocio

### 5.1 Procedimientos Almacenados

1. **sp_registrar_cita**: Inserta nueva cita
2. **sp_registrar_pago**: Registra pago para una cita
3. **sp_cancelar_cita**: Cancela una cita existente
4. **sp_agregar_tratamiento**: Agrega tratamiento a una cita

### 5.2 Funciones

1. **fn_calcular_total_cita**: Suma subtotales de tratamientos aplicados
2. **fn_saldo_pendiente**: Calcula resta de total - pagos realizados
3. **fn_citas_activas_dentista**: Cuenta citas en fecha específica
4. **fn_edad_paciente**: Calcula edad a partir de fecha_nacimiento

### 5.3 Triggers

1. **trg_validar_pago_mayor**: Impide pagos mayores al adeudo
2. **trg_actualizar_subtotal**: Calcula subtotal automáticamente
3. **trg_validar_horario**: Evita citas overlapped
4. **trg_cita_liquidada**: Cambia estado cuando saldo=0

---

## Fase 6: Álgebra y Cálculo Relacional

### Consulta 1
**Enunciado:** Listar a los pacientes con citas programadas.

**Álgebra Relacional:**
```
π nombre, apellido_paterno, apellido_materno (σ estado='programada' (Paciente ⨝ Cita))
```

**Cálculo Relacional:**
```
{p.nombre, p.apellido_paterno, p.apellido_materno | 
 Paciente(p) ∧ ∃c (Cita(c) ∧ c.id_paciente = p.id_paciente ∧ c.estado = 'programada')}
```

**Explicación:** Proyecta los nombres de pacientes que tienen al menos una cita con estado 'programada'.

---

### Consulta 2
**Enunciado:** Obtener las citas atendidas por un dentista específico.

**Álgebra Relacional:**
```
π id_cita, fecha_hora, estado (σ id_dentista = 5 (Cita))
```

**Cálculo Relacional:**
```
{c.id_cita, c.fecha_hora, c.estado | 
 Cita(c) ∧ c.id_dentista = 5}
```

**Explicación:** Filtra todas las citas del dentista con id=5.

---

### Consulta 3
**Enunciado:** Mostrar los tratamientos aplicados en una cita determinada.

**Álgebra Relacional:**
```
π t.nombre, ta.cantidad, ta.subtotal 
(σ ta.id_cita = 10 (TratamientoAplicado ⨝ Tratamiento))
```

**Cálculo Relacional:**
**
{t.nombre, ta.cantidad, ta.subtotal | 
 ∃ta (TratamientoAplicado(ta) ∧ ∃t (Tratamiento(t) ∧ 
 ta.id_tratamiento = t.id_tratamiento ∧ ta.id_cita = 10))}
```

**Explicación:** Join entre tratamientos aplicados y catálogo de tratamientos para cita id=10.

---

### Consulta 4
**Enunciado:** Obtener a los pacientes con saldo pendiente.

**Álgebra Relacional:**
```
π p.id_paciente, p.nombre, p.apellido_paterno 
(σ saldo_pendiente > 0 (Paciente ⨝ Cita ⨝ TratamientoAplicado ⨝ Pago))
```

**Cálculo Relacional:**
**
{p.id_paciente, p.nombre, p.apellido_paterno | 
 Paciente(p) ∧ ∃c ∃ta ∃pa (Cita(c) ∧ TratamientoAplicado(ta) ∧ Pago(pa) ∧
 c.id_paciente = p.id_paciente ∧ ta.id_cita = c.id_cita ∧ pa.id_cita = c.id_cita ∧
 (SUM(ta.subtotal) - SUM(pa.monto)) > 0)}
```

**Explicación:** Pacientes cuyo total de tratamientos excede sus pagos realizados.

---

### Consulta 5
**Enunciado:** Mostrar a los dentistas con una especialidad específica.

**Álgebra Relacional:**
```
π d.nombre, d.apellido_paterno (σ d.id_especialidad = 3 (Dentista ⨝ Especialidad))
```

**Cálculo Relacional:**
**
{d.nombre, d.apellido_paterno | 
 Dentista(d) ∧ Especialidad(e) ∧ d.id_especialidad = e.id_especialidad ∧ e.nombre = 'Ortodoncia'}
```

**Explicación:** Filtra dentistas cuya especialidad es Ortodoncia.

---

### Consulta 6
**Enunciado:** Obtener los consultorios que no han sido utilizados en una fecha dada.

**Álgebra Relacional:**
```
π id_consultorio, numero (Consultorio) - π id_consultorio, numero (σ DATE(fecha_hora) = '2024-01-15' (Cita))
```

**Cálculo Relacional:**
**
{c.id_consultorio, c.numero | 
 Consultorio(c) ∧ ¬∃cit (Cita(cit) ∧ DATE(cit.fecha_hora) = '2024-01-15' ∧ c.id_consultorio = cit.id_consultorio)}
```

**Explicación:** Resta los consultorios ocupados en la fecha de todos los consultorios.

---

### Consulta 7
**Enunciado:** Mostrar a los pacientes que han realizado al menos un pago.

**Álgebra Relacional:**
```
π DISTINCT p.nombre, p.apellido_paterno (Paciente ⨝ Cita ⨝ Pago)
```

**Cálculo Relacional:**
**
{p.nombre, p.apellido_paterno | 
 Paciente(p) ∧ ∃c ∃pa (Cita(c) ∧ Pago(pa) ∧ c.id_paciente = p.id_paciente ∧ pa.id_cita = c.id_cita)}
```

**Explicación:** Proyección de pacientes con pagos registrados.

---

### Consulta 8
**Enunciado:** Obtener las citas en las que se aplicó un tratamiento de costo superior a $2000.

**Álgebra Relacional:**
**
π c.id_cita, c.fecha_hora, t.nombre 
(σ t.costo_base > 2000 (Cita ⨝ TratamientoAplicado ⨝ Tratamiento))
```

**Cálculo Relacional:**
**
{c.id_cita, c.fecha_hora, t.nombre | 
 Cita(c) ∧ ∃ta ∃t (TratamientoAplicado(ta) ∧ Tratamiento(t) ∧
 ta.id_cita = c.id_cita ∧ ta.id_tratamiento = t.id_tratamiento ∧ t.costo_base > 2000)}
```

**Explicación:** Citas con tratamientos cuyo costo_base supera $2000.

---

## Anexo: Tabla de Estados de Cita

| Estado | Descripción |
|--------|--------------|
| programada | Cita confirmada, pendiente de atención |
| en_atencion | Paciente en consulta |
| completada | Atención finalizada |
| cancelada | Cita cancelada |
| liquidada | Saldo cubierto completamente |

## Anexo: Tabla de Métodos de Pago

| Método | Descripción |
|--------|--------------|
| efectivo | Pago en dinero físico |
| tarjeta_credito | Pago con tarjeta de crédito |
| tarjeta_debito | Pago con tarjeta de débito |
| transferencia | Depósito bancario |
| seguro | Billing a seguro dental |