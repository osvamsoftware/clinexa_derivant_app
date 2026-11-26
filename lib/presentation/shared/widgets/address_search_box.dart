import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/address/cubit/address_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressSearchBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onClear;
  final String? Function(String?)? validator;

  /// Rótulo visible encima del campo (opcional).
  final String? label;

  const AddressSearchBox({
    super.key,
    required this.controller,
    this.onClear,
    this.validator,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.clx;
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final showClear = value.text.isNotEmpty;
            return DebouncedSearchField(
              controller: controller,
              label: label,
              hintText: s.searchAddressPrompt,
              validator: validator,
              onSearch: context.read<AddressCubit>().search,
              icon: LucideIcons.mapPin,
              suffixIcon: showClear
                  ? IconButton(
                      tooltip: s.removeItem,
                      icon: Icon(LucideIcons.x, size: 16, color: c.inkSubtle),
                      onPressed: () {
                        controller.clear();
                        context.read<AddressCubit>().search("");
                        context.read<AddressCubit>().clearSelection();
                        onClear?.call();
                      },
                    )
                  : null,
            );
          },
        ),
        BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            // Un fallo del servicio de direcciones se veía igual que "sin
            // resultados": el desplegable simplemente no aparecía y no había
            // forma de saber por qué.
            if (state.status == Status.error && state.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.only(top: ClxSpace.s2),
                child: ClxNotice(
                  message: state.errorMessage!,
                  tone: ClxTone.danger,
                ),
              );
            }

            if (state.suggestions.isEmpty ||
                state.status == Status.initial ||
                state.status == Status.loading) {
              return const SizedBox.shrink();
            }

            return ClxSuggestionList(
              items: state.suggestions,
              icon: LucideIcons.mapPin,
              label: (item) => item.description,
              onSelected: (item) {
                controller.text = item.description;
                context.read<AddressCubit>().selectPlace(item.placeId);
              },
            );
          },
        ),
      ],
    );
  }
}
