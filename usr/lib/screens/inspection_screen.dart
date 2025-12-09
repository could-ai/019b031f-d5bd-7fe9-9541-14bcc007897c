import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/checklist_model.dart';
import '../utils/pdf_generator.dart';

class InspectionScreen extends StatefulWidget {
  final List<ChecklistItem> template;

  const InspectionScreen({super.key, required this.template});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  late List<ChecklistItem> _items;
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _driverController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Clone template for this specific inspection
    _items = widget.template.map((e) => e.clone()).toList();
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _items[index].imagePath = photo.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir câmera: $e')),
      );
    }
  }

  void _showCommentDialog(int index) {
    final controller = TextEditingController(text: _items[index].comment);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Observação para ${_items[index].title}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Digite o problema ou observação...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items[index].comment = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishInspection() async {
    if (_vehicleController.text.isEmpty || _driverController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha a Viatura e o Condutor.')),
      );
      return;
    }

    // Generate PDF
    await PdfGenerator.generateAndShare(
      _items,
      _vehicleController.text,
      _driverController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Inspeção'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: 'Gerar PDF e Enviar',
            onPressed: _finishInspection,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _vehicleController,
                      decoration: const InputDecoration(
                        labelText: 'Identificação da Viatura (Placa/Prefixo)',
                        prefixIcon: Icon(Icons.ambulance),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _driverController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Condutor/Socorrista',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (ctx, i) => const Divider(),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: Checkbox(
                    value: item.isChecked,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        item.isChecked = val ?? false;
                      });
                    },
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      decoration: item.isChecked ? null : TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.comment != null && item.comment!.isNotEmpty)
                        Text("Obs: ${item.comment}", style: const TextStyle(color: Colors.red)),
                      if (item.imagePath != null)
                        const Text("📷 Foto anexada", style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera_alt, 
                          color: item.imagePath != null ? Colors.blue : Colors.grey),
                        onPressed: () => _pickImage(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.comment,
                          color: (item.comment != null && item.comment!.isNotEmpty) ? Colors.red : Colors.grey),
                        onPressed: () => _showCommentDialog(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _finishInspection,
        label: const Text('Finalizar e Enviar'),
        icon: const Icon(Icons.picture_as_pdf),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
