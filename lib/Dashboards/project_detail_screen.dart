import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatelessWidget {
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

  String generateLink() {
    // Genera un enlace aleatorio
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
    // Muestra un mensaje indicando que el enlace ha sido copiado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Join link copied to clipboard.'),
        duration: Duration(seconds: 3),
      ),
    );
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
            Text(
              'Project Name: $projectName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Project Address: $projectAddress',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Manager Name: $managerName',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Manager Email: $managerEmail',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Manager Phone: $managerPhone',
              style: TextStyle(fontSize: 16),
            ),
            // Add more project details as needed
          ],
        ),
      ),
    );
  }
}