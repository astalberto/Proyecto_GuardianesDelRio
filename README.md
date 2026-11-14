# Guardianes del Río 🌊

App móvil educativa sobre los ríos de Loja, Ecuador (Malacatos, Zamora y Jipiro). Combina información ambiental, aprendizaje interactivo y gamificación para que niños y jóvenes conozcan y cuiden sus ríos. Nace del Taller de Proyectos Urbano Arquitectónicos II.

## Módulos y equipo

| Integrante | Módulo (vertical, de datos a pantalla) |
|---|---|
| **Cody** | Información y mapa: catálogo de ríos, fichas, mapa interactivo, calidad del agua, fauna y flora |
| **Josué** | Aprendizaje y juegos: lecciones, quizzes, minijuegos, retos |
| **Alberto** | Perfil y gamificación: registro, avatar, puntos, insignias, ranking, notificaciones |

## Stack

- **App:** Flutter + Riverpod — Clean Architecture + MVVM, organización feature-first
- **Backend:** Firebase plan Spark (Auth, Firestore, FCM) + API FastAPI (Python) en Render con Firebase Admin SDK
- **Mapas:** Mapbox · **Imágenes de usuarios:** Cloudinary · **Calidad del agua:** API externa (consumida vía backend)

## Estructura del repo

```
guardianes_del_rio/   # App Flutter
backend/              # API FastAPI (motor de puntos, moderación, notificaciones)
firebase/             # Reglas de Firestore, índices y seeds
docs/
├── architecture/     # ARCHITECTURE, PROJECT_STRUCTURE, DATA_MODEL, API_CONTRACTS, SECURITY, TESTING_DEPLOYMENT
├── adr/              # Decisiones de arquitectura (ADR-0001…0008)
└── *.md              # Requerimientos y material fuente del taller
```

## Empezar

1. **Leer primero:** [docs/architecture/ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md) y [CONTRIBUTING.md](CONTRIBUTING.md).
2. **App:** `cd guardianes_del_rio && flutter pub get && flutter run --dart-define=API_BASE_URL=http://localhost:8000 --dart-define=MAPBOX_TOKEN=<tu_token>`
3. **Backend:** `cd backend && pip install -r requirements.txt && uvicorn app.main:app --reload` (requiere `.env` según `.env.example`; para desarrollo usa el Firebase Emulator Suite).
4. **Emuladores:** `firebase emulators:start` (Auth + Firestore) para trabajar sin tocar cuota.

## Reglas de oro (resumen — la lista completa está en [CLAUDE.md](CLAUDE.md))

- Ningún ViewModel toca Firebase ni HTTP: eso es de la capa Data.
- Los puntos, insignias y ranking **solo** los escribe el backend. El cliente emite eventos.
- Un módulo nunca importa los internals de otro: contratos de `core/` y eventos.
- `main` siempre compila; todo entra por PR revisado.
