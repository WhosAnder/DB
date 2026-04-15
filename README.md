# Base de Datos — Aldo García 🗄️

Este es el repositorio de **Aldo García** para la clase de **Bases de Datos** en la UDLAP.
Aquí están todas las actividades, ejercicios y scripts SQL que se vayan haciendo durante el semestre.

> Disfruta. 🎉

---

## ¿Qué hay aquí?

Scripts de SQL organizados por clase. Principalmente PostgreSQL.

| Carpeta | Contenido |
|---|---|
| `clase 11/` | Creación de tablas e inserción de datos (Artistas, CDs, Tracks) |
| `clase 14/` | Triggers: INSERT, UPDATE y DELETE |

También hay algunos scripts sueltos en la raíz de experimentos varios.

---

## Cómo usar

1. Tener PostgreSQL corriendo localmente
2. Crear una base de datos: `CREATE DATABASE db_clase;`
3. Ejecutar los scripts en orden (primero las tablas, luego los datos, luego los triggers)

```bash
psql -d db_clase -f "clase 11/actividad11.sql"
psql -d db_clase -f "clase 14/actividad14.sql"
```

---

## Autor

**Aldo García** — UDLAP, 4to semestre  
Clase de Bases de Datos, 2025
