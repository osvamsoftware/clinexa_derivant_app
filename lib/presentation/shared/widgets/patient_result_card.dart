import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Tarjeta de paciente en la lista "Mis pacientes": nombre, protocolo,
/// ubicación y estados con insignias (siempre con texto).
class PatientResultCard extends StatelessWidget {
  final String name;
  final String? protocolName;
  final String address;
  final String pathology;
  final String notes;
  final String status;
  final bool hasActiveOrder;
  final String? orderStatus;
  final VoidCallback? onTap;

  const PatientResultCard({
    super.key,
    required this.name,
    this.protocolName,
    required this.address,
    required this.pathology,
    required this.notes,
    required this.status,
    this.hasActiveOrder = false,
    this.orderStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    final s = S.of(context);
    final isActive = status.toLowerCase() == 'active';

    return ClxCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ClxSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClxAvatar(name: name, size: 40),
              const SizedBox(width: ClxSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: t.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (protocolName != null && protocolName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      _MetaLine(icon: LucideIcons.clipboardList, text: protocolName!),
                    ],
                    const SizedBox(height: 2),
                    _MetaLine(icon: LucideIcons.mapPin, text: address),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: ClxSpace.s2),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(LucideIcons.chevronRight, size: 18, color: c.inkSubtle),
                ),
              ],
            ],
          ),
          const SizedBox(height: ClxSpace.s3),
          Wrap(
            spacing: ClxSpace.s2,
            runSpacing: ClxSpace.s2,
            children: [
              ClxBadge(
                label: isActive ? s.statusActive : s.statusInactive,
                tone: isActive ? ClxTone.success : ClxTone.neutral,
              ),
              if (hasActiveOrder && orderStatus != null)
                ClxBadge(
                  label: orderStatusLabel(orderStatus!, s),
                  tone: orderStatusTone(orderStatus!),
                  icon: LucideIcons.fileText,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Un estado = un color en todo el producto.
  static ClxTone orderStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return ClxTone.info;
      case 'accepted':
        return ClxTone.success;
      case 'rejected':
        return ClxTone.danger;
      default:
        return ClxTone.neutral;
    }
  }

  static String orderStatusLabel(String status, S s) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return s.orderStatusAssigned;
      case 'accepted':
        return s.orderStatusAccepted;
      case 'rejected':
        return s.orderStatusRejected;
      default:
        return status;
    }
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    return Row(
      children: [
        Icon(icon, size: 14, color: c.inkSubtle),
        const SizedBox(width: ClxSpace.s1 + 2),
        Expanded(
          child: Text(text, style: context.clxText.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
