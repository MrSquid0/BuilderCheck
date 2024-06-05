import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'login_screen.dart';
import 'package:lottie/lottie.dart';
import '../global_config.dart';

String phoneWithPrefix = '';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? emailError = 'Please enter your email';
  String? phoneError = 'Please enter your phone number';

  void checkEmail(String? value) async {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
        r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      emailError = 'Please enter your email';
    } else if (!regex.hasMatch(value)){
      emailError = 'Please, enter a valid e-mail';
    } else {
      var url = Uri.parse( '${api}/user/emailExists/$value');
      var response = await http.get(url, headers: <String, String>{'authorization': basicAuth});
      if (response.statusCode == 200) {
        if (response.body.toLowerCase() == 'true') {
          emailError = 'This email is already in use';
        } else {
          emailError = null;
        }
      } else {
        emailError = 'Failed to validate email';
      }
    }
    setState(() {});
  }

  void checkPhone(String? value) async {
    String pattern = r'^\+(?:[0-9] ?){6,14}[0-9]$';
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      phoneError = 'Please enter your phone number';
    } else if (!regex.hasMatch(value)){
      phoneError = 'Please, enter a valid phone number';
    } else {
      var url = Uri.parse('${api}/user/mobileExists/$value');
      var response = await http.get(url, headers: <String, String>{'authorization': basicAuth});
      if (response.statusCode == 200) {
        if (response.body.toLowerCase() == 'true') {
          phoneError = 'This phone number is already in use';
        } else {
          phoneError = null;
        }
      } else {
        phoneError = 'Failed to validate phone number';
      }
    }
    setState(() {});
  }

  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _roleController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: <String>['Owner', 'Manager'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Who are you?',
                  prefixIcon: Icon(Icons.lock_person),
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select who you are';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(
                  labelText: 'Surname',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your surname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                onChanged: checkEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => emailError,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  String pattern =
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
                  RegExp regex = RegExp(pattern);
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (!regex.hasMatch(value)){
                    return 'Password must be at least 8 characters long, \n'
                        'contain at least one uppercase letter, \n'
                        'one lowercase letter and one number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                height: 100,
                child: InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    phoneWithPrefix = number.phoneNumber.toString();
                    checkPhone(phoneWithPrefix);
                    print(phoneWithPrefix);
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: Colors.black),
                  initialValue: PhoneNumber(isoCode: 'ES'),
                  textFieldController: _mobileController,
                  formatInput: false,
                  spaceBetweenSelectorAndTextField: 0,
                  inputDecoration: const InputDecoration(
                    labelText: 'Manager phone',
                    prefixIcon: Icon(Icons.contact_phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => phoneError,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    print('Registering user...');

                    var url = Uri.parse( '${api}/user/register');
                    var response = await http.post(url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': basicAuth,
                        },
                        body: jsonEncode({
                      'id': '0',
                      'role': _selectedRole!.toLowerCase(),
                      'name': capitalize(_nameController.text),
                      'surname': capitalize(_surnameController.text),
                      'email': _emailController.text.toLowerCase(),
                      'password': _passwordController.text,
                      'mobile': phoneWithPrefix,
                    }));

                    if (response.statusCode == 200) {
                      print('User registered successfully');

                      // Show success dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Success!'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min, // This makes the column height wrap its content
                              children: <Widget>[
                                Flexible(
                                  child: Lottie.asset('tick_animation.json', fit: BoxFit.contain, repeat: false),
                                ),
                                const Text('You\'ve been registered successfully!'),
                              ],
                            ),
                            actions: <Widget>[
                              Center(
                                child: TextButton(
                                  child: const Text('Login'),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                          (Route<dynamic> route) => false,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      print('Failed to register user: ${response.body}');
                    }
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}