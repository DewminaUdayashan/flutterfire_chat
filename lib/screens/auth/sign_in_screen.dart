import 'package:chatty_chat/shared/extentions/global_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';
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
      appBar: AppBar(
        backgroundColor: context.theme.primaryContainer,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: context.width,
            height: context.height / 4,
            color: context.theme.primaryContainer,
            child: Text(
              '${authType.name} to your account',
              style: context.textTheme.headlineLarge?.copyWith(
                color: context.theme.onPrimaryContainer,
                fontSize: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _globalKey,
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
          const SizedBox(height: 16.0),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return state is Authenticating
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        if (state is Authenticating) {
                          return;
                        }
                        if (_globalKey.currentState?.validate() ?? false) {
                          context.read<AuthBloc>().add(
                                SignIn(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  authType: authType,
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
                    );
            },
          ),
          const SizedBox(height: 16.0),
          const Text(
            '--------- Or login with ---------',
            style: TextStyle(color: Colors.black45),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(GoogleSignIn());
            },
            child: const Text('Sign In with Google'),
          ),
          const Spacer(),
          InkWell(
            onTap: () => toggleAuthType(),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Already have an account? Log in'),
            ),
          ),
          const SizedBox(height: 30.0),
        ],
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
