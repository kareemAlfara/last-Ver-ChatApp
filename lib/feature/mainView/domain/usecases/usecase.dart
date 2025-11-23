import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PDFViewerPage extends StatelessWidget {
  final String filePath;
  const PDFViewerPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfController(
      document: PdfDocument.openFile(filePath),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: PdfView(
        controller: pdfController,
      ),
    );
  }
}
