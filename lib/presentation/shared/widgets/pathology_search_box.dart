import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DebouncedSearchField(
          controller: controller,
          hintText: s.searchPathologyHint,
          icon: LucideIcons.search,
          onSearch: context.read<PathologyCubit>().searchPathologies,
        ),
        BlocBuilder<PathologyCubit, PathologyState>(
          builder: (context, state) {
            if (state.status == PathologyStatus.loading ||
                state.status == PathologyStatus.initial ||
                state.filteredPathologies.isEmpty) {
              return const SizedBox.shrink();
            }
            return ClxSuggestionList<PathologyModel>(
              items: state.filteredPathologies,
              icon: LucideIcons.activity,
              label: (p) => p.name ?? '',
              onSelected: (pathology) {
                controller.text = pathology.name ?? '';
                onSelect(pathology);
              },
            );
          },
        ),
      ],
    );
  }
}
