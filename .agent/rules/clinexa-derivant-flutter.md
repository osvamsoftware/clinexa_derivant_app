---
trigger: always_on
---

Reglas de arquitectura

Usar siempre Clean Architecture.

Mantener estrictamente las capas core, data, domain y presentation.

No permitir dependencias inversas entre capas.

Mantener la capa data completamente agnóstica del backend.

Prohibir lógica de negocio en widgets.

Reglas de Cubit y estado

Usar Cubit como único sistema de gestión de estado.

Cada Screen debe tener su propio Cubit.

Permitir Cubits compartidos solo para estados globales (auth, carrito, notificaciones).

Cada Cubit debe definir su propio enum de status.

No usar enums de estado globales compartidos entre Cubits.

No mezclar responsabilidades dentro de un mismo Cubit.

Toda interacción con repositorios debe realizarse exclusivamente desde el Cubit.

Reglas de Screens y Widgets

Las Screens deben ser siempre StatelessWidget.

Separar cada pantalla en Screen y ScreenView.

Screen maneja Cubit, listeners y navegación.

ScreenView contiene solo UI pura.

No permitir lógica de negocio en widgets.

Permitir StatefulWidget solo en widgets custom cuando sea necesario.

Usar StatefulWidget únicamente para animaciones o estado visual local.

Prohibir estado de negocio dentro de widgets custom.

Implementar paginación o infinite scroll en listas largas.

Reglas de diseño y estilo

Usar exclusivamente Material Design 3.

Implementar soporte completo para modo claro y oscuro.

Obtener colores únicamente desde AppColors.

Obtener estilos y tipografías únicamente desde AppTheme.

Prohibir valores hardcodeados de colores, tamaños o estilos.

Mantener consistencia visual en espaciados y bordes.

Reglas de modelos

Definir todos los modelos como inmutables.

Incluir siempre copyWith, toMap, fromMap, toJson, fromJson.

Implementar Equatable cuando corresponda.

Separar claramente modelos de domain y data.

Reglas de repositorios

Definir cada repositorio con interfaz abstracta e implementación concreta.

Retornar modelos tipados o ApiResponseModel en listas paginadas.

Usar exclusivamente el ApiService estándar.

Envolver todos los métodos del repositorio en try/catch.

Registrar el error en consola antes de relanzarlo.

Implementar paginación por defecto en todos los métodos getAll.

Reglas de ApiService

Usar un único ApiService centralizado.

Centralizar en ApiService los requests HTTP.

Centralizar en ApiService el manejo de tokens.

Centralizar en ApiService los logs.

Prohibir servicios HTTP alternativos.

Reglas de internacionalización

Usar siempre intl con l10n.

Preparar todas las Screens para traducción.

Prohibir strings hardcodeados en la UI.

Definir textos en app_es.arb y app_en.arb.

Sugerir claves de traducción al entregar UI.

Reglas de navegación

Usar exclusivamente GoRouter.

Navegar solo con context.push, context.pop o context.go.

Prohibir el uso directo de Navigator.

Centralizar la definición de rutas.

Reglas generales de código

Usar camelCase en Dart.

Usar nombres descriptivos y coherentes.

No duplicar lógica.

No mezclar responsabilidades.

Mantener el código modular y escalable.

Permitir crecimiento del proyecto sin refactor estructural.

comentarios sin emoji