import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tfg/global_config.dart';

// PUSH notifications for Android and iOS devices

class ApiService {
  final String baseUrl = '$api/project';

  Future<String> requestBudget(int idProject) async {
    var url = Uri.parse('$baseUrl/$idProject/requestBudget');
    var response = await http.post(url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to request budget');
    }
  }

  Future<String> sendBudget(int idProject) async {
    var url = Uri.parse('$baseUrl/$idProject/sendBudget');
    var response = await http.post(url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to send budget');
    }
  }

  Future<String> acceptBudget(int idProject) async {
    var url = Uri.parse('$baseUrl/$idProject/acceptBudget');
    var response = await http.post(url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to accept budget');
    }
  }

  Future<String> rejectBudget(int idProject) async {
    var url = Uri.parse('$baseUrl/$idProject/rejectBudget');
    var response = await http.post(url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to reject budget');
    }
  }

  Future<String> changeTaskStatus(int idTask, String status) async {
    var url = Uri.parse('$baseUrl/tasks/$idTask/changeStatus');
    var response = await http.post(url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to change task status');
    }
  }

  Future<String> finishProject(int idProject) async {
    var url = Uri.parse('$baseUrl/$idProject/finish');
    var response = await http.post(url, headers: <String, String>{'authorization': basicAuth});

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to finish project');
    }
  }
}