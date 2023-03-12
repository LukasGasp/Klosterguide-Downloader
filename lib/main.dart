import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<String> _files = [];

  Future<void> _downloadAndUnzip() async {
    const url =
        "https://github.com/LukasGasp/Klosterguide-Videos/archive/refs/heads/main.zip";
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/myfile.zip');
    await file.writeAsBytes(bytes);
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final filename = file.name;
      print("File: $filename");
      if (file.isFile && filename.isNotEmpty) {
        _files.add(filename);
        print("New _files: $_files");
        // Old not working
        // final data = file.content as List<int>;
        // final extractedFile = File('${dir.path}/$filename');
        // await extractedFile.writeAsBytes(data);

        final data = file.content as List<int>;
        File('${dir.path}/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
    print("Extracting done...");
    setState(() {});
  }

  late VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zip File Viewer'),
        ),
        body: Center(
          child: _files.isEmpty
              ? TextButton(
                  onPressed: _downloadAndUnzip,
                  child: const Text('Download and Unzip'),
                )
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final filename = _files[index];
                    return ListTile(
                      title: Text(filename),
                      onTap: () async {
                        final dir = await getApplicationSupportDirectory();
                        final file = File('${dir.path}/$filename');

                        // Videoplayer
                        controller = VideoPlayerController.file(file)
                          ..initialize();

                        setState(() {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(filename),
                              content: AspectRatio(
                                aspectRatio: controller.value.aspectRatio,
                                child: VideoPlayer(controller),
                              ),
                            ),
                          ).then((_) {
                            controller.pause();
                            print("Pause!");
                          });
                          controller.play();
                          print("Playing!");
                        });
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
