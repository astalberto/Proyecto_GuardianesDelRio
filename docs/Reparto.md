Dentro de un ambiente universitario, una app móvil se desarrolla por diferentes etapas hasta llegar como mínimo hasta su primera versión en producción, sin embargo, hay un equipo detrás el cual debe repartir los roles, a continuación se detallará la modalidad de trabajo:
Normalmente siempre se reparte por capas, que si uno hace solo backend u otro hace solo frontend, con ayuda de inteligencia artificial se investigó y se decidió entre diferentes opciones. La mejor vía es manejar una **División por funcionalidades** (vertical o feature teams).
___
Cada uno lleva su módulo completo, de la base de datos a la pantalla

**Cody**: Información y mapa de ríos con fichas de cada río, mapa interactivo, calidad del agua (consumo de data de los sensores), fauna y flora
**Josué**: Aprendizaje y juegos con diferentes lecciones, quizzes, minijuegos y retos
**Alberto**: Perfil y gamificación como registro, avatar, puntos, insignias, ranking y notificaciones

# Historias

Para una primera versión primero se definirá una planificación desde un punto de vista general y reemplazable a través del tiempo siendo solamente una base o una pequeña referencia. En ordenar el desarrollo conviene pensar en capas de dependencia: primero lo que todos usan, después los módulos que se apoyan en eso, y al final lo que se construye encima.

### Fase 0: Cimientos (trabajo conjunto)

**F0.1 Repositorio y convenciones** (C lidera, todos participan)

- Repositorio único con ramas , al menos una revisión.
- Estructura de carpetas del proyecto móvil y del backend.
- Estándares de nombres y diseño, formatos de código.
- _Criterio de aceptación:_ la app compila en los tres equipos y el pipeline básico corre.

**F0.2 Sistema de diseño base** (A lidera, J y C revisan)

- Paleta de colores, tipografía, espaciados y componentes: botón, tarjeta, lista, barra de navegación.
- Tamaños de toque mínimos adecuados para niños y contraste accesible.
- _Criterio:_ existe una pantalla de muestra con todos los componentes.

**F0.3 Autenticación y sesión** (C lidera)

- Registro, inicio de sesión y cierre de sesión.
- Emisión y renovación de tokens. Almacenamiento seguro en el dispositivo.
- Roles: niño, docente o padre, administrador.
- _Depende de:_ F0.1.
- _Criterio:_ un usuario puede registrarse, iniciar sesión y mantener la sesión tras cerrar la app.

**F0.4 Modelo de datos y contrato de API** (C lidera, J y A validan)

- Entidades mínimas: Usuario, Río, Tramo o Punto de interés, Lección, Pregunta, Progreso, Puntos, Insignia.
- Especificación OpenAPI de endpoints de cada módulo.
- _Criterio:_ el contrato está aprobado por los tres y publicado en el repositorio.

**F0.5 Esqueleto de navegación** (J lidera)

- Rutas entre pantallas vacías: inicio, mapa, ríos, lecciones, juegos, perfil, ranking.
- Datos simulados en cada pantalla.
- _Depende de:_ F0.2, F0.4.
- _Criterio:_ se puede recorrer toda la app sin errores aunque no tenga datos reales.

---

### Fase 1: Núcleo de contenido 

**F1.1 Catálogo de ríos de Loja** (T)

- CRUD de ríos y puntos de interés con nombre, descripción, ubicación, imágenes y datos de calidad del agua.
- Endpoint de lectura para la app y panel básico de carga para el equipo.
- _Depende de:_ F0.3, F0.4.
- _Criterio:_ al menos los ríos principales de Loja están cargados y se consultan desde la app.

**F1.2 Mapa interactivo** (T)

- Mapa con marcadores de los ríos y puntos de interés del catálogo.
- Al tocar un marcador se abre la ficha.
- _Depende de:_ F1.1, F0.5.
- _Criterio:_ el mapa muestra datos reales y la ficha abre desde cualquier marcador.

**F1.3 Pantalla de fichas de río** (T)

- Vista detallada con texto corto, imágenes y datos para niños.
- _Depende de:_ F1.1.
- _Criterio:_ cada río tiene su ficha completa.

**F1.4 Motor de contenido educativo** (J)

- Modelo genérico de lección: título, pasos, texto, imagen y bloque de preguntas.
- Renderizado de lecciones en la app.
- _Depende de:_ F0.4, F0.5.
- _Criterio:_ una lección de prueba se recorre completa desde el backend.

**F1.5 Carga de contenido educativo** (J)

