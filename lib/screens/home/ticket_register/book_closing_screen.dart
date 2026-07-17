import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _Temple {
  final String id;
  final String name;
  const _Temple({required this.id, required this.name});
}

class _PoojaItem {
  final int slno;
  final String vazhivadItem;
  final int fromNo;
  final double ratePerTicket;
  final int openingTicket;

  const _PoojaItem({
    required this.slno,
    required this.vazhivadItem,
    required this.fromNo,
    required this.ratePerTicket,
    required this.openingTicket,
  });
}

class _PoojaRow {
  final _PoojaItem item;
  final TextEditingController toNoCtrl;

  _PoojaRow({required this.item}) : toNoCtrl = TextEditingController();

  int get toNo => int.tryParse(toNoCtrl.text.trim()) ?? 0;
  int get nos => toNo > item.fromNo ? (toNo - item.fromNo + 1) : 0;
  double get amount => nos * item.ratePerTicket;
  int get closingTickets => item.openingTicket - nos;

  void dispose() => toNoCtrl.dispose();
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class BookClosingTableScreen extends StatefulWidget {
  const BookClosingTableScreen({super.key});

  @override
  State<BookClosingTableScreen> createState() => _BookClosingTableScreenState();
}

class _BookClosingTableScreenState extends State<BookClosingTableScreen> {
  static const _primary = Color(0xFFE77F75);
  static const _saffron = Color(0xFFE77F75);
  static const _bg = Color(0xFFF8F4F0);
  static const _labelColor = Color(0xFF4A3728);
  static const _hintColor = Color.fromARGB(255, 3, 3, 3);

  // ── Placeholder data ──────────────────────────────────────────────────────
  final List<_Temple> _temples = const [
    _Temple(id: 't1', name: 'Sree Padmanabhaswamy Temple'),
    _Temple(id: 't2', name: 'Attukal Bhagavathy Temple'),
    _Temple(id: 't3', name: 'Sabarimala Temple'),
  ];

  // pooja items per temple — wire to provider/API later
  final Map<String, List<_PoojaItem>> _templePooja = const {
    't1': [
      _PoojaItem(
        slno: 1,
        vazhivadItem: 'പൂഷ്ഠാഞ്ജലി',
        fromNo: 1,
        ratePerTicket: 12,
        openingTicket: 1000,
      ),
      _PoojaItem(
        slno: 14,
        vazhivadItem: 'നെയ്യ്',
        fromNo: 1,
        ratePerTicket: 0,
        openingTicket: 1000,
      ),
    ],
    't2': [
      _PoojaItem(
        slno: 1,
        vazhivadItem: 'Archana',
        fromNo: 1,
        ratePerTicket: 25,
        openingTicket: 500,
      ),
      _PoojaItem(
        slno: 2,
        vazhivadItem: 'Nivedyam',
        fromNo: 501,
        ratePerTicket: 50,
        openingTicket: 300,
      ),
    ],
    't3': [
      _PoojaItem(
        slno: 1,
        vazhivadItem: 'Sahasranamam',
        fromNo: 1,
        ratePerTicket: 100,
        openingTicket: 200,
      ),
    ],
  };

  String? _selectedTempleId;
  DateTime _selectedDate = DateTime.now();
  List<_PoojaRow> _rows = [];
  bool _isSaving = false;

  List<_Temple> get _templeList => _temples;
  _Temple? get _selectedTemple => _selectedTempleId != null
      ? _temples.firstWhere((t) => t.id == _selectedTempleId)
      : null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void dispose() {
    for (final r in _rows) r.dispose();
    super.dispose();
  }

