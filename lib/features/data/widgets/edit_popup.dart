import 'package:flutter/material.dart';

class EditPopup extends StatefulWidget {
  final Map<dynamic, dynamic> row;
  final String face;
  final Function(String?, Map<dynamic, dynamic>, String) onEdit;
  final Function(Map<dynamic, dynamic>, BuildContext) onDelete;

  EditPopup({
    required this.row,
    required this.face,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _EditPopupState createState() => _EditPopupState();
}

class _EditPopupState extends State<EditPopup> {
  late TextEditingController _textController;
  String? _newText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.row[widget.face]);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier un mot'),
      content: TextField(
        controller: _textController,
        onChanged: (String value) {
          _newText = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onEdit(_newText, widget.row, widget.face);
            Navigator.of(context).pop();
          },
          child: const Text('Modifier'),
        ),
        TextButton(
          onPressed: () {
            widget.onDelete(widget.row, context);
          },
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}