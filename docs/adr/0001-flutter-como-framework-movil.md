# ADR-0001: Flutter como framework móvil

- **Estado:** Aceptada (2026-11-14)
- **Contexto:** App para Android (prioritario) e iOS (RNF-01), equipo de 3 estudiantes, UI muy visual y animada para niños, un solo código base viable en el tiempo del taller. El equipo ya creó el scaffold (`guardianes_del_rio/`) y tiene afinidad con Dart.
- **Decisión:** Flutter (Dart, SDK ^3.13) para toda la app móvil.
- **Alternativas descartadas:** React Native (puente JS, ecosistema de mapas/animaciones menos integrado para este caso); nativo Kotlin+Swift (duplica el esfuerzo, inviable para 3 personas).
- **Consecuencias:** un solo código para Android/iOS; widgets y animaciones adecuados para la estética infantil; integración FlutterFire oficial con Firebase. Riesgo: tamaño del binario y rendimiento en gama básica → se prueba en dispositivo básico antes de cada release (RNF-03, F3.5).
