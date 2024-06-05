import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:tfg/global_config.dart';

class TaskForm extends StatefulWidget {
  final int idProject;
  final VoidCallback onTaskCreated;

  TaskForm({required this.idProject, required this.onTaskCreated});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Low';

  Future<void> _createTask() async {
    var url = Uri.parse('$api/task/create');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
      body: jsonEncode(<String, String>{
        'idTask': '0',
        'idProject': widget.idProject.toString(),
        'name': capitalizeOnlyFirstLetter(_nameController.text),
        'description': capitalizeOnlyFirstLetter(_descriptionController.text),
        'priority': _priority,
        'image': '',
        'status': 'disabled',
      }),
    );

    if (response.statusCode == 200) {
      print('Task created successfully');
      widget.onTaskCreated();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success!'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // This makes the column height wrap its content
              children: <Widget>[
                Flexible(
                  child: Lottie.asset('tick_animation.json', fit: BoxFit.contain, repeat: false),
                ),
                const Text('You have created the task successfully!'),
              ],
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  child: const Text('Continue'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        },
      );
    } else {
      print('Failed to create task');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<String>(
                value: _priority,
                items: <String>['Low', 'Medium', 'High'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.priority_high),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _createTask();
                }
              },
              child: const Text('Create task'),
            ),
          ],
        ),
      ),
    );
  }
}
