import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/data/models/specialty_model.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';
import 'package:clinexa_derivant_app/presentation/specialty/cubit/specialty_cubit.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpecialtySearchBox extends StatelessWidget {
  final TextEditingController controller;
  final Function(SpecialtyModel) onSelect;

  const SpecialtySearchBox({
    super.key,
    required this.controller,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DebouncedSearchField(
          controller: controller,
          hintText: s.searchSpecialtyHint,
          icon: LucideIcons.stethoscope,
          onSearch: context.read<SpecialtyCubit>().searchSpecialties,
        ),
        BlocBuilder<SpecialtyCubit, SpecialtyState>(
          builder: (context, state) {
            if (state.status == SpecialtyStatus.loading ||
                state.status == SpecialtyStatus.initial ||
                state.filteredSpecialties.isEmpty) {
              return const SizedBox.shrink();
            }
            return ClxSuggestionList<SpecialtyModel>(
              items: state.filteredSpecialties,
              icon: LucideIcons.stethoscope,
              label: (sp) => sp.name,
              onSelected: (specialty) {
                controller.text = specialty.name;
                onSelect(specialty);
              },
            );
          },
        ),
      ],
    );
  }
}
