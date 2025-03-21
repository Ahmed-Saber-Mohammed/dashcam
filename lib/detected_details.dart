import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';


import 'model.dart';

class DetectedDetails extends StatefulWidget {
  final DetectedObject object;

  const DetectedDetails({super.key, required this.object});

  @override
  _DetectedDetailsState createState() => _DetectedDetailsState();
}

class _DetectedDetailsState extends State<DetectedDetails> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.object.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Update UI when video is ready
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  Future<void> _downloadVideo(BuildContext context, String url) async {
    try {
      // Request storage permission
      if (!await _requestPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to save video')),
        );
        return;
      }

      // Get directory for saving the file
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception("Failed to get directory");
      }

      String filePath = '${directory.path}/downloaded_video.mp4';

      // Download the video
      Dio dio = Dio();
      var response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save the file
      File file = File(filePath);
      await file.writeAsBytes(response.data);

      // Save to gallery
      final result = await ImageGallerySaver.saveFile(filePath);

      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video saved to Gallery')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save video')),
        );
      }
    } catch (e) {
      print("Error downloading video: $e"); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download video: $e')),
      );
    }
  }


  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detected Details", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Date: ${widget.object.data}",
                style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Time: ${widget.object.time}",
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Video Player
              _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    Positioned(
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 50,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                  ],
                ),
              )
                  : const CircularProgressIndicator(), // Show loading indicator until video loads

              const SizedBox(height: 20),

              // Play/Pause Button
              ElevatedButton.icon(
                onPressed: _togglePlayPause,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(_isPlaying ? "Pause Video" : "Play Video"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              // Download Button
              ElevatedButton.icon(
                onPressed: () => _downloadVideo(context, widget.object.videoUrl),
                icon: const Icon(Icons.download),
                label: const Text("Download Video"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
