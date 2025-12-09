import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/checklist_model.dart';
import 'dart:io';

class PdfGenerator {
  static Future<void> generateAndShare(
      List<ChecklistItem> items, String vehicleId, String driverName) async {
    final pdf = pw.Document();
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Load font if necessary, but standard is fine for basic text
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(vehicleId, driverName, date),
            pw.SizedBox(height: 20),
            _buildTable(items),
            pw.SizedBox(height: 20),
            pw.Text("Assinatura do Responsável:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 40),
            pw.Divider(),
          ];
        },
      ),
    );

    // Add a page for photos if any exist
    final itemsWithPhotos = items.where((i) => i.imagePath != null).toList();
    if (itemsWithPhotos.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 1, text: "Anexos Fotográficos"),
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: itemsWithPhotos.map((item) {
                return pw.Container(
                  width: 200,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      // Note: In a real app, we need to handle image loading carefully.
                      // Since we can't easily pass File objects to PDF in web preview without extra work,
                      // we will show a placeholder text if image loading fails or just the logic.
                      // For this demo, we assume local file path works (mobile).
                      pw.Container(
                        height: 150,
                        width: 200,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Center(child: pw.Text("Foto: ${item.title}")), 
                        // To actually render image: pw.Image(pw.MemoryImage(File(item.imagePath!).readAsBytesSync()))
                      ),
                      pw.Text(item.comment ?? "Sem observações", style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            )
          ],
        ),
      );
    }

    // Share the PDF
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'checklist_ambulancia_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  static pw.Widget _buildHeader(String vehicleId, String driverName, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Relatório de Inspeção - Ambulância",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text("Viatura: $vehicleId"),
          pw.Text("Data: $date"),
        ]),
        pw.Text("Condutor/Responsável: $driverName"),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildTable(List<ChecklistItem> items) {
    return pw.Table.fromTextArray(
      headers: ['Item', 'Status', 'Observações'],
      data: items.map((item) {
        return [
          item.title,
          item.isChecked ? 'OK' : 'PENDENTE/FALHA',
          item.comment ?? ''
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }
}
