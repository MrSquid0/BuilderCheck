import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class Task {
  String name;
  String description;
  String priority;
  bool completed;

  Task(this.name, {this.description = '', this.priority = 'Low', this.completed = false});
}

class TaskEditScreen extends StatelessWidget {
  final Task task;
  final Function onDelete;
  final int taskIndex;



  TaskEditScreen({required this.task, required this.onDelete, required this.taskIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDelete(taskIndex);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: task.name),
              onChanged: (value) {
                task.name = value;
              },
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: TextEditingController(text: task.description),
              onChanged: (value) {
                task.description = value;
              },
              decoration: InputDecoration(labelText: 'Description'),
            ),
            DropdownButtonFormField(
              value: task.priority,
              items: ['High', 'Medium', 'Low'].map((String priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) {
                task.priority = value.toString();
              },
              decoration: InputDecoration(labelText: 'Priority'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, task);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectDetailsScreen extends StatefulWidget {
  final String projectName;
  final String projectAddress;
  final String managerName;
  final String managerEmail;
  final String managerPhone;

  const ProjectDetailsScreen({
    required this.projectName,
    required this.projectAddress,
    required this.managerName,
    required this.managerEmail,
    required this.managerPhone,
  });

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final List<Task> tasks = [];
  final taskNameController = TextEditingController();

  String generateLink() {
    const String _allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    const int _linkLength = 30;

    final random = Random();
    final link = String.fromCharCodes(Iterable.generate(
        _linkLength, (_) => _allowedChars.codeUnitAt(random.nextInt(_allowedChars.length))));
    return 'https://yourwebsite.com/join/$link';
  }

  Future<void> copyLinkToClipboard(BuildContext context) async {
    final link = generateLink();
    await Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Join link copied to clipboard.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void addTask(String taskName) {
    setState(() {
      tasks.add(Task(taskName));
    });
  }

  void editTask(int index, Task editedTask) {
    setState(() {
      tasks[index] = editedTask;
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () => copyLinkToClipboard(context),
              child: Text('Copy join link to share with the manager'),
            ),
            SizedBox(height: 16),
            Text(
              'Tasks:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      tasks[index].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // Si la tarea está completada, tacha el texto y cambia su color
                        decoration: tasks[index].completed ? TextDecoration.lineThrough : null,
                        color: tasks[index].completed ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text(
                      'Priority: ${tasks[index].priority}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        // Si la tarea está completada, tacha el texto y cambia su color
                        decoration: tasks[index].completed ? TextDecoration.lineThrough : null,
                        color: tasks[index].completed ? Colors.grey : null,
                      ),
                    ),
                    trailing: Checkbox(
                      value: tasks[index].completed,
                      onChanged: (newValue) {
                        setState(() {
                          tasks[index].completed = newValue!;
                        });
                      },
                    ),
                    onTap: () async {
                      Task? editedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskEditScreen(task: tasks[index], onDelete: deleteTask, taskIndex: index)),
                      );
                      if (editedTask != null) {
                        editTask(index, editedTask);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add Task'),
              content: TextField(
                controller: taskNameController,
                onChanged: (value) {
                  // Handle changes to the new task name
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    addTask(taskNameController.text);
                    taskNameController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
