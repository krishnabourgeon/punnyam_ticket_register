import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ISSUE BOOK SCREEN — pooja dropdown filter, per-row issue selection
// ─────────────────────────────────────────────────────────────────────────────
class IssueBookScreen extends StatefulWidget {
  const IssueBookScreen({super.key});

  @override
  State<IssueBookScreen> createState() => _IssueBookScreenState();
}

class _LeafRangeRow {
  final int slNo;
  final String item;
  final DateTime date;
  final int fromNo;
  final int toNo;

  bool selected = false;
  DateTime? issueDate;
  String? temple;

  _LeafRangeRow({
    required this.slNo,
    required this.item,
    required this.date,
    required this.fromNo,
    required this.toNo,
  });
}

class _IssueBookScreenState extends State<IssueBookScreen>
    with SingleTickerProviderStateMixin {
  // ── Palette ─────────────────────────────────────────────────────────────────
  static const _primary = Color(0xFFE77F75);
  static const _saffron = Color(0xFFE77F75);
  static const _bg = Color(0xFFF8F4F0);
  static const _cardBg = Colors.white;
  static const _labelColor = Color(0xFF4A3728);
  static const _hintColor = Color.fromARGB(255, 8, 8, 8);
  static const _border = Color(0xFFEADDD8);

  // ── Data ─────────────────────────────────────────────────────────────────────
  final Map<String, int> _poojaLeafCounts = const {
    'Ganapathi Homam': 50,
    'Sahasranamam': 100,
    'Ashtothram': 30,
    'Pradosham': 75,
    'Abhishekam': 25,
    'Deeparadhana': 10,
  };

  final List<String> _temples = const [
    'Sree Padmanabhaswamy Temple',
    'Attukal Bhagavathy Temple',
    'Vamanapuram Devi Temple',
  ];

  List<_LeafRangeRow> _allRows = [];
  String? _selectedPooja; // currently chosen pooja
  bool _isLoading = true;
  bool _isIssuing = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _loadData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Data helpers ─────────────────────────────────────────────────────────────
  void _loadData() {
    setState(() {
      _isLoading = true;
      _selectedPooja = null;
      _allRows = [];
    });
    _fadeCtrl.reset();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final generated = <_LeafRangeRow>[];
      int slNo = 58;
      final today = DateTime.now();
      for (final entry in _poojaLeafCounts.entries) {
        final leavesPerBook = entry.value;
        for (int i = 0; i < 3; i++) {
          final from = 1 + (i * leavesPerBook);
          final to = from + leavesPerBook - 1;
          generated.add(
            _LeafRangeRow(
              slNo: slNo++,
              item: entry.key,
              date: today,
              fromNo: from,
              toNo: to,
            ),
          );
        }
      }
      setState(() {
        _allRows = generated;
        _isLoading = false;
      });
      _fadeCtrl.forward();
    });
  }

  List<String> get _poojaOptions =>
      _allRows.map((r) => r.item).toSet().toList();

  List<_LeafRangeRow> get _visibleRows => _selectedPooja == null
      ? []
      : _allRows.where((r) => r.item == _selectedPooja).toList();

  int get _selectedCount => _visibleRows.where((r) => r.selected).length;

  // ── Date picker ──────────────────────────────────────────────────────────────
  Future<void> _pickIssueDate(_LeafRangeRow row) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: row.issueDate ?? today,
      firstDate: DateTime(2020),
      lastDate: today,
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => row.issueDate = picked);
  }

  // ── Issue action ─────────────────────────────────────────────────────────────
  void _onIssueTicket() {
    final selected = _visibleRows.where((r) => r.selected).toList();

    if (selected.isEmpty) {
      _showSnack('Select at least one row to issue', Colors.grey.shade700);
      return;
    }
    final missing = selected.where(
      (r) => r.issueDate == null || (r.temple?.isEmpty ?? true),
    );
    if (missing.isNotEmpty) {
      _showSnack(
        'Set Issue Date & Temple for every selected row',
        Colors.red.shade400,
        bold: true,
      );
      return;
    }

    setState(() => _isIssuing = true);
    // TODO: call provider / API
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isIssuing = false;
        _allRows.removeWhere((r) => selected.contains(r));
      });
      _showSnack(
        '${selected.length} leaf range${selected.length > 1 ? "s" : ""} issued',
        _primary,
        bold: true,
      );
    });
  }

  void _showSnack(String msg, Color bg, {bool bold = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          msg,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: _primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildPoojaSelector(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _selectedPooja != null && _visibleRows.isNotEmpty
          ? _buildIssueBar()
          : null,
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE77F75), Color(0xFFF1907A), Color(0xFFE77F75)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 22.h),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              // Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Double Lock Issue',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                    ),
                  ),
                  Text(
                    'Issue Leaf Ranges',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Selected badge
              if (_selectedCount > 0)
                AnimatedScale(
                  scale: _selectedCount > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$_selectedCount selected',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pooja selector ───────────────────────────────────────────────────────────
  Widget _buildPoojaSelector() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Pooja',
            style: GoogleFonts.poppins(
              color: _labelColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _isLoading
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _primary,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Loading poojas…',
                          style: GoogleFonts.poppins(
                            color: _hintColor,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPooja,
                      isExpanded: true,
                      isDense: false,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _selectedPooja != null ? _primary : _hintColor,
                        size: 22,
                      ),
                      hint: Text(
                        'Choose a pooja to view leaf ranges',
                        style: GoogleFonts.poppins(
                          color: _hintColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        color: _labelColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      items: _poojaOptions
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: const BoxDecoration(
                                      color: _saffron,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(p),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedPooja = v;
                          // Deselect rows from other poojas on change
                          for (final r in _allRows) {
                            r.selected = false;
                          }
                        });
                        _fadeCtrl
                          ..reset()
                          ..forward();
                      },
                    ),
                  ),
          ),
          // Subtle count indicator
          if (_selectedPooja != null) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: Text(
                '${_visibleRows.length} unissued range${_visibleRows.length != 1 ? "s" : ""} for $_selectedPooja',
                style: GoogleFonts.poppins(
                  color: _saffron,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    // Nothing selected yet
    if (_selectedPooja == null) {
      return _buildPromptState();
    }

    // Selected pooja has no rows left
    if (_visibleRows.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 100.h),
        itemCount: _visibleRows.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => _buildLeafRangeCard(_visibleRows[i]),
      ),
    );
  }

  // ── Prompt state (no pooja chosen) ──────────────────────────────────────────
  Widget _buildPromptState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_outlined, color: _hintColor, size: 44),
            SizedBox(height: 14.h),
            Text(
              'Choose a Pooja above',
              style: GoogleFonts.poppins(
                color: _labelColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Leaf ranges for the selected\npooja will appear here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: _hintColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state (pooja chosen but all rows issued) ───────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: _primary,
                size: 40,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'All ranges issued',
              style: GoogleFonts.poppins(
                color: _labelColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'No unissued leaf ranges left\nfor $_selectedPooja',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: _hintColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Leaf range card ──────────────────────────────────────────────────────────
  Widget _buildLeafRangeCard(_LeafRangeRow row) {
    final dateStr = _fmt(row.date);
    final issueDateStr = row.issueDate == null
        ? 'mm/dd/yyyy'
        : _fmt(row.issueDate!);
    final hasDate = row.issueDate != null;
    final hasTemple = row.temple != null;
    final isReady = hasDate && hasTemple;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: row.selected
              ? isReady
                    ? _saffron.withOpacity(0.7)
                    : _primary.withOpacity(0.4)
              : _border,
          width: row.selected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(row.selected ? 0.06 : 0.03),
            blurRadius: row.selected ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row top: checkbox / slno / date / leaf range ──────────────────
          Row(
            children: [
              // Checkbox
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: row.selected,
                  activeColor: _primary,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (v) => setState(() => row.selected = v ?? false),
                ),
              ),
              SizedBox(width: 4.w),
              // Sl no badge
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              //   decoration: BoxDecoration(
              //     color       : const Color(0xFFF9E8E8),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Text('#${row.slNo}',
              //       style: GoogleFonts.poppins(
              //         color     : _primary,
              //         fontSize  : 11.sp,
              //         fontWeight: FontWeight.w700,
              //       )),
              // ),
              SizedBox(width: 8.w),
              Icon(Icons.calendar_today_rounded, color: _hintColor, size: 12),
              SizedBox(width: 4.w),
              // This date is the book added
              Text(
                dateStr,
                style: GoogleFonts.poppins(
                  color: _hintColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Leaf range chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${row.fromNo} – ${row.toNo}',
                  style: GoogleFonts.poppins(
                    color: _primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // ── Row bottom: issue date + temple ──────────────────────────────
          Row(
            children: [
              Expanded(child: _buildIssueDateField(row, issueDateStr, hasDate)),
              SizedBox(width: 10.w),
              Expanded(child: _buildTempleDropdown(row)),
            ],
          ),
          // ── Ready indicator ───────────────────────────────────────────────
          if (row.selected && isReady) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade600,
                  size: 14,
                ),
                SizedBox(width: 5.w),
                Text(
                  'Ready to issue',
                  style: GoogleFonts.poppins(
                    color: Colors.green.shade600,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Issue date field ─────────────────────────────────────────────────────────
  Widget _buildIssueDateField(
    _LeafRangeRow row,
    String issueDateStr,
    bool hasValue,
  ) {
    return InkWell(
      onTap: () => _pickIssueDate(row),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue ? _primary.withOpacity(0.3) : _border,
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Row(
          children: [
            Icon(
              Icons.event_outlined,
              color: hasValue ? _primary : _hintColor,
              size: 14,
            ),
            SizedBox(width: 7.w),
            Expanded(
              child: Text(
                issueDateStr,
                style: GoogleFonts.poppins(
                  color: hasValue ? _labelColor : _hintColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Temple dropdown ──────────────────────────────────────────────────────────
  Widget _buildTempleDropdown(_LeafRangeRow row) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: row.temple != null ? _primary.withOpacity(0.3) : _border,
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: row.temple,
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: row.temple != null ? _primary : _hintColor,
            size: 18,
          ),
          hint: Text(
            'Temple',
            style: GoogleFonts.poppins(
              color: _hintColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: GoogleFonts.poppins(
            color: _labelColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          items: _temples
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(t, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => row.temple = v),
        ),
      ),
    );
  }

  // ── Floating issue bar ───────────────────────────────────────────────────────
  Widget _buildIssueBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: _cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Summary
            if (_selectedCount > 0) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_selectedCount row${_selectedCount > 1 ? "s" : ""} selected',
                    style: GoogleFonts.poppins(
                      color: _primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Tap to confirm & issue',
                    style: GoogleFonts.poppins(
                      color: _hintColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.w),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isIssuing ? null : _onIssueTicket,
                icon: _isIssuing
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.local_activity_outlined, size: 18),
                label: Text(
                  _isIssuing
                      ? 'Issuing…'
                      : _selectedCount > 0
                      ? 'Issue $_selectedCount Book${_selectedCount > 1 ? "s" : ""}'
                      : 'Double Issue',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primary.withOpacity(0.55),
                  elevation: 2,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Date formatter ───────────────────────────────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';
}
