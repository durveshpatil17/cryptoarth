import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportGenerator {
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Backtest Report: $strategyName', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Win Rate: ${winRate.toStringAsFixed(2)}%', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Total P&L: \$${totalPnl.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text('Max Drawdown: \$${maxDrawdown.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 40),
              pw.Text('Powered by CryptoArth AI.', style: pw.TextStyle(color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: '${strategyName.replaceAll(' ', '_')}_backtest_report.pdf');
  }
}
