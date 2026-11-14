# API_CONTRACTS.md — Contratos y comunicación entre módulos

> Entregable 5. Define los contratos de repositorio por módulo, los eventos de progreso, los endpoints de la API FastAPI y los permisos de acceso a Firestore. Cambiar un contrato de este documento requiere PR aprobado por los tres integrantes (criterio F0.4).

## 1. Principio general

Hay **tres canales** de comunicación, y solo tres:

1. **SDK Firebase (lectura)** — contenido y estado propio, vía DataSources.
2. **API FastAPI (escritura crítica)** — todo lo que otorga valor o toca datos de terceros.
3. **Eventos de progreso** — la única forma en que un módulo "le habla" a gamificación.

Ningún módulo llama código interno de otro módulo (regla 6).

## 2. Contratos de repositorio (Domain, por módulo)

Firmas en Dart (se implementan en `data/`; los ViewModels solo conocen estas interfaces):

```dart
// ---- core (compartido) ----
abstract interface class AuthRepository {
  Stream<AppUser?> watchSession();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInAsGuest();
  Future<AppUser> register({required String email, required String password,
      required String displayName, required AgeRange ageRange});
  Future<void> signOut();
}

abstract interface class ProgressEventRepository {         // único "escritor" de eventos
  Future<EventResult> submit(ProgressEvent event);          // encola + POST /events
  Stream<Progress> watchProgress(String uid);               // lectura Firestore
}

// ---- rivers / map / water_quality (Cody) ----
abstract interface class RiverRepository {
  Future<List<River>> getRivers();
  Future<River> getRiver(String riverId);
  Future<List<Sector>> getSectors(String riverId);
  Future<List<Species>> getSpecies(List<String> ids);
}

abstract interface class WaterQualityRepository {
  Future<WaterQualityMeasurement> getCurrent(String riverId);   // GET /water-quality ó caché Firestore
  Future<List<WaterQualityMeasurement>> getHistory(String riverId, {int limit});
}

// ---- learning / games / missions (Josué) ----
abstract interface class LessonRepository {
  Future<List<LessonSummary>> getLessons({String? riverId});
  Future<Lesson> getLesson(String lessonId);
  Future<List<Question>> getQuestions(String lessonId);
}

abstract interface class QuizRepository {
  Future<QuizResult> submitQuiz(QuizSubmission submission);  // delega en ProgressEventRepository
}

abstract interface class GameRepository {
  Future<List<Game>> getGames({Zone? zone});
  Future<Game> getGame(String gameId);
}

abstract interface class MissionRepository {
  Future<List<Mission>> getActiveMissions();
  Stream<MissionProgress> watchMissionProgress(String uid);
}

// ---- profile / gamification / reports / notifications (Alberto) ----
abstract interface class UserProfileRepository {
  Stream<AppUser> watchProfile(String uid);
  Future<void> updateProfile({String? displayName, String? avatarId, String? neighborhoodId});
}

abstract interface class GamificationRepository {
  Stream<UserPoints> watchPoints(String uid);                // Firestore (solo lectura)
  Stream<List<UserBadge>> watchBadges(String uid);
  Future<List<Badge>> getBadgeCatalog();
  Future<Ranking> getRanking(RankingScope scope);            // GET /rankings ó doc agregado
}

abstract interface class ReportRepository {
  Future<Report> createReport(NewReport draft);              // firma Cloudinary + POST /reports
  Stream<List<Report>> watchMyReports(String uid);
  Future<List<Report>> getApprovedReports({LatLngBounds? bounds});
}

abstract interface class NotificationRepository {
  Stream<List<AppNotification>> watchInbox(String uid);
  Future<void> markRead(String notificationId);
  Future<void> registerDeviceToken(String fcmToken);         // POST /notify/register
}
```

## 3. Eventos de progreso (el contrato más importante)

### 3.1 Esquema del evento

```jsonc
// POST /events  (body)  — el cliente NUNCA envía puntos
{
  "id": "u123_leccion-malacatos-1_lesson_completed",   // determinista, ver 3.2
  "type": "lesson_completed",
  "refId": "leccion-malacatos-1",
  "payload": { },                                      // por tipo, ver 3.3
  "clientCreatedAt": "2026-11-14T10:33:00-05:00"
}
```

### 3.2 Tipos, IDs deterministas y quién los emite

| Evento (nombre de negocio) | `type` | Emisor | Formato de `id` |
|---|---|---|---|
| LeccionCompletada | `lesson_completed` | learning (J) | `{uid}_{lessonId}_lesson_completed` |
| PreguntaRespondida | `question_answered` | learning (J) | `{uid}_{questionId}_question_answered_{yyyymmdd}` |
| QuizCompletado | `quiz_completed` | learning (J) | `{uid}_{lessonId}_quiz_completed_{yyyymmdd}` |
| MinijuegoCompletado | `game_completed` | games (J) | `{uid}_{gameId}_game_completed_{yyyymmdd}` |
| MisionCompletada | `mission_completed` | backend (derivado) | `{uid}_{missionId}_mission_completed` |
| ReporteAprobado | `report_approved` | backend (moderación) | `{uid}_{reportId}_report_approved` |
| PuntosOtorgados | — | **solo backend** | resultado, no evento de entrada: campo `pointsAwarded` en el evento procesado + update de `user_points` |
| InsigniaDesbloqueada | — | **solo backend** | documento en `user_badges` con `eventId` causa |

Reglas:
- Eventos únicos por vida (`lesson_completed`) no llevan fecha → repetir la lección no vuelve a puntuar.
- Eventos repetibles llevan `_{yyyymmdd}` → máximo 1 puntuación por día (anti-farming).
- `MisionCompletada`, `PuntosOtorgados` e `InsigniaDesbloqueada` **no los emite el cliente**: el backend los deriva al procesar eventos de entrada.

