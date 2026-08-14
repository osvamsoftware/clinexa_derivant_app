import 'package:flutter/material.dart';

/// Bandera visible en el login que confirma que la app instalada viene de
/// TestFlight y no de un build local.
///
/// **Es temporal, y a propósito.** Sirve para una sola cosa: verificar de
/// punta a punta el circuito compilar → subir a App Store Connect →
/// instalar desde TestFlight. Si al abrir la app en el iPhone se ve este
/// cartel con el número de build de abajo, el circuito funciona.
///
/// El texto está escrito a mano (no se lee del paquete ni del `.env`) justo
/// por eso: al ser un valor único de este código, verlo en el teléfono
/// demuestra que ESTE código es el que llegó a TestFlight, sin margen de
/// duda.
///
/// Quitar antes de publicar en la App Store: borrar este archivo y la
/// llamada en `login_screen.dart`.
class TestFlightBanner extends StatelessWidget {
  const TestFlightBanner({super.key});

  /// Subir a la par de `version:` en `pubspec.yaml` en cada build de prueba,
  /// para distinguir de un vistazo qué build quedó instalado.
  static const String buildTag = 'v0.1.0 (6) · 14-ago-2026';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4CC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0A800), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch, color: Color(0xFF8A6100), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'BUILD DE PRUEBA · TESTFLIGHT',
                  style: TextStyle(
                    color: Color(0xFF8A6100),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  buildTag,
                  style: const TextStyle(
                    color: Color(0xFF8A6100),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
