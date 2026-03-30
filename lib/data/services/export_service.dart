import 'dart:io';
import 'package:excel/excel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import '../models/enums.dart';

class ExportService {

  /// Generates and shares a PDF report
  static Future<void> exportToPDF({
    required List<Transaction> transactions,
    required DateTime start,
    required DateTime end,
    required Map<String, double> categorySummary,
    required String currencySymbol,
  }) async {
    final pdf = pw.Document();
    
    // Load font for Turkish characters support
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) => [
          _buildHeader('reports.title'.tr(), start, end),
          pw.SizedBox(height: 20),
          _buildSummarySection(categorySummary, transactions, currencySymbol),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions, currencySymbol),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${'export.filename'.tr()}_${DateFormat('dd.MM.yyyy').format(start)}_${DateFormat('dd.MM.yyyy').format(end)}.pdf',
    );
  }

  /// Generates and shares an Excel file
  static Future<void> exportToExcel({
    required List<Transaction> transactions,
    required DateTime start,
    required DateTime end,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['export.filename'.tr()];
    
    // Header Row
    sheet.appendRow([
      TextCellValue('export.headers.date'.tr()),
      TextCellValue('export.headers.title'.tr()),
      TextCellValue('export.headers.category'.tr()),
      TextCellValue('export.headers.type'.tr()),
      TextCellValue('export.headers.amount'.tr()),
      TextCellValue('export.headers.status'.tr()),
    ]);

    for (var t in transactions) {
      sheet.appendRow([
        TextCellValue(DateFormat('dd.MM.yyyy HH:mm').format(t.date)),
        TextCellValue(t.title),
        TextCellValue(t.category),
        TextCellValue(t.type == TransactionType.income 
            ? 'transactions.income'.tr() 
            : (t.type == TransactionType.expense ? 'transactions.expense'.tr() : 'transactions.investment'.tr())),
        DoubleCellValue(t.amount),
        TextCellValue(t.isPaid ? 'export.status.paid'.tr() : 'export.status.pending'.tr()),
      ]);
    }

    final bytes = excel.save();
    if (bytes != null) {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${'export.filename'.tr()}_${DateFormat('dd.MM.yyyy').format(start)}.xlsx');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'export.share_text'.tr());
    }
  }

  /// Generates and shares a CSV file
  static Future<void> exportToCSV({
    required List<Transaction> transactions,
  }) async {
    String csv = '${'export.headers.date'.tr()},${'export.headers.title'.tr()},${'export.headers.category'.tr()},${'export.headers.type'.tr()},${'export.headers.amount'.tr()},${'export.headers.status'.tr()}\n';
    
    for (var t in transactions) {
      final type = t.type == TransactionType.income 
          ? 'transactions.income'.tr() 
          : (t.type == TransactionType.expense ? 'transactions.expense'.tr() : 'transactions.investment'.tr());
      csv += '${DateFormat('dd.MM.yyyy HH:mm').format(t.date)},"${t.title}",${t.category},$type,${t.amount},${t.isPaid ? 'export.status.paid'.tr() : 'export.status.pending'.tr()}\n';
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${'export.filename'.tr()}.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'export.share_text'.tr());
  }

  // --- PDF Helper Widgets ---

  static pw.Widget _buildHeader(String title, DateTime start, DateTime end) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.SizedBox(height: 4),
        pw.Text('export.period'.tr(namedArgs: {
          'start': DateFormat('dd.MM.yyyy').format(start),
          'end': DateFormat('dd.MM.yyyy').format(end)
        }), style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.Divider(thickness: 1, color: PdfColors.grey300, indent: 0, endIndent: 0),
      ],
    );
  }

  static pw.Widget _buildSummarySection(Map<String, double> categorySummary, List<Transaction> transactions, String currencySymbol) {
    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in transactions) {
      if (t.type == TransactionType.income) totalIncome += t.amount;
      if (t.type == TransactionType.expense) totalExpense += t.amount;
    }

    final currencyFormat = NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('export.summary_title'.tr(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSummaryBox('reports.total_income'.tr(), totalIncome, PdfColors.green900, currencyFormat),
            _buildSummaryBox('reports.total_expense'.tr(), totalExpense, PdfColors.red900, currencyFormat),
            _buildSummaryBox('reports.net_status'.tr(), totalIncome - totalExpense, (totalIncome - totalExpense) >= 0 ? PdfColors.blue900 : PdfColors.red900, currencyFormat),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text('export.category_dist'.tr(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...categorySummary.entries.map((e) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(e.key),
              pw.Text(currencyFormat.format(e.value), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        )),
      ],
    );
  }

  static pw.Widget _buildSummaryBox(String title, double amount, PdfColor color, NumberFormat format) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(format.format(amount), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionTable(List<Transaction> transactions, String currencySymbol) {
    final currencyFormat = NumberFormat.currency(symbol: currencySymbol, decimalDigits: 2);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('export.details_title'.tr(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            // Table Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('export.headers.date'.tr(), isHeader: true),
                _buildTableCell('export.headers.title'.tr(), isHeader: true),
                _buildTableCell('export.headers.category'.tr(), isHeader: true),
                _buildTableCell('export.headers.amount'.tr(), isHeader: true),
              ],
            ),
            // Table Rows
            ...transactions.map((t) => pw.TableRow(
              children: [
                _buildTableCell(DateFormat('dd.MM.yyyy').format(t.date)),
                _buildTableCell(t.title),
                _buildTableCell(t.category),
                _buildTableCell(
                  currencyFormat.format(t.amount),
                  color: t.type == TransactionType.income ? PdfColors.green900 : PdfColors.red900,
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }
}
