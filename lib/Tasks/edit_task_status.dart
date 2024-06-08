import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:tfg/global_config.dart';

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
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker(); // Declare _picker here

  @override
  void initState() {
    super.initState();
    _status = widget.statusTask.capitalizeFirstofEach;
  }

  Future<bool> _isImageEmpty() async {
    var url = Uri.parse('$api/task/${widget.idTask}/isImageEmpty');
    var response = await http.get(url, headers: {'authorization': basicAuth});
    return response.body.toLowerCase() == 'true';
  }

  Future<Uint8List> _getImageBytes() async {
    var url = Uri.parse('$api/task/${widget.idTask}/getImageFile');
    var response = await http.get(url, headers: {'authorization': basicAuth});

    return response.bodyBytes;
  }

  Future<void> _uploadImageFile(XFile imageFile) async {
    var url = Uri.parse('$api/task/${widget.idTask}/uploadImageFile');
    var request = http.MultipartRequest('POST', url)
      ..headers['authorization'] = basicAuth
      ..files.add(http.MultipartFile.fromBytes(
          'image',
          await imageFile.readAsBytes(),
          filename: imageFile.name
      ));
    var response = await request.send();
    if (response.statusCode == 200) {
      _showSuccessDialog();
    } else {
      throw Exception('Failed to upload image file');
    }
  }

  Future<void> _deleteImage() async {
    var url = Uri.parse('$api/task/${widget.idTask}/deleteImage');
    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    if (response.statusCode == 200) {
      _showSuccessDialog();
    } else {
      throw Exception('Failed to delete image');
    }
  }

  void _showSuccessDialog() {
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
      if (_selectedImage != null) {
        await _uploadImageFile(_selectedImage!);
        Navigator.pop(context); // Segundo pop si se sube una imagen
      }
    } else {
      throw Exception('Failed to update task status');
    }
  }

  Future<void> _pickImage() async {
    try {
      XFile? image;
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
        if(result != null) {
          Uint8List bytes = result.files.single.bytes!;
          String fileName = result.files.single.name;
          // Create a Blob from the image bytes and get its URL
          var blob = html.Blob([bytes]);
          var url = html.Url.createObjectUrlFromBlob(blob);
          image = XFile(url, name: fileName);
        }
      } else {
        image = await _picker.pickImage(source: ImageSource.gallery);
      }

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task Status'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              await _updateTaskStatus();
              _showSuccessDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _buildForm(),
            ],
          ),
        ),
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _isImageEmpty(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return FloatingActionButton(
                onPressed: _pickImage,
                child: const Icon(Icons.upload_file),
              );
            }
          }
          return Container(); // Retorna un contenedor vacío si ya hay una imagen
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _status,
            items: <String>['To-Do', 'In Progress', 'Blocked', 'Done'].map((String value) {
              Color backgroundColor;
              switch (value) {
                case 'To-Do':
                  backgroundColor = Colors.orange;
                  break;
                case 'Blocked':
                  backgroundColor = Colors.red;
                  break;
                case 'In Progress':
                  backgroundColor = Colors.blue;
                  break;
                case 'Done':
                  backgroundColor = Colors.green;
                  break;
                default:
                  backgroundColor = Colors.grey;
              }
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  color: backgroundColor,
                  child: Text(
                    value,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
          if (_selectedImage != null)
            Image.network(_selectedImage!.path),
          const SizedBox(height: 20),
          FutureBuilder<bool>(
            future: _isImageEmpty(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!) {
                  if (_selectedImage == null) {
                    return Container(
                      color: Colors.yellow,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'There is no image associated to this task! '
                              'You can upload an image with the button below.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      color: Colors.red,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Image not uploaded yet! Please press the upper right button to upload it.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                } else {
                  return Column(
                    children: <Widget>[
                      FutureBuilder<Uint8List>(
                        future: _getImageBytes(),
                        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                          if (snapshot.hasData) {
                            if (kIsWeb) {
                              var blob = html.Blob([snapshot.data!]);
                              var url = html.Url.createObjectUrlFromBlob(blob);
                              return Image.network(url);
                            } else {
                              return Image.memory(snapshot.data!);
                            }
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _deleteImage,
                        child: Text('Delete image'),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        color: Colors.yellow,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'If you want to update the image, then you need to '
                                'delete the current one first.',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
