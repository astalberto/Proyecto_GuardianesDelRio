# ADR-0005: Mapbox como proveedor de mapas

- **Estado:** Aceptada (2026-11-14) — decisión del equipo en ETAPA A
- **Contexto:** El mapa interactivo (F1.2, RF-04) necesita: marcadores de 12 sectores, capas activables (inundación, contaminación, reportes), estilo visual atractivo para niños y caché para RNF-03. Opciones: Google Maps (facturación obligatoria), flutter_map+OSM (gratis, visual básico), Mapbox.
- **Decisión:** Mapbox con `mapbox_maps_flutter`. Token público con restricción por aplicación, inyectado por `--dart-define=MAPBOX_TOKEN=...` — nunca commiteado.
- **Consecuencias:** estilos personalizables (estética azul-turquesa/verde lima del RNF-10), buen soporte de capas/GeoJSON para las polilíneas de ríos y zonas de riesgo, free tier amplio (50k cargas de mapa/mes) sin tarjeta para empezar. Riesgos: SDK más pesado que flutter_map y requiere cuenta/token por desarrollador — se documenta en el onboarding del README. El acceso al mapa queda tras `map/data/` igual que todo lo externo, por si hubiera que cambiar de proveedor.
