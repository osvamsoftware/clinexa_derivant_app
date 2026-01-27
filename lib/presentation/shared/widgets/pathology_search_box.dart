import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/data/models/pathology_model.dart';
import 'package:clinexa_derivant_app/presentation/pathology/cubit/pathology_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PathologySearchBox extends StatelessWidget {
  final TextEditingController controller;
  final Function(PathologyModel) onSelect;

  const PathologySearchBox({
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
          hintText: s.searchPathologyHint,
          icon: Icons.search,
          onSearch: context.read<PathologyCubit>().searchPathologies,
        ),

        const SizedBox(height: 4),

        // 🔽 Sugerencias
        BlocBuilder<PathologyCubit, PathologyState>(
          builder: (context, state) {
            if (state.status == PathologyStatus.loading ||
                state.status == PathologyStatus.initial ||
                state.filteredPathologies.isEmpty) {
              return const SizedBox.shrink();
            }

            final suggestions = state.filteredPathologies;

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
                  final pathology = suggestions[index];

                  return ListTile(
                    leading: Icon(
                      Icons.coronavirus_outlined,
                      color: isDark ? AppColors.neutral60 : AppColors.primary40,
                    ),
                    title: Text(
                      pathology.name ?? '',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.neutral90
                            : AppColors.neutral20,
                      ),
                    ),
                    onTap: () {
                      controller.text = pathology.name ?? '';
                      onSelect(pathology);
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
