# Actividad 01 — Cálculo Relacional

## Relaciones

Estudiante(cuenta, nombre, carrera)  
Curso(clave, nombre, creditos)  
Inscrito(cuenta, clave)

---

## TRC — Cálculo Relacional de Tuplas

### 1. Obtener las tuplas de estudiantes de la carrera 'Informática'

{ t | t ∈ Estudiante ∧ t.carrera = 'Informática' }

### 2. Obtener los nombres de estudiantes que están inscritos en algún curso

{ t | ∃e ∈ Estudiante ∃i ∈ Inscrito (t.nombre = e.nombre ∧ e.cuenta = i.cuenta) }

### 3. Obtener las claves de cursos en los que está inscrito el estudiante con cuenta '2023001'

{ t | ∃i ∈ Inscrito (t.clave = i.clave ∧ i.cuenta = '2023001') }

---

## DRC — Cálculo Relacional de Dominios

### 1. Obtener las cuentas de estudiantes de 'Sistemas'

{ c | Estudiante(c, \_, 'Sistemas') }

### 2. Obtener los nombres de cursos con más de 5 créditos

{ n | ∃cl ∃cr (Curso(cl, n, cr) ∧ cr > 5) }

### 3. Obtener los nombres de estudiantes inscritos en el curso con clave 'BD101'

{ n | ∃c ∃ca (Estudiante(c, n, ca) ∧ Inscrito(c, 'BD101')) }
