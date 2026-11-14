# CLAUDE.md — Guardianes del Río

App móvil educativa sobre los ríos de Loja (Ecuador) para niños/jóvenes. Equipo universitario de 3 devs con **división vertical por features**: Cody (ríos/mapa/calidad del agua), Josué (lecciones/juegos/misiones), Alberto (auth/perfil/gamificación/notificaciones).

## Stack (decidido — no proponer alternativas sin ADR nuevo)

- **App:** Flutter (Dart ^3.13) en `guardianes_del_rio/` · Riverpod (Notifier = ViewModel, providers = DI) · go_router · Clean Architecture + MVVM, feature-first.
- **Firebase plan Spark (gratuito)**: Auth (email/Google/anónimo, roles por custom claims), **Firestore** (única BD), FCM. **NO hay Cloud Functions ni Firebase Storage** (requieren Blaze) — no sugerirlos.
- **Backend:** FastAPI (Python) en `backend/`, Docker en Render free tier, Firebase Admin SDK con service account (solo env vars). Procesa eventos de progreso, puntos/insignias, ranking, moderación de reportes, FCM, proxy de calidad del agua.
- **Mapas:** Mapbox (`MAPBOX_TOKEN` vía `--dart-define`, nunca commiteado). **Fotos de usuarios:** Cloudinary con firma emitida por la API. **Calidad del agua:** API externa consumida/cacheada por el backend (no se desarrolla ingesta de sensores).
- Ambientes: flavors `dev`/`prod`, dos proyectos Firebase; desarrollo local con Emulator Suite.

## Documentos de referencia (leer antes de diseñar o cambiar algo)

- `docs/architecture/ARCHITECTURE.md` — capas, flujos, responsabilidades Firebase vs API.
- `docs/architecture/PROJECT_STRUCTURE.md` — dónde vive cada pieza (seguir exactamente).
- `docs/architecture/DATA_MODEL.md` — entidades y colecciones Firestore.
- `docs/architecture/API_CONTRACTS.md` — contratos de repos, **esquema de eventos**, endpoints. Cambiar un contrato = PR aprobado por los 3.
- `docs/architecture/SECURITY.md` — reglas Firestore, roles, privacidad de menores (LOPDP Ecuador).
- `docs/architecture/TESTING_DEPLOYMENT.md` — qué testear por capa, CI, despliegue.
- `docs/adr/` — decisiones tomadas; una decisión nueva ⇒ ADR nuevo.
- `docs/Reparto.md` — fases F0–F5 y dueños; `docs/requerimientos_app_guardianes_del_rio.md` — RF/RNF.

## Reglas arquitectónicas obligatorias (se verifican en revisión de código)

1. Ningún ViewModel importa Firebase/HTTP — solo use cases y entidades. Los SDKs externos solo se importan en `features/*/data/datasources/` y `core/data/`.
2. Lógica de negocio en Domain (use cases), no en widgets ni ViewModels.
3. Use cases dependen de contratos (`abstract interface class` en `domain/repositories/`); implementaciones en `data/repositories/`.
4. `features/X/**` nunca importa `features/Y/**` — lo compartido se promueve a `core/` (única fuente de verdad: User, ProgressEvent, Failure, theme, router, ApiClient, EventQueue).
5. **Puntos/insignias/ranking/progreso: solo los escribe el backend.** El cliente emite `ProgressEvent` con ID determinista (`{uid}_{refId}_{type}[_{yyyymmdd}]`) vía `POST /events`; nunca envía puntos ni scores (el servidor recalcula). Idempotencia = create-only del doc evento en transacción.
6. Reglas Firestore deny-by-default (`firebase/firestore.rules` es la fuente de verdad; cambios con tests de reglas).
7. Datos de menores: minimización (alias, rango de edad, sin datos reales), ranking seudonimizado sin uid, nada público sin moderación.
8. Sin abstracciones sin necesidad real; sin duplicar lógica entre app y backend (lecturas → SDK Firestore directo desde DataSources; escrituras críticas → API).
9. Secretos solo en env vars/GitHub secrets (`.env`, service account, Cloudinary, X-Cron-Key). Si un secreto se commitea: rotar credencial.
10. Errores: DataSources lanzan excepciones → RepositoryImpl convierte a `Failure` (sealed, `core/error/`) → ViewModel expone `AsyncValue`.

## Convenciones

- Commits: Conventional Commits `tipo(ámbito): descripción` (`feat(rivers): ...`). Ramas: `feature/<modulo>-<desc>`. `main` protegida, PR con ≥1 revisión, squash merge.
- Código y nombres de clases en inglés; docs y UI en español.
- Tests mínimos por historia: use case feliz + 1 error, y ViewModel con lógica (mocktail, ProviderContainer overrides). Backend: pytest, con test de idempotencia obligatorio si se tocan reglas de puntos.
- Al tocar módulo ajeno: solo con revisión del dueño (tabla en CONTRIBUTING.md).

## Comandos

```bash
# App (desde guardianes_del_rio/)
flutter pub get && flutter analyze && flutter test
flutter run --dart-define=API_BASE_URL=http://localhost:8000 --dart-define=MAPBOX_TOKEN=<token>
# Backend (desde backend/)
pip install -r requirements.txt && uvicorn app.main:app --reload && pytest
# Firebase
firebase emulators:start                      # desarrollo local sin cuota
firebase deploy --only firestore:rules        # solo desde main
```

## Estado actual

- Scaffold Flutter por defecto en `guardianes_del_rio/` (sin dependencias todavía); `backend/`, `firebase/` y `.github/workflows/` aún no existen — crearlos siguiendo PROJECT_STRUCTURE.md cuando empiece F0.
- Pendientes conocidos: proveedor real de calidad del agua (mientras tanto `FakeWaterQualityProvider` con `source: "editorial"`), proceso de verificación de docentes, contenido del río Punzara (decisión editorial).
