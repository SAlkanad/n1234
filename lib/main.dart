import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/client_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/settings_controller.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'services/status_update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize other services
  await NotificationService.initialize();
  tz.initializeTimeZones();

  // Start background services
  BackgroundService.startBackgroundTasks();
  StatusUpdateService.startAutoStatusUpdate();

  runApp(PassengersApp());
}

class PassengersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ClientController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: MaterialApp(
        title: 'نظام إدارة تأشيرات العمرة',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
        locale: Locale('ar', 'SA'),
        supportedLocales: [
          Locale('ar', 'SA'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}