# CONTRIBUTING.md — Cómo trabajamos

> Entregable 7. Flujo de colaboración para Cody, Josué y Alberto. La meta: desarrollar en paralelo sin pisarse, con `main` siempre compilable.

## 1. Organización del repositorio

Monorepo (ver [docs/architecture/PROJECT_STRUCTURE.md](docs/architecture/PROJECT_STRUCTURE.md)): `guardianes_del_rio/` (app), `backend/` (API), `firebase/` (reglas+seeds), `docs/`, `.github/`.

## 2. Propiedad de módulos

| Integrante | Features de la app | Backend | Datos/seeds |
|---|---|---|---|
| **Cody** | `rivers`, `map`, `water_quality`, `reports` (app) | `routers/water_quality.py` | ríos, sectores, especies |
| **Josué** | `learning`, `games`, `missions` | — | lecciones, preguntas, juegos, misiones |
| **Alberto** | `auth`, `profile`, `gamification`, `notifications` | `points_engine`, `badges`, `ranking`, `notifications`, `moderation` | usuarios, insignias, ranking |
| **Compartido** (cambio = PR aprobado por los 3) | `lib/core/**` | `app/auth/`, `schemas/events.py` | `firebase/firestore.rules`, esquema de eventos |

El dueño decide los internals de su módulo; **nadie** modifica el módulo de otro sin su revisión. `CODEOWNERS` refleja esta tabla para asignar revisores automáticamente.

## 3. Ramas

- `main` — protegida: solo por PR con CI verde y ≥1 aprobación. Siempre compila (criterio F0.1).
- `feature/<modulo>-<descripcion>` — ej. `feature/rivers-catalogo`, `feature/gamification-insignias`.
- `fix/<descripcion>` para correcciones.
- Vida corta (< 1 semana): se parte de `main` actualizado y se mergea pronto. Nada de ramas eternas por integrante.

## 4. Commits — Conventional Commits

`tipo(ámbito): descripción en minúsculas` — tipos: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`. El ámbito es la feature o área.

```
feat(rivers): ficha de río con pestañas historia/fauna/amenazas
fix(gamification): evitar doble conteo de racha al reintentar evento
docs(adr): ADR-0008 cloudinary en lugar de storage
```

## 5. Pull Requests y revisión

- PR pequeño (ideal < 400 líneas de diff) con descripción: qué, por qué, cómo probarlo.
- **1 revisor mínimo**: otro integrante (el que toque por CODEOWNERS). Cambios a lo compartido (§2): aprobación de los tres.
- El revisor verifica además las **reglas arquitectónicas** (CLAUDE.md): imports prohibidos (feature→feature, ViewModel→Firebase), escrituras críticas fuera de la API, secretos commiteados.
- CI en verde obligatoria para mergear. Merge con *squash* para historial limpio.

## 6. Desarrollo en paralelo sin bloqueos

1. **Contratos primero**: antes de implementar, el contrato (interfaz de repo, endpoint, esquema) se escribe/actualiza en [API_CONTRACTS.md](docs/architecture/API_CONTRACTS.md) y en código (`domain/repositories/`). Aprobado el contrato, cada quien avanza por su lado.
2. **Fakes para todo**: cada feature incluye un `FakeXxxRepository` con datos realistas (del periódico). Las pantallas de los demás se desarrollan contra fakes — nadie espera al backend ni al módulo ajeno.
3. **Eventos, no llamadas**: la gamificación de Alberto reacciona a eventos; Josué solo necesita emitir el evento según el esquema. La dependencia F2.1→F2.2 es de contrato, no de código.
4. **Seeds compartidos**: `firebase/seeds/` da a todos los mismos datos de `dev`.
5. Si dos personas necesitan tocar `core/`: se coordina en el canal del equipo antes, cambios chicos, PR inmediato.

## 7. Resolución de conflictos

- Conflicto de git: lo resuelve quien mergea su PR después, consultando al dueño del código tocado.
- Desacuerdo técnico: 1) ¿lo decide un documento ya aprobado (ARCHITECTURE/ADR)? se aplica; 2) si no, discusión con propuesta escrita y gana la opción más simple que cumpla los requisitos (regla 10); 3) empate: decide el dueño del módulo afectado; si es compartido, se escribe un ADR nuevo con la decisión de mayoría.
- Toda decisión arquitectónica nueva ⇒ ADR en `docs/adr/`.

## 8. Integración continua y ambientes

- CI descrita en [TESTING_DEPLOYMENT.md](docs/architecture/TESTING_DEPLOYMENT.md): formato + analyze + tests de app, lint + pytest de backend, tests de reglas.
- Ambientes `dev`/`prod` (dos proyectos Firebase). El día a día es contra `dev` o el Emulator Suite local. `prod` solo recibe lo que está en `main`.
- Nunca apuntar herramientas locales a `prod` salvo despliegue acordado.

## 9. Definición de Hecho (DoD) de una historia

1. Cumple el criterio de aceptación de su historia (Reparto.md).
2. Tests según TESTING_DEPLOYMENT.md §1 (mínimo: use case + ViewModel con lógica).
3. Sin violaciones de las reglas arquitectónicas.
4. Documentación tocada si cambió un contrato o modelo.
5. PR revisado y mergeado a `main` con CI verde.
