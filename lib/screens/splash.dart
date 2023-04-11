import 'package:chatty_chat/shared/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/auth/auth_bloc.dart';
import 'auth/sign_in_screen.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      listener: (context, state) {
        if (state is Authenticated) {
          if (state.verificationException != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.verificationException.toString(),
                  ),
                ),
              );
          }
          Navigator.pushReplacementNamed(context, Routes.chat);
        }
        if (state is AuthenticationFailed) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.exception.toString(),
                ),
              ),
            );
        }
        if (state is NotAuthenticated) {
          Navigator.pushReplacementNamed(context, Routes.splash);
        }
      },
      bloc: context.read<AuthBloc>(),
      builder: (context, state) {
        if (state is Authenticated) {
          // if (!state.verifiedUser) {
          //   return const VerifyEmailScreen();
          // }
          return const SizedBox.shrink();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
