import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../client/login_page.dart';

/// PLACEHOLDER: temporary screen to test the login redirection.
/// The real pro dashboard (statistics, services) comes later.
class DashboardPro extends StatelessWidget {
  const DashboardPro({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace professionnel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Bienvenue, ${user?.name ?? ''}',
            style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}