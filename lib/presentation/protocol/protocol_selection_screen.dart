import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/domain/protocol_repository.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_cubit.dart';
import 'package:clinexa_derivant_app/presentation/protocol/cubit/protocol_state.dart';
import 'package:clinexa_derivant_app/presentation/protocol/protocol_criteria_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/specialty/cubit/specialty_cubit.dart';
import 'package:clinexa_derivant_app/presentation/pathology/cubit/pathology_cubit.dart';
import 'package:clinexa_derivant_app/presentation/pathology/pathology_repository.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:clinexa_derivant_app/data/models/specialty_model.dart';
import 'package:clinexa_derivant_app/data/models/pathology_model.dart';
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
          create: (context) {
            final user = context.read<AuthCubit>().state.user;
            return ProtocolCubit(context.read<ProtocolRepository>())
              ..updateFilters(useIds: user?.specialties)
              ..loadProtocols();
          },
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
  SpecialtyModel? _selectedSpecialty;
  PathologyModel? _selectedPathology;

  List<String> _lastSpecialtyIds = [];
  List<SpecialtyModel>? _userSpecialties;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoadSpecialties();
  }

  Future<void> _checkAndLoadSpecialties() async {
    final user = context.watch<AuthCubit>().state.user;
    final currentIds = user?.specialties ?? [];

    // Verificamos si las specialties en el usuario cambiaron
    bool hasChanged = false;
    if (currentIds.length != _lastSpecialtyIds.length) {
      hasChanged = true;
    } else {
      for (int i = 0; i < currentIds.length; i++) {
        if (currentIds[i] != _lastSpecialtyIds[i]) {
          hasChanged = true;
          break;
        }
      }
    }

    if (hasChanged) {
      _lastSpecialtyIds = List.from(currentIds);

      final repo = context.read<SpecialtyRepository>();
      final List<SpecialtyModel> loaded = [];

      try {
        for (final id in currentIds) {
          final s = await repo.getSpecialtyById(id);
          loaded.add(s);
        }
      } catch (e) {
        // En caso de error, dejamos las cargadas hasta el momento
      }

      if (mounted) {
        setState(() {
          _userSpecialties = loaded;
          
          // Validar que la especialidad seleccionada aún exista en la lista (por si acaso cambian desde el perfil)
          if (_selectedSpecialty != null && !loaded.any((s) => s.id == _selectedSpecialty!.id)) {
            _selectedSpecialty = null;
            _selectedPathology = null;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final cubit = context.read<ProtocolCubit>();
    final userSpecialties = _userSpecialties ?? [];

    return Scaffold(
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
                      child: DropdownButtonFormField<SpecialtyModel>(
                        decoration: InputDecoration(
                          labelText: s.specialty,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        isExpanded: true,
                        hint: const Text("Seleccione", maxLines: 1),
                        value: _selectedSpecialty,
                        items: userSpecialties.map((specialty) {
                          return DropdownMenuItem<SpecialtyModel>(
                            value: specialty,
                            child: Text(
                              specialty.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (SpecialtyModel? newValue) {
                          setState(() {
                            _selectedSpecialty = newValue;
                            _selectedPathology = null; // reset pathology
                          });
                          
                          if (newValue != null) {
                            // Apply only specialty, Cubit will reset pathologyIds
                            cubit.applySpecialty(newValue.id);
                          } else {
                            // If no specialty selected, reset to all user specialties
                            cubit.updateFilters(
                              useIds: userSpecialties.map((e) => e.id).toList(), 
                              pathologyIds: [],
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<PathologyModel>(
                        decoration: InputDecoration(
                          labelText: "Patología",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        isExpanded: true,
                        hint: const Text("Seleccione", maxLines: 1),
                        value: _selectedPathology,
                        items: (_selectedSpecialty?.pathologies ?? []).map((pathology) {
                          return DropdownMenuItem<PathologyModel>(
                            value: pathology,
                            child: Text(
                              pathology.name ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _selectedSpecialty == null 
                            ? null 
                            : (PathologyModel? newValue) {
                                setState(() {
                                  _selectedPathology = newValue;
                                });
                                if (newValue?.id != null) {
                                  // Apply specialty + pathology
                                  cubit.applyPathology(newValue!.id!);
                                } else if (_selectedSpecialty != null) {
                                  // If pathology cleared, reset to specialty only
                                  cubit.applySpecialty(_selectedSpecialty!.id);
                                }
                              },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

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
                                          protocol.description,
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
