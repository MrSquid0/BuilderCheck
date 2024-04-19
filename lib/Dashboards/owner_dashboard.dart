import 'package:flutter/material.dart';
import '../Login/login_screen.dart';
import 'project_detail_screen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:libphonenumber/libphonenumber.dart';

class OwnerDashboardScreen extends StatefulWidget {
  @override
  _OwnerDashboardScreenState createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  String telephone = '';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerEmailController = TextEditingController();
  final _managerPhoneController = TextEditingController();
  List<Map<String, String>> projects = [];

  void _createProject() {
    if (_formKey.currentState!.validate()) {
      final newProject = {
        'name': _nameController.text,
        'address': _addressController.text,
        'managerName': _managerNameController.text,
        'managerEmail': _managerEmailController.text,
        'managerPhone': _managerPhoneController.text,
      };

      setState(() {
        projects.add(newProject);
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Builder Check'),
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                projects[index]['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                projects[index]['address']!,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailsScreen(
                      projectName: projects[index]['name']!,
                      projectAddress: projects[index]['address']!,
                      managerName: projects[index]['managerName']!,
                      managerEmail: projects[index]['managerEmail']!,
                      managerPhone: projects[index]['managerPhone']!,
                    ),
                  ),
                );
                // Navigate to project details screen
              },
            );
          },
          separatorBuilder: (context, index) => Divider(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Center(
                child: SingleChildScrollView(
                  child: AlertDialog(
                    title: const Text('Create Project'),
                    content: Container(
                      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                      height: MediaQuery.of(context).size.height * 0.5, // 50% of screen height
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Property Details',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Project Name',
                                        prefixIcon: Icon(Icons.business),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Project name is obligatory';
                                        } else if (value.length < 5){
                                          return 'Project name must be at least 5 characters long';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Flexible(
                                    child: TextFormField(
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
                                        else if (value.length < 15){
                                          return 'Project address must be at least 15 characters long';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Manager Details',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: TextFormField(
                                      controller: _managerNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Manager name',
                                        prefixIcon: Icon(Icons.man_4),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Manager name is obligatory';
                                        } else if (value.length < 5){
                                          return 'Manager name must be at least 5 characters long';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Flexible(
                                    child: TextFormField(
                                      controller: _managerEmailController,
                                      decoration: const InputDecoration(
                                        labelText: 'Manager email',
                                        prefixIcon: Icon(Icons.alternate_email),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        String pattern =
                                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
                                            r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                        RegExp regex = RegExp(pattern);
                                        if (value == null || value.isEmpty) {
                                          return 'Manager email is obligatory';
                                        } else if (!regex.hasMatch(value)){
                                          return 'Please, enter a valid e-mail';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Flexible(
                                    child: InternationalPhoneNumberInput(
                                      onInputChanged: (PhoneNumber number) {
                                        telephone = number.phoneNumber.toString();
                                        print(telephone); // Aquí se imprime el número de teléfono con el prefijo
                                      },
                                      onInputValidated: (bool value) {
                                        print(value); // Aquí se imprime si el número de teléfono es válido o no
                                      },
                                      selectorConfig: const SelectorConfig(
                                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                      ),
                                      ignoreBlank: false,
                                      autoValidateMode: AutovalidateMode.disabled,
                                      selectorTextStyle: TextStyle(color: Colors.black),
                                      initialValue: PhoneNumber(isoCode: 'ES'),
                                      textFieldController: _managerPhoneController,
                                      formatInput: false,
                                      spaceBetweenSelectorAndTextField: 0,
                                      inputDecoration: const InputDecoration(
                                        labelText: 'Manager phone',
                                        prefixIcon: Icon(Icons.contact_phone),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        String pattern = r'^\+(?:[0-9] ?){6,14}[0-9]$';
                                        RegExp regex = RegExp(pattern);
                                        if (value == null || value.isEmpty) {
                                          return 'Manager phone is obligatory';
                                        } else if (!regex.hasMatch(telephone)){
                                          return 'Please, enter a valid phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _nameController.clear();
                          _addressController.clear();
                          _managerNameController.clear();
                          _managerEmailController.clear();
                          _managerPhoneController.clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _createProject();
                            _nameController.clear();
                            _addressController.clear();
                            _managerNameController.clear();
                            _managerEmailController.clear();
                            _managerPhoneController.clear();
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
