import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tfg/Login/login_bloc.dart';
import 'package:tfg/Login/session_manager.dart';
import 'package:tfg/dashboard_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: MaterialApp(
        title: 'Login App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key ? key
  }): super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State < LoginScreen > {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final sessionManager = SessionManager();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _retrieveSession();
  }

  Future<void> _retrieveSession() async {
    final sessionData = await sessionManager.retrieveSession();
    if (sessionData != null) {
      // If there is session data, navigate to the DashboardScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of < LoginBloc > (context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Builder Check - Login'),
      ),
      body: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) => loginBloc.add(
                LoginButtonPressed(
                  email: _emailController.text,
                  password: _passwordController.text,
                ),
              ),
            ),
          },
          child: BlocListener < LoginBloc, LoginState > (
            listener: (context, state) {
              if (state is LoginFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(state.error),
                    duration: const Duration(seconds: 3),
                  ));
              } else if (state is LoginSuccess){
                sessionManager.saveSession(_emailController.text);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              }
            },
            child: BlocBuilder < LoginBloc, LoginState > (
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: < Widget > [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: state is!LoginLoading ?
                            () {
                          loginBloc.add(
                            LoginButtonPressed(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                          );
                        } :
                        null,
                        child: const Text('Login'),
                      ),
                      if (state is LoginLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}