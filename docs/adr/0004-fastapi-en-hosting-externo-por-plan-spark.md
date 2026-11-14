# ADR-0004: Backend Python como FastAPI en hosting externo gratuito (restricción plan Spark)

- **Estado:** Aceptada (2026-11-14)
- **Contexto:** La lógica crítica (puntos, insignias, moderación, FCM, proxy de calidad del agua) debe correr en servidor con credenciales privilegiadas (reglas 8 y 9). La opción natural en el ecosistema serían Cloud Functions for Firebase (Python), pero **el equipo usará el plan Spark (gratuito)**, que no incluye Cloud Functions (requieren Blaze). Cloud Run queda descartado por la misma razón.
- **Decisión:** Una API **FastAPI** (`backend/`) empaquetada en Docker y desplegada en el **free tier de Render**, usando **Firebase Admin SDK** con una service account (env vars del hosting) para acceder a Firestore, Auth y FCM — todo compatible con Spark. El flujo de puntos pasa de "trigger de Firestore" a "request/response": el cliente envía el evento a `POST /events` y la API lo procesa transaccionalmente.
- **Alternativas descartadas:** Cloud Functions Python (Blaze); FastAPI en Cloud Run (Blaze); "sin backend" con lógica en el cliente (viola la regla 8: puntos manipulables); PythonAnywhere/Railway/Fly como primera opción (equivalentes — el Dockerfile los mantiene disponibles como plan B).
- **Consecuencias:**
  - FastAPI genera OpenAPI automáticamente (cumple F0.4).
  - **Trade-off principal: cold start** del free tier (~30–60 s tras 15 min de inactividad). Mitigado por: cola local de eventos con reintento (la UX no bloquea), el cron de recordatorios que mantiene la API tibia, y migración trivial a instancia paga o a Blaze+Functions si el proyecto crece (cambia el despliegue, no la arquitectura).
  - El modelo request/response es más fácil de testear y razonar que los triggers.
  - Las reglas de Firestore pueden negar TODO acceso de escritura del cliente a datos críticos, porque el Admin SDK las bypasea.
