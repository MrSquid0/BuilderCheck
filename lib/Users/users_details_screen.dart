import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tfg/global_config.dart';
import 'dart:convert' show utf8;
import 'package:lottie/lottie.dart';
import 'package:tfg/Dashboards/main_dashboard.dart';
import '../Users/login_screen.dart';
import 'package:flutter/services.dart';

class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  String? emailError = null;
  String? phoneError = null;

  String? userId;
  String? userPassword;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _roleController = TextEditingController();

  Future<Map<String, dynamic>> getUserDetails(String? userId) async {
    var url = Uri.parse('${api}/user/$userId');
    var response = await http.get(
        url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      var bodyDecoded = utf8.decode(response.bodyBytes);
      return jsonDecode(bodyDecoded);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<bool> checkPassword(String enteredPassword) async {
    var url = Uri.parse('${api}/user/check-password');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': basicAuth,
      },
      body: jsonEncode(<String, String>{
        'userId': userId ?? '',
        'password': enteredPassword,
      }),
    );

    if (response.statusCode == 200) {
      return response.body.toLowerCase() == 'true';
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }


  void _loadUserDetails() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';
    try {
      getUserDetails(userId).then((userDetails) async{
        _roleController.text = capitalize(userDetails['role']);
        _nameController.text = userDetails['name'];
        _surnameController.text = userDetails['surname'];
        _emailController.text = userDetails['email'];
        _mobileController.text = userDetails['mobile'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('There was an internal error: $e'),
          duration: Duration(seconds: 3),
        ));
    }
  }

  Future<void> updateUserDetails(String userId, String name, String surname, String email, String mobile) async {
    var url = Uri.parse('${api}/user/update');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': basicAuth,
      },
      body: jsonEncode({
        'id': userId,
        'name': name,
        'surname': surname,
        'email': email,
        'mobile': mobile,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user details');
    } else{
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
                  child: Lottie.asset('images/tick_animation.json', fit: BoxFit.contain, repeat: false),
                ),
                const Text('Your changes are done!'),
              ],
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  child: const Text('Continue'),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainDashboardScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> updateUserPassword(String userId, String currentPassword, String newPassword) async {
    var url = Uri.parse('${api}/user/update-password');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': basicAuth,
      },
      body: jsonEncode({
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user password');
    }
  }

  Future<void> deleteUser(String userId, String password) async {
    var url = Uri.parse('${api}/user/delete-user');
    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': basicAuth,
      },
      body: jsonEncode({
        'userId': userId,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  bool validateNewPassword(String newPassword, String confirmPassword) {
    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(newPassword) && newPassword == confirmPassword;
  }

  InputDecoration textFieldDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(),
    );
  }

  Future<void> checkEmail(String? value) async {
    var url1 = Uri.parse('${api}/user/$userId');
    var response1 = await http.get(url1, headers: <String, String>{'authorization': basicAuth});

    String emailUser = '';

    if (response1.statusCode == 200) {
      var bodyDecoded = utf8.decode(response1.bodyBytes);
      var userDetails = jsonDecode(bodyDecoded);
      emailUser = userDetails['email'];
    } else {
      throw Exception('Failed to load user details');
    }

    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
        r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      emailError = 'Please enter your email';
    } else if (!regex.hasMatch(value)){
      emailError = 'Please, enter a valid e-mail';
    } else {
      var url2 = Uri.parse( '${api}/user/emailExists/$value');
      var response2 = await http.get(url2, headers: <String, String>{'authorization': basicAuth});
      print(emailUser);
      if (response2.statusCode == 200) {
        if (response2.body.toLowerCase() == 'true' && value != emailUser) {
          emailError = 'This email is already in use by another user.';
        } else {
          emailError = null;
        }
      } else {
        emailError = 'Failed to validate email';
      }
    }
    setState(() {});
  }

  Future<void> checkPhone(String? value) async {
    var url1 = Uri.parse('${api}/user/$userId');
    var response1 = await http.get(url1, headers: <String, String>{'authorization': basicAuth});

    String mobileUser = '';

    if (response1.statusCode == 200) {
      var bodyDecoded = utf8.decode(response1.bodyBytes);
      var userDetails = jsonDecode(bodyDecoded);
      mobileUser = userDetails['mobile'];
    } else {
      throw Exception('Failed to load user details');
    }

    String pattern = r'^\+(?:[0-9] ?){6,14}[0-9]$';
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      phoneError = 'Please enter your phone number';
    } else if (!regex.hasMatch(value)){
      phoneError = 'Please, enter a valid phone number';
    } else {
      var url2 = Uri.parse('${api}/user/mobileExists/$value');
      var response2 = await http.get(url2, headers: <String, String>{'authorization': basicAuth});
      if (response2.statusCode == 200) {
        if (response2.body.toLowerCase() == 'true' && value != mobileUser) {
          phoneError = 'This phone number is already in use by another user.';
        } else {
          phoneError = null;
        }
      } else {
        phoneError = 'Failed to validate phone number';
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _roleController,
              decoration: textFieldDecoration('You are', Icons.lock_person),
              enabled: false, // This makes the field read-only
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: textFieldDecoration('Name', Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _surnameController,
              decoration: textFieldDecoration('Surname', Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your surname';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: textFieldDecoration('Email', Icons.email),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else {
                  return emailError;
                }
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _mobileController,
              decoration: textFieldDecoration('Mobile', Icons.contact_phone),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your mobile number';
                } else {
                  return phoneError;
                }
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_nameController.text.isEmpty ||
                      _surnameController.text.isEmpty ||
                      _emailController.text.isEmpty ||
                      _mobileController.text.isEmpty) {
                    showErrorDialog(context, 'All fields must be filled out.');
                  } else {
                    // Check email and phone
                    await checkEmail(_emailController.text);
                    await checkPhone(_mobileController.text);
                    if (emailError != null) {
                      showErrorDialog(context, emailError!);
                    } else if (phoneError != null) {
                      showErrorDialog(context, phoneError!);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final _passwordFormKey = GlobalKey<FormState>();
                          final _passwordController = TextEditingController();

                          return AlertDialog(
                            title: Text('Confirm Save'),
                            content: Form(
                              key: _passwordFormKey,
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.password),
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Confirm'),
                                onPressed: () async{
                                  if (_passwordFormKey.currentState?.validate() ?? false) {
                                    if (await checkPassword(_passwordController.text)){
                                      try {
                                        updateUserDetails(
                                          userId ?? '',
                                          _nameController.text,
                                          _surnameController.text,
                                          _emailController.text,
                                          _mobileController.text,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                            content: Text('There was an internal error: $e'),
                                            duration: Duration(seconds: 3),
                                          ));
                                      }
                                    } else{
                                      showErrorDialog(context, 'Incorrect password. Please try again.');
                                    }
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Text('Change Password'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final _changePasswordFormKey = GlobalKey<FormState>();
                    final _currentPasswordController = TextEditingController();
                    final _newPasswordController = TextEditingController();
                    final _confirmNewPasswordController = TextEditingController();

                    return AlertDialog(
                      title: Text('Change Password'),
                      content: Form(
                        key: _changePasswordFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              controller: _currentPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Current Password',
                                prefixIcon: Icon(Icons.password),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your current \npassword';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _newPasswordController,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                prefixIcon: Icon(Icons.password),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your new password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _confirmNewPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm New Password',
                                prefixIcon: Icon(Icons.password),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your new \npassword';
                                } else if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Save'),
                          onPressed: () async {
                            if (_changePasswordFormKey.currentState?.validate() ?? false) {
                              if (await checkPassword(_currentPasswordController.text)) {
                                if (validateNewPassword(_newPasswordController.text, _confirmNewPasswordController.text)) {
                                  try {
                                    await updateUserPassword(
                                      userId ?? '',
                                      _currentPasswordController.text,
                                      _newPasswordController.text,
                                    );
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
                                                child: Lottie.asset('images/tick_animation.json', fit: BoxFit.contain, repeat: false),
                                              ),
                                              const Text('Your password has been changed successfully!'),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            Center(
                                              child: TextButton(
                                                child: const Text('Continue'),
                                                onPressed: () {
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => MainDashboardScreen()),
                                                        (Route<dynamic> route) => false,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    showErrorDialog(context, 'There was an internal error: $e');
                                  }
                                } else {
                                  showErrorDialog(context, 'New password is invalid. It must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter and one number, and match the confirmation password.');
                                }
                              } else {
                                showErrorDialog(context, 'Incorrect current password. Please try again.');
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Text('Delete account'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final _deleteAccountFormKey = GlobalKey<FormState>();
                    final _passwordController = TextEditingController();

                    return AlertDialog(
                      title: Text('Confirm account deletion'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Are you sure you want to delete your account? This action can not be undone.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 15),
                          Form(
                            key: _deleteAccountFormKey,
                            child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.password),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Confirm'),
                          onPressed: () async {
                            if (_deleteAccountFormKey.currentState?.validate() ?? false) {
                              if (await checkPassword(_passwordController.text)) {
                                try {
                                  await deleteUser(userId ?? '', _passwordController.text);
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
                                              child: Lottie.asset('images/tick_animation.json', fit: BoxFit.contain, repeat: false),
                                            ),
                                            const Text('Your account has been deleted successfully!'),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          Center(
                                            child: TextButton(
                                              child: const Text('Exit'),
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
                                } catch (e) {
                                  showErrorDialog(context, 'There was an internal error: $e');
                                }
                              } else {
                                showErrorDialog(context, 'Incorrect password. Please try again.');
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}