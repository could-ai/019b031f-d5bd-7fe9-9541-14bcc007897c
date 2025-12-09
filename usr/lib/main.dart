import 'package:flutter/material.dart';
import 'models/checklist_model.dart';
import 'screens/inspection_screen.dart';
import 'screens/template_editor_screen.dart';

void main() {
  runApp(const AmbulanceApp());
}

class AmbulanceApp extends StatelessWidget {
  const AmbulanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist Ambulância',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Default Template
  List<ChecklistItem> template = [
    ChecklistItem(id: '1', title: 'Giroflex e Sirene'),
    ChecklistItem(id: '2', title: 'Faróis e Setas'),
    ChecklistItem(id: '3', title: 'Nível de Óleo do Motor'),
    ChecklistItem(id: '4', title: 'Nível de Água (Radiador)'),
    ChecklistItem(id: '5', title: 'Pneus e Estepe'),
    ChecklistItem(id: '6', title: 'Freios'),
    ChecklistItem(id: '7', title: 'Cilindro de Oxigênio (Cheio)'),
    ChecklistItem(id: '8', title: 'Maleta de Primeiros Socorros'),
    ChecklistItem(id: '9', title: 'Desfibrilador (Bateria OK)'),
    ChecklistItem(id: '10', title: 'Maca Retrátil'),
    ChecklistItem(id: '11', title: 'Limpeza Interna'),
  ];

  void _updateTemplate(List<ChecklistItem> newTemplate) {
    setState(() {
      template = newTemplate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Viatura'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.medical_services_outlined, size: 100, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                'Controle de Frota',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 40),
              _buildMenuButton(
                context,
                icon: Icons.add_task,
                label: 'INICIAR INSPEÇÃO',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InspectionScreen(template: template),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                icon: Icons.edit_note,
                label: 'EDITAR CHECKLIST',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TemplateEditorScreen(
                        currentTemplate: template,
                        onSave: _updateTemplate,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
