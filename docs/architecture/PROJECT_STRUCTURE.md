# PROJECT_STRUCTURE.md — Estructura del proyecto

> Entregable 3. Estructura de carpetas del monorepo: app Flutter (feature-first + Clean Architecture + MVVM), backend FastAPI y documentación.
> Regla: no se crean carpetas vacías "por patrón"; cada carpeta aparece cuando su primera pieza existe.

## 1. Vista general del monorepo

```
Proyecto_GuardianesDelRio/
├── CLAUDE.md                    # Memoria del proyecto para Claude Code
├── README.md                    # Visión general y cómo empezar
├── CONTRIBUTING.md              # Flujo de trabajo del equipo
├── docs/
│   ├── architecture/            # Estos documentos
│   ├── adr/                     # Architecture Decision Records
│   └── *.md                     # Requerimientos y material fuente (ya existentes)
├── guardianes_del_rio/          # App Flutter
├── backend/                     # API FastAPI (Python)
├── firebase/                    # Configuración compartida de Firebase
│   ├── firestore.rules          # Reglas de seguridad (única fuente de verdad)
│   ├── firestore.indexes.json
│   └── seeds/                   # Scripts/JSON de datos iniciales (ríos, lecciones de prueba)
└── .github/
    └── workflows/               # CI (analyze+test app, pytest backend) y cron de recordatorios
```

## 2. App Flutter — `guardianes_del_rio/lib/`

```
lib/
├── main.dart                        # Entry point: inicializa Firebase, ProviderScope, router
├── app.dart                         # MaterialApp.router, theme, localización
│
├── core/                            # ÚNICA fuente de verdad de lo compartido (regla 7)
│   ├── config/                      # AppConfig: flavor, API_BASE_URL, MAPBOX_TOKEN (--dart-define)
│   ├── error/                       # Failure (sealed): Network/Auth/Validation/ServerFailure
│   ├── theme/                       # Design system F0.2: colores, tipografía, espaciados, componentes base
│   ├── navigation/                  # Router (go_router): rutas de las 5 pestañas + detalle
│   ├── widgets/                     # Componentes reutilizables: GdrButton, GdrCard, GdrBadgeChip...
│   ├── domain/                      # Entidades y contratos TRANSVERSALES
│   │   ├── entities/                #   User, UserRole, ProgressEvent, EventType
│   │   └── events/                  #   Definición de eventos de progreso (el "idioma" entre módulos)
│   ├── data/
│   │   ├── firebase/                # Providers de FirebaseAuth/Firestore (lo único que los conoce)
│   │   ├── api/                     # ApiClient: HTTP hacia la FastAPI, adjunta ID token, mapea errores
│   │   └── local/                   # EventQueue offline (cola persistente de eventos pendientes)
│   └── utils/                       # Helpers puros (formatos, validadores)
│
└── features/                        # Un subárbol por funcionalidad; dueño indicado
    │
    ├── auth/                        # (Alberto, coordina F0.3) registro, login, invitado, sesión
    │   ├── domain/
    │   │   ├── repositories/        #   AuthRepository (contrato)
    │   │   └── usecases/            #   SignInUseCase, SignOutUseCase, GetSessionUseCase
    │   ├── data/
    │   │   ├── datasources/         #   FirebaseAuthDataSource
    │   │   └── repositories/        #   AuthRepositoryImpl
    │   └── presentation/
    │       ├── screens/             #   WelcomeScreen, LoginScreen, RegisterScreen
    │       ├── viewmodels/          #   AuthViewModel (Notifier)
    │       └── widgets/
    │
    ├── rivers/                      # (Cody) catálogo, fichas, sectores, fauna/flora
    ├── map/                         # (Cody) mapa Mapbox, marcadores, capas, geolocalización
    ├── water_quality/               # (Cody) indicador de calidad, semáforo, histórico
    │
    ├── learning/                    # (Josué) lecciones, motor de contenido, quizzes
    ├── games/                       # (Josué) minijuegos (trivia, sopa de letras, detective...)
    ├── missions/                    # (Josué + Cody) misiones diarias/ambientales
    │
    ├── profile/                     # (Alberto) perfil, avatar, estadísticas
    ├── gamification/                # (Alberto) puntos, insignias, niveles, ranking
    ├── reports/                     # (Cody/equipo) reportes ciudadanos de contaminación
    └── notifications/               # (Alberto) FCM, recordatorios, preferencias
```

Cada feature replica internamente la misma estructura mostrada en `auth/`:
`domain/{entities,repositories,usecases}`, `data/{datasources,models,repositories}`, `presentation/{screens,viewmodels,widgets}`.
`data/models/` contiene los DTOs de Firestore/API y sus mappers hacia las entidades de `domain/entities/`.

### Reglas de dependencia (verificables por imports)

