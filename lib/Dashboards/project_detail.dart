import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:tfg/global_config.dart';
import 'package:http/http.dart' as http;

import 'package:tfg/Dashboards/task_form.dart';

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
  String decodeUtf8(String source) {
    List<int> sourceBytes = source.codeUnits;
    return utf8.decode(sourceBytes);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: <Widget>[
          if (widget.currentUserRole == 'owner')
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
                          future: _getUserDetails(widget.idManager),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Failed to load manager details');
                            } else if (snapshot.hasData) {
                              Map<String, dynamic> manager = snapshot.data!;
                              return Row(
                                children: <Widget>[
                                  const Icon(Icons.manage_accounts_outlined),
                                  const SizedBox(width: 8),
                                  Text('${decodeUtf8(manager['name'])} ${decodeUtf8(manager['surname'])}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Failed to load owner details');
                            } else if (snapshot.hasData) {
                              Map<String, dynamic> owner = snapshot.data!;
                              return Row(
                                children: <Widget>[
                                  const Icon(Icons.person_4_outlined),
                                  const SizedBox(width: 8),
                                  Text('${decodeUtf8(owner['name'])} ${decodeUtf8(owner['surname'])}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                              decodeUtf8(widget.projectAddress),
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
                  for (var task in tasks)
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(decodeUtf8(task['name']), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text('Priority: ${task['priority']}', style: const TextStyle(fontSize: 16)),
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
    );
  }
}