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
import 'package:intl/intl.dart';

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
  final ImagePicker _picker = ImagePicker();
  PageController _pageController = PageController();

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

  Future<Uint8List> _getImageBytes(int idImage) async {
    var url = Uri.parse('$api/task/image/$idImage');
    var response = await http.get(url, headers: {'authorization': basicAuth});

    return response.bodyBytes;
  }

  Future<List<Map<String, dynamic>>> _getTaskImages(int idTask) async {
    var url = Uri.parse('$api/task/$idTask/getImages');
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
      throw Exception('Failed to load task images');
    }
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
                child: Lottie.asset('images/tick_animation.json', fit: BoxFit.contain, repeat: false),
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
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: FloatingActionButton(
                heroTag: 'uploadButton', // Unique tag for this FloatingActionButton
                onPressed: _pickImage,
                child: const Icon(Icons.upload_file),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: FloatingActionButton(
                heroTag: 'doneButton', // Unique tag for this FloatingActionButton
                onPressed: () async {
                  await _updateTaskStatus();
                  _showSuccessDialog();
                },
                child: const Icon(Icons.done),
              ),
            ),
          ),
        ],
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
                    style: const TextStyle(color: Colors.white),
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
            Column(
              children: <Widget>[
                Image.network(_selectedImage!.path),
                const SizedBox(height: 20),
                Container(
                  color: Colors.red,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Image not uploaded yet! Please press the button below right to upload it.',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          FutureBuilder<bool>(
            future: _isImageEmpty(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data! && _selectedImage == null) {
                  return Container(
                    color: Colors.yellow,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'There is no image associated to this task! '
                            'You can upload an image with the button below left.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else if (!snapshot.data! && _selectedImage == null) {
                  return _buildImageSlider();
                }
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getTaskImages(widget.idTask),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> images = snapshot.data!;
          images = images.reversed.toList();
          return Column(
            children: <Widget>[
              Container(
                height: 250, // Ajusta la altura según tus necesidades
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<Uint8List>(
                      future: _getImageBytes(images[index]['idImage']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          Uint8List imageBytes = snapshot.data!;
                          DateTime timestamp = DateTime.parse(images[index]['timestamp']);
                          String formattedTimestamp = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
                          return LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              return Container(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                                child: Stack(
                                  children: <Widget>[
                                    AspectRatio(
                                      aspectRatio: 16 / 9, // Ajusta este valor según tus necesidades
                                      child: Image.memory(
                                        imageBytes,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Text(
                                        formattedTimestamp,
                                        style: const TextStyle(
                                          backgroundColor: Colors.black54,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return const Text('No data');
                        }
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        } else {
          return const Text('No data');
        }
      },
    );
  }
  }