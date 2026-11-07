import 'package:flutter/material.dart';

import 'routes/router.dart';
import 'theme/app_theme.dart';

class ModernPosApp extends StatelessWidget {
  const ModernPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Modern POS',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
