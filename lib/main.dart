import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gala_mobile/app/router.dart';
import 'package:gala_mobile/core/network/api_client.dart';
import 'package:gala_mobile/core/network/auth_interceptor.dart';
import 'package:gala_mobile/core/storage/secure_storage.dart';
import 'package:gala_mobile/features/auth/data/auth_repository.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final storage = SecureStorage();
  final dio = createDio();
  final authRepository = AuthRepository(dio: dio, storage: storage);

  final authCubit = AuthCubit(repository: authRepository);

  dio.interceptors.add(AuthInterceptor(
    dio: dio,
    storage: storage,
    onForceLogout: () => authCubit.logout(),
  ));

  await authCubit.checkAutoLogin();

  runApp(GalaApp(
    authCubit: authCubit,
    storage: storage,
  ));
}

class GalaApp extends StatefulWidget {
  final AuthCubit authCubit;
  final SecureStorage storage;

  const GalaApp({
    super.key,
    required this.authCubit,
    required this.storage,
  });

  @override
  State<GalaApp> createState() => _GalaAppState();
}

class _GalaAppState extends State<GalaApp> {
  late final _router = createRouter(widget.authCubit, widget.storage);
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void _showSnack(SnackBar snack) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldMessengerKey.currentState?.showSnackBar(snack);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.authCubit,
      child: MaterialApp.router(
        title: 'GALA',
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        scaffoldMessengerKey: _scaffoldMessengerKey,
        routerConfig: _router,
        builder: (context, child) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthEmailInput) {
                _router.go('/auth/email');
              } else if (state is AuthOtpSent) {
                _router.go('/auth/otp', extra: state);
              } else if (state is AuthAuthenticated) {
                _router.go('/profile');
              } else if (state is AuthInitial) {
                _router.go('/');
              } else if (state is AuthUserStatusMismatch) {
                _showSnack(SnackBar(
                  content: Text(state.message),
                  action: SnackBarAction(
                    label: state.suggestedMode == AuthMode.login
                        ? 'Login'
                        : 'Register',
                    onPressed: () {
                      widget.authCubit.switchToSuggestedMode(state);
                    },
                  ),
                ));
              } else if (state is AuthError) {
                _showSnack(SnackBar(content: Text(state.message)));
              }
            },
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
