import 'package:clinexa_derivant_app/data/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatelessWidget {
  static const String path = '/notifications/detail';
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'dd MMM yyyy HH:mm',
    ).format(notification.createdAt);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Notificación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              notification.body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (notification.data.isNotEmpty) ...  [
              const SizedBox(height: 24),
              const Divider(),
              const Text(
                'Datos adicionales:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notification.data.toString(),
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
