# assets/ — Recursos estáticos de la app

Solo recursos **empaquetados con la app**: identidad visual y contenido que no cambia sin release. El contenido editorial administrable (fotos de ríos, flora/fauna, insignias) va por URL en Firestore/Cloudinary (ADR-0008), no aquí.

| Carpeta | Contenido | Convención de nombre |
|---|---|---|
| `logos/` | Logo de Guardianes del Río y variantes (claro/oscuro, horizontal, isotipo) | `logo_<variante>.png` / `.svg` |
| `icons/` | Íconos propios de la UI que no cubre Material (mascotas, categorías de reporte, avatares) | `ic_<nombre>.png` / `.svg` |
| `images/` | Ilustraciones e imágenes de pantallas (onboarding, estados vacíos, fondos) | `img_<pantalla>_<nombre>.png` |

Reglas:
- Nombres en minúsculas con guion bajo; sin espacios ni tildes.
- Optimizar antes de commitear (la app debe correr en gama básica, RNF-03): PNG comprimido o SVG; WebP para fotos.
- Las tres carpetas ya están declaradas en `pubspec.yaml` (sección `flutter.assets`); al crear una subcarpeta nueva hay que agregarla ahí también (Flutter no incluye subdirectorios recursivamente).
- El ícono del launcher y el splash NO viven aquí: se generan en `android/`/`ios/` (en F5.3 con `flutter_launcher_icons`).
