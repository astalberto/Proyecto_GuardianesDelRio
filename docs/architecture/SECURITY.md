# SECURITY.md — Seguridad y privacidad

> Entregable 6. La app está dirigida a menores de edad: la seguridad y la minimización de datos son requisitos de diseño, no un añadido. Principio rector: **ocultar algo en la interfaz no lo protege; todo se protege en servidor (reglas Firestore + API)**.

## 1. Autenticación

- **Firebase Authentication**: email/contraseña, Google y **anónimo** (modo invitado, RF-01).
- La sesión persiste con el manejo de tokens del SDK (refresh automático); no se almacenan contraseñas ni tokens manualmente.
- El modo invitado puede explorar contenido y jugar; para ranking, misiones con recompensa y reportes no anónimos se pide crear cuenta (linking de la cuenta anónima, conserva el progreso).
- La API verifica el **ID token** en cada request con Admin SDK (firma, expiración, revocación) y deriva `uid` + rol. Nunca se confía en un `uid` enviado en el body.

## 2. Autorización y roles

- Roles: `child` (por defecto), `teacher`, `parent`, `admin` — almacenados como **custom claims** (fuente de verdad). La copia en `users/{uid}.role` es solo informativa para UI.
- Asignación: solo vía `POST /admin/users/{uid}/role` por un admin. Los roles `teacher`/`parent` requieren verificación fuera de banda (proceso manual del equipo en v1 — ej. código de aula entregado al docente).
- Vinculación padre/docente ↔ niño (F4.3): lista explícita (`classroomId` / `guardianOf[]` escrita por backend). Un docente solo lee el progreso de su aula; un padre solo el de sus hijos vinculados. Se valida en reglas y en la API, nunca solo en UI.

## 3. Reglas de Firestore (esqueleto normativo)

Deny-by-default; la matriz completa está en [API_CONTRACTS.md §6](API_CONTRACTS.md). Esqueleto de `firebase/firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    // deny-by-default: sin match, no hay acceso

    function signedIn() { return request.auth != null; }
    function isSelf(uid) { return signedIn() && request.auth.uid == uid; }
    function role() { return signedIn() ? request.auth.token.get('role', 'child') : ''; }

    // Contenido publicado: lectura pública autenticada, escritura solo backend (Admin SDK bypasea)
    match /rivers/{r} { allow read: if signedIn() && resource.data.published == true; allow write: if false;
      match /sectors/{s} { allow read: if signedIn(); allow write: if false; } }
    match /lessons/{l} { allow read: if signedIn(); allow write: if false;
      match /questions/{q} { allow read: if signedIn(); allow write: if false; } }
    // ... species, games, missions, badges, water_quality, rankings: read signedIn, write false

    // Perfil: solo el propio, y solo campos permitidos
    match /users/{uid} {
      allow read: if isSelf(uid) || role() == 'admin';
      allow update: if isSelf(uid)
        && request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['displayName', 'avatarId', 'neighborhoodId']);
      allow create, delete: if false;   // los crea el backend/el flujo de registro
    }

    // Estado derivado: solo lectura propia (docente: su aula vía claim classroomIds)
    match /user_points/{uid}  { allow read: if isSelf(uid); allow write: if false; }
    match /progress/{uid}     { allow read: if isSelf(uid); allow write: if false;
      match /items/{i}        { allow read: if isSelf(uid); allow write: if false; } }
    match /user_badges/{uid}/badges/{b} { allow read: if isSelf(uid); allow write: if false; }

    // Eventos: nadie desde el cliente
    match /progress_events/{e} { allow read, write: if false; }

    // Reportes: propios + aprobados
    match /reports/{id} {
      allow read: if signedIn() && (resource.data.uid == request.auth.uid
                                    || resource.data.status == 'approved');
      allow write: if false;  // se crean/moderan vía API
    }

    match /notifications/{uid}/items/{n} {
      allow read: if isSelf(uid);
      allow update: if isSelf(uid)
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['read']);
      allow create, delete: if false;
    }
  }
}
```

Las reglas se **prueban** con el Emulator Suite (tests de reglas en CI, ver TESTING_DEPLOYMENT.md) y se despliegan solo desde `main` con `firebase deploy --only firestore:rules`.

## 4. Privacidad de menores (minimización de datos)

