import 'package:clinexa_derivant_app/core/constants/argentina_provinces.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register/register_profile_screen.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';
import 'package:clinexa_derivant_app/presentation/specialty/cubit/specialty_cubit.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:clinexa_derivant_app/domain/address_repository.dart';
import 'package:clinexa_derivant_app/presentation/address/cubit/address_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/address_search_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterProfessionalScreen extends StatelessWidget {
  static const path = "/register-professional";
  const RegisterProfessionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              SpecialtyCubit(context.read<SpecialtyRepository>()),
        ),
        BlocProvider(
          create: (context) => AddressCubit(context.read<AddressRepository>()),
        ),
      ],
      child: const RegisterProfessionalView(),
    );
  }
}

class RegisterProfessionalView extends StatelessWidget {
  const RegisterProfessionalView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();
    final specialtyCubit = context.read<SpecialtyCubit>();
    final s = S.of(context);

    return Scaffold(
      appBar: const ClxAppBar(),
      body: Form(
        key: cubit.formStep2Key,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(ClxSpace.s6, ClxSpace.s4, ClxSpace.s6, ClxSpace.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClxStepper(current: 2, total: 3, label: s.registerStepProfessional),
              const SizedBox(height: ClxSpace.s6),
              ClxPageHeader(title: s.registerStepProfessional, subtitle: s.registerProfessionalSubtitle),
              const SizedBox(height: ClxSpace.s8),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClxDropdown<String>(
                        label: s.licenseType,
                        hint: s.selectOption,
                        icon: LucideIcons.idCard,
                        value: state.licenseType,
                        items: const ['provincial', 'national'],
                        itemLabel: (v) => v == 'provincial'
                            ? s.provincialLicense
                            : s.nationalLicense,
                        onChanged: cubit.setLicenseType,
                        validator: (val) =>
                            val == null ? s.fieldRequired : null,
                      ),

                      // Provincia (solo si la matrícula es provincial)
                      if (state.licenseType == "provincial") ...[
                        const SizedBox(height: ClxSpace.s5),
                        ClxDropdown<String>(
                          label: s.provinceState,
                          hint: s.selectProvince,
                          icon: LucideIcons.map,
                          value: state.provincialLicenseName,
                          items: argentinaProvinces,
                          itemLabel: (p) => p,
                          onChanged: cubit.setProvincialLicenseName,
                          validator: (val) {
                            if (state.licenseType == "provincial" &&
                                (val == null || val.isEmpty)) {
                              return s.fieldRequired;
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: ClxSpace.s5),
              ClxTextField(
                label: s.medicalLicense,
                icon: LucideIcons.hash,
                mono: true,
                controller: cubit.licenseController,
                validator: (t) =>
                    (t == null || t.isEmpty) ? s.fieldRequired : null,
              ),
              const SizedBox(height: ClxSpace.s5),
              DebouncedSearchField(
                label: s.searchSpecialty,
                icon: LucideIcons.stethoscope,
                onSearch: (value) => specialtyCubit.searchSpecialties(value),
                hintText: s.searchSpecialtyHint,
                controller: cubit.specialtyController,
                validator: (val) {
                  if (cubit.state.specialties.isEmpty) {
                    return s.specialty_required;
                  }
                  return null;
                },
              ),
              BlocBuilder<SpecialtyCubit, SpecialtyState>(
                builder: (_, state) {
                  if (state.filteredSpecialties.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return ClxSuggestionList(
                    items: state.filteredSpecialties,
                    icon: LucideIcons.stethoscope,
                    label: (item) => item.name,
                    onSelected: (item) {
                      cubit.addSpecialty(item);
                      specialtyCubit.clearSearch();
                    },
                  );
                },
              ),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (_, state) {
                  if (state.specialties.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: ClxSpace.s3),
                    child: Wrap(
                      spacing: ClxSpace.s2,
                      runSpacing: ClxSpace.s2,
                      children: state.specialties
                          .map(
                            (e) => ClxInputChip(
                              label: e.name,
                              removeTooltip: s.removeItem,
                              onRemove: () => cubit.removeSpecialty(e.id),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: ClxSpace.s5),
              AddressSearchBox(
                label: s.address,
                controller: cubit.addressController,
                onClear: cubit.clearAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return s.fieldRequired;
                  }
                  final addressState = context.read<AddressCubit>().state;
                  if (addressState.selectedAddress == null) {
                    return s.selectValidAddress;
                  }
                  return null;
                },
              ),
              const SizedBox(height: ClxSpace.s8),
              ClxButton(
                label: s.register_next,
                trailingIcon: LucideIcons.arrowRight,
                onPressed: () {
                  if (cubit.state.specialties.isEmpty) {
                    ClxToast.error(context, s.specialty_required);
                    return;
                  }
                  if (cubit.formStep2Key.currentState!.validate()) {
                    final addressState = context.read<AddressCubit>().state;
                    cubit.setAddressDetail(
                      detail: addressState.selectedAddress,
                    );
                    context.push(RegisterProfileScreen.path, extra: cubit);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
