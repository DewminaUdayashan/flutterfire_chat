import 'package:chatty_chat/services/auth_services.dart';
import 'package:chatty_chat/services/firestore_services.dart';
import 'package:chatty_chat/shared/observer.dart';
import 'package:chatty_chat/shared/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'logic/auth/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            AuthServices(
              FirestoreServices(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        initialRoute: Routes.splash,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: Routes.getRoutes,
      ),
    );
  }
}
