# ADR-0003: Cloud Firestore como única base de datos

- **Estado:** Aceptada (2026-11-14)
- **Contexto:** Había que elegir entre Firestore, Realtime Database o una combinación. Necesidades: consultas por río/sector/zona, modo offline (RNF-02, F4.2), reglas de seguridad finas por documento y campo (app de menores), listeners en tiempo real para puntos/progreso, contenido administrable sin republicar (RNF-09).
- **Decisión:** Cloud Firestore para todo; no se usa Realtime Database.
- **Justificación:** Firestore ofrece consultas ricas con índices, persistencia offline integrada en el SDK de Flutter, reglas con funciones y validación de campos (`affectedKeys`), y un modelo de colecciones que mapea directo al modelo de datos. RTDB solo ganaría en latencia de sincronización continua (no es un caso de uso aquí) y usar ambos violaría la regla 11 (no duplicar lógica) y complicaría reglas y seeds.
- **Consecuencias:** un solo motor que aprender y asegurar. Cuota Spark (50k lecturas/día) obliga a modelar para pocas lecturas: documentos agregados (ranking en 1 doc, resumen de progreso), steps embebidos en la lección, caché offline agresiva.
