import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Ensure flutter_markdown is in pubspec.yaml

class LegalPage extends StatelessWidget {
  final String title;
  final String content;

  const LegalPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Markdown(
        data: content,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          p: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}