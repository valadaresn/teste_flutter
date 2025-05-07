import 'package:flutter/material.dart';

class ExpandableGroup extends StatefulWidget {
  // Mapa estático para armazenar o estado de expansão de cada grupo
  static final Map<String, bool> _expandedStates = {};

  final String title;
  final String? count;
  final List<Widget> children;
  final bool initiallyExpanded;

  const ExpandableGroup({
    super.key,
    required this.title,
    this.count,
    required this.children,
    this.initiallyExpanded = true,
  });

  @override
  State<ExpandableGroup> createState() => _ExpandableGroupState();
}

class _ExpandableGroupState extends State<ExpandableGroup> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Verifica se já existe um estado salvo para este grupo
    if (ExpandableGroup._expandedStates.containsKey(widget.title)) {
      _isExpanded = ExpandableGroup._expandedStates[widget.title]!;
    } else {
      // Usa o valor inicial apenas na primeira vez
      _isExpanded = widget.initiallyExpanded;
      ExpandableGroup._expandedStates[widget.title] = _isExpanded;
    }
  }

  @override
  void didUpdateWidget(ExpandableGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Não resetamos o _isExpanded aqui para manter o estado
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              // Atualiza o mapa estático quando o estado muda
              ExpandableGroup._expandedStates[widget.title] = _isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (widget.count != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.count!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const Spacer(),
                RotatedBox(
                  quarterTurns: _isExpanded ? 1 : 3,
                  child: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
      ],
    );
  }
}
