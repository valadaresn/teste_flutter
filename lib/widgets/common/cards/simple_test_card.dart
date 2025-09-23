import 'package:flutter/material.dart';

/// 🧪 CARD DE TESTE SIMPLES - para debug
class SimpleTestCard extends StatelessWidget {
  final String title;
  final String? content;

  const SimpleTestCard({Key? key, required this.title, this.content})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (content != null) ...[
                const SizedBox(height: 4),
                Text(content!, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
