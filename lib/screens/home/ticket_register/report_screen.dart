import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/models/counters_model.dart';
import 'package:punnyam/models/reports_model.dart';
import 'package:punnyam/providers/home_provider.dart';
import 'package:punnyam/providers/ticket_providetr.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COUNTER STATEMENT REPORT SCREEN
// Backed by GET reports/counter-statement (see ReportsModel)
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
  static const _bg = Color(0xFFF8F4F0);
  static const _openColor = Color(0xFF1A4A7A);
  static const _settledColor = Color(0xFF2E6B4F);

  Datum? _selectedCounter;
  DateTime? _from;
  DateTime? _to;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeProvider>();
      if (homeProvider.counterdata == null ||
          homeProvider.counterdata!.isEmpty) {
        homeProvider.getCounter();
      }
    });
  }

  // ── API date formatter (yyyy-MM-dd) ───────────────────────────────────────
  String _apiDateFmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Data fetch ─────────────────────────────────────────────────────────────
  void _fetchReport() {
    final counter = _selectedCounter;
    final from = _from;
    final to = _to;
    if (counter?.id == null || from == null || to == null) return;
    context.read<TicketProvidetr>().getReports(
          fromDate: _apiDateFmt(from),
          toDate: _apiDateFmt(to),
          counterId: counter!.id!,
        );
  }

  void _onCounterChanged(Datum? counter) {
    setState(() => _selectedCounter = counter);
    _fetchReport();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _accent)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
    _fetchReport();
  }

  // ── PDF export ─────────────────────────────────────────────────────────────
  Future<void> _exportPdf(Data data) async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await _buildPdf(data);
      final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'counter_statement_$ts.pdf',
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

  Future<Uint8List> _buildPdf(Data data) async {
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
    const pdfStripeBg = PdfColor.fromInt(0xFFFAFAFA);
    const pdfTotalBg = PdfColor.fromInt(0xFFF5F0EB);

    final dateRange =
        '${DateFormat('dd MMM yyyy').format(_from!)} – ${DateFormat('dd MMM yyyy').format(_to!)}';
    String fmtDate(DateTime d) => DateFormat('dd-MM-yy').format(d);

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
                fontSize: isHeader ? 7 : 7.5,
                fontWeight: bold || isHeader
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
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
                  'COUNTER STATEMENT REPORT',
                  style: pw.TextStyle(
                    color: pdfWhite,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  data.counter.name,
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
          pw.SizedBox(height: 12),

          // Totals summary
          pw.Table(
            border: pw.TableBorder.all(color: pdfBorder, width: 0.4),
            children: [
              makeRow(
                ['Books Issued', 'Books Open', 'Books Settled', 'Leaves Used'],
                bg: pdfPrimary,
                isHeader: true,
              ),
              makeRow(
                [
                  '${data.totals.booksIssued}',
                  '${data.totals.booksOpen}',
                  '${data.totals.booksSettled}',
                  '${data.totals.leavesUsed}',
                ],
                bg: pdfTotalBg,
                bold: true,
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // Pooja-wise summary
          if (data.poojaWise.isNotEmpty) ...[
            pw.Text(
              'Pooja-wise Summary',
              style: pw.TextStyle(
                color: pdfPrimary,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: pdfBorder, width: 0.4),
              columnWidths: const {
                0: pw.FlexColumnWidth(2.4),
                1: pw.FlexColumnWidth(1),
                2: pw.FlexColumnWidth(1),
                3: pw.FlexColumnWidth(1),
                4: pw.FlexColumnWidth(1),
              },
              children: [
                makeRow(
                  ['Pooja', 'Issued', 'Open', 'Settled', 'Leaves Used'],
                  bg: pdfPrimary,
                  isHeader: true,
                ),
                ...data.poojaWise.asMap().entries.map(
                  (e) => makeRow(
                    [
                      e.value.poojaName,
                      '${e.value.booksIssued}',
                      '${e.value.booksOpen}',
                      '${e.value.booksSettled}',
                      '${e.value.leavesUsed}',
                    ],
                    bg: e.key % 2 == 1 ? pdfStripeBg : pdfWhite,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 14),
          ],

          // Issues
          pw.Text(
            'Book Issues',
            style: pw.TextStyle(
              color: pdfPrimary,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          if (data.issues.isEmpty)
            pw.Text(
              'No book issues in this period',
              style: const pw.TextStyle(fontSize: 8, color: pdfText),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: pdfBorder, width: 0.4),
              children: [
                makeRow(
                  [
                    'Book No',
                    'Pooja',
                    'Issue Date',
                    'Leaf From',
                    'Leaf To',
                    'Used To',
                    'Leaves Used',
                    'Status',
                  ],
                  bg: pdfPrimary,
                  isHeader: true,
                ),
                ...data.issues.asMap().entries.map(
                  (e) => makeRow(
                    [
                      '${e.value.bookNo}',
                      e.value.poojaName,
                      fmtDate(e.value.issueDate),
                      '${e.value.leafFrom}',
                      '${e.value.leafTo}',
                      '${e.value.leafUsedTo}',
                      '${e.value.noOfLeafsUsed}',
                      e.value.status,
                    ],
                    bg: e.key % 2 == 1 ? pdfStripeBg : pdfWhite,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
    return doc.save();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvidetr>();
    final reportData = ticketProvider.reportsModel?.data;

    return Scaffold(
      backgroundColor: _bg,
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
          if (reportData != null)
            Padding(
              padding: EdgeInsets.only(right: 14.w),
              child: TextButton.icon(
                onPressed: _isDownloading ? null : () => _exportPdf(reportData),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
          _buildFilterBar(),
          Expanded(child: _buildBody(ticketProvider, reportData)),
        ],
      ),
    );
  }

  // ── Filter bar (From / To date + Counter) ─────────────────────────────────
  Widget _buildFilterBar() {
    final fmt = DateFormat('dd/MM/yyyy');
    final counterList = context.watch<HomeProvider>().counterdata ?? [];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F4F0),
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dateChip(
                  'From',
                  _from != null ? fmt.format(_from!) : 'Select date',
                  () => _pickDate(true),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _dateChip(
                  'To',
                  _to != null ? fmt.format(_to!) : 'Select date',
                  () => _pickDate(false),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Datum>(
                value: _selectedCounter,
                isExpanded: true,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _accent,
                  size: 18,
                ),
                hint: Text(
                  'Select Counter',
                  style: GoogleFonts.poppins(
                    color: _muted,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: _text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10),
                items: counterList
                    .map(
                      (t) => DropdownMenuItem<Datum>(
                        value: t,
                        child:
                            Text(t.name ?? '', overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: _onCounterChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label, String value, VoidCallback onTap) {
    final isPlaceholder = value == 'Select date';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isPlaceholder ? _saffron : _border),
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
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: isPlaceholder ? _saffron : _text,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  fontStyle:
                      isPlaceholder ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            const Icon(Icons.calendar_today_rounded, size: 14, color: _accent),
          ],
        ),
      ),
    );
  }

  // ── Body states ────────────────────────────────────────────────────────────
  Widget _buildBody(TicketProvidetr provider, Data? data) {
    if (_selectedCounter == null) {
      return _emptyState(
        Icons.temple_hindu_outlined,
        'Select a counter to view the report',
      );
    }
    if (_from == null || _to == null) {
      return _emptyState(
        Icons.date_range_rounded,
        'Select a From and To date\nto view the report',
      );
    }
    if (provider.isLoadingReport) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (data == null) {
      return _emptyState(
        Icons.inbox_outlined,
        'No report data found for\n${_selectedCounter?.name ?? ''} in this period',
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryGrid(data.totals),
          SizedBox(height: 20.h),
          if (data.poojaWise.isNotEmpty) ...[
            _sectionHeading('POOJA-WISE SUMMARY', _accent),
            ...data.poojaWise.map((p) => _poojaWiseCard(p)),
            SizedBox(height: 8.h),
          ],
          _sectionHeading('BOOK ISSUES', _openColor),
          if (data.issues.isEmpty)
            _inlineNote('No book issues in this period')
          else
            ...data.issues.map((issue) => _issueCard(issue)),
        ],
      ),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _muted, size: 40),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: _muted,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inlineNote(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: _muted,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Totals summary (2x2 metric grid) ──────────────────────────────────────
  Widget _summaryGrid(Totals totals) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'BOOKS\nISSUED',
                '${totals.booksIssued}',
                _accent,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _metricCard(
                'BOOKS\nOPEN',
                '${totals.booksOpen}',
                _openColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'BOOKS\nSETTLED',
                '${totals.booksSettled}',
                _settledColor,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _metricCard(
                'LEAVES\nUSED',
                '${totals.leavesUsed}',
                _saffron,
              ),
            ),
          ],
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

  // ── Section heading ────────────────────────────────────────────────────────
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

  // ── Pooja-wise summary card ───────────────────────────────────────────────
  Widget _poojaWiseCard(PoojaWise p) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.poojaName,
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _statPill('Issued', p.booksIssued, _accent),
              _statPill('Open', p.booksOpen, _openColor),
              _statPill('Settled', p.booksSettled, _settledColor),
              _statPill('Leaves Used', p.leavesUsed, _saffron),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '$value',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ── Issue entry card ──────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return _openColor;
      case 'settled':
      case 'closed':
        return _settledColor;
      default:
        return _muted;
    }
  }

  Widget _issueCard(Issue e) {
    final statusColor = _statusColor(e.status);
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
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: statusColor,
                  size: 18,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.poojaName,
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Book #${e.bookNo}',
                      style: GoogleFonts.poppins(
                        color: _muted,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  e.status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _metaPill(
                Icons.calendar_today_rounded,
                DateFormat('dd-MM-yy').format(e.issueDate),
              ),
              _metaPill(
                Icons.arrow_forward_rounded,
                '${e.leafFrom} → ${e.leafTo}',
              ),
              _metaPill(Icons.check_circle_outline_rounded, 'Used to ${e.leafUsedTo}'),
              _metaPill(
                Icons.confirmation_number_outlined,
                '${e.noOfLeafsUsed} leaves used',
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
}
