import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kora/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kora/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kora/features/auth/domain/repositories/auth_repository.dart';
import 'package:kora/features/auth/domain/usecases/forgot_password.dart';
import 'package:kora/features/auth/domain/usecases/get_current_user.dart';
import 'package:kora/features/auth/domain/usecases/sign_in.dart';
import 'package:kora/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:kora/features/auth/domain/usecases/sign_out.dart';
import 'package:kora/features/auth/domain/usecases/sign_up.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/get_entries.dart';
import 'package:kora/features/new_journal_entry/entry/presentation/bloc/entry_bloc.dart';
import 'package:kora/features/new_journal_entry/health/presentation/bloc/health_bloc.dart';
import 'package:kora/features/new_journal_entry/recording/data/datasources/emotion_local_datasource.dart';
import 'package:kora/features/new_journal_entry/entry/data/datasources/entry_local_datasource.dart';
import 'package:kora/features/new_journal_entry/entry/data/datasources/entry_remote_datasource.dart';
import 'package:kora/features/new_journal_entry/health/data/datasources/health_local_datasource.dart';
import 'package:kora/features/new_journal_entry/recording/data/repositories/audio_repository_impl.dart';
import 'package:kora/features/new_journal_entry/recording/data/repositories/emotion_repository_impl.dart';
import 'package:kora/features/new_journal_entry/entry/data/repositories/entry_repository_impl.dart';
import 'package:kora/features/new_journal_entry/health/data/repositories/health_repository_impl.dart';
import 'package:kora/features/new_journal_entry/entry/data/repositories/location_repository_impl.dart';
import 'package:kora/features/new_journal_entry/recording/domain/repositories/audio_repository.dart';
import 'package:kora/features/new_journal_entry/recording/domain/repositories/emotion_repository.dart';
import 'package:kora/features/new_journal_entry/entry/domain/repositories/entry_repository.dart';
import 'package:kora/features/new_journal_entry/health/domain/repositories/health_repository.dart';
import 'package:kora/features/new_journal_entry/entry/domain/repositories/location_repository.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/analyze_sentiment_usecase.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/calculate_viatlity_usecase.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/detect_emotion_usecase.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/draft_usecases.dart';
import 'package:kora/features/new_journal_entry/health/domain/usecases/fetch_activity_usecase.dart';
import 'package:kora/features/new_journal_entry/health/domain/usecases/fetch_health_data_usecases.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/recording_control_usecases.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/resolve_location_usecase.dart';
import 'package:kora/features/new_journal_entry/entry/domain/usecases/save_entry.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/start_recording_usecase.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/stop_recording_usecase.dart';
import 'package:kora/features/new_journal_entry/recording/domain/usecases/watch_recording_ticks_usecase.dart';
import 'package:kora/features/new_journal_entry/recording/presentation/bloc/recording_bloc.dart';
import 'package:kora/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:kora/features/profile/data/repositories/profile_repository.dart';
import 'package:kora/features/profile/domain/repositories/profile_repository_impl.dart';
import 'package:kora/features/profile/domain/usecases/get_profile.dart';
import 'package:kora/features/profile/domain/usecases/get_profile_stats.dart';
import 'package:kora/features/profile/domain/usecases/upload_profile.dart';
import 'package:kora/features/profile/presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =====================
  // External
  // =====================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
sl.registerLazySingleton(() => GoogleSignIn(
  serverClientId: '568736312947-gaifb9svlscnan43sb9j1kr41cf7vces.apps.googleusercontent.com',
));

  // =====================
  // Data Sources
  // =====================

sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSource(sl(), sl()),
);
  sl.registerLazySingleton<EntryLocalDataSource>(
    () => EntryLocalDataSource(),
  );
  sl.registerLazySingleton<EntryRemoteDataSource>(
    () => EntryRemoteDataSource(),
  );
  sl.registerLazySingleton<EmotionLocalDataSource>(
    () => EmotionLocalDataSource(),
  );
  sl.registerLazySingleton<HealthLocalDataSource>(
    () => HealthLocalDataSource(),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
  () => ProfileRemoteDataSource(),
);

  await sl<EmotionLocalDataSource>().initialize();

  // =====================
  // Repositories
  // =====================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<EmotionRepository>(
    () => EmotionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<EntryRepository>(
    () => EntryRepositoryImpl(
      local: sl(),
      remote: sl(),
    ),
  );
  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(),
  );
  sl.registerLazySingleton<AudioRepository>(
    () => AudioRepositoryImpl(),
  );

  // =====================
  // Use Cases
  // =====================
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  sl.registerLazySingleton(() => SaveEntryUseCase(sl()));
  sl.registerLazySingleton(() => SaveDraftUseCase(sl()));
  sl.registerLazySingleton(() => LoadDraftUseCase(sl()));
  sl.registerLazySingleton(() => ClearDraftUseCase(sl()));
  sl.registerLazySingleton(() => HasDraftUseCase(sl()));

  sl.registerLazySingleton(() => FetchHealthDataUseCase(sl()));
  sl.registerLazySingleton(() => FetchHeartRateUseCase(sl()));
  sl.registerLazySingleton(() => RequestHealthPermissionsUseCase(sl()));

  sl.registerLazySingleton(() => ResolveLocationUseCase(sl()));
  sl.registerLazySingleton(() => DetectEmotionUseCase(sl()));
  sl.registerLazySingleton(() => ExtractSpectrogramCurveUseCase(sl()));
  sl.registerLazySingleton(() => AnalyzeSentimentUseCase());
  sl.registerLazySingleton(() => CalculateVitalityUseCase());
  sl.registerLazySingleton(() => FetchActivityUseCase(sl()));
  sl.registerLazySingleton(() => StartRecordingUseCase(sl()));
  sl.registerLazySingleton(() => StopRecordingUseCase(
        repository: sl(),
        detectEmotion: sl(),
        extractCurve: sl(),
      ));
  sl.registerLazySingleton(() => PauseRecordingUseCase(sl()));
  sl.registerLazySingleton(() => ResumeRecordingUseCase(sl()));
  sl.registerLazySingleton(() => CancelRecordingUseCase(sl()));
  sl.registerLazySingleton(() => CheckMicrophonePermissionUseCase(sl()));
  sl.registerLazySingleton(() => WatchRecordingTicksUseCase(sl()));

  sl.registerLazySingleton(() => GetEntries(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => GetProfileStats(sl()));
  sl.registerLazySingleton(() => UploadProfilePhoto(sl()));
 


  // =====================
  // Blocs
  // =====================
  sl.registerFactory(() => AuthBloc(
        signIn: sl(),
        signUp: sl(),
        forgotPassword: sl(),
        signOut: sl(),
        getCurrentUser: sl(),
        signInWithGoogle: sl()
      ));

  sl.registerFactory(() => HealthBloc(
        fetchHeartRate: sl(),
        fetchActivity: sl(),
        requestPermissions: sl(),
      ));

  sl.registerFactory(() => RecordingBloc(
        start: sl(),
        stop: sl(),
        pause: sl(),
        resume: sl(),
        cancel: sl(),
        checkMicPermission: sl(),
        watchTicks: sl(),
      ));
sl.registerFactoryParam<EntryBloc, HealthBloc, RecordingBloc>(
    (healthBloc, recordingBloc) => EntryBloc(
      saveEntry: sl(),
      saveDraft: sl(),
      loadDraft: sl(),
      clearDraft: sl(),
      hasDraft: sl(),
      resolveLocation: sl(),
      analyzeSentiment: sl(),
      calculateVitality: sl(),
      healthBloc: healthBloc,
      recordingBloc: recordingBloc,
    ),
  );
sl.registerFactory(() => ProfileBloc(
      getProfile: sl(),
      getProfileStats: sl(),
      uploadProfilePhoto: sl(),
    ));
}