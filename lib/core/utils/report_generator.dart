import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cryptoarth/core/network/api_client.dart';

class ReportGenerator {
  static final ApiClient _apiClient = ApiClient();

  static Future<void> downloadPdfFromUrl(String url, String filename) async {
    try {
      // Use ApiClient to get auth headers automatically
      final response = await _apiClient.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.statusCode == 200) {
        // If the response is already bytes (depends on how ApiClient is used)
        // Extract from dynamic response data
        final Uint8List data;
        if (response.data is Uint8List) {
          data = response.data;
        } else if (response.data is List<int>) {
          data = Uint8List.fromList(response.data);
        } else {
           // Fallback for cases where it might be returned as string or other
           throw Exception("PDF download returned non-binary data");
        }
        await Printing.sharePdf(bytes: data, filename: filename);
      } else {
        throw Exception("Failed to download file: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error downloading PDF: $e");
    }
  }

  static Future<void> downloadPnLReport(double totalPnl, double todayPnl, int trades) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('CryptoArth P&L Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Total P&L: \$${totalPnl.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Today P&L: \$${todayPnl.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Total Trades: $trades', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 40),
              pw.Text('Detailed summary is generated dynamically by CryptoArth AI.', style: pw.TextStyle(color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'cryptoarth_pnl_report.pdf');
  }

  static Future<void> downloadBacktestReport(String strategyName, double winRate, double totalPnl, double maxDrawdown) async {
    final pdf = pw.Document();
    final primaryColor = PdfColor.fromInt(0xFF00E5FF); // App Cyan

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('CRYPTOARTH', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    pw.Text('BACKTEST REPORT', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2, color: primaryColor),
                pw.SizedBox(height: 24),

                // Strategy Title
                pw.Text('Strategy: $strategyName', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Generated on: ${DateTime.now().toString().split('.')[0]}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.SizedBox(height: 32),

                // Key Performance Indicators (Grid)
                pw.Row(
                  children: [
                    _buildMetricBox("Total P&L", "\$${totalPnl.toStringAsFixed(2)}", totalPnl >= 0 ? PdfColors.green : PdfColors.red),
                    pw.SizedBox(width: 20),
                    _buildMetricBox("Win Rate", "${winRate.toStringAsFixed(2)}%", primaryColor),
                    pw.SizedBox(width: 20),
                    _buildMetricBox("Max Drawdown", "\$${maxDrawdown.toStringAsFixed(2)}", PdfColors.red),
                  ],
                ),
                pw.SizedBox(height: 40),

                // Strategy Analysis Section
                pw.Text('Performance Analysis', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(
                    "This strategy has demonstrated a ${winRate > 50 ? 'stable' : 'volatile'} win rate of ${winRate.toStringAsFixed(2)}%. "
                    "With a total profitability of \$${totalPnl.toStringAsFixed(2)}, the risk-to-reward ratio suggests "
                    "${totalPnl > 0 ? 'positive expected value' : 'need for optimization'}. "
                    "The maximum drawdown of \$${maxDrawdown.toStringAsFixed(2)} should be monitored against your account capital.",
                    style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                  ),
                ),
                
                pw.Spacer(),
                
                // Footer
                pw.Divider(color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('CONFIDENTIAL - CryptoArth AI Internal Report', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                    pw.Text('Page 1 of 1', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: '${strategyName.replaceAll(' ', '_')}_backtest_report.pdf');
  }

  static Future<void> generateBacktestPdf(dynamic result) async {
    // result is expected to be a BacktestModel
    final String name = result.strategyName ?? result.strategyCode ?? "AI Strategy";
    final double winRate = (result.winRate ?? 0).toDouble();
    final double pnl = (result.pnl ?? 0).toDouble();
    final double drawdown = (result.drawdown ?? 0).toDouble();
    
    await downloadBacktestReport(name, winRate, pnl, drawdown);
  }

  static pw.Widget _buildMetricBox(String label, String value, PdfColor color) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  static Future<void> downloadTextFile(String content, String filename) async {
    final bytes = Uint8List.fromList(content.codeUnits);
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
