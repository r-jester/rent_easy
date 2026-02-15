import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/property_card.dart';
import 'edit_property_screen.dart';

class OwnerPropertyListScreen extends StatelessWidget {
  const OwnerPropertyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PropertyProvider>(
      builder: (context, auth, propertyProvider, _) {
        final ownerId = auth.currentUserId ?? '';
        final properties = propertyProvider.ownerProperties(ownerId);

        if (properties.isEmpty) {
          return const Center(child: Text('No properties yet. Add your first listing.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: properties.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) {
            final property = properties[index];
            return PropertyCard(
              property: property,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPropertyScreen(property: property),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => propertyProvider.deleteProperty(property.id),
              ),
            );
          },
        );
      },
    );
  }
}
