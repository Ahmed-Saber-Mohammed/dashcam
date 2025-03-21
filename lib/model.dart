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
    videoUrl: "https://static.videezy.com/system/resources/previews/000/044/479/original/banana.mp4", // Placeholder video URL
  ),
  DetectedObject(
    data: "2024-03-14",
    time: "14:35",
    videoUrl: "https://v.ftcdn.net/07/87/47/68/700_F_787476806_vvS2OGgyv5BgfftZvrMcgrVMRt4TF1ob_ST.mp4", // Placeholder video URL
  ),
  DetectedObject(
    data: "2024-03-13",
    time: "16:20",
    videoUrl: "",
  ),
];
