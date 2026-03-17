import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final s = S.of(context);

    // Determinar el color del círculo basado en el status del order
    Color statusColor;
    if (orderStatus != null) {
      statusColor = _getOrderStatusColor(orderStatus!);
    } else {
      // Sin order vinculado - verificar si el paciente está activo o inactivo
      final isActive = status.toLowerCase() == 'active';
      statusColor = isActive ? Colors.indigo : Colors.grey;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 12,
        left: 4,
        right: 4,
      ), // Added minimal margin
      color: AppColors.secondary95, // Secondary tenue
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ), // Minimally rounded
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Indicador de estado basado en el order
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 14),

              // Patient information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (protocolName != null && protocolName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        protocolName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Removed Pathology and Notes
                    const SizedBox(height: 8),
                    // Status text and Order Status
                    Row(
                      children: [
                        Text(
                          status.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral50,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (hasActiveOrder && orderStatus != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getOrderStatusColor(
                                orderStatus!,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getOrderStatusColor(orderStatus!),
                              ),
                            ),
                            child: Text(
                              _getOrderStatusText(orderStatus!, s),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getOrderStatusColor(orderStatus!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.amber;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getOrderStatusText(String status, S s) {
    switch (status) {
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