- **No se recolecta**: nombre legal, fecha de nacimiento exacta (solo rango de edad), dirección, teléfono, ni geolocalización continua.
- **Geolocalización**: solo on-demand (centrar mapa, adjuntar a un reporte) y con consentimiento explícito del sistema operativo + explicación en lenguaje de niños. Los reportes pueden ser anónimos (RNF-07).
- **Fotos**: solo en reportes; se instruye no fotografiar personas; la moderación rechaza fotos con menores identificables antes de publicarlas en el mapa.
- **Ranking**: solo `alias` + `avatarId` + puntos (F3.3). El documento agregado jamás contiene `uid` ni permite correlacionar con `users` (que no es legible por terceros).
- **Marco legal**: LOPDP de Ecuador (Ley Orgánica de Protección de Datos Personales, 2021) — base de licitud, consentimiento del representante para menores, derechos ARCO (acceso/rectificación/cancelación: el usuario puede borrar su cuenta → la API elimina `users`, `progress*`, `user_points`, `user_badges`, `notifications` y anonimiza sus reportes). Además, políticas de Google Play Familias / App Store Kids si se publica para niños: sin anuncios ni tracking de terceros; ligar la política de privacidad (F5.3).

## 5. Integridad del juego (anti-trampa)

- Los puntos, niveles, insignias, progreso y ranking **solo** los escribe el backend (reglas: `write: if false`). Un cliente modificado no puede otorgarse nada.
- Idempotencia por ID determinista + transacción: el replay de eventos no duplica puntos (detalle en ARCHITECTURE.md §3).
- El backend **recalcula** los resultados de quizzes con las respuestas crudas; nunca acepta un "score" del cliente. Para minijuegos aplica la `pointsRule` del servidor con topes por día.
- Limitación aceptada en v1: `correctIndex` de las preguntas es legible por el cliente (necesario para feedback inmediato offline, RNF-02). Mitigaciones: topes diarios de puntos por tipo de evento, 1 intento puntuable por día, y es una app educativa — el incentivo de trampa es bajo. Si se vuelve problema: endpoint de corrección server-side para modo online (registrado como deuda en ADR-0006).
- Rate limiting básico en la API (por uid/IP) contra abuso.

## 6. Protección de credenciales y secretos

| Secreto | Dónde vive | Dónde NUNCA |
|---|---|---|
| Service account de Firebase (Admin SDK) | Variable de entorno del hosting (Render) / secret de GitHub Actions | Repo, imagen Docker, app |
| Token de Mapbox | `--dart-define` en CI/local; restricción por aplicación en el dashboard de Mapbox | Hardcodeado en código commiteado |
| API key/secret de Cloudinary | Solo backend (env var); el cliente sube con **firmas de un solo uso** emitidas por la API | App |
| `X-Cron-Key` (cron de notificaciones) | Secret de GitHub Actions + env var del backend | Repo |
| `google-services.json` / `firebase_options.dart` | Son identificadores públicos del proyecto, no secretos — la seguridad real son las reglas. Se commitean los de `dev`; los de `prod` solo en CI |

`.gitignore` incluye `.env`, `*.serviceaccount.json`. Prohibido commitear secretos: si ocurre, se rota la credencial (no basta borrar el commit).

## 7. Validación en servidor de operaciones críticas

Toda operación de esta lista pasa por la API con token verificado y validación completa (existencia, pertenencia, estado, rol): envío de eventos, creación/moderación de reportes, asignación de roles, carga de contenido, refresco de calidad del agua, envío de notificaciones. La interfaz puede deshabilitar botones por rol, pero eso es UX, no seguridad.

## 8. Datos de sensores / API externa

- El backend trata la API externa como **entrada no confiable**: valida rangos (`index` 0–100, fechas no futuras), timeouts y fallback a último valor cacheado.
- Todo dato mostrado lleva `source` (`official`/`estimated`/`editorial`) visible en la UI (observación §6.3 de requerimientos) para no presentar como oficial lo que no lo es.
- Las credenciales del proveedor (si las hay) viven solo en el backend.

## 9. Moderación de contenido de usuarios

Único contenido generado por usuarios en v1: reportes (foto + texto) y alias. Flujo: nada es público sin pasar por `approved` (RF-07); filtro de palabras para alias y descripciones; los moderadores son admin/teacher; auditoría con `moderatedBy`/`moderatedAt`.
