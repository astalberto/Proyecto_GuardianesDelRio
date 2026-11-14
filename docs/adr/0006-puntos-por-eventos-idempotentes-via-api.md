# ADR-0006: Puntuación por eventos idempotentes procesados en la API

- **Estado:** Aceptada (2026-11-14)
- **Contexto:** Reglas 7 y 8: los puntos no pueden confiar en el cliente y deben ser consistentes aunque un evento se repita (criterio F2.2). Además hay modo offline (RNF-02): los eventos pueden reenviarse. Y los módulos deben estar desacoplados: lecciones/juegos (Josué) no deben conocer el motor de puntos (Alberto).
- **Decisión:**
  1. Los módulos emiten `ProgressEvent` con **ID determinista** (`{uid}_{refId}_{type}` + `_{yyyymmdd}` si es repetible por día) a través del único `ProgressEventRepository` de `core`, que encola localmente y envía `POST /events`.
  2. La API procesa cada evento en **una transacción Firestore**: create del documento evento (si existe ⇒ duplicado ⇒ 200 sin efectos), validación, cálculo de puntos según tabla del servidor, actualización de `user_points`/`progress`, evaluación de insignias.
  3. El cliente **jamás** envía puntos ni scores: para quizzes envía las respuestas crudas y el servidor recalcula.
- **Alternativas descartadas:** triggers de Firestore (sin Functions en Spark, ADR-0004); escritura de puntos desde el cliente con reglas de validación (imposible validar aritmética de incrementos con reglas; manipulable); IDs aleatorios con tabla de deduplicación (más complejo que el create-only con ID determinista).
- **Consecuencias:** reintentos, doble tap y replays son inocuos; la dependencia Josué→Alberto es solo el esquema del evento (API_CONTRACTS.md §3); trazabilidad total (cada punto tiene un evento causa). **Deuda registrada:** `correctIndex` legible en el cliente para feedback offline — mitigado con topes diarios y recálculo server-side; si se abusa, se añadirá corrección server-side en modo online (SECURITY.md §5).
