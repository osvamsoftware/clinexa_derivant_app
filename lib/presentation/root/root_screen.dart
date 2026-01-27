import 'package:clinexa_derivant_app/l10n/app_localizations.dart';
import 'package:clinexa_derivant_app/presentation/home_screen.dart';
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
      extendBody: true,
      body: child,

      // 🌟 FLOATING NAV BAR
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12), // separa un poquito
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (i) => _onItemTapped(i, context),
              backgroundColor: Colors.transparent,
              elevation: 0,

              type: BottomNavigationBarType.fixed,

              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,

              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  label: s.navHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.people_alt_outlined),
                  label: s.navPatients,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.description_outlined),
                  label: s.navProtocols,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: s.navMessages,
                ),
              ],
            ),
          ),
        ),
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
