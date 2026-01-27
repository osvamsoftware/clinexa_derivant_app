import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/protocol/protocol_selection_screen.dart'; // Import ProtocolSelectionScreen
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/home_header.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/patient_result_card.dart';
import 'package:flutter/material.dart';
import 'package:clinexa_derivant_app/core/services/notification_service.dart';
import 'package:clinexa_derivant_app/presentation/home/cubit/home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  static const path = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) =>
          HomeCubit(context.read<NotificationService>())..init(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              HomeHeader(name: "John Doe"),

              const SizedBox(height: 20),

              // SEARCH FIELD
              DebouncedSearchField(
                hintText: s.searchPatient,
                onSearch: (query) {
                  // Perform search based on the query
                  debugPrint("Search query: $query");
                },
              ),

              const SizedBox(height: 20),

              // TITLE RESULTS
              Text(
                s.homeSearchResults,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              // FIXED RESULTS BOX
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        PatientResultCard(
                          name: "María López",
                          protocolName: "Protocolo Migraña 2025",
                          address: "Av. Siempre Viva 742",
                          pathology: s.exampleMigraine,
                          status: "Pending",
                          notes: "--",
                        ),
                        PatientResultCard(
                          name: "Jorge Ramírez",
                          protocolName: "Protocolo Hipertensión B",
                          address: "Calle 15 #23",
                          pathology: s.exampleHypertension,
                          status: "Active",
                          notes: "--",
                        ),
                        PatientResultCard(
                          name: "Sofía Duarte",
                          // No protocol for this one to test null case
                          address: "Ruta 9 km 21",
                          pathology: s.exampleArrhythmia,
                          status: "Critical",
                          notes: "--",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomButton(
                text: s.registerPatient,
                onPressed: () async {
                  context.pushNamed(ProtocolSelectionScreen.path);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
