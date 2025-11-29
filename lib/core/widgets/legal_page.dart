// lib/core/widgets/legal_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LegalPage extends StatelessWidget {
  final String title;
  final String content;

  const LegalPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Markdown(
              data: content,
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                h1: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87,
                  height: 1.5,
                ),
                h2: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87,
                  height: 1.5,
                ),
                h3: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.black87,
                  height: 1.5,
                ),
                p: TextStyle(
                  fontSize: 15, 
                  color: Colors.grey[700],
                  height: 1.6, // Better readability
                ),
                listBullet: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
                blockSpacing: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}