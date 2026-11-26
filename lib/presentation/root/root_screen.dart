import 'package:clinexa_derivant_app/core/ui/clx_ui.dart';
import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/notifications/screens/home_screen.dart';
import 'package:clinexa_derivant_app/presentation/patients/patients_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootPage extends StatelessWidget {
  final Widget child;
  static const path = "/";

  const RootPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getIndexFromLocation(context);
    final s = S.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: ClxNavBar(
        currentIndex: currentIndex,
        onTap: (i) => _onItemTapped(i, context),
        items: [
          ClxNavItem(icon: LucideIcons.house, label: s.navHome),
          ClxNavItem(icon: LucideIcons.usersRound, label: s.navPatients),
        ],
      ),
    );
  }

  // =============================================================
  // 🔹 DETECT ACTIVE INDEX BASED ON GO ROUTER LOCATION
  // =============================================================
  int _getIndexFromLocation(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith(PatientsScreen.path)) return 1;
    // if (location.startsWith(ProtocolListScreen.path)) return 2;
    // if (location.startsWith(ConversationScreen.path)) return 3;

    return 0; // default -> home
  }

  // =============================================================
  // 🔹 HANDLE TAPS
  // =============================================================
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(HomeScreen.path);
        break;
      case 1:
        context.go(PatientsScreen.path);
        break;
      // case 2:
      //   context.go(ProtocolListScreen.path);
      //   break;
      // case 3:
      //   context.go(ConversationScreen.path);
      //   break;
    }
  }
}
