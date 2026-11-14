# Requerimientos del Aplicativo Móvil: Guardianes del Río

**Proyecto:** Taller de Proyectos Urbano Arquitectónicos II, Loja, Ecuador
**Fuentes:** Periódico general del taller, transcripción de notas completas y wireframe inicial del prototipo
**Fecha:** 13 de octubre de 2026

---

## 1. Descripción general

**Propósito:** App móvil educativa y de participación ciudadana que enseña a jóvenes, adultos y ciudadanía en general la realidad de los ríos Malacatos, Zamora y Jipiro en Loja: causas de contaminación e inundación, memoria de los barrios y acciones para protegerlos.

**Público objetivo:** jóvenes (principal), familias, estudiantes y habitantes de los sectores analizados.

**Objetivo pedagógico:** informar desde el origen y las causas de los problemas, y resaltar lo positivo: el agua todavía convive con la gente y las prácticas del habitar lojano siguen fluyendo junto a ella.

**Prioridades:** `MVP` = primera versión, `F2` = segunda fase.

---

## 2. Requerimientos funcionales

### RF-01. Onboarding y cuenta `MVP`
- Pantalla de bienvenida con "Comenzar aventura" e "Ya tengo cuenta".
- Registro e inicio de sesión (correo, Google) y modo invitado.
- Perfil básico: nombre, avatar, rango de edad y barrio (opcional).

### RF-02. Pantalla de inicio `MVP`
- Saludo personalizado, nivel y puntos acumulados.
- "Misión del día" con barra de progreso (ej. "Responde 5 preguntas sobre el río Malacatos").
- Lista de ríos con tarjeta, descripción corta e indicador de estado: **Saludable / Moderado / En riesgo**.

### RF-03. Contenido educativo por río y sector `MVP`

Estructura jerárquica: **Zona → Sector → Contenido**.

| Zona | Sectores |
|---|---|
| Sur | Capulí II, Capulí I, La Tebaida, Supermaxi |
| Centro | El León, Parque Simón Bolívar, El Mayorista |
| Norte | Parque Jipiro, La Paz, Amable María, Comil (La Banda), Sauces Norte I, Sauces Norte II |

Cada sector incluye:
- **Historia y evolución urbana** (ej. ampliación del perímetro urbano en 1997, canalización del Zamora desde los años 60).
- **Problemáticas:** contaminación, inundaciones, deslaves, residuos, inseguridad, falta de servicios.
- **Relación con el agua:** usos históricos y actuales.
- **Atlas biológico:** flora y fauna con foto, nombre común y científico.
- **Voces del territorio:** testimonios de vecinos.
- **"¿Sabías que…?":** datos curiosos (ej. aguacero de 76,6 l/m² el 10 de marzo de 2025).
- **Datos de contexto:** pendientes, cobertura de servicios, proximidad a equipamientos.

El detalle de río usa pestañas **Historia / Fauna / Amenazas**; se sugiere una cuarta, **Voces**.

### RF-04. Mapa interactivo `MVP`
- Recorrido de los ríos Malacatos y Zamora de sur a norte.
- Marcadores de los 12 sectores que abren su ficha.
- Capas activables: zonas de inundación, puntos de contaminación, zonas de deslave, descargas de aguas residuales, reportes ciudadanos.
- Geolocalización del usuario y sugerencia del sector más cercano.

### RF-05. Calidad y estado del agua `MVP`
- Indicador de calidad por río y sector (barra de porcentaje).
- Semáforo de estado: Saludable, Moderado, En riesgo.
- Indicar si el dato es oficial, estimado o editorial.

### RF-06. Trivias y juegos (módulo "Jugar") `MVP`
- Trivia de opción múltiple por río o sector: pregunta N/total, vidas, retroalimentación y puntos por acierto (+20 pts).
- Juegos de la sección "Entretenimiento" del periódico `F2`:
  - Sopa de letras
  - Laberinto
  - Crucigrama ecológico
  - Verdadero o falso
  - "Detective del río" (reto visual para identificar causas de inundación y malas prácticas)
  - Minijuego "Atrapa la basura"
- Relatos breves interactivos (ej. el río aprisionado en muros de hormigón, relatos sobre inseguridad nocturna en tramos abandonados).

### RF-07. Misiones y acción ciudadana `MVP`
- Misiones diarias, semanales y especiales con puntos.
- **Jornadas de limpieza:** listado, detalle, botón "Unirme" y recordatorio.
- **Reportar contaminación:** foto, ubicación automática, categoría (basura, vertido, escombros, mal olor, inundación, deslave) y descripción.
- Seguimiento del estado del reporte: recibido, en revisión, atendido.
- Reportes visibles en el mapa tras moderación.

