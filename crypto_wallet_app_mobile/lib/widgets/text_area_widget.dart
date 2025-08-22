import 'package:flutter/material.dart';

class TextAreaWidget extends StatefulWidget {
  final String? initialText;
  final bool isEditable;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const TextAreaWidget({
    super.key,
    this.initialText,
    this.isEditable = false,
    this.onChanged,
    this.controller,
  });

  @override
  State<TextAreaWidget> createState() => _TextAreaWidgetState();
}

class _TextAreaWidgetState extends State<TextAreaWidget> {
  late final TextEditingController _localController;
  late List<String> _words;

  @override
  void initState() {
    super.initState();
    _localController = widget.controller ?? TextEditingController();

    if (widget.isEditable) {
      _words = [];
    } else {
      _words = widget.initialText?.split(' ') ?? [];
      _localController.text = widget.initialText ?? '';
    }
  }

  @override
  void didUpdateWidget(covariant TextAreaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditable && widget.isEditable) {
      setState(() {
        _words.clear();
        _localController.clear();
      });
    } else if (!widget.isEditable) {
      _words = widget.initialText?.split(' ') ?? [];
      _localController.text = widget.initialText ?? '';
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _localController.dispose();
    super.dispose();
  }

  void _handleInput(String value) {
    if (widget.isEditable && value.endsWith(' ')) {
      final word = value.trim();
      if (word.isNotEmpty) {
        setState(() {
          _words.add(word);
        });
        _localController.clear();
        widget.onChanged?.call(_words.join(' '));
      }
    } else {
      widget.onChanged?.call(value);
    }
  }

  void _removeWord(int index) {
    if (!widget.isEditable) return;
    setState(() {
      _words.removeAt(index);
    });
    widget.onChanged?.call(_words.join(' '));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: 120,
            maxHeight: screenHeight * 0.35,
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white54),
          ),
          child: GridView.builder(
            itemCount: _words.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              final word = "${index + 1}. ${_words[index]}";

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(210, 176, 217, 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          word,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    if (widget.isEditable)
                      GestureDetector(
                        onTap: () => _removeWord(index),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.close, size: 10),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        if (widget.isEditable)
          TextField(
            controller: _localController,
            onChanged: _handleInput,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type a word and press space...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey.shade900,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
      ],
    );
  }
}
