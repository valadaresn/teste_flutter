// ============================================================================
// WIDGET DEMONSTRAÇÃO - BACKUP/RESTORE DAS CONFIGURAÇÕES
// ============================================================================
// Widget de exemplo mostrando como usar o sistema de backup para evitar
// perder configurações quando reinstalar o app.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_backup_service.dart';

class BackupDemoWidget extends StatefulWidget {
  const BackupDemoWidget({super.key});

  @override
  State<BackupDemoWidget> createState() => _BackupDemoWidgetState();
}

class _BackupDemoWidgetState extends State<BackupDemoWidget> {
  String _status = 'Pronto para backup/restore';
  bool _isLoading = false;

  void _setStatus(String message) {
    setState(() {
      _status = message;
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  /// Faz backup das configurações e copia para clipboard
  Future<void> _createBackup() async {
    _setLoading(true);
    try {
      await SettingsBackupService.copyBackupToClipboard();
      _setStatus(
        '✅ Backup copiado para clipboard!\nCole em um local seguro (notas, email, etc.)',
      );

      // Feedback visual
      HapticFeedback.lightImpact();
    } catch (e) {
      _setStatus('❌ Erro ao criar backup: $e');
    }
    _setLoading(false);
  }

  /// Restaura configurações do clipboard
  Future<void> _restoreBackup() async {
    _setLoading(true);
    try {
      final success = await SettingsBackupService.restoreFromClipboard();
      if (success) {
        _setStatus(
          '✅ Configurações restauradas com sucesso!\nReinicie o app para ver as mudanças.',
        );
        HapticFeedback.mediumImpact();
      } else {
        _setStatus('⚠️ Nenhum backup válido encontrado no clipboard');
      }
    } catch (e) {
      _setStatus('❌ Erro ao restaurar: $e');
    }
    _setLoading(false);
  }

  /// Salva backup em arquivo na pasta Documents
  Future<void> _saveToFile() async {
    _setLoading(true);
    try {
      final filePath = await SettingsBackupService.exportBackupToFile();
      _setStatus(
        '✅ Backup salvo em:\n$filePath\nGuarde este arquivo em local seguro!',
      );
      HapticFeedback.lightImpact();
    } catch (e) {
      _setStatus('❌ Erro ao salvar arquivo: $e');
    }
    _setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💾 Backup das Configurações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Evite perder suas configurações quando reinstalar o app:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_status, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 16),

            // Botões de ação
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  // Backup via clipboard
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createBackup,
                      icon: const Icon(Icons.copy),
                      label: const Text('Backup → Clipboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Restore do clipboard
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _restoreBackup,
                      icon: const Icon(Icons.paste),
                      label: const Text('Restore ← Clipboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Salvar em arquivo
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _saveToFile,
                      icon: const Icon(Icons.save_alt),
                      label: const Text('Salvar em Arquivo'),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Instruções
            const Text(
              '📋 Como usar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '1. Configure seu app como preferir\n'
              '2. Clique "Backup → Clipboard"\n'
              '3. Cole o texto em um local seguro (notas, email)\n'
              '4. Após reinstalar: cole o backup e clique "Restore"',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
