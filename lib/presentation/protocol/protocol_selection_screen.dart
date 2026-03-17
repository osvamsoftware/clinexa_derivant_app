import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/domain/protocol_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_cubit.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_state.dart';
import 'package:clinexa_derivant_app/presentation/protocol/protocol_criteria_screen.dart';
import 'package:clinexa_derivant_app/presentation/contact/contact_protocol_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:flutter/gestures.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/pathology_search_box.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/specialty_search_box.dart';
import 'package:clinexa_derivant_app/presentation/specialty/cubit/specialty_cubit.dart';
import 'package:clinexa_derivant_app/presentation/pathology/cubit/pathology_cubit.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:clinexa_derivant_app/presentation/pathology/pathology_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProtocolSelectionScreen extends StatelessWidget {
  static const path = '/protocol-selection';

  const ProtocolSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ProtocolCubit(context.read<ProtocolRepository>())
                ..loadProtocols(),
        ),
        BlocProvider(
          create: (context) =>
              SpecialtyCubit(context.read<SpecialtyRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              PathologyCubit(context.read<PathologyRepository>()),
        ),
      ],
      child: const ProtocolSelectionView(),
    );
  }
}

class ProtocolSelectionView extends StatefulWidget {
  const ProtocolSelectionView({super.key});

  @override
  State<ProtocolSelectionView> createState() => _ProtocolSelectionViewState();
}

class _ProtocolSelectionViewState extends State<ProtocolSelectionView> {
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _pathologyController = TextEditingController();

  @override
  void dispose() {
    _specialtyController.dispose();
    _pathologyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ProtocolCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(s.protocolsList)),
      body: BlocConsumer<ProtocolCubit, ProtocolState>(
        listener: (context, state) {
          if (state.status == ProtocolStatus.failure) {
            CustomDialogs.errorDialog(
              context,
              state.errorMessage ?? s.errorLoadingProtocols,
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  s.protocolSelectionSubtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral10),
                ),
                const SizedBox(height: 16),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: SpecialtySearchBox(
                        controller: _specialtyController,
                        onSelect: (specialty) {
                          cubit.applySpecialty(specialty.id);
                          context.read<SpecialtyCubit>().clearSearch();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PathologySearchBox(
                        controller: _pathologyController,
                        onSelect: (pathology) {
                          if (pathology.id != null) {
                            cubit.applyPathology(pathology.id!);
                            context.read<PathologyCubit>().clearSearch();
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // Active Filters and Clear Button
                if (state.selectedUseIds.isNotEmpty ||
                    state.selectedPathologyIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          cubit.clearFilters();
                          _specialtyController.clear();
                          _pathologyController.clear();
                        },
                        icon: const Icon(Icons.clear, size: 18),
                        label: Text(s.clearFilters),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: s.cantFindProtocol,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral40,
                        ),
                        children: [
                          TextSpan(
                            text: s.contactUsHere,
                            style: const TextStyle(
                              color: AppColors.primary40,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  context.push(ContactProtocolScreen.path),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // List
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.status == ProtocolStatus.loading &&
                          state.protocols.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.protocols.isEmpty) {
                        return Center(child: Text(s.noProtocolsFound));
                      }

                      return RefreshIndicator(
                        onRefresh: () async =>
                            cubit.loadProtocols(refresh: true),
                        child: ListView.separated(
                          itemCount:
                              state.protocols.length +
                              (state.hasReachedMax ? 0 : 1),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index >= state.protocols.length) {
                              cubit.loadProtocols();
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final protocol = state.protocols[index];
                            return Card(
                              elevation: 0,
                              color: AppColors.neutral95,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  context.pushNamed(
                                    ProtocolCriteriaScreen.path,
                                    extra: protocol,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        protocol.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.neutral10,
                                            ),
                                      ),
                                      ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          protocol.description!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.neutral40,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.assignment_outlined,
                                            size: 18,
                                            color: AppColors.primary60,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${protocol.criteria.length} criteria",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.neutral40,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
