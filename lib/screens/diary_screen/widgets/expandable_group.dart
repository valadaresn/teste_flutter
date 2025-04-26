import 'package:flutter/material.dart';

class ExpandableGroup extends StatefulWidget {
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
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.expand_more : Icons.chevron_right,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                if (widget.count != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.count!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(children: widget.children),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _isExpanded 
              ? CrossFadeState.showFirst 
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}