import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Choose your role. This is required once after register.'),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_search_outlined),
                    title: const Text('Renter'),
                    subtitle: const Text('Browse and request properties'),
                    onTap: () => context.read<AuthProvider>().setRole(UserRole.renter),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: const Text('Property Owner'),
                    subtitle: const Text('Create and manage property listings'),
                    onTap: () => context.read<AuthProvider>().setRole(UserRole.owner),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
