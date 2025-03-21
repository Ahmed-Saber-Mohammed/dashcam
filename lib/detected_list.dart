import 'package:flutter/material.dart';

import 'detected_details.dart';
import 'model.dart';

class DetectedList extends StatefulWidget {
  const DetectedList({super.key});

  @override
  _DetectedListState createState() => _DetectedListState();
}

class _DetectedListState extends State<DetectedList> {
  List<DetectedObject> carsList = List.from(DetectedObjects);

  void _deleteCar(int index) {
    setState(() {
      carsList.removeAt(index);
    });
  }

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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteCar(index); // Proceed with deletion
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
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
        iconTheme: const IconThemeData(
          color: Colors.white54,
        ),
      ),
      backgroundColor: Colors.white,
      body: carsList.isEmpty
          ? const Center(
        child: Text(
          "No detected video",
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: carsList.length,
        itemBuilder: (context, index) {
          final car = carsList[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetectedDetails(object: car),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  "Date: ${car.data}",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Time: ${car.time}",
                  style: TextStyle(color: Colors.black12.withOpacity(0.8), fontSize: 15),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(index), // Call confirmation dialog
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
