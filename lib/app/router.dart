import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gala_mobile/app/home_shell.dart';
import 'package:gala_mobile/core/storage/secure_storage.dart';
import 'package:gala_mobile/features/account/data/events_repository.dart';
import 'package:gala_mobile/features/account/presentation/cubit/events_cubit.dart';
import 'package:gala_mobile/features/account/presentation/pages/account_menu_page.dart';
import 'package:gala_mobile/features/account/presentation/pages/event_form_page.dart';
import 'package:gala_mobile/features/account/presentation/pages/my_events_page.dart';
import 'package:gala_mobile/features/interests/data/interests_repository.dart';
import 'package:gala_mobile/features/interests/presentation/cubit/interests_cubit.dart';
import 'package:gala_mobile/features/interests/presentation/pages/interest_form_page.dart';
import 'package:gala_mobile/features/interests/presentation/pages/my_interests_page.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/otp_timer_cubit.dart';
import 'package:gala_mobile/features/auth/presentation/pages/landing_page.dart';
import 'package:gala_mobile/features/auth/presentation/pages/email_input_page.dart';
import 'package:gala_mobile/features/auth/presentation/pages/otp_input_page.dart';
import 'package:gala_mobile/features/members/data/members_repository.dart';
import 'package:gala_mobile/features/members/presentation/cubit/member_search_cubit.dart';
import 'package:gala_mobile/features/members/presentation/pages/member_search_page.dart';
import 'package:gala_mobile/features/network/presentation/pages/network_page.dart';
import 'package:gala_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:gala_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:gala_mobile/features/requests/presentation/pages/requests_page.dart';

const _authenticatedRoots = ['/network', '/requests', '/interests', '/account'];

bool _isAuthenticatedPath(String path) {
  return _authenticatedRoots
      .any((root) => path == root || path.startsWith('$root/'));
}

GoRouter createRouter(AuthCubit authCubit, SecureStorage storage, Dio dio) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRefreshNotifier(authCubit),
    redirect: (context, state) {
      final isAuthenticated = authCubit.state is AuthAuthenticated;
      final currentPath = state.matchedLocation;
      final inAuthenticatedSection = _isAuthenticatedPath(currentPath);

      if (isAuthenticated && !inAuthenticatedSection) {
        return '/network';
      }
      if (!isAuthenticated && inAuthenticatedSection) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/auth/email',
        builder: (context, state) => const EmailInputPage(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final otpState = (state.extra as AuthOtpSent?) ??
              _otpContextOf(authCubit.state);
          if (otpState == null) {
            return const Scaffold(
              body: Center(child: Text('Lost OTP context')),
            );
          }
          return BlocProvider(
            create: (_) => OtpTimerCubit()..start(otpState.expiresIn),
            child: OtpInputPage(otpState: otpState),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/network',
                builder: (context, state) => const NetworkPage(),
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (context, state) => BlocProvider(
                      create: (_) => MemberSearchCubit(
                        repository: MembersRepository(dio: dio),
                      ),
                      child: const MemberSearchPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/requests',
                builder: (context, state) => const RequestsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/interests',
                builder: (context, state) => BlocProvider(
                  create: (_) => InterestsCubit(
                    repository: InterestsRepository(dio: dio),
                  )..load(),
                  child: const MyInterestsPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) {
                      final cubit = state.extra as InterestsCubit;
                      return BlocProvider.value(
                        value: cubit,
                        child: const InterestFormPage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountMenuPage(),
                routes: [
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => BlocProvider(
                      create: (context) => ProfileCubit(storage: storage),
                      child: const ProfilePage(),
                    ),
                  ),
                  GoRoute(
                    path: 'events',
                    builder: (context, state) => BlocProvider(
                      create: (_) => EventsCubit(
                        repository: EventsRepository(dio: dio),
                      )..load(),
                      child: const MyEventsPage(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) {
                          final cubit = state.extra as EventsCubit;
                          return BlocProvider.value(
                            value: cubit,
                            child: const EventFormPage(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

AuthOtpSent? _otpContextOf(AuthState state) {
  return switch (state) {
    AuthOtpSent s => s,
    AuthOtpInvalid s => s.context,
    AuthOtpLocked s => s.context,
    _ => null,
  };
}

class _AuthRefreshNotifier extends ChangeNotifier {
  bool _wasAuthenticated;

  _AuthRefreshNotifier(AuthCubit cubit)
      : _wasAuthenticated = cubit.state is AuthAuthenticated {
    cubit.stream.listen((state) {
      final isAuth = state is AuthAuthenticated;
      if (isAuth != _wasAuthenticated) {
        _wasAuthenticated = isAuth;
        notifyListeners();
      }
    });
  }
}
