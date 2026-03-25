import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinexa_derivant_app/presentation/protocol/protocol_selection_screen.dart';
import 'package:clinexa_derivant_app/presentation/shared/widgets/home_header.dart';
import 'package:clinexa_derivant_app/presentation/auth_loading/cubit/auth_cubit.dart';

class HomeScreen extends StatelessWidget {
  static const path = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final rawName = authState.user?.firstName ?? 'User';
        final userName = _formatName(rawName);

        return Scaffold(
          body: Column(
            children: [
              HomeHeader(name: userName),
              const Expanded(
                child: ProtocolSelectionScreen(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatName(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
