// Clinexapp Design System — componentes para Flutter.
//
// Importa este archivo en cualquier pantalla:
//   import 'package:<app>/core/ui/clx_ui.dart';
//
// Reglas (resumen del README del sistema, design-system/README.md):
// - Colores siempre desde `context.clx` (respeta tema claro y oscuro).
// - Texto desde `context.clxText` (h1, h2, h3, body, bodySm, label, data).
// - Íconos Lucide (`LucideIcons.*`), nunca Material Icons ni emoji.
// - Una sola acción principal (`ClxButton`) por zona.
// - Violeta (`ClxTone.ai`, `ClxButton.ai`) solo para lo que hace la IA.
// - Estados con `ClxBadge`: siempre con texto, nunca solo color.
// - Cargas de listas con `ClxSkeletonList`, no spinners a pantalla completa.
//
// Esta carpeta es idéntica en las dos apps: si cambias algo, cópialo.
export 'package:lucide_icons_flutter/lucide_icons.dart';

export '../clinexapp_tokens.dart';
export 'clx_buttons.dart';
export 'clx_extra_derivante.dart';
export 'clx_feedback.dart';
export 'clx_forms.dart';
export 'clx_layout.dart';
export 'clx_palette.dart';
