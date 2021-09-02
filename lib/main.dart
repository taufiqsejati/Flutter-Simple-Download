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
        title: "Download 1",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap2.pdf"));
    courseContent.add(Course(
        title: "Download 2",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap3.pdf"));
    courseContent.add(Course(
        title: "Download 3",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap4.pdf"));
    courseContent.add(Course(
        title: "Download 4",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap5.pdf"));
    courseContent.add(Course(
        title: "Download 5",
        path: "https://www.cs.purdue.edu/homes/ayg/CS251/slides/chap6.pdf"));
    courseContent.add(Course(
        title: "Download 6",
        path:
            "https://cdn-2.tstatic.net/tribunnews/foto/bank/images/kritik-biden.jpg"));
  }

  requestWritePermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      setState(() {
        _allowWriteFile = true;
      });
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.manageExternalStorage,
      ].request();
    }
  }

  Future<String> getDirectoryPath() async {
    // Directory appDocDirectory = await getApplicationDocumentsDirectory();

    // Directory directory =
    //     await new Directory(appDocDirectory.path).create(recursive: true);
    // print(directory);
    // return directory.path;

    Directory? appDocDir = await getExternalStorageDirectory();
    String newPath = "";
    // print(appDocDir);
    List<String> paths = appDocDir!.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/" + folder;
      } else {
        break;
      }
    }
    newPath = newPath + "/Download";
    appDocDir = Directory(newPath);
    // Directory directory = await new Directory(newPath).create();
    print(appDocDir);
    return appDocDir.path;
  }

  Future downloadFile(String url, path) async {
    if (!_allowWriteFile) {
      requestWritePermission();
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("FIle Download"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            String url = courseContent[index].path;
            String title = courseContent[index].title;
            String extension = url.substring(url.lastIndexOf("/"));
            String extension2 = extension.substring(extension.lastIndexOf("."));
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
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                      RaisedButton(
                        color: Colors.green,
                        onPressed: () {
                          // await getDirectoryPath();
                          getDirectoryPath().then((path) {
                            File f = File(path + "$extension");
                            if (f.existsSync()) {
                              // print(extension.split('/')[1].trim());
                              print(title);
                              if (!_allowWriteFile) {
                                requestWritePermission();
                              } else {
                                if (extension2 == '.pdf') {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return PDFScreen(f.path);
                                  }));
                                } else {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ImageScreen(f.path);
                                  }));
                                }
                              }
                              return;
                            }

                            downloadFile(url, "$path$extension");
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('File Download')),
      body: SfPdfViewer.file(
        File(pathPDF),
        key: _pdfViewerKey,
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  String pathIMAGE = "";
  ImageScreen(this.pathIMAGE);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('File Download')),
      body: Container(
        child: Center(
          child: Container(
            // child: Text(pathIMAGE),
            child: Image.file(
              File(pathIMAGE),
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class Course {
  String title;
  String path;
  Course({required this.title, required this.path});
}
