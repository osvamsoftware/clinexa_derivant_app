import 'package:clinexa_derivant_app/core/legal/legal_catalog.dart';
import 'package:clinexa_derivant_app/presentation/legal/legal_document_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Listado de los documentos legales, accesible desde la cuenta.
///
/// Apple exige (guideline 5.1.1) que los términos y la política de privacidad
/// se puedan consultar dentro de la app, no solo al momento de aceptarlos.
class LegalDocumentsScreen extends StatelessWidget {
  static const path = '/legal-documents';

  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documentos legales')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: LegalCatalog.all.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final document = LegalCatalog.all[index];

          return ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(document.title),
            subtitle: Text(
              document.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            isThreeLine: true,
            onTap: () =>
                context.push('${LegalDocumentScreen.path}/${document.slug}'),
          );
        },
      ),
    );
  }
}
