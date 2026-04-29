import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lookstrip/core/theme/app_theme.dart';
import 'package:lookstrip/core/services/app_config.dart';
import 'package:lookstrip/core/services/chat_storage.dart';
import 'package:lookstrip/core/services/expense_service.dart';
import 'package:lookstrip/core/services/packing_service.dart';
import 'package:lookstrip/core/services/trip_storage.dart';
import 'package:lookstrip/core/services/profile_storage.dart';
import 'package:lookstrip/core/services/serpapi_service.dart';
import 'package:lookstrip/core/services/supabase_service.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:lookstrip/features/configuration/configuration_screen.dart';
import 'package:lookstrip/features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Optional local development config. Production should use --dart-define.
  await dotenv.load(fileName: '.env', isOptional: true);

  // Initialize Mapbox only when configured.
  if (AppConfig.hasMapboxConfig) {
    MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
  }

  // Initialize Supabase only when configured.
  await SupabaseService.initialize();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await ChatStorage.init();
  await TripStorage.init();
  await ExpenseService.init();
  await PackingService.init();
  await ProfileStorage.init();
  await SerpApiService.init();

  // Force dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1C1917),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: LooksTripApp()));
}

class LooksTripApp extends StatelessWidget {
  const LooksTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LooksTrip',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const StartupGate(),
    );
  }
}

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _continueOffline = false;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasRecommendedConfiguration && !_continueOffline) {
      return ConfigurationScreen(
        onContinue: () => setState(() => _continueOffline = true),
      );
    }

    return const SplashScreen();
  }
}
