import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfg/Dashboards/pdf_view_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:tfg/global_config.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:tfg/Tasks/edit_task.dart';
import 'package:tfg/Tasks/task_form.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_platform/universal_platform.dart';

import '../Tasks/edit_task_status.dart';
import 'edit_project.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int idProject;
  final int idOwner;
  final int idManager;
  final String projectName;
  final String projectAddress;
  final String startDate;
  final String endDate;
  final String currentUserRole;

  ProjectDetailScreen({
    required this.idProject,
    required this.idOwner,
    required this.idManager,
    required this.projectName,
    required this.projectAddress,
    required this.startDate,
    required this.endDate,
    required this.currentUserRole,
  });

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {

  String decodeUtf8IfNeeded(String source) {
    try {
      // Try to decode the string
      List<int> sourceBytes = source.codeUnits;
      String decodedString = utf8.decode(sourceBytes);

      if (decodedString.contains('�')) {
        // If the string contains no valid strings, it was not in UTF-8
        return source;
      }
      return decodedString;
    } catch (e) {
      // If there is an error, we assume the string in correct format
      print('Error decoding UTF-8 string: $e');
      print('Source string: $source');
      return source;
    }
  }

  Future<bool> _isImageEmpty(int idTask) async {
    var url = Uri.parse('$api/task/$idTask/isImageEmpty');
    var response = await http.get(url, headers: {'authorization': basicAuth});
    return response.body.toLowerCase() == 'true';
  }

  Future<Uint8List> _getImageBytes(int idTask) async {
    var url = Uri.parse('$api/task/$idTask/getImageFile');
    var response = await http.get(url, headers: {'authorization': basicAuth});

    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> _getUserDetails(int idUser) async {
    var url = Uri.parse('$api/user/$idUser');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      return body;
    } else {
      throw Exception('Failed to load manager details');
    }
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getTasks() async {
    var url = Uri.parse('$api/task/project/${widget.idProject}');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Map<String, dynamic>> _getProjectStatus(int idProject) async {
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
      return body;
    } else {
      throw Exception('Failed to load project status');
    }
  }

  Future<String> getUserEmail(int idUser) async {
    var url = Uri.parse('$api/user/$idUser/email');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load user email');
    }
  }

  Future<String> _getBudgetStatus(int idProject) async {
    var url = Uri.parse('$api/project/$idProject/budgetStatus');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      return response.body; // Asumiendo que la respuesta es una cadena simple
    } else {
      throw Exception('Failed to load budget status');
    }
  }

  Future<void> _updateBudgetStatus(int idProject, String newStatus) async {
    var url = Uri.parse('$api/project/$idProject/updateBudgetStatus');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
      body: newStatus, // Solo la cadena newStatus
    );

    if (response.statusCode == 200) {
      print('Budget status updated successfully');
    } else {
      throw Exception('Failed to update budget status');
    }
  }


  Future<bool> _isBudgetPdfEmpty(int idProject) async {
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
      return body['budget_pdf'] == null || body['budget_pdf'] == '';
    } else {
      throw Exception('Failed to load budget PDF status');
    }
  }

  Future<html.File?> _pickFile() async {
    final completer = Completer<html.File>();
    final input = html.FileUploadInputElement();
    input.accept = '.pdf';
    input.click();

    // On change call the `complete` function with the selected file
    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        if (file.name.toLowerCase().endsWith('.pdf')) {
          completer.complete(file);
        } else {
          completer.completeError(Exception('Only PDF files are allowed'));
        }
      } else {
        completer.complete(null);
      }
    });

    // Need to append on body else will not work on iOS Safari
    html.document.body!.append(input);

    // Clean up
    completer.future.then((_) => input.remove());

    return completer.future;
  }

  Future<String> _getFilePath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      return result.files.single.path!;
    } else {
      throw Exception('User cancelled the picker');
    }
  }

  Future<String> _convertPdfFileToBase64(dynamic file) async {
    if (UniversalPlatform.isWeb) {
      // Use FileReader for web
      final reader = html.FileReader();
      reader.readAsDataUrl(file as html.File);
      await reader.onLoad.first;
      return reader.result as String;
    } else {
      // Use File for mobile
      List<int> fileBytes = await (file as File).readAsBytesSync();
      return base64Encode(fileBytes);
    }
  }

  Future<void> _uploadBudgetPdf(int idProject) async {
    try {
      dynamic file; // Declare file as dynamic
      if (UniversalPlatform.isWeb) {
        // Use universal_html for web
        try {
          file = await _pickFile();
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Error: $e'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
      } else {
        // Use file_picker for mobile
        String filePath = await _getFilePath();
        file = File(filePath);
      }

      if (file != null) {
        var url = Uri.parse('$api/project/$idProject/uploadBudgetPdf');

        // Create a FormData instance
        var formData = html.FormData();
        formData.appendBlob('file', file, file.name);

        // Create an HttpRequest and open it
        var request = html.HttpRequest();
        request.open('POST', url.toString());

        // Set the request headers
        request.setRequestHeader('authorization', basicAuth);

        // Send the request with the form data
        request.send(formData);

        // Listen for the load end event to determine if the request was successful
        request.onLoadEnd.listen((event) async {
          if (request.status == 200) {
            await _updateBudgetStatus(idProject, 'sent');
            print('Budget PDF uploaded success fully');
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
                        child: Lottie.asset('tick_animation.json',
                            fit: BoxFit.contain, repeat: false),
                      ),
                      const Text(
                          'You have uploaded the budget PDF successfully!'),
                    ],
                  ),
                  actions: <Widget>[
                    Center(
                      child: TextButton(
                        child: const Text('Continue'),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            print('Failed to upload budget PDF');
          }
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Error: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'update');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.projectName),
          actions: <Widget>[
            if (widget.currentUserRole == 'owner')
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  var url = Uri.parse('$api/project/${widget.idProject}');
                  var response = await http.get(
                    url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      'authorization': basicAuth,
                    },
                  );
                  if (response.statusCode == 200) {
                    String managerEmail = await getUserEmail(widget.idManager);
                    // Inicializa los controladores con los valores actuales
                    // Navega a la pantalla de edición
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProjectScreen(
                            idProject: widget.idProject,
                            projectName: widget.projectName,
                            projectAddress: widget.projectAddress,
                            managerEmail: managerEmail,
                            startDate: widget.startDate,
                            endDate: widget.endDate,
                      ),
                    ),
                  );
                  } else {
                  throw Exception('Failed to load project details');
                  }
                },
              ),
            if (widget.currentUserRole == 'owner')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool? confirmDelete = await showDeleteConfirmationDialog(context);
                if (confirmDelete == true) {
                  var url = Uri.parse('$api/project/delete/${widget.idProject}');
                  var response = await http.delete(
                    url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      'authorization': basicAuth,
                    },
                  );
                  if (response.statusCode == 200) {
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
                              const Text('You have deleted the project successfully!'),
                            ],
                          ),
                          actions: <Widget>[
                            Center(
                              child: TextButton(
                                child: const Text('Continue'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context, 'update');
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    throw Exception('Failed to delete project');
                  }
                }
              },
            ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskForm(
                        idProject: widget.idProject,
                        onTaskCreated: () {
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getTasks(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>> tasks = snapshot.data!;
              Map<String, dynamic>? taskChosen;
              return ListView(
                children: <Widget>[
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FutureBuilder<Map<String, dynamic>>(
                            future: _getProjectStatus(widget.idProject),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                Map<String, dynamic> projectStatus =
                                snapshot.data!;
                                bool done = projectStatus['done'] ?? false;
                                String budgetStatus = projectStatus['budget_status'];
                                String statusText;
                                Color statusColor;

                                if (done) {
                                  statusText = 'FINISHED';
                                  statusColor = Colors.green[800]!;
                                } else if (budgetStatus != 'confirmed') {
                                  statusText = 'PENDING BUDGET APPROVAL';
                                  statusColor = Colors.orange;
                                } else {
                                  statusText = 'IN PROGRESS';
                                  statusColor = Colors.blue;
                                }

                                return Container(
                                  color: statusColor,
                                  padding: EdgeInsets.all(8.0),
                                  margin: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      statusText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const Text('No data');
                              }
                            },
                          ),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _getUserDetails(widget.idManager),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text(
                                    'Failed to load manager details');
                              } else if (snapshot.hasData) {
                                Map<String, dynamic> manager = snapshot.data!;
                                return Row(
                                  children: <Widget>[
                                    const Icon(Icons.construction_outlined),
                                    const SizedBox(width: 8),
                                    Text(
                                        '${decodeUtf8IfNeeded(manager['name'])} ${decodeUtf8IfNeeded(manager['surname'])}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                );
                              } else {
                                return const Text('No data');
                              }
                            },
                          ),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _getUserDetails(widget.idOwner),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text(
                                    'Failed to load owner details');
                              } else if (snapshot.hasData) {
                                Map<String, dynamic> owner = snapshot.data!;
                                return Row(
                                  children: <Widget>[
                                    const Icon(Icons.manage_accounts_outlined),
                                    const SizedBox(width: 8),
                                    Text(
                                        '${decodeUtf8IfNeeded(owner['name'])} ${decodeUtf8IfNeeded(owner['surname'])}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                );
                              } else {
                                return const Text('No data');
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.location_on_outlined),
                              const SizedBox(width: 8),
                              Text(
                                decodeUtf8IfNeeded(widget.projectAddress),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              const Icon(Icons.calendar_today_outlined),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.startDate} - ${widget.endDate}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  if (tasks.isEmpty)
                    Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            widget.currentUserRole == 'owner'
                                ? 'Any task added to the project yet! Press the + button to add a new one!'
                                : 'Tasks not found! The owner of this project did not add any task yet!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Image.asset('builder-notFound.png'),
                        ],
                      ),
                    )
                  else
                    const Text(
                      'Tasks',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (tasks
                      .isNotEmpty) // Solo muestra el siguiente widget si hay tareas
                    FutureBuilder<String>(
                      future: _getBudgetStatus(widget.idProject),
                      builder: (context, budgetSnapshot) {
                        if (budgetSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (budgetSnapshot.hasError) {
                          return Text('Error: ${budgetSnapshot.error}');
                        } else if (budgetSnapshot.hasData) {
                          String budgetStatus = budgetSnapshot.data!;

                          if (budgetStatus == 'disabled') {
                            if (widget.currentUserRole == 'owner') {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                  Colors.green, // color del texto
                                ),
                                onPressed: () async {
                                  await _updateBudgetStatus(
                                      widget.idProject, 'requested');
                                  setState(() {});
                                },
                                child:
                                const Text('Request budget to the manager'),
                              );
                            } else if (widget.currentUserRole == 'manager') {
                              return Center(
                                child: Container(
                                  color: Colors.yellow,
                                  padding: EdgeInsets.all(8.0),
                                  child: const Text(
                                    'The owner did not request the budget for the project yet!',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          } else if (budgetStatus == 'requested') {
                            if (widget.currentUserRole == 'owner') {
                              return Center(
                                child: Container(
                                  color: Colors.yellow,
                                  padding: EdgeInsets.all(8.0),
                                  child: const Text(
                                    'Waiting for the budget from the manager',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            } else if (widget.currentUserRole == 'manager') {
                              return FutureBuilder<bool>(
                                future: _isBudgetPdfEmpty(widget.idProject),
                                builder: (context, pdfSnapshot) {
                                  if (pdfSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (pdfSnapshot.hasError) {
                                    return Text('Error: ${pdfSnapshot.error}');
                                  } else if (pdfSnapshot.hasData) {
                                    bool budgetPdfEmpty =
                                        pdfSnapshot.data ?? true;
                                    if (budgetPdfEmpty) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                          Colors.green, // color del texto
                                        ),
                                        onPressed: () =>
                                            _uploadBudgetPdf(widget.idProject),
                                        child: const Text('Upload Budget PDF'),
                                      );
                                    } else {
                                      return Center(
                                        child: Container(
                                          color: Colors.yellow,
                                          padding: EdgeInsets.all(8.0),
                                          child: const Text(
                                            'Budget PDF sent to the owner!',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    return const Text('No data');
                                  }
                                },
                              );
                            }
                          } else if (budgetStatus == 'sent') {
                            if (widget.currentUserRole == 'owner') {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () async {
                                  Map<String, dynamic> projectStatus = await _getProjectStatus(widget.idProject);
                                  String budgetPdfUrl = projectStatus['budget_pdf'];
                                  if (budgetPdfUrl.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewScreen(
                                          projectId: widget.idProject,
                                            idOwner: widget.idOwner,
                                            idManager: widget.idManager,
                                            projectName: widget.projectName,
                                            projectAddress: widget.projectAddress,
                                            startDate: widget.startDate,
                                            endDate: widget.endDate,
                                            currentUserRole: widget.currentUserRole,
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('No budget PDF URL available');
                                  }
                                },
                                child: const Text('View budget PDF'),
                              );
                            } else if (widget.currentUserRole == 'manager') {
                              return Center(
                                child: Container(
                                  color: Colors.yellow,
                                  padding: EdgeInsets.all(8.0),
                                  child: const Text(
                                    'Waiting for the approval of the budget',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          } else if (budgetStatus == 'confirmed') {
                            return Center(
                              child: Container(
                                color: Colors.green,
                                padding: EdgeInsets.all(8.0),
                                child: const Text(
                                  'Budget approved',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        } else {
                          return const Text('No data');
                        }
                      },
                    ),
                  const SizedBox(width: 5),
                  for (var task in tasks)
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(decodeUtf8IfNeeded(task['name']),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 5),
                            // Añade un poco de espacio a la derecha del nombre
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.01, vertical: 0.01),
                              decoration: BoxDecoration(
                                color: task['status'] == 'disabled'
                                    ? Colors.grey[800]
                                    : task['status'] == 'to-do'
                                    ? Colors.orange
                                    : task['status'] == 'blocked'
                                    ? Colors.red
                                    : task['status'] == 'in progress'
                                    ? Colors.blue
                                    : task['status'] == 'done'
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task['status'].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            if (widget.currentUserRole == 'manager' && task['status'] != 'disabled')
                              IconButton(
                                icon: const Icon(Icons.domain_verification_outlined),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTaskStatusScreen(
                                        idTask: task['idTask'],
                                        statusTask: task['status'],
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == 'update') {
                                      setState(() {});
                                    }
                                  });
                                },
                              ),
                          ],
                        ),
                        subtitle: Text('Priority: ${task['priority']}',
                            style: const TextStyle(fontSize: 16)),
                        trailing: widget.currentUserRole == 'owner'
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTaskScreen(
                                      idTask: task['idTask'],
                                      onTaskEdited: () {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Are you sure you want to delete this task?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Confirm'),
                                          onPressed: () async {
                                            var url = Uri.parse(
                                                '$api/task/delete/${task['idTask']}');
                                            var response =
                                            await http.delete(
                                              url,
                                              headers: <String, String>{
                                                'Content-Type':
                                                'application/json; charset=UTF-8',
                                                'authorization':
                                                basicAuth,
                                              },
                                            );
                                            if (response.statusCode ==
                                                200) {
                                              print(
                                                  'Task deleted successfully');
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext
                                                context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Success!'),
                                                    content: Column(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      children: <Widget>[
                                                        Flexible(
                                                          child: Lottie.asset(
                                                              'tick_animation.json',
                                                              fit: BoxFit
                                                                  .contain,
                                                              repeat:
                                                              false),
                                                        ),
                                                        const Text(
                                                            'You have deleted the task successfully!'),
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      Center(
                                                        child: TextButton(
                                                          child: const Text(
                                                              'Continue'),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              print(
                                                  'Failed to delete task');
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
                        )
                            : null,
                        onTap: widget.currentUserRole == 'owner' ||
                            widget.currentUserRole == 'manager'
                            ? () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FutureBuilder<bool>(
                                future: _isImageEmpty(task['idTask']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    bool imageIsEmpty = snapshot.data!;
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0), // Borde redondeado
                                      ),
                                      elevation: 16,
                                      child: Container(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min, // Para hacer el cuadro de diálogo tan grande como sus hijos
                                          children: <Widget>[
                                            Text(
                                              decodeUtf8IfNeeded(task['name']),
                                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              decodeUtf8IfNeeded(task['description']),
                                              style: const TextStyle(fontSize: 18),
                                            ),
                                            const SizedBox(height: 20),
                                            if (!imageIsEmpty)
                                              FutureBuilder<Uint8List>(
                                                future: _getImageBytes(task['idTask']),
                                                builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Image.memory(snapshot.data!);
                                                  } else if (snapshot.hasError) {
                                                    return Text('Error: ${snapshot.error}');
                                                  }
                                                  return CircularProgressIndicator();
                                                },
                                              )
                                            else
                                              const Text(
                                                  'No image available.',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            const SizedBox(height: 20),
                                            TextButton(
                                              child: const Text('Close', style: TextStyle(color: Colors.blue, fontSize: 18)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Text('No data');
                                  }
                                },
                              );
                            },
                          );
                        }
                            : null,
                      ),
                    ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // Muestra un spinner de carga mientras se espera la respuesta de la API
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
