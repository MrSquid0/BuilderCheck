import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:tfg/global_config.dart';

class EditTaskScreen extends StatefulWidget {
  final int idTask;
  final VoidCallback onTaskEdited;

  EditTaskScreen({required this.idTask, required this.onTaskEdited});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Low';

  Future<void> _getTask() async {
    var url = Uri.parse('$api/task/${widget.idTask}');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    String decodeUtf8(String source) {
      List<int> sourceBytes = source.codeUnits;
      return utf8.decode(sourceBytes);
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> task = jsonDecode(response.body);
      _nameController.text = decodeUtf8(task['name']);
      _descriptionController.text = decodeUtf8(task['description']);
      setState(() {
        _priority = task['priority'];
      });
    } else {
      throw Exception('Failed to load task');
    }
  }

  Future<void> _editTask() async {
    var url = Uri.parse('$api/task/edit/${widget.idTask}');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
      body: jsonEncode(<String, String>{
        'name': _nameController.text,
        'description': _descriptionController.text,
        'priority': _priority,
      }),
    );

    if (response.statusCode == 200) {
      print('Task edited successfully');
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
                const Text('You have edited the task successfully!'),
              ],
            ),
            actions: <Widget>[
              Center(
                child: TextButton(
                  child: const Text('Continue'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    widget.onTaskEdited();
                  },
                ),
              ),
            ],
          );
        },
      );
    } else {
      print('Failed to edit task');
    }
  }

  @override
  void initState() {
    super.initState();
    _getTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
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
              )
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _editTask();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}