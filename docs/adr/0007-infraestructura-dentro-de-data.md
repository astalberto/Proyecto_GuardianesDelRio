# ADR-0007: Infrastructure como parte de Data, no como capa separada

- **Estado:** Aceptada (2026-11-14)
- **Contexto:** El prompt maestro planteaba decidir si Infrastructure (Firebase, API, Mapbox, almacenamiento local) se representa como capa independiente o dentro de Data, evitando duplicar responsabilidades.
- **Decisión:** No existe carpeta/capa `infrastructure` separada. Los detalles de infraestructura viven como **DataSources dentro de `data/` de cada feature** (`FirebaseRiverDataSource`, `ApiEventDataSource`…), y los objetos compartidos de infraestructura (instancias de Firebase, `ApiClient`, `EventQueue`) en `core/data/`.
- **Justificación:** en Clean Architecture lo esencial es la dirección de dependencias (todo apunta a Domain, regla 14), no el número de capas. Una cuarta capa para 3 desarrolladores crearía carpetas espejo con pasamanos (violando la regla 10: ninguna abstracción sin necesidad real) sin aportar aislamiento adicional: el aislamiento ya lo da el contrato de repositorio.
- **Consecuencias:** estructura de 3 capas por feature, fácil de explicar y de revisar; la regla práctica queda simple: *"solo `data/datasources` y `core/data` pueden importar SDKs externos"*. Si algún día una pieza de infraestructura crece (ej. sincronización offline compleja), se extrae a su propio paquete — decisión reversible.
