// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/core/di/injector.dart';
import 'package:kora/core/theme/app_theme.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/journals/presentation/bloc/journal_bloc.dart';
import 'package:kora/features/journals/data/entry_firestore_service.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/get_entries.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/health/data/datasources/health_local_datasource.dart';
import 'package:kora/features/profile/domain/usecases/get_profile.dart';
import 'package:kora/features/profile/domain/usecases/get_profile_stats.dart';
import 'package:kora/features/profile/domain/usecases/upload_profile.dart';
import 'package:kora/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kora/features/profile/presentation/bloc/profile_event.dart';
import 'package:kora/features/settings/service/notification_service.dart';
import 'package:kora/firebase_options.dart';
import 'package:kora/features/onbording/presentation/bloc/onboarding_bloc.dart';
import 'package:kora/features/onbording/presentation/pages/onboarding_screen.dart';
import 'package:kora/features/onbording/presentation/pages/splash_screen.dart';
import 'package:kora/features/auth/presentation/pages/auth_gate.dart';
import 'package:kora/features/new_journal_entry/health/presentation/bloc/health_bloc.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/bloc/recording_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    await NotificationService.instance.init(); 
  await HealthLocalDataSource.configureEarly();

  await init();
  
  runApp(const KoraApp());
}

class KoraApp extends StatelessWidget {
  const KoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
    ),

    BlocProvider<JournalBloc>(
      create: (_) => JournalBloc(
        sl<GetEntries>(),
      ),
    ),
    BlocProvider<ProfileBloc>(
  create: (_) => ProfileBloc(
    getProfile: sl<GetProfile>(),
    getProfileStats: sl<GetProfileStats>(),
    uploadProfilePhoto: sl<UploadProfilePhoto>(),
  )..add(LoadProfileRequested()),
),
    //  BlocProvider<NewEntryBloc>(
    //   create: (context) => sl<NewEntryBloc>(),
    // ),
    BlocProvider<EntryBloc>(
      create: (context) => sl<EntryBloc>(
        param1: context.read<HealthBloc>(),
        param2: context.read<RecordingBloc>(),
      )..add(const EntryInitialized()),
    ),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    debugShowCheckedModeBanner: false,
    home: const _RootNavigator(),
  ),
);
  }
}

class _RootNavigator extends StatefulWidget {
  const _RootNavigator();

  @override
  State<_RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<_RootNavigator> {
  bool _showSplash = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showSplash) _onSplashFinished();
    });
  }

  void _onSplashFinished() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _showSplash = false;
      // Skip onboarding if already logged in
      _showOnboarding = user == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onFinished: _onSplashFinished);
    }

    if (_showOnboarding) {
      return BlocProvider(
        create: (_) => OnboardingBloc(),
        child: OnboardingScreen(
          onCompleted: () => setState(() => _showOnboarding = false),
        ),
      );
    }

    return const AuthGate();
  }
}