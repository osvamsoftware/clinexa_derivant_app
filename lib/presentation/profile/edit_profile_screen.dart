import 'package:clinexa_derivant_app/data/models/user_model.dart';
import 'package:clinexa_derivant_app/domain/address_repository.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:clinexa_derivant_app/domain/user_repository.dart';
import 'package:clinexa_derivant_app/presentation/address/cubit/address_cubit.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/profile/cubit/edit_profile_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/address_search_box.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_button.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_textfield.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';
import 'package:clinexa_derivant_app/presentation/specialty/cubit/specialty_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatelessWidget {
  static const path = "/edit-profile";
  final UserModel currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EditProfileCubit(
            userRepository: context.read<UserRepository>(),
            specialtyRepository: context.read<SpecialtyRepository>(),
            currentUser: currentUser,
          ),
        ),
        BlocProvider(
          create: (context) => AddressCubit(context.read<AddressRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              SpecialtyCubit(context.read<SpecialtyRepository>()),
        ),
      ],
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    final specialtyCubit = context.read<SpecialtyCubit>();

    return BlocListener<EditProfileCubit, EditProfileState>(
      listener: (context, state) {
        if (state.status == EditProfileStatus.loading) {
          CustomDialogs.loadingDialog(context);
        } else if (state.status == EditProfileStatus.success) {
          // Actualizar AuthCubit con información del usuario actualizada
          context.read<AuthCubit>().updateAuthUser();

          context.pop(); // Close loading
          CustomDialogs.successDialog(
            context: context,
            successMessage: "Perfil actualizado correctamente",
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to profile
            },
          );
        } else if (state.status == EditProfileStatus.error) {
          context.pop(); // Close loading
          CustomDialogs.errorDialog(
            context,
            state.errorMessage ?? "Error desconocido",
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Editar Perfil")),
        body: Form(
          key: cubit.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Información Personal",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Nombre",
                  controller: cubit.firstNameController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Campo requerido" : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Apellido",
                  controller: cubit.lastNameController,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Campo requerido" : null,
                ),
                const SizedBox(height: 32),

                const Text(
                  "Dirección",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                BlocListener<AddressCubit, AddressState>(
                  listener: (context, state) {
                    if (state.selectedAddress != null) {
                      cubit.setAddress(state.selectedAddress!);
                    }
                  },
                  child: AddressSearchBox(
                    controller: cubit.addressController,
                    onClear: cubit.clearAddress,
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  "Especialidades",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DebouncedSearchField(
                  label: "Buscar especialidad",
                  onSearch: (val) => specialtyCubit.searchSpecialties(val),
                  hintText: "Ej. Cardiología",
                  controller: cubit.specialtyController,
                ),
                const SizedBox(height: 8),

                // Search Results List
                BlocBuilder<SpecialtyCubit, SpecialtyState>(
                  builder: (context, state) {
                    if (state.filteredSpecialties.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      elevation: 4,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: state.filteredSpecialties.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
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
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                // Selected Specialties Chips
                BlocBuilder<EditProfileCubit, EditProfileState>(
                  builder: (context, state) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.specialties.map((s) {
                        return Chip(
                          label: Text(s.name),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => cubit.removeSpecialty(s),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 48),
                CustomButton(
                  text: "Guardar Cambios",
                  onPressed: () => cubit.save(),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      context.go(
                        '/login',
                      ); // Using hardcoded path or LoginScreen.path if imported
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Cerrar Sesión"),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