### RF-08. Gamificación y perfil `MVP`
- Puntos, niveles, insignias (ej. "Guardián del agua") y racha diaria.
- Estadísticas: puntos, misiones completadas, insignias.
- Ranking juvenil; ranking por barrio o colegio `F2`.

### RF-09. Navegación `MVP`
Barra inferior con cinco pestañas: **Inicio, Mapa, Jugar, Misiones, Perfil**.

### RF-10. Notificaciones `F2`
- Recordatorio de misión del día y de jornadas de limpieza.
- Alertas de lluvias intensas o crecidas en sectores de riesgo (temporada crítica: marzo a mayo).
- Aviso de cambio de estado de un reporte.

### RF-11. Compartir y comunidad `F2`
- Compartir insignias, reportes y datos curiosos en redes sociales.
- Sección "Lo positivo": memoria y prácticas del habitar lojano junto al agua.

---

## 3. Requerimientos no funcionales

| ID | Categoría | Requerimiento |
|---|---|---|
| RNF-01 | Plataforma | Android (prioritario) e iOS. |
| RNF-02 | Conectividad | Modo offline para contenido educativo y trivias; sincronización posterior de reportes. |
| RNF-03 | Rendimiento | Carga de pantallas en menos de 3 s; caché de mapas. |
| RNF-04 | Usabilidad | Lenguaje sencillo y juvenil, íconos claros, navegación de máximo 3 toques a cualquier contenido. |
| RNF-05 | Accesibilidad | Contraste adecuado, tamaños de texto legibles, etiquetas para lectores de pantalla. |
| RNF-06 | Idioma | Español; extensible a otros idiomas. |
| RNF-07 | Privacidad | Consentimiento para geolocalización y fotos; protección de datos de menores; reportes anónimos opcionales. |
| RNF-08 | Seguridad | Autenticación segura; moderación de contenido subido por usuarios. |
| RNF-09 | Escalabilidad | Agregar ríos, sectores, trivias y misiones desde un panel, sin republicar la app. |
| RNF-10 | Identidad visual | Paleta azul-turquesa y verde lima, tipografía sans-serif moderna, coherente con el wireframe. |

---

## 4. Requerimientos de contenido y datos

- Base de datos de **12 sectores** con textos, imágenes, mapas y testimonios (a partir del periódico).
- Catálogo de **flora y fauna** por sector: faique, capulí, sauce, eucalipto, higuera, aliso, colibríes, mirlo grande, tórtola orejuda, entre otras.
- Banco de preguntas de trivia clasificado por río, sector y dificultad.
- Capas geográficas: pendientes, zonas inundables, márgenes de protección (30 m del río y 10–15 m de quebradas), descargas y colectores.
- Créditos y fuentes de imágenes del taller.

---

## 5. Requerimientos administrativos

- **Panel web** para gestionar contenido, trivias, misiones y jornadas de limpieza.
- Módulo de **moderación** de reportes.
- Exportación de datos (CSV o mapa) para entidades como el Municipio, la universidad o colectivos ambientales.
- **Analítica de uso:** sectores más consultados, reportes por zona, participación en misiones.

---

## 6. Observaciones sobre el wireframe y los documentos

1. **Río Punzara:** aparece en el wireframe (bienvenida y lista de ríos), pero los documentos no lo tratan. Agregar su contenido o quitarlo.
2. **Ríos frente a sectores:** el wireframe organiza por río y el periódico por zona y sector. Propuesta: cada ficha de río contiene un recorrido por sus sectores.
3. **Calidad del agua (72 %):** el periódico solo ofrece menciones cualitativas (*E. coli*, metales pesados). Definir la fuente del dato o presentarlo como índice ilustrativo.
4. **Pantallas faltantes en el wireframe:**
   - Mapa con capas
   - Detalle de sector
   - Juegos (sopa de letras, crucigrama, etc.)
   - Estado de reportes
   - Configuración
   - Estados vacíos y de error
5. **Equilibrio juego y aprendizaje:** el periódico busca informar y generar reflexión; la app debe mantener visible el mensaje de corresponsabilidad ciudadana.

---

## 7. Resumen de pantallas

| # | Pantalla | Estado en wireframe |
|---|---|---|
| 1 | Bienvenida / login | Existe |
| 2 | Inicio (misión del día, ríos) | Existe |
| 3 | Detalle de río | Existe |
| 4 | Trivia | Existe |
| 5 | Misiones y reporte | Existe |
| 6 | Perfil e insignias | Existe |
| 7 | Mapa interactivo con capas | Por diseñar |
| 8 | Detalle de sector | Por diseñar |
| 9 | Juegos (sopa de letras, crucigrama, laberinto, detective) | Por diseñar |
| 10 | Seguimiento de reportes | Por diseñar |
| 11 | Notificaciones y configuración | Por diseñar |
