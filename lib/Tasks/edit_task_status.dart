import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tfg/global_config.dart';
import 'package:http/http.dart' as http;

class EditTaskStatusScreen extends StatefulWidget {
  final int idTask;
  final String statusTask;

  EditTaskStatusScreen({required this.idTask, required this.statusTask});

  @override
  _EditTaskStatusScreenState createState() => _EditTaskStatusScreenState();
}

extension StringExtension on String {
  String get capitalizeFirstofEach {
    return split(" ") // Separa por espacios
        .map((str) => str.split("-").map((part) => part.isEmpty ?
    part : part[0].toUpperCase() + part.substring(1)).join("-"))
        .join(" ");
  }
}

class _EditTaskStatusScreenState extends State<EditTaskStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'To-Do';

  @override
  void initState() {
    super.initState();
    _status = widget.statusTask.capitalizeFirstofEach;
  }

  Future<void> _updateTaskStatus() async {
    var url = Uri.parse('$api/task/${widget.idTask}/status');
    var response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
      body: _status.toLowerCase(),
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
                const Text('You have updated the task status successfully!'),
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
      throw Exception('Failed to update task status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task Status'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _status,
              items: <String>['To-Do', 'In Progress', 'Blocked', 'Done'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.domain_verification_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTaskStatus,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}