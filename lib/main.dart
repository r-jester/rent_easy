import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/property_provider.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()..initialize()),
      ],
      child: const RentEasyApp(),
    ),
  );
}
