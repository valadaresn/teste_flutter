import 'package:flutter/material.dart';

/// Widget that displays loading state, error state, or empty state
class DiaryStateWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onAddFirstEntry;

  const DiaryStateWidget({
    super.key,
    this.isLoading = false,
    this.errorMessage,
    required this.onRetry,
    required this.onAddFirstEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro: $errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Seu diário está vazio',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAddFirstEntry,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar primeira entrada'),
          ),
        ],
      ),
    );
  }
}