- `features/X/presentation` → solo `features/X/domain` y `core/`.
- `features/X/data` → solo `features/X/domain` y `core/`.
- `features/X/**` **nunca** importa `features/Y/**` (regla 6). Lo compartido se promueve a `core/`.
- `core/domain` no importa nada de Firebase ni HTTP (regla 14).
- Solo `core/data/firebase` y `features/*/data/datasources` conocen los SDKs.

## 3. Ubicación de las piezas de ejemplo (pedidas en el prompt)

| Pieza | Ruta |
|---|---|
| `RiverRepository` (contrato) | `lib/features/rivers/domain/repositories/river_repository.dart` |
| `RiverRepositoryImpl` | `lib/features/rivers/data/repositories/river_repository_impl.dart` |
| `GetRiversUseCase` | `lib/features/rivers/domain/usecases/get_rivers_usecase.dart` |
| `RiverViewModel` | `lib/features/rivers/presentation/viewmodels/river_viewmodel.dart` |
| `RiverScreen` | `lib/features/rivers/presentation/screens/river_screen.dart` |
| `FirebaseRiverDataSource` | `lib/features/rivers/data/datasources/firebase_river_datasource.dart` |
| `WaterQualityModel` (DTO) | `lib/features/water_quality/data/models/water_quality_model.dart` (entidad: `.../domain/entities/water_quality_measurement.dart`) |
| `QuizRepository` | `lib/features/learning/domain/repositories/quiz_repository.dart` |
| `AwardPointsUseCase`* | Servidor: `backend/app/services/points_engine.py`. En la app solo existe `SubmitProgressEventUseCase` (`lib/core/domain/events/`) — otorgar puntos es exclusivo del backend (regla 8) |
| `UserProfileViewModel` | `lib/features/profile/presentation/viewmodels/user_profile_viewmodel.dart` |

\* Decisión consciente: un `AwardPointsUseCase` cliente violaría la regla 8; el caso de uso del cliente es *emitir el evento*, no otorgar puntos.

## 4. Backend — `backend/`

```
backend/
├── Dockerfile                       # Imagen para Render/Railway/Fly
├── requirements.txt                 # fastapi, uvicorn, firebase-admin, httpx, cloudinary, pytest
├── .env.example                     # Variables requeridas (sin valores reales)
├── app/
│   ├── main.py                      # FastAPI app, routers, middleware, /healthz
│   ├── config.py                    # Settings desde env vars (pydantic-settings)
│   ├── auth/
│   │   └── firebase_auth.py         # Dependencia: verifica ID token → uid + rol (claims)
│   ├── routers/                     # Capa HTTP (equivale a Presentation)
│   │   ├── events.py                #   POST /events
│   │   ├── reports.py               #   POST /reports, GET /reports/mine, firma Cloudinary
│   │   ├── rankings.py              #   GET /rankings/{scope}
│   │   ├── water_quality.py         #   GET /water-quality/{riverId} (proxy+caché)
│   │   ├── notifications.py         #   POST /notify/* (protegido por secret del cron)
│   │   └── admin.py                 #   moderación, roles, carga de contenido
│   ├── services/                    # Lógica de negocio (equivale a Domain)
│   │   ├── points_engine.py         #   Reglas de puntos, transacción idempotente
│   │   ├── badges.py                #   Reglas de desbloqueo de insignias
│   │   ├── ranking.py               #   Agregación seudonimizada
│   │   ├── moderation.py
│   │   └── water_quality.py         #   Normalización de la API externa
│   ├── repositories/                # Acceso a Firestore vía Admin SDK (equivale a Data)
│   │   └── firestore_repo.py
│   └── schemas/                     # Modelos Pydantic (DTOs request/response)
│       ├── events.py
│       ├── reports.py
│       └── ...
└── tests/                           # pytest + TestClient; fakes de Firestore
```

## 5. Responsabilidad de cada carpeta raíz

| Carpeta | Responsabilidad | Dueño |
|---|---|---|
| `guardianes_del_rio/` | App Flutter completa | Equipo (features por integrante) |
| `backend/` | API FastAPI: operaciones críticas y privilegiadas | Alberto lidera (motor de puntos); routers por módulo según feature |
| `firebase/` | Reglas, índices y seeds — única fuente de verdad desplegable con `firebase deploy --only firestore:rules` | Cody lidera (F0.3/F0.4), cambios por PR revisado |
| `docs/` | Requerimientos, arquitectura y ADRs | Equipo |
| `.github/workflows/` | CI y cron de notificaciones | Cody lidera (F0.1) |

## 6. Dependencias previstas de la app (pubspec)

Mínimas para la v1 (se agregan cuando la feature las necesita, no antes):
`flutter_riverpod`, `go_router`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`,
`mapbox_maps_flutter`, `http` (o `dio`), `shared_preferences`/`drift` (cola de eventos), `logger`,
dev: `mocktail`, `fake_cloud_firestore`.
