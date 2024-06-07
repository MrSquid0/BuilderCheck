import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/global_config.dart';
import 'package:http/http.dart' as http;

class EditProjectScreen extends StatefulWidget {
  final int idProject;
  final String projectName;
  final String projectAddress;
  final String managerEmail;
  final String startDate;
  final String endDate;

  EditProjectScreen({
    required this.projectName,
    required this.projectAddress,
    required this.idProject,
    required this.managerEmail,
    required this.startDate,
    required this.endDate,
  });

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  String? currentUserId, emailError;
  int? managerId;

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _managerEmailController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  final _formKey = GlobalKey<FormState>();

  String decodeUtf8(String source) {
    List<int> sourceBytes = source.codeUnits;
    try {
      return utf8.decode(sourceBytes);
    } catch (e) {
      print('Error decoding string: $e');
      return '';
    }
  }

  bool isValidDateFormat(String input) {
    try {
      DateFormat('dd/MM/yyyy').parseStrict(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateProject() async {
    DateTime startDate = DateFormat('dd/MM/yyyy').parseStrict(_startDateController.text);
    DateTime endDate = DateFormat('dd/MM/yyyy').parseStrict(_endDateController.text);
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    Map<String, dynamic> projectData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'idManager': managerId,
      'startDate': formattedStartDate,
      'endDate': formattedEndDate,
    };

    String jsonProjectData = jsonEncode(projectData);

    var url = Uri.parse('$api/project/edit/${widget.idProject}');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': basicAuth,
      },
      body: jsonProjectData,
    );

    if (response.statusCode == 200) {
      print('Project updated successfully');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Lottie.asset('tick_animation.json', fit: BoxFit.contain, repeat: false),
                ),
                const Text('You have updated the project successfully!'),
              ],
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  child: const Text('Continue'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  /*
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailScreen(
                          idProject: widget.idProject,
                          idOwner: int.parse(idOwner!),
                          idManager: managerId!,
                          projectName: _nameController.text,
                          projectAddress: _addressController.text,
                          startDate: _startDateController.text,
                          endDate: _endDateController.text,
                          currentUserRole: currentRole!,
                        ),
                      ),
                    );
                  },*/
                ),
              ),
            ],
          );
        },
      );
    } else {
      throw Exception('Failed to update project: ${response.body}');
    }
  }

  Future<int> getUserId(String email) async {
    var url = Uri.parse('$api/user/get-user-id/$email');
    var response = await http.get(
        url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load user ID');
    }
  }

  Future<bool> isManager(int id) async {
    var url = Uri.parse('$api/user/is-manager/$id');
    var response = await http.get(
        url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return response.body.toLowerCase() == 'true';
    } else {
      throw Exception('Failed to load manager status');
    }
  }

  Future<bool> emailExists(String email) async {
    var url = Uri.parse('$api/user/emailExists/$email');
    var response = await http.get(
        url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return response.body.toLowerCase() == 'true';
    } else {
      throw Exception('Failed to load email existence');
    }
  }

  Future<void> validateEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentUserEmail = prefs.getString('email');
    currentUserId = prefs.getString('user_id');

    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
        r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (email.isEmpty) {
      setState(() {
        emailError = 'Manager email is obligatory';
      });
    } else if (!regex.hasMatch(email)) {
      setState(() {
        emailError = 'Please, enter a valid e-mail';
      });
    } else if (email == currentUserEmail) {
      setState(() {
        emailError = 'You are not a manager!';
      });
    } else if (!await emailExists(email)) {
      setState(() {
        emailError = 'This email does not exist. \nThe manager needs to be registered!';
      });
    } else {
      managerId = await getUserId(email);
      if (!await isManager(managerId!)) {
        setState(() {
          emailError = 'This user is not a manager';
        });
      } else {
        setState(() {
          emailError = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: decodeUtf8(widget.projectName));
    _addressController = TextEditingController(text: decodeUtf8(widget.projectAddress));
    _managerEmailController = TextEditingController(text: widget.managerEmail);
    _startDateController = TextEditingController(text: widget.startDate);
    _endDateController = TextEditingController(text: widget.endDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      validateEmail(widget.managerEmail);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _managerEmailController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Project name is obligatory';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Project Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Project address is obligatory';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _managerEmailController,
                  decoration: InputDecoration(
                    labelText: 'Manager Email',
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                    errorText: emailError,
                  ),
                  onChanged: (value) {
                    validateEmail(value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Start date is obligatory';
                    } else if (!isValidDateFormat(value)) {
                      return 'Invalid date format. Use dd/MM/yyyy';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    prefixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'End date is obligatory';
                    } else if (!isValidDateFormat(value)) {
                      return 'Invalid date format. Use dd/MM/yyyy';
                    }

                    // Convertir las fechas a DateTime
                    DateTime startDate = DateFormat('dd/MM/yyyy').parse(_startDateController.text);
                    DateTime endDate = DateFormat('dd/MM/yyyy').parse(value);

                    // Verificar si la fecha de finalización es anterior a la fecha de inicio
                    if (endDate.isBefore(startDate)) {
                      return 'End date cannot be earlier than start date';
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _endDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    print('Save button pressed');
                    if (_formKey.currentState!.validate() && emailError == null) {
                      print('Form is valid');
                      await _updateProject();
                    } else {
                      print('Form is not valid');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
