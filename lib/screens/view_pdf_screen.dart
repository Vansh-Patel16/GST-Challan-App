import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ViewPdfScreen extends StatelessWidget {
  final String invoicePath;
  final String challanPath;

  const ViewPdfScreen({
    super.key,
    required this.invoicePath,
    required this.challanPath,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Preview'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Invoice'),
              Tab(text: 'Challan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PdfPreview(
              build: (format) => File(invoicePath).readAsBytes(),
              allowSharing: true,
              allowPrinting: true,
            ),
            PdfPreview(
              build: (format) => File(challanPath).readAsBytes(),
              allowSharing: true,
              allowPrinting: true,
            ),
          ],
        ),
      ),
    );
  }
}
