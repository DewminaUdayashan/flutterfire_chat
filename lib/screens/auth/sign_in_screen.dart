import 'package:chatty_chat/helpers/dialog_helper.dart';
import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../shared/animations/opacity_tween.dart';
import '../../shared/animations/slide_up_tween.dart';
import '../../shared/enums.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _globalKey = GlobalKey<FormState>();
  AuthType authType = AuthType.signUp;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void toggleAuthType() {
    switch (authType) {
      case AuthType.signUp:
        setState(() {
          authType = AuthType.login;
        });
        break;
      default:
        setState(() {
          authType = AuthType.signUp;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: context.height,
          width: context.width,
          child: OpacityTween(
            duration: const Duration(milliseconds: 1000),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16, top: kToolbarHeight),
                  width: context.width,
                  height: context.height / 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.theme.primaryContainer,
                        context.theme.background,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          '${authType.name} to your account',
                          style: context.textTheme.headlineLarge?.copyWith(
                            color: context.theme.onPrimaryContainer,
                            fontSize: 40,
                          ),
                          key: ValueKey(authType.name),
                        ),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: authType.isLogin
                            ? Text(
                                'Welcome back you\'ve been missed!',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: context.theme.onPrimaryContainer,
                                ),
                                key: const ValueKey('w1'),
                              )
                            : Text(
                                'Create an account and join us now!',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: context.theme.onPrimaryContainer,
                                ),
                                key: const ValueKey('w2'),
                              ),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _globalKey,
                    child: SlideUpTween(
                      begin: const Offset(0, 100),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Enter email';
                              }
                              if (!value.isValidEmail) {
                                return 'Please enter valid email address!';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null) {
                                return 'Enter password';
                              }
                              if (value.length < 6) {
                                return 'Password should contain atleast 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10.0),
                          if (authType.isLogin)
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () {
                                  if (_emailController.text.isNotEmpty) {
                                    context.read<AuthBloc>().add(
                                          ResetAuth(_emailController.text),
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Check your mailbox to reset password!')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please enter your email to reset password!')));
                                  }
                                },
                                child: const Text(
                                  'Forgot Password?',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return state is Authenticating
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : SlideUpTween(
                            begin: const Offset(0, 100),
                            child: OpacityTween(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (state is Authenticating) {
                                    return;
                                  }
                                  if (_globalKey.currentState?.validate() ??
                                      false) {
                                    context.read<AuthBloc>().add(
                                          SignIn(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                            authType: authType,
                                            onLoading: () =>
                                                context.showLoading(),
                                            onDone: () =>
                                                context.dismissDialog(),
                                          ),
                                        );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.theme.primary,
                                ),
                                child: Text(
                                  authType.name,
                                  style: TextStyle(
                                    color: context.theme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),
                const SizedBox(height: 16.0),
                const OpacityTween(
                  duration: Duration(milliseconds: 1200),
                  child: Text(
                    '--------- Or login with ---------',
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 16.0),
                SlideUpTween(
                  begin: const Offset(0, 100),
                  child: OpacityTween(
                    child: Semantics(
                      button: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          context.read<AuthBloc>().add(GoogleSignIn(
                                onLoading: () => context.showLoading(),
                                onDone: () => context.dismissDialog(),
                              ));
                        },
                        child: Container(
                          width: context.width / 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: context.theme.primaryContainer,
                          ),
                          padding: const EdgeInsets.all(7),
                          child: Row(
                            children: [
                              SizedBox(
                                width: context.width / 15,
                                child: Image.network(
                                  'https://www.totalvisionpoolfencing.com.au/wp-content/uploads/2019/10/google-g-2015-logo-png-transparent-480x481.png',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sign In with Google',
                                style: context.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SlideUpTween(
                  begin: const Offset(0, 100),
                  child: InkWell(
                    onTap: () => toggleAuthType(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Already have an account? Log in'),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> _signInWithEmailAndPassword() async {
  //   try {
  //     UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //       email: _emailController.text,
  //       password: _passwordController.text,
  //     );
  //     // User signed in successfully
  //   } catch (e) {
  //     // Handle error
  //   }
  // }

  // Future<void> _signInWithGoogle() async {
  //   try {
  //     // Sign in with Google
  //     final GoogleSignInAccount googleSignInAccount =
  //         await _googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       idToken: googleSignInAuthentication.idToken,
  //       accessToken: googleSignInAuthentication.accessToken,
  //     );
  //     // Sign in with Firebase
  //     UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);
  //     // User signed in successfully
  //   } catch (e) {
  //     // Handle error
  //   }
  // }
}
