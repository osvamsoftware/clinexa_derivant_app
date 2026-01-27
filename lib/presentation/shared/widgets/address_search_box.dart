import 'package:clinexa_derivant_app/core/theme.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/address/cubit/address_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressSearchBox extends StatelessWidget {
  final TextEditingController controller;

  const AddressSearchBox({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);

    return Column(
      children: [
        DebouncedSearchField(
          controller: controller,
          hintText: s.searchAddress,
          onSearch: context.read<AddressCubit>().search,
          icon: Icons.location_on_outlined,
        ),

        const SizedBox(height: 4),

        BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            if (state.suggestions.isEmpty ||
                state.status == Status.initial ||
                state.status == Status.loading) {
              return const SizedBox.shrink();
            }

            return Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              color: isDark ? AppColors.neutral20 : AppColors.primary99,
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: state.suggestions.length > 6
                    ? 6
                    : state.suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? AppColors.neutral30 : AppColors.neutral80,
                ),
                itemBuilder: (_, i) {
                  final item = state.suggestions[i];

                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: isDark ? AppColors.neutral60 : AppColors.primary40,
                    ),
                    title: Text(
                      item.description,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.neutral90
                            : AppColors.neutral20,
                      ),
                    ),
                    onTap: () {
                      controller.text = item.description;
                      context.read<AddressCubit>().selectPlace(item.placeId);
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
