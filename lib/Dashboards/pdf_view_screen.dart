import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:tfg/global_config.dart';
import 'package:http/http.dart' as http;

class PdfViewScreen extends StatefulWidget {
  final int projectId;
  final int idOwner;
  final int idManager;
  final String projectName;
  final String projectAddress;
  final String startDate;
  final String endDate;
  final String currentUserRole;

  PdfViewScreen({required this.projectId, required this.idOwner, required this.idManager,
    required this.projectName, required this.projectAddress, required this.startDate,
    required this.endDate, required this.currentUserRole});

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  String budgetStatus = '';

  @override
  void initState() {
    super.initState();
    _getBudgetStatus(widget.projectId).then((status) {
      setState(() {
        budgetStatus = status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget PDF'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  size: 100,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Budget PDF',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'You can download, accept, or decline the budget proposal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _downloadPdfFile();
                  },
                  icon: Icon(Icons.download),
                  label: Text('Download'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                if (budgetStatus != 'confirmed')
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _updateBudgetStatus(widget.projectId, 'confirmed');
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
                                  child: Lottie.asset(
                                      'tick_animation.json',
                                      fit: BoxFit.contain,
                                      repeat: false),
                                ),
                                const Text(
                                    'You have approved the budget successfully!'),
                              ],
                            ),
                            actions: <Widget>[
                              Center(
                                child: TextButton(
                                  child: const Text('Close'),
                                  onPressed: () {
                                    Navigator.pop(context, 'update');
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewScreen(
                                          projectId: widget.projectId, idOwner: widget.idOwner,
                                          idManager: widget.idManager, projectName: widget.projectName,
                                          projectAddress: widget.projectAddress, startDate: widget.startDate,
                                          endDate: widget.endDate, currentUserRole: widget.currentUserRole,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                const SizedBox(height: 20),
                if (budgetStatus != 'confirmed')
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _deleteBudget(widget.projectId);
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
                                  child: Lottie.asset(
                                      'tick_animation.json',
                                      fit: BoxFit.contain,
                                      repeat: false),
                                ),
                                const Text(
                                    'You have declined the budget successfully! '
                                        'Now, the owner needs to request a new budget.'),
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
                              )
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Decline'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                if (budgetStatus == 'confirmed')
                  const Text(
                    'You have already approved this budget!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadPdfFile() async {
    var url = Uri.parse('$api/project/${widget.projectId}/budgetPdf');
    var dio = Dio();
    dio.options.headers['authorization'] = basicAuth;
    if (kIsWeb) {
      try {
        final response = await dio.get(url.toString(), options: Options(responseType: ResponseType.bytes));
        final blob = html.Blob([response.data], 'application/pdf');
        final urlBlob = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: urlBlob)
          ..setAttribute('download', 'budget.pdf')
          ..click();
        html.Url.revokeObjectUrl(urlBlob);
        print('PDF downloaded successfully (Web)');
      } catch (e) {
        print('Error downloading PDF (Web): $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading PDF: $e')),
        );
      }
    } else {
      try {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/budget.pdf');

        final response = await dio.get(
          url.toString(),
          options: Options(responseType: ResponseType.bytes),
        );
        await file.writeAsBytes(response.data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF downloaded to ${file.path}')),
        );
        print('PDF downloaded successfully to ${file.path}');
      } catch (e) {
        print('Error downloading PDF (Mobile): $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading PDF: $e')),
        );
      }
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
      return response.body;
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
      body: newStatus,
    );

    if (response.statusCode == 200) {
      print('Budget status updated successfully');
    } else {
      throw Exception('Failed to update budget status');
    }
  }

  Future<void> _deleteBudget(int idProject) async {
    var url = Uri.parse('$api/project/$idProject/deleteBudget');
    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      print('Budget deleted successfully');
    } else {
      throw Exception('Failed to delete budget');
    }
  }
}

