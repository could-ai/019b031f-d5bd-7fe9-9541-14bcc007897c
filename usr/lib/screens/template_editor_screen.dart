import 'package:flutter/material.dart';
import '../models/checklist_model.dart';

class TemplateEditorScreen extends StatefulWidget {
  final List<ChecklistItem> currentTemplate;
  final Function(List<ChecklistItem>) onSave;

  const TemplateEditorScreen({
    super.key,
    required this.currentTemplate,
    required this.onSave,
  });

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  late List<ChecklistItem> _items;
  final TextEditingController _newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Create a copy to edit
    _items = widget.currentTemplate.map((e) => e.clone()).toList();
  }

  void _addItem() {
    if (_newItemController.text.isNotEmpty) {
      setState(() {
        _items.add(ChecklistItem(
          id: DateTime.now().toString(),
          title: _newItemController.text,
        ));
        _newItemController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _saveAndExit() {
    widget.onSave(_items);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Modelo de Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAndExit,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    decoration: const InputDecoration(
                      labelText: 'Novo Item (ex: Extintor)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _items.length; i++)
                  ListTile(
                    key: ValueKey(_items[i].id),
                    title: Text(_items[i].title),
                    leading: const Icon(Icons.drag_handle),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeItem(i),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
