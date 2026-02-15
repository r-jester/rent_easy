import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Icon(Icons.apartment_rounded, size: 84),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(AppStrings.slogan),
                  const SizedBox(height: 24),
                  const Text('Browse homes, save favorites, and book rentals offline.'),
                  const Spacer(),
                  CustomButton(
                    label: 'Get Started',
                    onPressed: () => context.read<AuthProvider>().completeOnboarding(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
