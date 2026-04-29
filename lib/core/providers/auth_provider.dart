import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lookstrip/core/models/user_model.dart';
import 'package:lookstrip/core/services/chat_storage.dart';
import 'package:lookstrip/core/services/expense_service.dart';
import 'package:lookstrip/core/services/packing_service.dart';
import 'package:lookstrip/core/services/profile_storage.dart';
import 'package:lookstrip/core/services/serpapi_service.dart';
import 'package:lookstrip/core/services/supabase_service.dart';
import 'package:lookstrip/core/services/trip_storage.dart';

/// Auth status
enum AuthStatus { initial, loading, authenticated, unauthenticated }

/// Auth state
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Auth Notifier — real Supabase phone auth + Hive profile persistence
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  SupabaseClient? get _supabase => SupabaseService.maybeClient;

  /// Check if user is already signed in
  Future<void> checkAuthState() async {
    state = state.copyWith(status: AuthStatus.loading);
    final supabase = _supabase;

    // Check Supabase session first
    final session = supabase?.auth.currentSession;
    if (session != null) {
      final supaUser = supabase!.auth.currentUser;
      final remoteUser = supaUser == null
          ? null
          : await _loadRemoteProfile(supaUser.id);
      if (remoteUser != null) {
        TripStorage.setUserScope(remoteUser.id);
        ChatStorage.setUserScope(remoteUser.id);
        ExpenseService.setUserScope(remoteUser.id);
        PackingService.setUserScope(remoteUser.id);
        SerpApiService.setUserScope(remoteUser.id);
        await ProfileStorage.saveUser(remoteUser);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: remoteUser,
        );
        return;
      }

      // Active Supabase session — load profile from Hive
      final savedUser = ProfileStorage.loadUser();
      if (savedUser != null && savedUser.id == supaUser?.id) {
        TripStorage.setUserScope(savedUser.id);
        ChatStorage.setUserScope(savedUser.id);
        ExpenseService.setUserScope(savedUser.id);
        PackingService.setUserScope(savedUser.id);
        SerpApiService.setUserScope(savedUser.id);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: savedUser,
        );
        return;
      }

      // Session exists but no profile — create user from session
      if (supaUser != null) {
        final user = UserModel(
          id: supaUser.id,
          phone: supaUser.phone ?? '',
          createdAt: DateTime.parse(supaUser.createdAt),
        );
        TripStorage.setUserScope(user.id);
        ChatStorage.setUserScope(user.id);
        ExpenseService.setUserScope(user.id);
        PackingService.setUserScope(user.id);
        SerpApiService.setUserScope(user.id);
        await ProfileStorage.saveUser(user);
        await _saveRemoteProfile(user);
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return;
      }
    }

    // No session — check local profile (offline support)
    final savedUser = ProfileStorage.loadUser();
    if (savedUser != null) {
      TripStorage.setUserScope(savedUser.id);
      ChatStorage.setUserScope(savedUser.id);
      ExpenseService.setUserScope(savedUser.id);
      PackingService.setUserScope(savedUser.id);
      SerpApiService.setUserScope(savedUser.id);
      state = state.copyWith(status: AuthStatus.authenticated, user: savedUser);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Send OTP via real Supabase phone auth
  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final supabase = _supabase;
    if (supabase == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error:
            'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
      return false;
    }
    try {
      await supabase.auth.signInWithOtp(phone: phone);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error:
            'Failed to send OTP. Please check your phone number and try again.',
      );
      return false;
    }
  }

  /// Verify OTP via real Supabase
  Future<bool> verifyOtp(String phone, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    final supabase = _supabase;
    if (supabase == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error:
            'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
      return false;
    }
    try {
      final response = await supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user != null) {
        final user = UserModel(
          id: response.user!.id,
          phone: phone,
          createdAt: DateTime.parse(response.user!.createdAt),
        );
        TripStorage.setUserScope(user.id);
        ChatStorage.setUserScope(user.id);
        ExpenseService.setUserScope(user.id);
        PackingService.setUserScope(user.id);
        SerpApiService.setUserScope(user.id);
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        // Persist locally
        await ProfileStorage.saveUser(user);
        await _saveRemoteProfile(user);
        return true;
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Verification failed. Please try again.',
      );
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Verification failed. Please check the OTP and try again.',
      );
      return false;
    }
  }

  /// Complete profile setup
  Future<void> completeProfile({
    required String name,
    required List<String> travelStyles,
  }) async {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        name: name,
        travelStyles: travelStyles,
        isProfileComplete: true,
      );
      state = state.copyWith(user: updatedUser);
      await ProfileStorage.saveUser(updatedUser);
      await _saveRemoteProfile(updatedUser);
    }
  }

  /// Sign out — clears both Supabase session and local data
  Future<void> updateTravelStyles(List<String> travelStyles) async {
    final user = state.user;
    if (user == null) return;

    final updatedUser = user.copyWith(
      travelStyles: travelStyles,
      isProfileComplete: user.isProfileComplete || user.name.isNotEmpty,
    );
    state = state.copyWith(user: updatedUser);
    await ProfileStorage.saveUser(updatedUser);
    await _saveRemoteProfile(updatedUser);
  }

  Future<void> signOut() async {
    try {
      await _supabase?.auth.signOut();
    } catch (_) {
      // Ignore sign out errors (e.g., no internet)
    }
    await ChatStorage.clearAllMessages();
    await TripStorage.clearAllTrips();
    await ExpenseService.clearAllExpenses();
    await PackingService.clearAllItems();
    await SerpApiService.clearAllCache();
    await ProfileStorage.clearAllProfiles();
    ChatStorage.setUserScope(null);
    ExpenseService.setUserScope(null);
    PackingService.setUserScope(null);
    TripStorage.setUserScope(null);
    SerpApiService.setUserScope(null);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<UserModel?> _loadRemoteProfile(String userId) async {
    final supabase = _supabase;
    if (supabase == null) return null;

    try {
      final row = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      return UserModel.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveRemoteProfile(UserModel user) async {
    final supabase = _supabase;
    if (supabase == null) return;

    try {
      await supabase.from('profiles').upsert(user.toJson());
    } catch (_) {
      // Local profile remains the offline source until the next successful sync.
    }
  }
}

/// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
