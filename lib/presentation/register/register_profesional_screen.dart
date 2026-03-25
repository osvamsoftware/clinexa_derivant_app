import 'package:clinexa_derivant_app/core/constants/argentina_provinces.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/register/cubit/register_cubit.dart';
import 'package:clinexa_derivant_app/presentation/register/register_profile_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_textfield.dart';
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
      appBar: AppBar(title: Text(s.createAccount)),
      body: Form(
        key: cubit.formStep2Key,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Dropdown para tipo de licencia
              Text(
                '${s.licenseType} *',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        initialValue: state.licenseType,
                        items: [
                          DropdownMenuItem(
                            value: "provincial",
                            child: Text(s.provincialLicense),
                          ),
                          DropdownMenuItem(
                            value: "national",
                            child: Text(s.nationalLicense),
                          ),
                        ],
                        onChanged: cubit.setLicenseType,
                        validator: (val) =>
                            val == null ? s.fieldRequired : null,
                      ),

                      // Dropdown de provincias (solo si es provincial)
                      if (state.licenseType == "provincial") ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${s.provinceState} *', // Usamos la clave existente "Provincia/Estado" o se podría crear una nueva
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Selecciona una provincia",
                          ),
                          value: state.provincialLicenseName,
                          items: argentinaProvinces.map((province) {
                            return DropdownMenuItem(
                              value: province,
                              child: Text(province),
                            );
                          }).toList(),
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
              const SizedBox(height: 16),
              CustomTextField(
                label: '${s.medicalLicense} *',
                controller: cubit.licenseController,
                validator: (t) =>
                    (t == null || t.isEmpty) ? s.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              DebouncedSearchField(
                label: '${s.searchSpecialty} *',
                onSearch: (value) => specialtyCubit.searchSpecialties(value),
                hintText: s.specialty,
                controller: cubit.specialtyController,
                validator: (val) {
                  if (cubit.state.specialties.isEmpty) {
                    return "Debe seleccionar al menos una especialidad";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              BlocBuilder<SpecialtyCubit, SpecialtyState>(
                builder: (_, state) {
                  if (state.filteredSpecialties.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: state.filteredSpecialties.length,
                      itemBuilder: (_, index) {
                        final item = state.filteredSpecialties[index];

                        return ListTile(
                          title: Text(item.name),
                          onTap: () {
                            cubit.addSpecialty(item);
                            specialtyCubit.clearSearch();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (_, state) {
                  return Wrap(
                    spacing: 8,
                    children: state.specialties
                        .map(
                          (e) => Chip(
                            label: Text(e.name),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => cubit.removeSpecialty(e.id),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Dirección *",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AddressSearchBox(
                controller: cubit.addressController,
                onClear: cubit.clearAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return s.fieldRequired;
                  }
                  final addressState = context.read<AddressCubit>().state;
                  if (addressState.selectedAddress == null) {
                    return "Debe seleccionar una dirección de la lista";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: s.register_next,
                onPressed: () {
                  if (cubit.state.specialties.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Debe seleccionar al menos una especialidad',
                        ),
                      ),
                    );
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
