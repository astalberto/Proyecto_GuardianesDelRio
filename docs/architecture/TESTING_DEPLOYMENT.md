# TESTING_DEPLOYMENT.md — Estrategia de pruebas y despliegue

> Entregable 8. Qué se prueba en cada capa, con qué herramienta, y cómo se despliega app, backend y reglas.

## 1. Pirámide de pruebas

```
            ┌────────────────────┐
            │  Manual / usuarios  │  F5.1: sesiones con niños y docentes (desde Fase 2)
            ├────────────────────┤
            │  Integración        │  Emulator Suite: reglas + flujos API→Firestore
            ├────────────────────┤
            │  Widget / ViewModel │  flutter_test + ProviderContainer con fakes
            ├────────────────────┤
            │  Unitarias (base)   │  Domain (use cases, entidades) y services del backend
            └────────────────────┘
```

### 1.1 Unitarias de Domain (app)
- Use cases y entidades sin ninguna dependencia de Firebase/HTTP (la arquitectura lo garantiza).
- Repos sustituidos por fakes/mocks con `mocktail`.
- Ejemplo mínimo exigido por feature: el use case feliz + 1 caso de error (`Failure`).

### 1.2 ViewModels
- `ProviderContainer` de Riverpod con `overrides` de los providers de repositorio → se prueba la transición de estados (`loading → data/error`) sin UI.
- Cada ViewModel con lógica condicional tiene test; los triviales (pasamanos) no (regla 10: sin ceremonia innecesaria).

### 1.3 Repositorios y DataSources
- `RepositoryImpl` con DataSource mockeado: mapeo DTO↔Entity y conversión de excepciones a `Failure`.
- DataSources de Firestore: `fake_cloud_firestore` para lógica de queries.

### 1.4 Integración con Firebase (Emulator Suite — gratuito y local)
- **Tests de reglas** (`firebase/`): con `@firebase/rules-unit-testing` se verifica la matriz de API_CONTRACTS.md §6 (ej. "un niño no puede escribir `user_points`", "un usuario no lee el perfil de otro"). Corren en CI.
- **Tests de flujo**: backend apuntado al emulador (`FIRESTORE_EMULATOR_HOST`) → `POST /events` dos veces ⇒ puntos otorgados una sola vez (criterio F2.2).

### 1.5 Backend Python
- `pytest` + `fastapi.testclient`.
- `points_engine` y `badges`: tests de tabla de reglas e **idempotencia** (obligatorios antes de mergear cambios de reglas de puntos).
- Auth: tokens inválidos/expirados → 401; rol insuficiente → 403.
- Proveedor de calidad de agua: adaptador contra respuestas grabadas (fixtures), incluido el fallback a caché.

### 1.6 Seguridad
- Tests de reglas (1.4) son la base.
- Checklist por release: intentar escribir puntos desde el cliente, leer datos de otro uid, llamar endpoints admin con rol `child`, replay de un evento.
- Secret scanning activado en GitHub; dependabot para dependencias.

### 1.7 UI / Widget y rendimiento
- Widget tests de componentes del design system (F0.2) y de pantallas críticas (login, trivia).
- Smoke test de navegación: recorrer las 5 pestañas sin excepciones (criterio F0.5).
- Rendimiento (F3.5/RNF-03): prueba manual en dispositivo de gama básica antes de cada release; `flutter run --profile` para animaciones.

## 2. CI (GitHub Actions)

Workflow `ci.yml` en cada PR:
1. **App**: `flutter pub get` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`.
2. **Backend**: `pip install -r requirements.txt` → `ruff check` → `pytest`.
3. **Reglas**: tests de reglas contra el emulador (job con `firebase-tools`).
Merge a `main` bloqueado si falla cualquiera (criterio F0.1: "el pipeline básico corre").

Workflow `reminders.yml`: `schedule` (cron) → `curl -H "X-Cron-Key: $KEY" $API/notify/daily-reminders`. Doble función: recordatorios + warm-up del free tier.

## 3. Ambientes

| Ambiente | Proyecto Firebase | API | Uso |
|---|---|---|---|
| `dev` | `guardianes-rio-dev` (Spark) | Local (`uvicorn`) o servicio dev en Render | Desarrollo diario; seeds de prueba |
| `prod` | `guardianes-rio-prod` (Spark) | Servicio prod en Render | Pilotos con usuarios reales y tiendas |

- La app selecciona ambiente por **flavor** + `--dart-define=API_BASE_URL=...`; `firebase_options` por flavor (FlutterFire CLI).
- Desarrollo sin red/cuota: Emulator Suite local (Auth+Firestore) — recomendado para trabajar con seeds sin tocar `dev`.

## 4. Despliegue

### App Flutter
- **v1 / pilotos**: APK por GitHub Releases o Firebase App Distribution (compatible Spark) para docentes y pruebas F5.1.
- **Tiendas (F5.3)**: `flutter build appbundle` → Google Play (prioritario, RNF-01); iOS después. Checklist de tienda: política de privacidad publicada, declaración de datos, apto para familias.

### Backend (Render free tier)
- Deploy automático desde `main` (carpeta `backend/`, Dockerfile). PRs no despliegan.
- Env vars en el dashboard: service account, Cloudinary, `X-Cron-Key`, proveedor de calidad de agua.
- `/healthz` como health check. Cold start (~30–60 s tras inactividad) mitigado por la cola de eventos del cliente y el cron (ARCHITECTURE.md §1.6).
- Portabilidad: el Dockerfile corre igual en Railway/Fly/PythonAnywhere; migrar es cambiar `API_BASE_URL`.

### Reglas e índices de Firestore
- Solo desde `main` (manual o job de CI): `firebase deploy --only firestore:rules,firestore:indexes`.
- Cambios de reglas requieren PR con test de reglas que cubra el cambio.

### Seeds de contenido
- `firebase/seeds/` + script Python (usa Admin SDK) para cargar ríos/sectores/lecciones iniciales a `dev` y, aprobado el contenido, a `prod`.

## 5. Definición de "listo para release" (v1)

- CI verde en `main`; cero errores críticos abiertos (F5.2).
- Checklist de seguridad (§1.6) ejecutada.
- Probado en un dispositivo Android de gama básica.
- Reglas desplegadas y versión de contenido cargada en `prod`.
