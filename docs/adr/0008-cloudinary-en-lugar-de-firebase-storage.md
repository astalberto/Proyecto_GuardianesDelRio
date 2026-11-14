# ADR-0008: Cloudinary en lugar de Firebase Storage

- **Estado:** Aceptada (2026-11-14)
- **Contexto:** Las fotos de reportes ciudadanos (RF-07) y las imágenes de contenido necesitan almacenamiento. Desde octubre de 2024, **Firebase Storage requiere plan Blaze para crear buckets en proyectos nuevos**, y el equipo decidió permanecer en Spark (ADR-0004).
- **Decisión:**
  - **Contenido editorial** (ríos, sectores, flora/fauna, insignias): imágenes empaquetadas como assets de la app o servidas por URL pública (ej. el propio Cloudinary en carpeta `content/`), referenciadas por `imageUrl` en Firestore.
  - **Fotos de usuarios** (reportes): **Cloudinary free tier** (~25 créditos/mes, suficiente para el piloto). La app pide a la API una **firma de subida de un solo uso** (`POST /reports/upload-signature`) y sube directo a Cloudinary; el API key/secret solo existe en el backend.
- **Alternativas descartadas:** Firebase Storage (Blaze); Supabase Storage (introduce una segunda plataforma BaaS completa solo para archivos); guardar imágenes en base64 en Firestore (límite de 1 MB/doc y consumo absurdo de cuota).
- **Consecuencias:** cero costo, transformaciones de imagen gratis (thumbnails por URL — útil para listas), subidas sin pasar los bytes por nuestro backend. La moderación usa la URL de Cloudinary; al rechazar un reporte, la API elimina el asset. Riesgo: dependencia de un tercer proveedor — acotado porque solo `reports` lo usa y detrás del contrato `ReportRepository`.
