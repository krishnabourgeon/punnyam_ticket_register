import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a single denomination column (e.g. ഗണപതിഹോമം, സഹസ്രനാമം, …)
class _DenomCol {
  final String label; // Malayalam/English label shown in header
  final String key; // map key used in _DlrEntry.counts

  const _DenomCol({required this.label, required this.key});
}

/// One data row in the register (Receipt or Issue transaction)
class _DlrEntry {
  final int slno;
  final DateTime date;
  final String item; // e.g. "ഡോർ", "Sp പൂജ്യഞ്ചലി", "പൂജ്യഞ്ചലി"
  final String temple; // e.g. "Ac office-BNo-1"
  final int fromNo;
  final int toNo;
  final Map<String, int> counts; // keyed by _DenomCol.key
  final int total;
  final _EntryType type;

  const _DlrEntry({
    required this.slno,
    required this.date,
    required this.item,
    required this.temple,
    required this.fromNo,
    required this.toNo,
    required this.counts,
    required this.total,
    required this.type,
  });
}

enum _EntryType { receipt, issue }

// ─────────────────────────────────────────────────────────────────────────────
// DOUBLE LOCK REGISTER SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class DoubleLockRegisterScreen extends StatefulWidget {
  const DoubleLockRegisterScreen({super.key});

  @override
  State<DoubleLockRegisterScreen> createState() =>
      _DoubleLockRegisterScreenState();
}

class _DoubleLockRegisterScreenState extends State<DoubleLockRegisterScreen> {
  // ── Palette (matches rest of app) ─────────────────────────────────────────
  static const _accent = Color(0xFF6D1A1A);
  static const _saffron = Color(0xFFC17D26);
  static const _text = Color(0xFF222222);
  static const _muted = Color(0xFF8A8A8A);
  static const _border = Color(0xFFE0E0E0);
  static const _headerBg = Color(0xFF6D1A1A);
  static const _subHeaderBg = Color(0xFFF5F0EB);
  static const _stripeBg = Color(0xFFFAFAFA);
  static const _receiptSectionBg = Color(0xFFEEF4EE);
  static const _issueSectionBg = Color(0xFFEEEEF8);
  static const _totalRowBg = Color(0xFFF5F0EB);
  static const _balanceRowBg = Color(0xFFFFF8EE);

  // ── Denomination columns ───────────────────────────────────────────────────
  static const List<_DenomCol> _cols = [
    _DenomCol(label: 'ഗണപതി\nഹോമം', key: 'ganapathi'),
    _DenomCol(label: 'സഹസ്ര\nനാമം', key: 'sahasra'),
    _DenomCol(label: 'അഷ്ടോ\nത്തരം', key: 'ashtothram'),
    _DenomCol(label: 'പ്രദോ\nഷം', key: 'pradosham'),
    _DenomCol(label: 'അഭി\nഷേകം', key: 'abhishekam'),
    _DenomCol(label: 'ദീപ\nആരാ', key: 'deepa'),
    _DenomCol(label: 'മറ്റു\nള്ളവ', key: 'others'),
  ];

  // ── Date range ─────────────────────────────────────────────────────────────
  late DateTime _from;
  late DateTime _to;
  bool _isDownloading = false;

  // ── Sample data ───────────────────────────────────────────────────────────
  // In a real app this comes from Provider/API filtered by date range.
  late List<_DlrEntry> _receipts;
  late List<_DlrEntry> _issues;

  // Opening balance (counts per denomination)
  final Map<String, int> _openingBalance = {
    'ganapathi': 6,
    'sahasra': 9,
    'ashtothram': 3,
    'pradosham': 9,
    'abhishekam': 5,
    'deepa': 0,
    'others': 5,
  };

  @override
  void initState() {
    super.initState();
    _from = DateTime(2026, 6, 1);
    _to = DateTime(2026, 6, 18);
    _loadData();
  }

