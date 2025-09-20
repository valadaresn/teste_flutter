import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../repositories/tag_repository.dart';

class TagInitializationService {
  final TagRepository _tagRepository = TagRepository();

  /// Inicializa tags padrão se ainda não existirem
  Future<void> initializeDefaultTags() async {
    try {
      // Verificar se já existem tags
      final stream = _tagRepository.getTags();
      final existingTags = await stream.first;

      if (existingTags.isNotEmpty) {
        // Já existem tags, não precisa criar padrão
        return;
      }

      // Criar tags padrão
      final defaultTags = [
        Tag.create(name: 'Importante', color: Colors.red),
        Tag.create(name: 'Trabalho', color: Colors.blue),
        Tag.create(name: 'Pessoal', color: Colors.purple),
        Tag.create(name: 'Ideias', color: Colors.green),
        Tag.create(name: 'Lembrete', color: Colors.orange),
        Tag.create(name: 'Compras', color: Colors.teal),
      ];

      // Criar cada tag no Firebase
      for (final tag in defaultTags) {
        await _tagRepository.createTag(tag);
      }

      print('Tags padrão inicializadas com sucesso');
    } catch (e) {
      print('Erro ao inicializar tags padrão: $e');
    }
  }

  /// Cria tags de exemplo para testes
  Future<void> createSampleTags() async {
    try {
      final sampleTags = [
        Tag.create(name: 'Estudos', color: Colors.indigo),
        Tag.create(name: 'Família', color: Colors.pink),
        Tag.create(name: 'Saúde', color: Colors.cyan),
        Tag.create(name: 'Financeiro', color: Colors.amber),
        Tag.create(name: 'Viagem', color: Colors.deepOrange),
      ];

      for (final tag in sampleTags) {
        await _tagRepository.createTag(tag);
      }

      print('Tags de exemplo criadas com sucesso');
    } catch (e) {
      print('Erro ao criar tags de exemplo: $e');
    }
  }
}
