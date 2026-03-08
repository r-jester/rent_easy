import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.home_work, size: 84, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            SizedBox(height: 8),
            Text(AppStrings.slogan),
          ],
        ),
      ),
    );
  }
}
