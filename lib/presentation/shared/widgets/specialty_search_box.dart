import 'package:clinexa_derivant_app/core/theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 🔍 Search field
        DebouncedSearchField(
          controller: controller,
          hintText: s.searchSpecialtyHint,
          icon: Icons.medical_information_outlined,
          onSearch: context.read<SpecialtyCubit>().searchSpecialties,
        ),

        const SizedBox(height: 4),

        // 🔽 Sugerencias
        BlocBuilder<SpecialtyCubit, SpecialtyState>(
          builder: (context, state) {
            if (state.status == SpecialtyStatus.loading ||
                state.status == SpecialtyStatus.initial ||
                state.filteredSpecialties.isEmpty) {
              return const SizedBox.shrink();
            }

            final suggestions = state.filteredSpecialties;

            return Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              color: isDark ? AppColors.neutral20 : AppColors.primary99,
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: suggestions.length > 6 ? 6 : suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? AppColors.neutral30 : AppColors.neutral80,
                ),
                itemBuilder: (_, index) {
                  final specialty = suggestions[index];

                  return ListTile(
                    leading: Icon(
                      Icons.local_hospital_outlined,
                      color: isDark ? AppColors.neutral60 : AppColors.primary40,
                    ),
                    title: Text(
                      specialty.name,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.neutral90
                            : AppColors.neutral20,
                      ),
                    ),
                    onTap: () {
                      controller.text = specialty.name;
                      onSelect(specialty);
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
