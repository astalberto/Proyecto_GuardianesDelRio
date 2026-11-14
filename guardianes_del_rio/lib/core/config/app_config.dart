/// Configuración por ambiente, inyectada en compilación con `--dart-define`.
///
/// Ejemplo:
/// ```sh
/// flutter run \
///   --dart-define=FLAVOR=dev \
///   --dart-define=API_BASE_URL=http://localhost:8000 \
///   --dart-define=MAPBOX_TOKEN=pk.xxx
/// ```
/// Los valores nunca se commitean (SECURITY.md §6); en CI se inyectan desde
/// GitHub Secrets.
abstract final class AppConfig {
  /// `dev` o `prod`. Determina el proyecto Firebase y la API a usar.
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// URL base de la API FastAPI (sin slash final).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Token público de Mapbox (restringido por aplicación en el dashboard).
  static const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');

  static bool get isProd => flavor == 'prod';
}
