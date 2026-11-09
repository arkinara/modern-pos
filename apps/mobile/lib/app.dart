import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/sign_in_screen.dart';
import 'routes/router.dart';
import 'theme/app_theme.dart';

class ModernPosApp extends ConsumerStatefulWidget {
  const ModernPosApp({super.key});

  @override
  ConsumerState<ModernPosApp> createState() => _ModernPosAppState();
}

class _ModernPosAppState extends ConsumerState<ModernPosApp> {
  late final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final theme = buildAppTheme();

    if (auth.isLoading && !auth.hasValue) {
      return MaterialApp(
        title: 'Modern POS',
        theme: theme,
        home: const _StartupScreen(),
      );
    }

    if (auth.value == null) {
      return MaterialApp(
        title: 'Modern POS',
        theme: theme,
        home: const SignInScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Modern POS',
      theme: theme,
      routerConfig: _router,
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Restoring session'),
          ],
        ),
      ),
    );
  }
}
