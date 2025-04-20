import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'detected_details.dart';
import 'model.dart';

const String baseUrl = "";

class DetectedList extends StatefulWidget {
  final String baseUrl;
  const DetectedList({super.key, required this.baseUrl});

  @override
  _DetectedListState createState() => _DetectedListState();
}

class _DetectedListState extends State<DetectedList> {
  List<DetectedObject> objectsList = [];

  @override
  void initState() {
    super.initState();
    fetchDetectedVideos();
  }

  Future<void> fetchDetectedVideos() async {
    try {
      var response = await Dio().get(widget.baseUrl);
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        List<dynamic> videos = response.data;

        setState(() {
          objectsList =
              videos.map((video) {
                String nameWithoutExtension = video.split('.').first;

                // Expected format: YYYY-MM-DD_HH-MM-SS
                List<String> parts = nameWithoutExtension.split('_');
                String date = parts.length > 0 ? parts[0] : "Unknown";
                String time =
                    parts.length > 1
                        ? parts[1].replaceAll('-', ':')
                        : "Unknown";

                return DetectedObject(
                  date: date, // or extract from filename if applicable
                  time: time,
                  videoUrl: "$baseUrl/$videos",
                );
              }).toList();
        });
      } else {
        print("Error: Status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching detected videos: $e");
    }
  }

  void _deleteobject(int index) async {
    final filename = objectsList[index].videoUrl.split('/').last;

    try {
      final response = await Dio().delete("$baseUrl/$filename");

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          objectsList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video deleted from server')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Delete error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }
  // Show confirmation dialog before deleting
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteobject(index);
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detected Videos",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white54),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: fetchDetectedVideos,
        child:
            objectsList.isEmpty
                ? ListView(
                  // Ensures RefreshIndicator can scroll
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text(
                          "No detected video",
                          style: TextStyle(color: Colors.red, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: objectsList.length,
                  itemBuilder: (context, index) {
                    final object = objectsList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetectedDetails(object: object),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFF00AE46)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          title: Text(
                            "Date: ${object.date}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Time: ${object.time}",
                            style: TextStyle(
                              color: Colors.black12.withOpacity(0.8),
                              fontSize: 15,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
