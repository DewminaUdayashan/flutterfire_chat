import 'package:flutter/material.dart';

import '../screens/splash.dart';

class Routes {
  static const splash = '/splash';

  static Map<String, Widget Function(BuildContext)> getRoutes = {
    splash: (_) {
      return const Splash();
    },
  };
}
