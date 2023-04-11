import 'package:chatty_chat/logic/chat/chat_cubit.dart';
import 'package:chatty_chat/logic/message/message_cubit.dart';
import 'package:chatty_chat/logic/users/users_cubit.dart';
import 'package:chatty_chat/services/auth_services.dart';
import 'package:chatty_chat/services/firestore_services.dart';
import 'package:chatty_chat/services/notification_services.dart';
import 'package:chatty_chat/services/storage_services.dart';
import 'package:chatty_chat/shared/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'logic/auth/auth_bloc.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Bloc.observer = AppBlocObserver();
  NotificationServices().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      // Navigator.pushNamed(
      //   context,
      //   '/chat',
      //   arguments: ChatArguments(message),
      // );
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreServices = FirestoreServices();
    final authServices = AuthServices(
      firestoreServices,
    );
    return RepositoryProvider(
      create: (context) => authServices,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authServices,
              StorageServices(),
            ),
          ),
          BlocProvider(
            create: (context) => UsersCubit(
              FirestoreServices(),
            ),
          ),
          BlocProvider(
            create: (context) => ChatCubit(firestoreServices),
          ),
          BlocProvider(
            create: (context) => MessageCubit(firestoreServices),
            lazy: true,
          ),
        ],
        child: MaterialApp(
          title: 'Chatty',
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.splash,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          routes: Routes.getRoutes,
        ),
      ),
    );
  }
}
