import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'model.dart';

class DetectedDetails extends StatefulWidget {
  final DetectedObject object;

  const DetectedDetails({super.key, required this.object});

  @override
  _DetectedDetailsState createState() => _DetectedDetailsState();
}

class _DetectedDetailsState extends State<DetectedDetails> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    if (widget.object.videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.object.videoUrl)
        ..initialize().then((_) {
          setState(() {});
        }).catchError((error) {
          setState(() {
            _videoError = true;
          });
        });
    } else {
      _videoError = true;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          _isPlaying = false;
        } else {
          _controller!.play();
          _isPlaying = true;
        }
      });
    }
  }

  void _downloadVideo() {
    FileDownloader.downloadFile(
      url: widget.object.videoUrl,
      onDownloadError: (String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download error: $error')),
        );
      },
      onDownloadCompleted: (path) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download complete!')),
        );
      },
      onProgress: (fileName, progress) {
        setState(() {
          _progress = progress;
        });
      },
    );
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

              // Video Player or Error Message
              _videoError
                  ? const Text("No video available", style: TextStyle(fontSize: 18, color: Colors.red))
                  : _controller != null && _controller!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller!),
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
                  : const CircularProgressIndicator(),

              const SizedBox(height: 20),


              // Download Button
              ElevatedButton.icon(
                onPressed: _downloadVideo,
                icon: const Icon(Icons.download),
                label: const Text("Download Video"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              // Download Progress Indicator
              if (_progress > 0 && _progress < 100)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress / 100,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 10),
                    Text('${_progress.toStringAsFixed(2)} %',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
