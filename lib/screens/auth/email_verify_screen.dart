import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../services/auth_services.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state changed =============== ${state.name}');
    if (state == AppLifecycleState.resumed) {
      /// when user going to verify the email address, this comes to play
      /// when app resumed, we reload the `firebase user` to get updates
      context.read<AuthBloc>().add(ReloadAuth());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool waiting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              waiting
                  ? 'Please check your main inbox.\nWaiting for confirmation...'
                  : 'Tap below button to verify your email!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: waiting
                  ? () {
                      print(AuthServices().currentUser?.emailVerified);
                    }
                  : () {
                      setState(() {
                        waiting = true;
                      });
                      context.read<AuthBloc>().add(VerifyEmail());
                    },
              child: waiting
                  ? const CircularProgressIndicator.adaptive()
                  : const Text('Send Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}
