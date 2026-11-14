# core/ — núcleo compartido

Única fuente de verdad de todo lo transversal (regla 7). Si dos features necesitan lo mismo, vive aquí — nunca se duplica ni se importa de otra feature. Cambios en `core/` se coordinan con el equipo y requieren PR aprobado por los tres (CONTRIBUTING.md §2).

| Carpeta | Contenido |
|---|---|
| `config/` | `AppConfig`: flavor, `API_BASE_URL`, `MAPBOX_TOKEN` (vía `--dart-define`) |
| `error/` | `Failure` (sealed): Network/Auth/Validation/ServerFailure |
| `theme/` | Design system F0.2: colores, tipografía, espaciados (lidera Alberto) |
| `navigation/` | Router go_router: 5 pestañas + rutas de detalle, F0.5 (lidera Josué) |
| `widgets/` | Componentes reutilizables del design system (GdrButton, GdrCard…) |
| `domain/entities/` | Entidades transversales: `AppUser`, roles |
| `domain/events/` | `ProgressEvent` + `EventType`: el contrato entre módulos (API_CONTRACTS.md §3) |
| `data/firebase/` | Providers de FirebaseAuth/Firestore — lo único que los conoce |
| `data/api/` | `ApiClient`: HTTP a la FastAPI, adjunta ID token, mapea errores a `Failure` |
| `data/local/` | `EventQueue`: cola offline persistente de eventos pendientes |
| `utils/` | Helpers puros (formatos, validadores) |

**Regla de imports:** solo `core/data/` y `features/*/data/datasources/` pueden importar SDKs externos (Firebase, http, Mapbox). `core/domain/` es Dart puro. Ningún ViewModel importa nada de `data/`.
