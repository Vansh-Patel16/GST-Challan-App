import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/client.dart';
import '../models/invoice_item.dart';
import '../models/business_info.dart';

Future<Uint8List> generateInvoicePDF({
  required BusinessInfo? businessInfo,
  required Client client,
  required List<InvoiceItem> items,
  required double gst,
  required double total,
}) async {
  final pdf = pw.Document();
  final font = await PdfGoogleFonts.robotoRegular();
  final bold = await PdfGoogleFonts.robotoBold();

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    build: (context) => [
      if (businessInfo != null) ...[
        pw.Text(businessInfo.companyName, style: pw.TextStyle(font: bold, fontSize: 18)),
        pw.Text(businessInfo.address, style: pw.TextStyle(font: font, fontSize: 10)),
        pw.Text('GSTIN: ${businessInfo.gstNo}', style: pw.TextStyle(font: font, fontSize: 10)),
        pw.Text('Contact: ${businessInfo.contact}', style: pw.TextStyle(font: font, fontSize: 10)),
        pw.Divider(),
      ],
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('TAX INVOICE', style: pw.TextStyle(font: bold, fontSize: 22)),
          pw.Text('Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
              style: pw.TextStyle(font: font)),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To:', style: pw.TextStyle(font: bold)),
                pw.Text(client.name, style: pw.TextStyle(font: font)),
                pw.Text(client.address, style: pw.TextStyle(font: font)),
                pw.Text('GSTIN: ${client.gstNo}', style: pw.TextStyle(font: font)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.TableHelper.fromTextArray(
        headers: ['Product', 'Qty', 'Rate', 'GST%', 'Total'],
        data: items.map((i) => [
          i.productName,
          i.qty.toString(),
          i.rate.toStringAsFixed(2),
          i.gstRate.toStringAsFixed(2),
          (i.qty * i.rate * (1 + i.gstRate / 100)).toStringAsFixed(2)
        ]).toList(),
        headerStyle: pw.TextStyle(font: bold),
        cellStyle: pw.TextStyle(font: font),
      ),
      pw.SizedBox(height: 20),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Sub-Total: ₹${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(font: font)),
              pw.Text('GST Amount: ₹${gst.toStringAsFixed(2)}',
                  style: pw.TextStyle(font: font)),
              pw.Divider(),
              pw.Text('Grand Total: ₹${(total + gst).toStringAsFixed(2)}',
                  style: pw.TextStyle(font: bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    ],
  ));
  return pdf.save();
}

Future<Uint8List> generateChallanPDF({
  required BusinessInfo? businessInfo,
  required Client client,
  required List<InvoiceItem> items,
}) async {
  final pdf = pw.Document();
  final font = await PdfGoogleFonts.robotoRegular();
  final bold = await PdfGoogleFonts.robotoBold();

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    build: (context) => [
      if (businessInfo != null) ...[
        pw.Text(businessInfo.companyName, style: pw.TextStyle(font: bold, fontSize: 18)),
        pw.Text(businessInfo.address, style: pw.TextStyle(font: font, fontSize: 10)),
        pw.Text('Contact: ${businessInfo.contact}', style: pw.TextStyle(font: font, fontSize: 10)),
        pw.Divider(),
      ],
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('DELIVERY CHALLAN', style: pw.TextStyle(font: bold, fontSize: 22)),
          pw.Text('Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
              style: pw.TextStyle(font: font)),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Consignee:', style: pw.TextStyle(font: bold)),
                pw.Text(client.name, style: pw.TextStyle(font: font)),
                pw.Text(client.address, style: pw.TextStyle(font: font)),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.TableHelper.fromTextArray(
        headers: ['Product', 'Quantity'],
        data: items.map((i) => [
          i.productName,
          i.qty.toString(),
        ]).toList(),
        headerStyle: pw.TextStyle(font: bold),
        cellStyle: pw.TextStyle(font: font),
      ),
      pw.SizedBox(height: 40),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Receiver\'s Signature', style: pw.TextStyle(font: font)),
          pw.Text('Authorised Signatory', style: pw.TextStyle(font: font)),
        ],
      ),
    ],
  ));
  return pdf.save();
}