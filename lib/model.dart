class DetectedObject {
  final String data;
  final String time;
  final String videoUrl; // Changed from imageUrl to videoUrl

  DetectedObject({
    required this.data,
    required this.time,
    required this.videoUrl,
  });
}

// Sample data for testing
List<DetectedObject> DetectedObjects = [
  DetectedObject(
    data: "2024-03-14",
    time: "14:35",
    videoUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", // Placeholder video URL
  ),
  DetectedObject(
    data: "2024-03-13",
    time: "16:20",
    videoUrl: "https://www.example.com/sample-video.mp4",
  ),
];