  void _loadData() {
    _receipts = [
      _DlrEntry(
        slno: 1,
        date: DateTime(2026, 6, 18),
        item: 'ഡോർ',
        temple: 'Ac office-BNo-1',
        fromNo: 1,
        toNo: 100,
        counts: {
          'ganapathi': 0,
          'sahasra': 0,
          'ashtothram': 0,
          'pradosham': 0,
          'abhishekam': 0,
          'deepa': 1,
          'others': 0,
        },
        total: 1,
        type: _EntryType.receipt,
      ),
      _DlrEntry(
        slno: 2,
        date: DateTime(2026, 6, 18),
        item: 'Sp പൂജ്യഞ്ചലി',
        temple: 'Ac office-BNo-1-2',
        fromNo: 1,
        toNo: 2000,
        counts: {
          'ganapathi': 0,
          'sahasra': 2,
          'ashtothram': 0,
          'pradosham': 0,
          'abhishekam': 0,
          'deepa': 0,
          'others': 0,
        },
        total: 2,
        type: _EntryType.receipt,
      ),
      _DlrEntry(
        slno: 3,
        date: DateTime(2026, 6, 18),
        item: 'Sp പൂജ്യഞ്ചലി',
        temple: 'Ac office-BNo-1-6',
        fromNo: 1,
        toNo: 6000,
        counts: {
          'ganapathi': 0,
          'sahasra': 6,
          'ashtothram': 0,
          'pradosham': 0,
          'abhishekam': 0,
          'deepa': 0,
          'others': 0,
        },
        total: 6,
        type: _EntryType.receipt,
      ),
      _DlrEntry(
        slno: 4,
        date: DateTime(2026, 6, 18),
        item: 'പൂജ്യഞ്ചലി',
        temple: 'Ac office-BNo-1-10',
        fromNo: 1,
        toNo: 10000,
        counts: {
          'ganapathi': 10,
          'sahasra': 0,
          'ashtothram': 0,
          'pradosham': 0,
          'abhishekam': 0,
          'deepa': 0,
          'others': 0,
        },
        total: 10,
        type: _EntryType.receipt,
      ),
    ];

    _issues = [
      _DlrEntry(
        slno: 55,
        date: DateTime(2026, 6, 18),
        item: 'പൂജ്യഞ്ചലി',
        temple: 'temple1-BNo-1',
        fromNo: 1,
        toNo: 1000,
        counts: {
          'ganapathi': 1,
          'sahasra': 0,
          'ashtothram': 0,
          'pradosham': 0,
          'abhishekam': 0,
          'deepa': 0,
          'others': 0,
        },
        total: 1,
        type: _EntryType.issue,
      ),
      _DlrEntry(
        slno: 56,
        date: DateTime(2026, 6, 18),
        item: 'പൂജ്യഞ്ചലി',
        temple: 'temple1-BNo-2',
        fromNo: 1001,
        toNo: 2000,
        counts: {
          'ganapathi': 1,
          'sahasra': 0,
          'ashtothram': 0,
          'pradosham': 0,
          'abhishekam': 0,
          'deepa': 0,
          'others': 0,
        },
        total: 1,
        type: _EntryType.issue,
      ),
      _DlrEntry(
        slno: 57,
        date: DateTime(2026, 6, 18),
        item: 'പൂജ്യഞ്ചലി',
        temple: 'temple2-BNo-3',
        fromNo: 2001,
        toNo: 3000,
        counts: {
          'ganapathi': 1,
          'sahasra': 0,
          'ashtothram': 0,
          'pradosham': 0,
          'abhishekam': 0,
          'deepa': 0,
          'others': 0,
        },
        total: 1,
        type: _EntryType.issue,
      ),
    ];
  }

  // ── Computed totals ────────────────────────────────────────────────────────
  Map<String, int> _sumCounts(List<_DlrEntry> entries) {
    final result = <String, int>{};
    for (final col in _cols) {
      result[col.key] = entries.fold(0, (s, e) => s + (e.counts[col.key] ?? 0));
    }
    return result;
  }

  Map<String, int> _addMaps(Map<String, int> a, Map<String, int> b) {
    final result = <String, int>{};
    for (final col in _cols) {
      result[col.key] = (a[col.key] ?? 0) + (b[col.key] ?? 0);
    }
    return result;
  }

  Map<String, int> _subtractMaps(Map<String, int> a, Map<String, int> b) {
    final result = <String, int>{};
    for (final col in _cols) {
      result[col.key] = (a[col.key] ?? 0) - (b[col.key] ?? 0);
    }
    return result;
  }

