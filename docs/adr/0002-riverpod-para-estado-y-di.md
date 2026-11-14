# ADR-0002: Riverpod para estado (MVVM) e inyección de dependencias

- **Estado:** Aceptada (2026-11-14)
- **Contexto:** Se requiere MVVM con ViewModels testeables y una forma de inyectar dependencias (regla 3: use cases sin implementaciones concretas) sin agregar más librerías de las necesarias (regla 12).
- **Decisión:** `flutter_riverpod`. Los ViewModels son `Notifier`/`AsyncNotifier`; los contratos de repositorio se exponen como providers (`riverRepositoryProvider`) que en tests se sobreescriben con fakes (`ProviderContainer(overrides: ...)`). Estados de carga/éxito/error con `AsyncValue`.
- **Alternativas descartadas:** BLoC (más boilerplate de eventos/estados para 3 estudiantes); Provider+ChangeNotifier (DI manual y menos seguridad de compilación); get_it+injectable (segunda librería solo para DI que Riverpod ya cubre).
- **Consecuencias:** una sola librería resuelve estado + DI + ciclo de vida; tests de ViewModel sin widgets. Requiere disciplina: los providers de infraestructura (Firebase, ApiClient) viven en `core/data/` y solo los consumen DataSources/Repos, nunca las Views.
