import 'package:clinexa_derivant_app/data/models/user_model.dart';
import 'package:clinexa_derivant_app/domain/address_repository.dart';
import 'package:clinexa_derivant_app/presentation/specialty/specialty_repository.dart';
import 'package:clinexa_derivant_app/domain/user_repository.dart';
import 'package:clinexa_derivant_app/presentation/address/cubit/address_cubit.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';
import 'package:clinexa_derivant_app/presentation/profile/cubit/edit_profile_cubit.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/address_search_box.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/custom_dialogs.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/debounced_search_textfield.dart';
import 'package:clinexa_derivant_app/presentation/specialty/cubit/specialty_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/login/login_screen.dart';

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

  Future<void> _confirmLogout(BuildContext context) async {
    final s = S.of(context);
    final ok = await ClxDialog.confirm(
      context,
      title: s.logoutConfirmTitle,
      message: s.logoutConfirmMessage,
      confirmLabel: s.logout,
      cancelLabel: s.cancel,
      icon: LucideIcons.logOut,
    );
    if (!ok || !context.mounted) return;
    context.read<AuthCubit>().logout();
    context.go(LoginScreen.path);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    final specialtyCubit = context.read<SpecialtyCubit>();
    final s = S.of(context);
    final t = context.clxText;
    final user = context.read<AuthCubit>().state.user;
    final fullName = [user?.firstName, user?.lastName].whereType<String>().join(' ');

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
            title: s.profileUpdatedTitle,
            successMessage: s.profileUpdatedSuccess,
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to profile
            },
          );
        } else if (state.status == EditProfileStatus.error) {
          context.pop(); // Close loading
          CustomDialogs.errorDialog(
            context,
            state.errorMessage ?? s.unexpectedError,
          );
        }
      },
      child: Scaffold(
        appBar: ClxAppBar(title: s.myProfile),
        bottomNavigationBar: ClxBottomBar(
          child: ClxButton(
            key: const Key('profile_save_button'),
            label: s.saveChanges,
            onPressed: () => cubit.save(),
          ),
        ),
        body: Form(
          key: cubit.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(ClxSpace.s4, ClxSpace.s5, ClxSpace.s4, ClxSpace.s8),
            children: [
              // Encabezado con la cuenta
              Row(
                children: [
                  ClxAvatar(name: fullName.isEmpty ? (user?.email ?? '?') : fullName, size: 56),
                  const SizedBox(width: ClxSpace.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName, style: t.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(user?.email ?? '', style: t.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
                        if ((user?.medicalLicense ?? '').isNotEmpty) ...[
                          const SizedBox(height: ClxSpace.s2),
                          ClxBadge(
                            label: s.licenseBadge(user!.medicalLicense!),
                            icon: LucideIcons.idCard,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ClxSpace.s8),

              _Section(title: s.personalInformation),
              ClxTextField(
                label: s.firstName,
                controller: cubit.firstNameController,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.isEmpty) ? s.fieldRequired : null,
              ),
              const SizedBox(height: ClxSpace.s5),
              ClxTextField(
                label: s.lastName,
                controller: cubit.lastNameController,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.isEmpty) ? s.fieldRequired : null,
              ),
              const SizedBox(height: ClxSpace.s8),

              _Section(title: s.address),
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
              const SizedBox(height: ClxSpace.s8),

              _Section(title: s.specialties, subtitle: s.specialtiesProfileHint),
              DebouncedSearchField(
                icon: LucideIcons.stethoscope,
                onSearch: (val) => specialtyCubit.searchSpecialties(val),
                hintText: s.searchSpecialtyHint,
                controller: cubit.specialtyController,
              ),

              // Resultados de búsqueda
              BlocBuilder<SpecialtyCubit, SpecialtyState>(
                builder: (context, state) {
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

              // Especialidades elegidas
              BlocBuilder<EditProfileCubit, EditProfileState>(
                builder: (context, state) {
                  if (state.specialties.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: ClxSpace.s3),
                    child: Wrap(
                      spacing: ClxSpace.s2,
                      runSpacing: ClxSpace.s2,
                      children: state.specialties.map((sp) {
                        return ClxInputChip(
                          label: sp.name,
                          removeTooltip: s.removeItem,
                          onRemove: () => cubit.removeSpecialty(sp),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: ClxSpace.s8),
              _Section(title: s.accountSection),
              ClxListGroup(
                children: [
                  ClxListTile(
                    key: const Key('profile_logout_tile'),
                    title: s.logout,
                    subtitle: s.logoutSubtitle,
                    icon: LucideIcons.logOut,
                    destructive: true,
                    showChevron: false,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ClxSpace.s4),
      child: ClxSectionHeader(title: title, subtitle: subtitle),
    );
  }
}