### 3.3 Payloads por tipo

| `type` | `payload` |
|---|---|
| `lesson_completed` | `{}` |
| `question_answered` | `{ "selectedIndex": 2 }` |
| `quiz_completed` | `{ "answers": [{"questionId": "...", "selectedIndex": 1}, ...] }` — el backend **recalcula** el score contra Firestore |
| `game_completed` | `{ "resultRaw": {...} }` — el backend aplica la `pointsRule` del juego con topes |

### 3.4 Procesamiento (contrato de comportamiento del backend)

En **una transacción** Firestore:
1. `create` de `progress_events/{id}` → si existe: responder `200 {status:"duplicate", pointsAwarded:0}` y terminar.
2. Validar: `refId` existe y está publicado; `uid` del token == `uid` del id; payload bien formado → si no: `422`, no se persiste nada.
3. Calcular puntos según tabla de reglas del servidor; actualizar `user_points` y `progress`.
4. Evaluar reglas de `badges` y misiones activas → crear `user_badges`/evento derivado si corresponde.
5. Responder:

```jsonc
// 200
{ "status": "processed", "pointsAwarded": 20,
  "newBadges": ["maestro-del-quiz"], "totalPoints": 450, "level": 3 }
```

### 3.5 Cola offline (cliente)

`EventQueue` (core/data/local): persiste eventos pendientes, reintenta con backoff al recuperar red, descarta al recibir `processed`/`duplicate`. El ID determinista hace el reintento seguro. La UI muestra el progreso local de inmediato (optimista) y reconcilia con el listener de `user_points`.

## 4. Endpoints de la API FastAPI

Base: `{API_BASE_URL}` (por flavor). Auth: header `Authorization: Bearer <Firebase ID token>` salvo donde se indica. FastAPI publica el OpenAPI en `/docs` (criterio F0.4).

| Método y ruta | Auth | Descripción |
|---|---|---|
| `GET /healthz` | pública | Liveness (y warm-up del cron) |
| `POST /events` | usuario | Envía un ProgressEvent (ver §3) |
| `POST /reports/upload-signature` | usuario | Firma de subida a Cloudinary (carpeta `reports/`, límites de tamaño/formato) |
| `POST /reports` | usuario (o invitado: anónimo) | Crea reporte `received` |
| `GET /rankings/{scope}` | usuario | Ranking seudonimizado (también legible como doc Firestore) |
| `GET /water-quality/{riverId}` | usuario | Estado actual (proxy+caché de la API externa) |
| `POST /notify/register` | usuario | Registra token FCM del dispositivo |
| `POST /notify/daily-reminders` | **secret del cron** (header `X-Cron-Key`) | Dispara recordatorios (GitHub Actions schedule) |
| `POST /admin/water-quality/refresh` | admin o cron | Refresca caché desde la API externa |
| `PATCH /admin/reports/{id}` | admin/teacher | Moderación: cambia estado; si `approved` → evento `report_approved` |
| `POST /admin/users/{uid}/role` | admin | Asigna custom claim de rol |
| `POST /admin/content/*` | admin | Carga de ríos/lecciones/misiones (F1.5, sustituye panel en v1) |

Errores: `401` token inválido · `403` rol insuficiente · `404` recurso · `409` conflicto · `422` validación · `5xx` con `requestId`. Cuerpo estándar: `{ "error": {"code": "...", "message": "...", "requestId": "..."} }`.

## 5. Contrato esperado de la API externa de calidad del agua

Lo único que el sistema asume (adaptador `water_quality.py` lo normaliza; si el proveedor difiere, solo cambia el adaptador):

```jsonc
// Lo que el backend necesita poder derivar del proveedor:
{ "riverId|stationId": "...", "index|parameters": "...", "measuredAt": "ISO-8601" }
// Normalizado SIEMPRE a WaterQualityMeasurement (DATA_MODEL.md) con source marcado.
```

Mientras no exista proveedor confirmado: `FakeWaterQualityProvider` en el backend sirve datos del seed con `source: "editorial"`. **El módulo de Cody no cambia en ningún caso** — consume `WaterQualityRepository`.

## 6. Matriz de acceso a Firestore (resumen; reglas completas en `firebase/firestore.rules`)

| Colección | Cliente lee | Cliente escribe | Backend (Admin SDK) |
|---|---|---|---|
| `rivers`, `species`, `lessons`, `games`, `missions`, `badges` | ✅ (publicado) | ❌ | escribe (admin/content) |
| `water_quality/**` | ✅ | ❌ | escribe (caché) |
| `users/{uid}` | solo el propio | solo campos `displayName`, `avatarId`, `neighborhoodId` | escribe rol |
| `progress/{uid}/**`, `user_points/{uid}`, `user_badges/{uid}/**`, `quiz_attempts` | solo el propio (docente: su aula) | ❌ | escribe (motor) |
| `progress_events` | ❌ | ❌ | create-only |
| `rankings/{scope}` | ✅ | ❌ | regenera |
| `reports` | propios + `approved` | ❌ (van por API) | crea/modera |
| `notifications/{uid}/**` | solo el propio | solo `read: true` | crea |

## 7. Responsabilidad sobre los datos (por integrante)

| Datos | Dueño del contrato y del seed |
|---|---|
| `rivers`, `sectors`, `species`, `water_quality` | Cody |
| `lessons`, `questions`, `games`, `missions` | Josué |
| `users`, `progress*`, `user_points`, `badges`, `rankings`, `notifications`, `reports` | Alberto |
| `progress_events` (esquema §3) | Compartido — cambio solo por PR de los tres |
