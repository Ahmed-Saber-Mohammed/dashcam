import 'package:dash_cam/detected_list.dart';
import 'package:flutter/material.dart';

class EnterServerIPPage extends StatefulWidget {
  const EnterServerIPPage({super.key});

  @override
  State<EnterServerIPPage> createState() => _EnterServerIPPageState();
}

class _EnterServerIPPageState extends State<EnterServerIPPage> {
  final List<TextEditingController> ipControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  void _navigateToDetectedList() {
    final parts = ipControllers.map((c) => c.text.trim()).toList();
    if (parts.every((part) => part.isNotEmpty && int.tryParse(part) != null)) {
      final fullUrl = "http://${parts.join('.')}:5000/videos";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetectedList(baseUrl: fullUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all IP segments correctly")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Enter Server IP", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                    child: TextField(
                      controller: ipControllers[i],
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "${i + 1}st",
                        hintStyle: const TextStyle(color: Color.fromARGB(77, 65, 58, 58)),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToDetectedList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("Continue", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
