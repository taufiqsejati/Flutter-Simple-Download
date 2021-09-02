import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndialog/ndialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, //primary theme color
      ),
      home: FileDownload(), //call to homepage class
    );
  }
}

class FileDownload extends StatefulWidget {
  @override
  _FileDownloadState createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {
  late bool isLoading;
  bool _allowWriteFile = false;

  List<Course> courseContent = [];

  String progress = "";
  late Dio dio;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    courseContent.add(Course(
        title: "Chapter 2",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap2.pdf"));
    courseContent.add(Course(
        title: "Chapter 3",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap3.pdf"));
    courseContent.add(Course(
        title: "Chapter 4",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap4.pdf"));
    courseContent.add(Course(
        title: "Chapter 5",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap5.pdf"));
    courseContent.add(Course(
        title: "Chapter 6",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap6.pdf"));
    courseContent.add(Course(
        title: "Chapter 7A",
        path:
            "https://i0.wp.com/flutteragency.com/wp-content/uploads/2020/11/How-to-Download-File-From-URL-and-Save-to-Phone-Storage-In-Flutter.jpg"));
  }

  requestWritePermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        _allowWriteFile = true;
      });
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  Future<String> getDirectoryPath() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    Directory directory =
        await new Directory(appDocDirectory.path + '/' + 'dir')
            .create(recursive: true);

    return directory.path;
  }

  Future downloadFile(String url, path) async {
    if (!_allowWriteFile) {
      requestWritePermission();
    }
    try {
      ProgressDialog progressDialog = ProgressDialog(context,
          dialogTransitionType: DialogTransitionType.Bubble,
          title: Text("Downloading File"));

      progressDialog.show();

      await dio.download(url, path, onReceiveProgress: (rec, total) {
        setState(() {
          isLoading = true;
          progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
          progressDialog.setMessage(Text("Dowloading $progress"));
        });
      });
      progressDialog.dismiss();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text("FIle Download"),
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            String url = courseContent[index].path;
            String title = courseContent[index].title;
            String extension = url.substring(url.lastIndexOf("/"));
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$title",
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      RaisedButton(
                        color: Colors.green,
                        onPressed: () {
                          getDirectoryPath().then((path) {
                            File f = File(path + "$extension");
                            if (f.existsSync()) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PDFScreen(f.path);
                              }));
                              return;
                            }

                            downloadFile(url, "$path/$extension");
                          });
                        },
                        child: Text(
                          "View",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: courseContent.length,
        ),
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.file(
      File(pathPDF),
      key: _pdfViewerKey,
    );
  }
}

class Course {
  String title;
  String path;
  Course({required this.title, required this.path});
}
