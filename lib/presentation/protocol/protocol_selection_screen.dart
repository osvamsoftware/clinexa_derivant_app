import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/protocol_model.dart' show ProtocolModel;
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
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';

enum SearchMode { category, name }

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
  SearchMode _searchMode = SearchMode.category;

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
          if (_selectedSpecialty != null &&
              !loaded.any((s) => s.id == _selectedSpecialty!.id)) {
            _selectedSpecialty = null;
            _selectedPathology = null;
          }
        });
      }
    }
  }

  void _onModeChanged(SearchMode mode, List<SpecialtyModel> userSpecialties) {
    if (mode == _searchMode) return;
    final cubit = context.read<ProtocolCubit>();
    setState(() {
      _searchMode = mode;
      _selectedSpecialty = null;
      _selectedPathology = null;

      final userIds = userSpecialties.map((e) => e.id).toList();

      // Al cambiar de modo, reseteamos a las especialidades del usuario
      // y limpiamos patología y query anterior
      cubit.updateFilters(useIds: userIds, pathologyIds: [], clearQuery: true);
    });
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s4, ClxSpace.s4, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClxSectionHeader(
                      title: s.homeProtocolsTitle,
                      subtitle: s.protocolSelectionSubtitle,
                    ),
                    const SizedBox(height: ClxSpace.s4),
                    ClxSegmented<SearchMode>(
                      value: _searchMode,
                      onChanged: (mode) => _onModeChanged(mode, userSpecialties),
                      segments: [
                        ClxSegment(value: SearchMode.category, label: s.searchByCategory, icon: LucideIcons.layers),
                        ClxSegment(value: SearchMode.name, label: s.searchByName, icon: LucideIcons.search),
                      ],
                    ),
                    const SizedBox(height: ClxSpace.s3),
                    if (_searchMode == SearchMode.category)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClxDropdown<SpecialtyModel>(
                              key: const Key('protocol_specialty_dropdown'),
                              label: s.specialty,
                              hint: s.selectPlaceholder,
                              value: _selectedSpecialty,
                              items: userSpecialties,
                              itemLabel: (sp) => sp.name,
                              onChanged: (SpecialtyModel? newValue) {
                                setState(() {
                                  _selectedSpecialty = newValue;
                                  _selectedPathology = null; // reset pathology
                                });

                                if (newValue != null) {
                                  cubit.applySpecialty(newValue.id);
                                } else {
                                  cubit.updateFilters(
                                    useIds: userSpecialties.map((e) => e.id).toList(),
                                    pathologyIds: [],
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: ClxSpace.s3),
                          Expanded(
                            child: ClxDropdown<PathologyModel>(
                              // Se recrea al cambiar de especialidad para
                              // que la patología vuelva a "Selecciona".
                              key: ValueKey('pathology_${_selectedSpecialty?.id}'),
                              label: s.pathology,
                              hint: s.selectPlaceholder,
                              value: _selectedPathology,
                              items: _selectedSpecialty?.pathologies ?? const [],
                              itemLabel: (p) => p.name ?? '',
                              onChanged: _selectedSpecialty == null
                                  ? null
                                  : (PathologyModel? newValue) {
                                      setState(() {
                                        _selectedPathology = newValue;
                                      });
                                      if (newValue?.id != null) {
                                        cubit.applyPathology(newValue!.id!);
                                      } else if (_selectedSpecialty != null) {
                                        cubit.applySpecialty(_selectedSpecialty!.id);
                                      }
                                    },
                            ),
                          ),
                        ],
                      )
                    else
                      DebouncedSearchField(
                        key: const Key('protocol_name_search'),
                        hintText: s.searchProtocolHint,
                        onSearch: (value) {
                          cubit.applyQuery(value);
                        },
                      ),
                    const SizedBox(height: ClxSpace.s4),
                  ],
                ),
              ),

              // Lista
              Expanded(
                child: Builder(
                  builder: (context) {
                    if ((state.status == ProtocolStatus.loading ||
                            state.status == ProtocolStatus.initial) &&
                        state.protocols.isEmpty) {
                      return const ClxSkeletonList(
                        count: 4,
                        padding: EdgeInsets.fromLTRB(ClxSpace.s4, 0, ClxSpace.s4, ClxSpace.s4),
                      );
                    }

                    if (state.protocols.isEmpty) {
                      return SingleChildScrollView(
                        child: ClxEmptyState(
                          icon: LucideIcons.fileSearch,
                          title: s.noProtocolsFound,
                          message: s.noProtocolsHint,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: context.clx.brandBlue,
                      onRefresh: () async => cubit.loadProtocols(refresh: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(ClxSpace.s4, 0, ClxSpace.s4, ClxSpace.s6),
                        itemCount: state.protocols.length + (state.hasReachedMax ? 0 : 1),
                        separatorBuilder: (_, __) => const SizedBox(height: ClxSpace.s3),
                        itemBuilder: (context, index) {
                          if (index >= state.protocols.length) {
                            cubit.loadProtocols();
                            return const Padding(
                              padding: EdgeInsets.all(ClxSpace.s4),
                              child: ClxLoader(size: 22),
                            );
                          }

                          final protocol = state.protocols[index];
                          return _ProtocolCard(
                            key: ValueKey('protocol_card_$index'),
                            protocol: protocol,
                            onTap: () {
                              context.pushNamed(
                                ProtocolCriteriaScreen.path,
                                extra: protocol,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard({super.key, required this.protocol, required this.onTap});

  final ProtocolModel protocol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final t = context.clxText;
    final s = S.of(context);
    final tags = [
      ...protocol.specialties.map((e) => e.name),
      ...protocol.pathologies.map((e) => e.name ?? ''),
    ].where((e) => e.isNotEmpty).take(2).toList();

    return ClxCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ClxSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.brandBlueSoft,
                  borderRadius: BorderRadius.circular(ClxRadius.md),
                ),
                child: Icon(LucideIcons.clipboardList, size: 18, color: c.onBrandBlueSoft),
              ),
              const SizedBox(width: ClxSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(protocol.name, style: t.h3),
                    if (protocol.description.isNotEmpty) ...[
                      const SizedBox(height: ClxSpace.s1),
                      Text(
                        protocol.description,
                        style: t.bodySm,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: ClxSpace.s2),
              Icon(LucideIcons.chevronRight, size: 18, color: c.inkSubtle),
            ],
          ),
          const SizedBox(height: ClxSpace.s3),
          Wrap(
            spacing: ClxSpace.s2,
            runSpacing: ClxSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ClxBadge(
                label: s.criteriaCount(protocol.criteria.length),
                tone: ClxTone.info,
                icon: LucideIcons.listChecks,
              ),
              for (final tag in tags) ClxBadge(label: tag),
            ],
          ),
        ],
      ),
    );
  }
}
