import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/diary_entry.dart';

class TesteFirebase extends StatefulWidget {
  const TesteFirebase({super.key});

  @override
  State<TesteFirebase> createState() => _TesteFirebaseState();
}

class _TesteFirebaseState extends State<TesteFirebase> {
  bool _inicializado = false;
  bool _carregando = false;
  String _mensagemStatus = "Firebase não inicializado";
  List<DiaryEntry> _entradas = [];
  final TextEditingController _controladorTitulo = TextEditingController();
  final TextEditingController _controladorConteudo = TextEditingController();

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorConteudo.dispose();
    super.dispose();
  }

  Future<void> _inicializarFirebase() async {
    setState(() {
      _carregando = true;
      _mensagemStatus = "Conectando ao Firebase...";
    });

    try {
      await Firebase.initializeApp();
      setState(() {
        _inicializado = true;
        _mensagemStatus = "Firebase conectado com sucesso!";
        _registrarLog("Firebase inicializado com sucesso");
      });
      await _buscarEntradas();
    } catch (e) {
      setState(() {
        _mensagemStatus = "Erro ao conectar: $e";
        _registrarLog("ERRO na inicialização: $e");
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _registrarLog(String mensagem) {
    print("[TESTE FIREBASE] $mensagem");
    // Também podemos mostrar como snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _buscarEntradas() async {
    if (!_inicializado) {
      _registrarLog("Firebase não está inicializado!");
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemStatus = "Buscando entradas do diário...";
    });

    try {
      _registrarLog("Iniciando busca de entradas...");
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('entradas_diario').get();

      _registrarLog("Encontrados ${snapshot.docs.length} documentos");

      final entradas =
          snapshot.docs.map((doc) {
            final dados = doc.data() as Map<String, dynamic>;
            _registrarLog(
              "Documento ID: ${doc.id} - Título: ${dados['title'] ?? 'Sem título'}",
            );

            return DiaryEntry(
              id: doc.id,
              title: dados['title'],
              content: dados['content'],
              dateTime: (dados['dateTime'] as Timestamp).toDate(),
              mood: dados['mood'],
              tags: List<String>.from(dados['tags'] ?? []),
              isFavorite: dados['isFavorite'] ?? false,
            );
          }).toList();

      setState(() {
        _entradas = entradas;
        _mensagemStatus = "Encontradas ${entradas.length} entradas";
      });
    } catch (e) {
      setState(() {
        _mensagemStatus = "Erro ao buscar entradas: $e";
        _registrarLog("ERRO na busca: $e");
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _adicionarEntrada() async {
    if (!_inicializado) {
      _registrarLog("Firebase não está inicializado!");
      return;
    }

    if (_controladorConteudo.text.isEmpty) {
      _registrarLog("O conteúdo não pode estar vazio!");
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemStatus = "Adicionando entrada ao diário...";
    });

    try {
      // Gerar um ID simples
      final String novoId = DateTime.now().millisecondsSinceEpoch.toString();

      _registrarLog("Criando entrada com ID: $novoId");

      final novaEntrada = DiaryEntry(
        id: novoId,
        title:
            _controladorTitulo.text.isNotEmpty
                ? _controladorTitulo.text
                : "Entrada de teste",
        content: _controladorConteudo.text,
        dateTime: DateTime.now(),
        mood: "neutro",
        tags: ["teste", "firebase"],
        isFavorite: false,
      );

      _registrarLog("Enviando dados para Firestore...");

      await FirebaseFirestore.instance
          .collection('entradas_diario')
          .doc(novaEntrada.id)
          .set({
            'title': novaEntrada.title,
            'content': novaEntrada.content,
            'dateTime': Timestamp.fromDate(novaEntrada.dateTime),
            'mood': novaEntrada.mood,
            'tags': novaEntrada.tags,
            'isFavorite': novaEntrada.isFavorite,
          });

      setState(() {
        _mensagemStatus = "Entrada adicionada com sucesso!";
        _controladorTitulo.clear();
        _controladorConteudo.clear();
      });

      _registrarLog("Entrada adicionada com sucesso!");

      // Atualizar a lista
      await _buscarEntradas();
    } catch (e) {
      setState(() {
        _mensagemStatus = "Erro ao adicionar entrada: $e";
        _registrarLog("ERRO ao adicionar: $e");
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste do Firebase')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de status
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _inicializado ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _mensagemStatus,
                style: TextStyle(
                  color: _inicializado ? Colors.green[800] : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botão conectar
            ElevatedButton(
              onPressed: _carregando ? null : _inicializarFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _inicializado
                    ? 'Atualizar entradas do diário'
                    : 'Conectar ao Firebase',
              ),
            ),
            const SizedBox(height: 20),

            // Formulário de entrada
            if (_inicializado) ...[
              TextField(
                controller: _controladorTitulo,
                decoration: const InputDecoration(
                  labelText: 'Título (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controladorConteudo,
                decoration: const InputDecoration(
                  labelText: 'Conteúdo*',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _carregando ? null : _adicionarEntrada,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Adicionar entrada'),
              ),
              const SizedBox(height: 20),
            ],

            // Lista de entradas
            Expanded(
              child:
                  _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : _entradas.isEmpty
                      ? const Center(child: Text('Nenhuma entrada encontrada'))
                      : ListView.builder(
                        itemCount: _entradas.length,
                        itemBuilder: (context, index) {
                          final entrada = _entradas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(entrada.title ?? 'Sem título'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entrada.content.length > 50
                                        ? '${entrada.content.substring(0, 50)}...'
                                        : entrada.content,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Data: ${entrada.dateTime.day}/${entrada.dateTime.month}/${entrada.dateTime.year}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Tags: ${entrada.tags.join(", ")}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing:
                                  entrada.isFavorite
                                      ? const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      )
                                      : null,
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