- Creación y edición de lecciones desde el panel.
- _Depende de:_ F1.4.
- _Criterio:_ el equipo puede crear una lección nueva sin tocar código.

---

### Fase 2: Progreso y lógica de juego 

**F2.1 Registro de progreso** (J lidera, A apoya)

- Guarda lecciones completadas, preguntas respondidas y fecha.
- Emite eventos internos: `LeccionCompletada`, `PreguntaRespondida`.
- _Depende de:_ F0.3, F1.4.
- _Criterio:_ completar una lección actualiza el progreso del usuario en el backend.

**F2.2 Motor de puntos y reglas** (A)

- Reglas de puntuación en el servidor, separadas de la interfaz.
- Escucha los eventos de F2.1 y actualiza el saldo de puntos.
- _Depende de:_ F2.1.
- _Criterio:_ los puntos son consistentes aunque se repita un evento.

**F2.3 Perfil y avatar** (A)

- Datos del usuario, selección de avatar y estadísticas personales.
- _Depende de:_ F0.3, F0.5.
- _Criterio:_ el usuario puede cambiar su avatar y ver sus puntos y lecciones completadas.

**F2.4 Quizzes** (J)

- Preguntas de opción múltiple y verdadero o falso con retroalimentación inmediata.
- Cada respuesta genera un evento para F2.1.
- _Depende de:_ F1.4, F2.1.
- _Criterio:_ el resultado del quiz queda registrado y suma puntos.

---

### Fase 3: Interactividad y gamificación 

**F3.1 Minijuegos** (J)

- Al menos dos minijuegos educativos sobre ríos, por ejemplo clasificar residuos o identificar especies.
- Cada juego reporta su resultado a F2.1.
- _Depende de:_ F2.1, F2.4.
- _Criterio:_ el resultado de un juego se refleja en el progreso y en los puntos.

**F3.2 Insignias y niveles** (A)

- Reglas de desbloqueo a partir de eventos de progreso y puntos.
- Pantalla de insignias en el perfil.
- _Depende de:_ F2.2, F2.3.
- _Criterio:_ al cumplir una condición se muestra la insignia correspondiente.

**F3.3 Ranking** (A)

- Tabla de posiciones por grupo o aula, sin exponer datos personales de los menores.
- _Depende de:_ F2.2.
- _Criterio:_ el ranking se actualiza y respeta la privacidad.

**F3.4 Misiones ambientales** (C y J)

- Retos que combinan una ficha de río con una lección o un juego, por ejemplo “conoce el río X y completa su quiz”.
- _Depende de:_ F1.3, F2.4, F3.1.
- _Criterio:_ una misión se puede iniciar y completar de punta a punta.

**F3.5 Personaje mascota y animaciones** (A y J)

- Animaciones de reacción a respuestas correctas, incorrectas y logros.
- _Depende de:_ F0.2, F3.2. Se aplica sobre pantallas ya funcionales.
- _Criterio:_ las animaciones no bajan el rendimiento en dispositivos de gama básica.

---

### Fase 4: Experiencia completa 

**F4.1 Notificaciones y recordatorios** (A)

- Recordatorios de lecciones pendientes y avisos de logros.
- _Depende de:_ F2.1, F3.2.

**F4.2 Modo sin conexión** (C)

- Caché local de fichas, mapa y lecciones descargadas.
- Sincronización de progreso al recuperar la conexión.
- _Depende de:_ F1.1, F2.1.
- _Criterio:_ una lección descargada se completa sin señal y se sincroniza después.

**F4.3 Panel de padres y docentes** (C y A)

- Consulta de progreso de cada niño o aula.
- _Depende de:_ F2.1, F0.3.

**F4.4 Accesibilidad** (A)

- Lectura en voz alta, tamaño de texto ajustable y navegación sin texto complejo.
- _Depende de:_ F0.2 y todas las pantallas de las fases anteriores.

---

### Fase 5: Estabilización y publicación 

**F5.1 Pruebas con usuarios reales** (A coordina, todos participan)

- Sesiones con niños y docentes. Se inician desde la Fase 2 con prototipos y se cierran aquí.
- _Criterio:_ registro de hallazgos y ajustes aplicados.

**F5.2 Pruebas técnicas y corrección de errores** (C lidera)

- Pruebas de integración, carga y rendimiento.
- _Criterio:_ cero errores críticos abiertos.

**F5.3 Preparación para tiendas** (C coordina)

- Iconos, capturas, descripción.
- Política de privacidad y tratamiento de datos de menores.
- _Criterio:_ la app está lista para revisión en Google Play y App Store.

---

_Las semanas son estimadas y pueden ajustarse. El orden de dependencias no debe cambiar._
