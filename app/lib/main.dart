import 'package:flutter/material.dart';

void main() {
  runApp(const StudentAiAssistantApp());
}

class StudentAiAssistantApp extends StatelessWidget {
  const StudentAiAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Student AI Assistant'),
        ),
      ),
    );
  }
}