  void _onTempleChanged(String? id) {
    for (final r in _rows) r.dispose();
    setState(() {
      _selectedTempleId = id;
      final items = _templePooja[id] ?? [];
      _rows = items.map((i) => _PoojaRow(item: i)).toList();
      for (final r in _rows) {
        r.toNoCtrl.addListener(() => setState(() {}));
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _onSave() {
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            'Book closed for ${_selectedTemple?.name ?? ''}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  // ── Totals ────────────────────────────────────────────────────────────────
  int get _totalNos => _rows.fold(0, (s, r) => s + r.nos);
  double get _totalAmount => _rows.fold(0.0, (s, r) => s + r.amount);
  int get _totalOpening => _rows.fold(0, (s, r) => s + r.item.openingTicket);
  int get _totalClosing => _rows.fold(0, (s, r) => s + r.closingTickets);

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
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
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(14.w, 20.h, 14.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date + Temple row ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker()),
                      SizedBox(width: 10.w),
                      Expanded(child: _buildTempleDropdown()),
                    ],
                  ),
                  SizedBox(height: 22.h),

                  // ── Table ─────────────────────────────────────────────
                  if (_selectedTempleId != null) ...[
                    _sectionLabel('Vazhivad Entries'),
                    SizedBox(height: 10.h),
                    _buildTable(),
                    SizedBox(height: 24.h),
                    _buildSaveButton(),
                  ] else
                    _buildEmptyPrompt(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket Entry',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                    ),
                  ),
                  Text(
                    'Close & Settle Book',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
        width: 3.w,
        height: 14.h,
        decoration: BoxDecoration(
          color: _saffron,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      SizedBox(width: 8.w),
      Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          color: _labelColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
        ),
      ),
    ],
  );

  // ── Date picker tile ──────────────────────────────────────────────────────
  Widget _buildDatePicker() {
    final label =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEADDD8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF9E8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: _primary,
                size: 15,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DATE',
                    style: GoogleFonts.poppins(
                      color: _hintColor,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: _labelColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── Temple dropdown ───────────────────────────────────────────────────────
  Widget _buildTempleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedTempleId,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(10.w),
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF9E8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.temple_hindu_outlined,
                color: _primary,
                size: 15,
              ),
            ),
          ),
          labelText: 'Temple',
          labelStyle: GoogleFonts.poppins(
            color: _hintColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        ),
        style: GoogleFonts.poppins(
          color: _labelColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
        items: _templeList
            .map(
              (t) => DropdownMenuItem(
                value: t.id,
                child: Text(
                  t.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _labelColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: _onTempleChanged,
      ),
    );
  }

  // ── TABLE ─────────────────────────────────────────────────────────────────
  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADDD8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 28.w,
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              ...List.generate(
                _rows.length,
                (i) => _buildTableRow(_rows[i], i),
              ),
              _buildTotalRow(),
            ],
          ),
        ),
      ),
    );
  }

  static const _cols = [
    'Sl\nNo',
    'Vazhivad Item',
    'From\nNo',
    'To No',
    'Nos',
    'Amount\n(₹)',
    'Opening\nTicket',
    'Closing\nTickets',
  ];
  static const _colWidths = [38.0, 120.0, 58.0, 72.0, 44.0, 72.0, 68.0, 68.0];

  Widget _buildTableHeader() {
    return Container(
      color: _primary,
      child: Row(
        children: List.generate(_cols.length, (i) {
          return SizedBox(
            width: _colWidths[i].w,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
              child: Text(
                _cols[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  height: 1.3,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTableRow(_PoojaRow row, int index) {
    final isEven = index.isEven;
    final nosVal = row.nos;
    final amtVal = row.amount;

    return Container(
      color: isEven ? const Color(0xFFFDF8F5) : Colors.white,
      child: Row(
        children: [
          // Sl No
          _cell(row.item.slno.toString(), _colWidths[0], center: true),
          // Vazhivad
          _cell(row.item.vazhivadItem, _colWidths[1], isLeft: true),
          // From No
          _cell(row.item.fromNo.toString(), _colWidths[2], center: true),
          // To No — editable
          SizedBox(
            width: _colWidths[3].w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: Container(
                height: 34.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E8E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _primary.withOpacity(0.3)),
                ),
                child: TextFormField(
                  controller: row.toNoCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: _primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '—',
                    hintStyle: GoogleFonts.poppins(
                      color: _hintColor,
                      fontSize: 12.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
          // Nos
          _cell(
            nosVal > 0 ? nosVal.toString() : '0',
            _colWidths[4],
            center: true,
            bold: nosVal > 0,
            color: nosVal > 0 ? _saffron : _hintColor,
          ),
          // Amount
          _cell(
            amtVal > 0 ? amtVal.toStringAsFixed(0) : '0',
            _colWidths[5],
            center: true,
            bold: amtVal > 0,
            color: amtVal > 0 ? _saffron : _hintColor,
          ),
          // Opening ticket
          _cell(
            row.item.openingTicket.toString(),
            _colWidths[6],
            center: true,
            color: const Color(0xFF6D1A1A),
            bold: true,
          ),
          // Closing tickets
          _cell(
            row.closingTickets.toString(),
            _colWidths[7],
            center: true,
            color: row.closingTickets < row.item.openingTicket
                ? const Color(0xFF2E6B4F)
                : _hintColor,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6D1A1A).withOpacity(0.06),
        border: Border(
          top: BorderSide(color: _primary.withOpacity(0.2), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          _cell('', _colWidths[0]),
          _cell(
            'Total',
            _colWidths[1],
            isLeft: true,
            bold: true,
            color: _primary,
          ),
          _cell('', _colWidths[2]),
          _cell('', _colWidths[3]),
          _cell(
            _totalNos.toString(),
            _colWidths[4],
            center: true,
            bold: true,
            color: _saffron,
          ),
          _cell(
            _totalAmount.toStringAsFixed(0),
            _colWidths[5],
            center: true,
            bold: true,
            color: _saffron,
          ),
          _cell(
            _totalOpening.toString(),
            _colWidths[6],
            center: true,
            bold: true,
            color: _primary,
          ),
          _cell(
            _totalClosing.toString(),
            _colWidths[7],
            center: true,
            bold: true,
            color: const Color(0xFF2E6B4F),
          ),
        ],
      ),
    );
  }

  Widget _cell(
    String text,
    double width, {
    bool center = false,
    bool isLeft = false,
    bool bold = false,
    Color? color,
  }) {
    return SizedBox(
      width: width.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
        child: Text(
          text,
          textAlign: isLeft
              ? TextAlign.left
              : (center ? TextAlign.center : TextAlign.right),
          style: GoogleFonts.poppins(
            color: color ?? _labelColor,
            fontSize: 12.sp,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Empty prompt ──────────────────────────────────────────────────────────
  Widget _buildEmptyPrompt() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADDD8)),
      ),
      child: Column(
        children: [
          Icon(Icons.temple_hindu_outlined, color: _hintColor, size: 36),
          SizedBox(height: 12.h),
          Text(
            'Select a date and temple\nto load vazhivad entries',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _hintColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    final canSave = !_isSaving && _selectedTempleId != null && _totalNos > 0;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: canSave ? _onSave : null,
        icon: _isSaving
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.lock_outline_rounded, size: 20),
        label: Text(
          _isSaving ? 'Closing...' : 'Ticket Register',
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withOpacity(0.4),
          elevation: 3,
          shadowColor: _primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