  int _totalOf(Map<String, int> m) => m.values.fold(0, (s, v) => s + v);

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _accent)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
        _loadData(); // re-fetch filtered data
      });
    }
  }

  // ── PDF export ─────────────────────────────────────────────────────────────
  Future<void> _exportPdf() async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await _buildPdf();
      final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'double_lock_register_$ts.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed: $e',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<Uint8List> _buildPdf() async {
    final font = await PdfGoogleFonts.robotoRegular();
    final bold = await PdfGoogleFonts.robotoBold();
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: bold),
    );

    const pdfPrimary = PdfColor.fromInt(0xFF6D1A1A);
    const pdfSaffron = PdfColor.fromInt(0xFFC17D26);
    const pdfWhite = PdfColors.white;
    const pdfBorder = PdfColor.fromInt(0xFFE0E0E0);
    const pdfText = PdfColor.fromInt(0xFF222222);
    const pdfMuted = PdfColor.fromInt(0xFF8A8A8A);
    const pdfStripeBg = PdfColor.fromInt(0xFFFAFAFA);
    const pdfReceiptBg = PdfColor.fromInt(0xFFEEF4EE);
    const pdfIssueBg = PdfColor.fromInt(0xFFEEEEF8);
    const pdfBalanceBg = PdfColor.fromInt(0xFFFFF8EE);
    const pdfTotalBg = PdfColor.fromInt(0xFFF5F0EB);

    final receiptTotal = _sumCounts(_receipts);
    final issueTotal = _sumCounts(_issues);
    final afterReceiptBalance = _addMaps(_openingBalance, receiptTotal);
    final closingBalance = _subtractMaps(afterReceiptBalance, issueTotal);

    final dateRange =
        '${DateFormat('dd MMM yyyy').format(_from)} – ${DateFormat('dd MMM yyyy').format(_to)}';

    // Column widths
    final colWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(28), // slno
      1: const pw.FixedColumnWidth(52), // date
      2: const pw.FixedColumnWidth(70), // item
      3: const pw.FixedColumnWidth(74), // temple
      4: const pw.FixedColumnWidth(34), // fromno
      5: const pw.FixedColumnWidth(40), // tono
    };
    for (int i = 0; i < _cols.length; i++) {
      colWidths[6 + i] = const pw.FixedColumnWidth(28);
    }
    colWidths[6 + _cols.length] = const pw.FixedColumnWidth(28); // total

    List<String> headers = [
      'Sl',
      'Date',
      'Item',
      'Temple',
      'From',
      'To',
      ..._cols.map((c) => c.label.replaceAll('\n', ' ')),
      'Total',
    ];

    pw.TableRow makeRow(
      List<String> cells, {
      PdfColor? bg,
      bool bold = false,
      PdfColor textColor = pdfText,
      bool isHeader = false,
    }) {
      return pw.TableRow(
        decoration: pw.BoxDecoration(color: bg ?? pdfWhite),
        children: cells.map((c) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            child: pw.Text(
              c,
              style: pw.TextStyle(
                color: isHeader ? pdfWhite : textColor,
                fontSize: isHeader ? 6.5 : 7,
                fontWeight: bold || isHeader
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      );
    }

    String fmtDate(DateTime d) => DateFormat('dd-MM-yy').format(d);
    List<String> entryRow(_DlrEntry e) => [
      '${e.slno}',
      fmtDate(e.date),
      e.item,
      e.temple,
      '${e.fromNo}',
      '${e.toNo}',
      ..._cols.map((c) {
        final v = e.counts[c.key] ?? 0;
        return v == 0 ? '' : '$v';
      }),
      '${e.total}',
    ];
    List<String> sumRow(
      Map<String, int> m,
      String label, {
      String prefix = '',
    }) => [
      '',
      '',
      label,
      prefix,
      '',
      '',
      ..._cols.map((c) => '${m[c.key] ?? 0}'),
      '${_totalOf(m)}',
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (ctx) => [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [pdfPrimary, PdfColor.fromInt(0xFF8B2323), pdfSaffron],
              ),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SREE GURUMAHESWARA KSHETHRAM',
                  style: pw.TextStyle(
                    color: pdfWhite,
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Reports',
                  style: pw.TextStyle(
                    color: pdfWhite,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Period: $dateRange',
                  style: const pw.TextStyle(color: pdfSaffron, fontSize: 8),
                ),
                pw.SizedBox(height: 6),
                pw.Divider(color: pdfWhite, thickness: 0.3),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                  style: const pw.TextStyle(color: pdfWhite, fontSize: 7),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Table(
            border: pw.TableBorder.all(color: pdfBorder, width: 0.4),
            columnWidths: colWidths,
            children: [
              // Header row
              makeRow(headers, bg: pdfPrimary, isHeader: true),
              // Opening balance
              makeRow(
                sumRow(_openingBalance, 'Balance', prefix: 'Opening'),
                bg: pdfBalanceBg,
                bold: true,
                textColor: PdfColor.fromInt(0xFF6D1A1A),
              ),
              // RECEIPTS section label
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: pdfReceiptBg),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    child: pw.Text(
                      'Receipts',
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF2E6B4F),
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  ...List.generate(headers.length - 1, (_) => pw.SizedBox()),
                ],
              ),
              ..._receipts.asMap().entries.map(
                (e) => makeRow(
                  entryRow(e.value),
                  bg: e.key % 2 == 1 ? pdfStripeBg : pdfWhite,
                ),
              ),
              makeRow(
                sumRow(receiptTotal, 'ReceiptsTotal'),
                bg: pdfTotalBg,
                bold: true,
              ),
              // Issue balance row
              makeRow(
                sumRow(afterReceiptBalance, 'Balance', prefix: 'Issue'),
                bg: pdfBalanceBg,
                bold: true,
                textColor: PdfColor.fromInt(0xFF6D1A1A),
              ),
              // ISSUE section label
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: pdfIssueBg),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    child: pw.Text(
                      'Issue',
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(0xFF1A4A7A),
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  ...List.generate(headers.length - 1, (_) => pw.SizedBox()),
                ],
              ),
              ..._issues.asMap().entries.map(
                (e) => makeRow(
                  entryRow(e.value),
                  bg: e.key % 2 == 1 ? pdfStripeBg : pdfWhite,
                ),
              ),
              makeRow(
                sumRow(issueTotal, 'IssueTotal'),
                bg: pdfTotalBg,
                bold: true,
              ),
              // Closing balance
              makeRow(
                sumRow(closingBalance, 'Balance', prefix: 'Closing'),
                bg: pdfBalanceBg,
                bold: true,
                textColor: PdfColor.fromInt(0xFF6D1A1A),
              ),
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  // @override
  // Widget build(BuildContext context) {
  //   final receiptTotal = _sumCounts(_receipts);
  //   final issueTotal = _sumCounts(_issues);
  //   final afterReceiptBalance = _addMaps(_openingBalance, receiptTotal);
  //   final closingBalance = _subtractMaps(afterReceiptBalance, issueTotal);

  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       foregroundColor: _text,
  //       elevation: 0,
  //       scrolledUnderElevation: 0.5,
  //       surfaceTintColor: Colors.white,
  //       titleSpacing: 4,
  //       systemOverlayStyle: SystemUiOverlayStyle.dark,
  //       title: Text(
  //         'Reports ',
  //         style: GoogleFonts.poppins(
  //           color: _text,
  //           fontSize: 18.sp,
  //           fontWeight: FontWeight.w700,
  //         ),
  //       ),
  //       //actions: [
  //         // Padding(
  //         //   padding: EdgeInsets.only(right: 14.w),
  //         //   child: TextButton.icon(
  //         //     onPressed: _isDownloading ? null : _exportPdf,
  //         //     style: TextButton.styleFrom(
  //         //       foregroundColor: _accent,
  //         //       padding:
  //         //           EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
  //         //       shape: RoundedRectangleBorder(
  //         //         borderRadius: BorderRadius.circular(8),
  //         //         side: const BorderSide(color: _border),
  //         //       ),
  //         //     ),
  //         //     icon: _isDownloading
  //         //         ? SizedBox(
  //         //             width: 14.w,
  //         //             height: 14.w,
  //         //             child: const CircularProgressIndicator(
  //         //                 strokeWidth: 2, color: _accent),
  //         //           )
  //         //         : const Icon(Icons.download_rounded, size: 16),
  //         //     label: Text(
  //         //       'PDF',
  //         //       style: GoogleFonts.poppins(
  //         //           fontSize: 12.sp, fontWeight: FontWeight.w700),
  //         //     ),
  //         //   ),
  //         // ),
  //       //],
  //     ),
  //     body: Column(
  //       children: [
  //         _buildDateFilter(),
  //         Expanded(
  //           child: _buildRegisterTable(
  //             receiptTotal: receiptTotal,
  //             issueTotal: issueTotal,
  //             afterReceiptBalance: afterReceiptBalance,
  //             closingBalance: closingBalance,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // ── Date range filter bar ──────────────────────────────────────────────────

  // Replace the entire body structure in DoubleLockRegisterScreen
  // Keep all models, _cols, _sumCounts, _addMaps, _subtractMaps, _totalOf unchanged
  // Only the build() and widget methods change below

  @override
  Widget build(BuildContext context) {
    final receiptTotal = _sumCounts(_receipts);
    final issueTotal = _sumCounts(_issues);
    final afterReceiptBal = _addMaps(_openingBalance, receiptTotal);
    final closingBalance = _subtractMaps(afterReceiptBal, issueTotal);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Reports',
          style: GoogleFonts.poppins(
            color: _text,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: TextButton.icon(
              onPressed: _isDownloading ? null : _exportPdf,
              icon: _isDownloading
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _accent,
                      ),
                    )
                  : const Icon(Icons.download_rounded, size: 16),
              label: Text(
                'PDF',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: _accent,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: _border),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow(receiptTotal, issueTotal, closingBalance),
                  SizedBox(height: 16.h),
                  _balanceCard(
                    'OPENING BALANCE',
                    _openingBalance,
                    bg: const Color(0xFFFFF8EE),
                    border: const Color(0xFFC17D26),
                    labelColor: const Color(0xFFC17D26),
                    valColor: const Color(0xFF6D1A1A),
                  ),
                  _sectionHeading('RECEIPTS', const Color(0xFF2E6B4F)),
                  ..._receipts.map(
                    (e) => _entryCard(
                      e,
                      iconBg: const Color(0xFFEEF4EE),
                      iconColor: const Color(0xFF2E6B4F),
                      icon: Icons.upload_file_rounded,
                    ),
                  ),
                  _totalSummaryCard('RECEIPTS TOTAL', receiptTotal, _accent),
                  SizedBox(height: 8.h),
                  _balanceCard(
                    'ISSUE BALANCE  ·  Opening + Receipts',
                    afterReceiptBal,
                    bg: const Color(0xFFEEF0F8),
                    border: const Color(0xFF1A4A7A),
                    labelColor: const Color(0xFF1A4A7A),
                    valColor: const Color(0xFF1A4A7A),
                  ),
                  _sectionHeading('ISSUES', const Color(0xFF1A4A7A)),
                  ..._issues.map(
                    (e) => _entryCard(
                      e,
                      iconBg: const Color(0xFFEEF0F8),
                      iconColor: const Color(0xFF1A4A7A),
                      icon: Icons.download_rounded,
                    ),
                  ),
                  _totalSummaryCard(
                    'ISSUES TOTAL',
                    issueTotal,
                    const Color(0xFF1A4A7A),
                  ),
                  SizedBox(height: 8.h),
                  _balanceCard(
                    'CLOSING BALANCE',
                    closingBalance,
                    bg: const Color(0xFFEEF4EE),
                    border: const Color(0xFF2E6B4F),
                    labelColor: const Color(0xFF2E6B4F),
                    valColor: const Color(0xFF2E6B4F),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    final fmt = DateFormat('dd/MM/yyyy');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F4F0),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          _dateChip('From', fmt.format(_from), () => _pickDate(true)),
          SizedBox(width: 10.w),
          _dateChip('To', fmt.format(_to), () => _pickDate(false)),
          // const Spacer(),
          // Text(
          //   '${_receipts.length} receipts · ${_issues.length} issues',
          //   style: GoogleFonts.poppins(
          //     color: _muted,
          //     fontSize: 11.sp,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _dateChip(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: GoogleFonts.poppins(
                color: _muted,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: _text,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6.w),
            const Icon(Icons.calendar_today_rounded, size: 14, color: _accent),
          ],
        ),
      ),
    );
  }

  // ── Main register table ────────────────────────────────────────────────────
  Widget _buildRegisterTable({
    required Map<String, int> receiptTotal,
    required Map<String, int> issueTotal,
    required Map<String, int> afterReceiptBalance,
    required Map<String, int> closingBalance,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder(
                horizontalInside: BorderSide(color: _border, width: 0.6),
                verticalInside: BorderSide(color: _border, width: 0.6),
                top: BorderSide.none,
                bottom: BorderSide.none,
                left: BorderSide.none,
                right: BorderSide.none,
              ),
              children: [
                // ── HEADER ──────────────────────────────────────────────────
                _headerRow(),

                // ── OPENING BALANCE ──────────────────────────────────────────
                _balanceRow(
                  label: 'Balance',
                  sublabel: '',
                  counts: _openingBalance,
                  isOpening: true,
                ),

                // ── RECEIPTS SECTION LABEL ───────────────────────────────────
                _sectionLabelRow(
                  'Receipts',
                  const Color(0xFF2E6B4F),
                  _receiptSectionBg,
                ),

                // ── RECEIPT ENTRIES ──────────────────────────────────────────
                ..._receipts.asMap().entries.map(
                  (e) => _dataRow(e.value, isAlt: e.key % 2 == 1),
                ),

                // ── RECEIPTS TOTAL ───────────────────────────────────────────
                _totalRow('ReceiptsTotal', receiptTotal),

                // ── ISSUE BALANCE (opening + receipts) ──────────────────────
                _balanceRow(
                  label: 'Balance',
                  sublabel: 'Issue',
                  counts: afterReceiptBalance,
                  isOpening: false,
                ),

                // ── ISSUE SECTION LABEL ──────────────────────────────────────
                _sectionLabelRow(
                  'Issue',
                  const Color(0xFF1A4A7A),
                  _issueSectionBg,
                ),

                // ── ISSUE ENTRIES ────────────────────────────────────────────
                ..._issues.asMap().entries.map(
                  (e) => _dataRow(e.value, isAlt: e.key % 2 == 1),
                ),

                // ── ISSUE TOTAL ──────────────────────────────────────────────
                _totalRow('IssueTotal', issueTotal),

                // ── CLOSING BALANCE ──────────────────────────────────────────
                _balanceRow(
                  label: 'Balance',
                  sublabel: 'Closing',
                  counts: closingBalance,
                  isOpening: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Table row builders ─────────────────────────────────────────────────────

  TableRow _headerRow() {
    Widget hCell(String text, {int flex = 1}) => Container(
      color: _headerBg,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return TableRow(
      children: [
        hCell('Sl\nNo'),
        hCell('Date'),
        hCell('Item'),
        hCell('Temple'),
        hCell('From\nNo'),
        hCell('To\nNo'),
        ..._cols.map((c) => hCell(c.label)),
        hCell('Total'),
      ],
    );
  }

  TableRow _dataRow(_DlrEntry e, {bool isAlt = false}) {
    final bg = isAlt ? _stripeBg : Colors.white;

    Widget cell(String text, {TextAlign align = TextAlign.center}) => Container(
      color: bg,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.h),
      child: Text(
        text,
        textAlign: align,
        style: GoogleFonts.poppins(
          color: _text,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    Widget countCell(int v) => Container(
      color: bg,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.h),
      child: Text(
        v == 0 ? '' : '$v',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: _text,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return TableRow(
      children: [
        cell('${e.slno}'),
        cell(DateFormat('dd-MM-yy').format(e.date)),
        cell(e.item, align: TextAlign.left),
        cell(e.temple, align: TextAlign.left),
        cell('${e.fromNo}'),
        cell('${e.toNo}'),
        ..._cols.map((c) => countCell(e.counts[c.key] ?? 0)),
        Container(
          color: bg,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.h),
          child: Text(
            '${e.total}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  TableRow _sectionLabelRow(String label, Color color, Color bg) {
    return TableRow(
      children: [
        Container(
          color: bg,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Fill remaining cols with colored empty cells
        ...List.generate(5 + _cols.length + 1, (_) => Container(color: bg)),
      ],
    );
  }

  TableRow _totalRow(String label, Map<String, int> counts) {
    Widget cell(String text, {bool isLabel = false}) => Container(
      color: _totalRowBg,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(
        text,
        textAlign: isLabel ? TextAlign.left : TextAlign.center,
        style: GoogleFonts.poppins(
          color: _accent,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return TableRow(
      children: [
        cell(''),
        cell(''),
        cell(label, isLabel: true),
        cell(''),
        cell(''),
        cell(''),
        ..._cols.map((c) => cell('${counts[c.key] ?? 0}')),
        cell('${_totalOf(counts)}'),
      ],
    );
  }

  TableRow _balanceRow({
    required String label,
    required String sublabel,
    required Map<String, int> counts,
    required bool isOpening,
  }) {
    Widget cell(String text, {bool isLabel = false}) => Container(
      color: _balanceRowBg,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Text(
        text,
        textAlign: isLabel ? TextAlign.left : TextAlign.center,
        style: GoogleFonts.poppins(
          color: _saffron,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return TableRow(
      children: [
        cell(''),
        cell(sublabel),
        cell(label, isLabel: true),
        cell(''),
        cell(''),
        cell(''),
        ..._cols.map((c) => cell('${counts[c.key] ?? 0}')),
        cell('${_totalOf(counts)}'),
      ],
    );
  }

  // ── Summary metric row ────────────────────────────────────────────────────────
  Widget _summaryRow(
    Map<String, int> rTot,
    Map<String, int> iTot,
    Map<String, int> closing,
  ) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            'TOTAL\nRECEIPTS',
            '${_totalOf(rTot)}',
            const Color(0xFF2E6B4F),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _metricCard(
            'TOTAL\nISSUES',
            '${_totalOf(iTot)}',
            const Color(0xFF1A4A7A),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _metricCard(
            'CLOSING\nBALANCE',
            '${_totalOf(closing)}',
            _accent,
          ),
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color.withOpacity(0.7),
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              height: 1.3,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section heading ───────────────────────────────────────────────────────────
  Widget _sectionHeading(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  // ── Entry card ─────────────────────────────────────────────────────────────────
  Widget _entryCard(
    _DlrEntry e, {
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.item,
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      e.temple,
                      style: GoogleFonts.poppins(
                        color: _muted,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${e.slno}',
                  style: GoogleFonts.poppins(
                    color: _muted,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Meta pills
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _metaPill(
                Icons.calendar_today_rounded,
                DateFormat('dd-MM-yy').format(e.date),
              ),
              _metaPill(Icons.arrow_forward_rounded, '${e.fromNo} → ${e.toNo}'),
              _metaPill(
                Icons.confirmation_number_outlined,
                '${e.toNo - e.fromNo + 1} tickets',
              ),
            ],
          ),
          Divider(height: 18.h, color: _border, thickness: 0.5),
          // Denomination grid
          _denomGrid(e.counts),
          SizedBox(height: 10.h),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total books  ',
                style: GoogleFonts.poppins(
                  color: _muted,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${e.total}',
                style: GoogleFonts.poppins(
                  color: iconColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaPill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _muted),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: _muted,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Denomination grid (chips) ─────────────────────────────────────────────────
  Widget _denomGrid(Map<String, int> counts) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: _cols.map((c) {
        final v = counts[c.key] ?? 0;
        final active = v > 0;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF9E8E8) : const Color(0xFFF5F0EB),
            borderRadius: BorderRadius.circular(7),
            border: active
                ? Border.all(color: _accent.withOpacity(0.25))
                : null,
          ),
          child: Column(
            children: [
              Text(
                c.label.replaceAll('\n', ' '),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: active ? _accent : _muted,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$v',
                style: GoogleFonts.poppins(
                  color: active ? _accent : _muted,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Total summary card ────────────────────────────────────────────────────────
  Widget _totalSummaryCard(String title, Map<String, int> counts, Color color) {
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          _denomGrid(counts),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Grand Total  ',
                style: GoogleFonts.poppins(
                  color: _muted,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_totalOf(counts)}',
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Balance card ──────────────────────────────────────────────────────────────
  Widget _balanceCard(
    String title,
    Map<String, int> counts, {
    required Color bg,
    required Color border,
    required Color labelColor,
    required Color valColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: labelColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _cols.map((c) {
              final v = counts[c.key] ?? 0;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  children: [
                    Text(
                      c.label.replaceAll('\n', ' '),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: labelColor,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$v',
                      style: GoogleFonts.poppins(
                        color: valColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total  ',
                style: GoogleFonts.poppins(
                  color: labelColor.withOpacity(0.7),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_totalOf(counts)}',
                style: GoogleFonts.poppins(
                  color: valColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
