import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Dashboards/main_dashboard.dart';
import 'Users/login_bloc.dart';
import 'Users/login_screen.dart';

class MyApp extends StatelessWidget {
  final bool isTokenValid;

  const MyApp({super.key, required this.isTokenValid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: MaterialApp(
        title: 'Builder Check',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: isTokenValid ? MainDashboardScreen() : const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool tokenIsValid = await isTokenValid();
  runApp(MyApp(isTokenValid: tokenIsValid));
}