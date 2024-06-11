import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/Dashboards/project_detail.dart';
import '../Users/login_screen.dart';
import '../Users/users_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:tfg/global_config.dart';

class MainDashboardScreen extends StatefulWidget {
  @override
  _MainDashboardScreenState createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  String telephone = '';
  String? currentUserId, emailError = 'Manager email is obligatory';
  int? managerId;

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

  Future<String> _getProjectStatus(int idProject) async {
    var url = Uri.parse('$api/project/$idProject');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      if (body['done']) {
        return 'FINISHED';
      } else if (body['budget_status'] != 'confirmed') {
        return 'BUDGET';
      } else {
        return 'IN PROGRESS';
      }
    } else {
      throw Exception('Failed to load project status');
    }
  }

  Future<void> validateEmailAndUpdateForm(String? email) async {
    String? error = await validateEmail(email);
    setState(() {
      emailError = error;
    });
  }

  Future<String?> validateEmail(String? email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentUserEmail = prefs.getString('email');
    currentUserId = prefs.getString('user_id');

    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
        r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (email == null || email.isEmpty) {
      return 'Manager email is obligatory';
    } else if (!regex.hasMatch(email)){
      return 'Please, enter a valid e-mail';
    } else if (email == currentUserEmail) {
      return 'You are not a manager!';
    } else if (!await emailExists(email)){
      return 'This email does not exist. \nThe manager needs to be registered!';
    } else {
      managerId = await getUserId(email);
      if (!await isManager(managerId!)){
        return 'This user is not a manager';
      }
    }
    return null;
  }

  bool isValidDateFormat(String input) {
    try {
      DateFormat('dd/MM/yyyy').parseStrict(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _managerEmailController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  List<Map<String, String>> projects = [];

  void _createProject() async {
    if (_formKey.currentState!.validate()) {
      // Convert dates to yyyy-MM-dd format
      DateTime startDate = DateFormat('dd/MM/yyyy').parseStrict(_startDateController.text);
      DateTime endDate = DateFormat('dd/MM/yyyy').parseStrict(_endDateController.text);
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      // Create a map with the form data
      Map<String, dynamic> projectData = {
        'idProject': '0',
        'name': _nameController.text,
        'address': _addressController.text,
        'idOwner': currentUserId,
        'idManager': managerId,
        'startDate': formattedStartDate,
        'endDate': formattedEndDate,
        'active': 'false', //Only true once the budget is approved by the owner
        'done': 'false', //Only true once the owner approves the project as finished
      };

      // Convert the map to JSON
      String jsonProjectData = jsonEncode(projectData);

      // Send a POST request to the API
      var url = Uri.parse('$api/project/create');
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': basicAuth,
        },
        body: jsonProjectData,
      );

      if (response.statusCode == 200) {
        print('Project created successfully');
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
                  const Text('You have created the project succesfully!'),
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
      } else {
        print('Failed to create project: ${response.body}');
        // Add additional code here to handle failed project creation
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getProjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    String? currentUserId = prefs.getString('user_id');

    var url;
    if (role == 'owner') {
      url = Uri.parse('$api/project/owner/$currentUserId');
    } else if (role == 'manager') {
      url = Uri.parse('$api/project/manager/$currentUserId');
    } else {
      throw Exception('Invalid user role');
    }

    var response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      return responseBody.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Image.asset(
              'logo-appbar.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Builder Check',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
        //centerTitle: true, // To center the title
        actions: <Widget>[
          FutureBuilder<String>(
            future: SharedPreferences.getInstance().then((prefs) => prefs.getString('role')!.toUpperCase()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserDetailsScreen()),
                        );
                      },
                    ),
                    Text(
                      snapshot.data!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getProjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> projects = snapshot.data!;
            if (projects.isEmpty) {
              return FutureBuilder<String>(
                future: SharedPreferences.getInstance().then((prefs) => prefs.getString('role')!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink(); // Return an empty widget while waiting for the role
                  } else {
                    String message;
                    if (snapshot.data == 'owner') {
                      message = 'You have not created any project yet. Add one pushing the button below!';
                    } else {
                      message = 'You are not assigned to any project yet! '
                          'You need to be assigned by an owner to start a construction project.';
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24, // Increase font size
                            fontWeight: FontWeight.bold, // Make text bold
                          ),
                        ),
                        const SizedBox(height: 30),
                        Image.asset('builder-notFound.png'),
                      ],
                    );
                  }
                },
              );
            } else {
              return ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> project = projects[index];
                  DateTime startDate = DateTime.parse(project['startDate']);
                  DateTime endDate = DateTime.parse(project['endDate']);
                  String formattedStartDate = DateFormat('dd/MM/yyyy').format(startDate);
                  String formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      tileColor: Colors.blueGrey[50],
                      title: Text(
                        project['name'],
                        style: TextStyle(
                          color: Colors.blueGrey[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        'Start date: $formattedStartDate\nEnd date: $formattedEndDate',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(
                        Icons.business,
                        color: Colors.blueGrey[900],
                      ),
                      trailing: Container(
                        width: 100, // Adjust this value as needed
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blueGrey[900],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: -10,
                              child: FutureBuilder<String>(
                                future: _getProjectStatus(project['idProject']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    String status = snapshot.data!;
                                    Color statusColor;
                                    if (status == 'FINISHED') {
                                      statusColor = Colors.green[800]!;
                                    } else if (status == 'IN PROGRESS') {
                                      statusColor = Colors.blue;
                                    } else {
                                      statusColor = Colors.orange;
                                    }

                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0), // This makes the Container rounded
                                      child: Container(
                                        color: statusColor,
                                        padding: EdgeInsets.all(8.0),
                                        margin: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? currentUserRole = prefs.getString('role');
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailScreen(
                              idProject: project['idProject'],
                              idOwner: project['idOwner'],
                              idManager: project['idManager'],
                              projectName: project['name'],
                              projectAddress: project['address'],
                              startDate: formattedStartDate,
                              endDate: formattedEndDate,
                              currentUserRole: currentUserRole!,
                              done: false,
                            ),
                          ),
                        );
                        if (result == 'update') {
                          setState(() {
                            _getProjects();
                          });
                        }
                      },
                    ),
                  );
                },
              );
            }
          }
        },
      ),
      floatingActionButton: FutureBuilder<String>(
        future: SharedPreferences.getInstance().then((prefs) => prefs.getString('role')!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink(); // Return an empty widget while waiting for the role
          } else if (snapshot.data == 'manager') {
            return const SizedBox.shrink(); // Don't show the button if the user is a manager
          } else {
            return FloatingActionButton(
              child: const Icon(Icons.add),
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
                      child: SingleChildScrollView( // Add this
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Text(
                                'Property Details',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
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
                                  } else if (value.length < 5){
                                    return 'Project name must be at \nleast 5 characters long';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressController,
                                maxLines: 3,
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
                                    return 'Project address must be \nat least 15 characters long';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Manager Details',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _managerEmailController,
                                decoration: const InputDecoration(
                                  labelText: 'Manager email',
                                  prefixIcon: Icon(Icons.alternate_email),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value){
                                  return emailError;
                                }
                                ),
                              const SizedBox(height: 20),
                              const Text(
                                'Duration',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _startDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Start date',
                                  prefixIcon: Icon(Icons.date_range),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.datetime,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a start date';
                                  } else if (!isValidDateFormat(value)) {
                                    return 'Invalid date format. Use dd/MM/yyyy';
                                  } else {
                                    DateTime inputDate = DateFormat('dd/MM/yyyy').parseStrict(value);
                                    if (inputDate.isBefore(DateTime.now())) {
                                      return 'Start date cannot be in the past';
                                    }
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
                                  labelText: 'End date',
                                  prefixIcon: Icon(Icons.date_range),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.datetime,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an end date';
                                  } else if (!isValidDateFormat(value)) {
                                    return 'Invalid date format. Use dd/MM/yyyy';
                                  } else {
                                    DateTime inputDate = DateFormat('dd/MM/yyyy').parseStrict(value);
                                    DateTime startDate = DateFormat('dd/MM/yyyy').parseStrict(_startDateController.text);
                                    if (inputDate.isBefore(startDate)) {
                                      return 'End date cannot be before \nthe start date';
                                    }
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _nameController.clear();
                          _addressController.clear();
                          _managerEmailController.clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await validateEmailAndUpdateForm(_managerEmailController.text);
                          if (_formKey.currentState!.validate()) {
                            _createProject();
                            _nameController.clear();
                            _addressController.clear();
                            _managerEmailController.clear();
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
    );
  }
},
),
);
}
}