import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreIsolatedList<T> extends StatefulWidget {
  final String collectionPath;
  final Query Function(CollectionReference)? queryBuilder;
  final Widget Function(BuildContext, DocumentReference, String) itemBuilder;
  final Widget? emptyBuilder;
  final Widget? loadingBuilder;
  final Widget? errorBuilder;
  final EdgeInsetsGeometry? padding;
  final double? itemSpacing;
  final ScrollPhysics? physics;

  const FirestoreIsolatedList({
    required this.collectionPath,
    required this.itemBuilder,
    this.queryBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.padding,
    this.itemSpacing = 8.0,
    this.physics,
    Key? key,
  }) : super(key: key);

  @override
  State<FirestoreIsolatedList<T>> createState() =>
      FirestoreIsolatedListState<T>();
}

class FirestoreIsolatedListState<T> extends State<FirestoreIsolatedList<T>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _documentIds = [];
  bool _isLoading = true;
  String? _error;
  bool _hasLoadedIds = false;

  @override
  void initState() {
    super.initState();
    _loadDocumentIds();
  }

  @override
  void didUpdateWidget(covariant FirestoreIsolatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.collectionPath != widget.collectionPath ||
        oldWidget.queryBuilder != widget.queryBuilder) {
      _loadDocumentIds();
    }
  }

  /// Método público para forçar a recarga dos IDs
  /// Esta é a adição chave para resolver o problema
  void reloadIds() {
    _loadDocumentIds();
  }

  Future<void> _loadDocumentIds() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cria a query base na coleção
      CollectionReference collection = _firestore.collection(
        widget.collectionPath,
      );

      // Aplica modificadores de query se fornecidos
      Query query =
          widget.queryBuilder != null
              ? widget.queryBuilder!(collection)
              : collection;

      // Executa a query para obter apenas IDs uma vez
      final snapshot = await query.get();

      setState(() {
        _documentIds = snapshot.docs.map((doc) => doc.id).toList();
        _hasLoadedIds = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Erro ao carregar IDs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estado de carregamento
    if (_isLoading) {
      return widget.loadingBuilder ??
          const Center(child: CircularProgressIndicator());
    }

    // Estado de erro
    if (_error != null) {
      return widget.errorBuilder ?? Center(child: Text('Erro: $_error'));
    }

    // Lista vazia
    if (_documentIds.isEmpty) {
      return widget.emptyBuilder ??
          const Center(child: Text('Nenhum item encontrado'));
    }

    // Lista com itens isolados
    return ListView.builder(
      padding: widget.padding ?? const EdgeInsets.all(16),
      physics: widget.physics,
      itemCount: _documentIds.length,
      itemBuilder: (context, index) {
        final id = _documentIds[index];
        final docRef = _firestore.collection(widget.collectionPath).doc(id);

        return Padding(
          padding: EdgeInsets.only(bottom: widget.itemSpacing ?? 0),
          child: widget.itemBuilder(context, docRef, id),
        );
      },
    );
  }
}

class IsolatedFirestoreItem extends StatefulWidget {
  final DocumentReference documentRef;
  final Widget Function(BuildContext, Map<String, dynamic>, String) builder;
  final Map<String, dynamic> Function(Map<String, dynamic>)? dataTransformer;
  final Widget? loadingBuilder;
  final Widget? errorBuilder;

  const IsolatedFirestoreItem({
    required this.documentRef,
    required this.builder,
    this.dataTransformer,
    this.loadingBuilder,
    this.errorBuilder,
    Key? key,
  }) : super(key: key);

  @override
  State<IsolatedFirestoreItem> createState() => _IsolatedFirestoreItemState();
}

class _IsolatedFirestoreItemState extends State<IsolatedFirestoreItem> {
  int _rebuildCount = 0;

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;

    return StreamBuilder<DocumentSnapshot>(
      stream: widget.documentRef.snapshots(),
      builder: (context, snapshot) {
        // Estado de carregamento
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return widget.loadingBuilder ??
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
        }

        // Estado de erro
        if (snapshot.hasError || !snapshot.hasData) {
          return widget.errorBuilder ??
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Erro: ${snapshot.error ?? "Documento não encontrado"}',
                  ),
                ),
              );
        }

        // Documento existe e tem dados
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return const SizedBox.shrink(); // Documento foi excluído
        }

        // Transforma dados se necessário
        final processedData =
            widget.dataTransformer != null
                ? widget.dataTransformer!(Map<String, dynamic>.from(data))
                : Map<String, dynamic>.from(data);

        // Constrói o widget com contador de rebuilds para debug
        return Stack(
          children: [
            // Widget principal
            widget.builder(context, processedData, snapshot.data!.id),

            // DEBUG: Contador de rebuilds
            if (kDebugMode)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$_rebuildCount',
                    style: const TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
