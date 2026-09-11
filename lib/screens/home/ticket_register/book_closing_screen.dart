// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:provider/provider.dart';
// // import 'package:punnyam/models/counters_model.dart';
// // import 'package:punnyam/providers/home_provider.dart';
// // import 'package:punnyam/providers/ticket_providetr.dart';

// // // ─────────────────────────────────────────────────────────────────────────────
// // // MODELS
// // // ─────────────────────────────────────────────────────────────────────────────
// // class _PoojaItem {
// //   final int slno;
// //   final int bookIssueId; // needed by the close-book API
// //   final String vazhivadItem;
// //   final int fromNo;
// //   final double ratePerTicket;
// //   final int openingTicket;

// //   const _PoojaItem({
// //     required this.slno,
// //     required this.bookIssueId,
// //     required this.vazhivadItem,
// //     required this.fromNo,
// //     required this.ratePerTicket,
// //     required this.openingTicket,
// //   });
// // }

// // class _PoojaRow {
// //   final _PoojaItem item;
// //   final TextEditingController toNoCtrl;

// //   _PoojaRow({required this.item}) : toNoCtrl = TextEditingController();

// //   int get toNo => int.tryParse(toNoCtrl.text.trim()) ?? 0;
// //   int get nos => toNo > item.fromNo ? (toNo - item.fromNo + 1) : 0;
// //   double get amount => nos * item.ratePerTicket;
// //   int get closingTickets => item.openingTicket - nos;

// //   void dispose() => toNoCtrl.dispose();
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // SCREEN
// // // ─────────────────────────────────────────────────────────────────────────────
// // class BookClosingTableScreen extends StatefulWidget {
// //   const BookClosingTableScreen({super.key});

// //   @override
// //   State<BookClosingTableScreen> createState() => _BookClosingTableScreenState();
// // }

// // class _BookClosingTableScreenState extends State<BookClosingTableScreen> {
// //   static const _primary = Color(0xFFE77F75);
// //   static const _saffron = Color(0xFFE77F75);
// //   static const _bg = Color(0xFFF8F4F0);
// //   static const _labelColor = Color(0xFF4A3728);
// //   static const _hintColor = Color.fromARGB(255, 3, 3, 3);

// //   Datum? _selectedCounter;
// //   DateTime _selectedDate = DateTime.now();
// //   List<_PoojaRow> _rows = [];
// //   bool _isLoadingRows = false;
// //   bool _isSaving = false;

// //   // ── Lifecycle ─────────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       final homeProvider = context.read<HomeProvider>();
// //       if (homeProvider.counterdata == null ||
// //           homeProvider.counterdata!.isEmpty) {
// //         homeProvider.getCounter();
// //       }
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     for (final r in _rows) r.dispose();
// //     super.dispose();
// //   }

// //   // ── Data fetch ───────────────────────────────────────────────────────────
// //   Future<void> _fetchVazhivadEntries() async {
// //     final counter = _selectedCounter;
// //     if (counter?.id == null) return;

// //     setState(() => _isLoadingRows = true);

// //     final homeProvider = context.read<TicketProvidetr>();
// //     await homeProvider.bookIssueAvailable(
// //       counterId: counter!.id!,
// //       date: _apiDateFmt(_selectedDate),
// //     );

// //     if (!mounted) return;

// //     for (final r in _rows) {
// //       r.dispose();
// //     }

// //     final fetched = homeProvider.bookIssueAvailableList;
// //     setState(() {
// //       _rows = List.generate(fetched.length, (i) {
// //         final entry = fetched[i];
// //         return _PoojaRow(
// //           item: _PoojaItem(
// //             slno: i + 1,
// //             bookIssueId: entry.id ?? 0,
// //             vazhivadItem: entry.poojaName,
// //             fromNo: entry.leafFrom,
// //             ratePerTicket: entry.ratePerTicket,
// //             openingTicket: entry.openingTicket,
// //           ),
// //         );
// //       });
// //       _isLoadingRows = false;
// //     });
// //   }

// //   void _onCounterChanged(Datum? counter) {
// //     setState(() => _selectedCounter = counter);
// //     if (counter != null) _fetchVazhivadEntries();
// //   }

// //   Future<void> _pickDate() async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       builder: (ctx, child) => Theme(
// //         data: Theme.of(ctx).copyWith(
// //           colorScheme: const ColorScheme.light(
// //             primary: _primary,
// //             onPrimary: Colors.white,
// //             surface: Colors.white,
// //           ),
// //         ),
// //         child: child!,
// //       ),
// //     );
// //     if (picked != null) {
// //       setState(() => _selectedDate = picked);
// //       if (_selectedCounter != null) _fetchVazhivadEntries();
// //     }
// //   }

// //   // ── Save / Close book ───────────────────────────────────────────────────
// //   Future<void> _onSave() async {
// //     final counter = _selectedCounter;
// //     if (counter?.id == null) return;

// //     // Only close rows where a "To No" was actually entered.
// //     final itemsToClose =
// //         _rows.where((r) => r.toNoCtrl.text.trim().isNotEmpty).toList();

// //     if (itemsToClose.isEmpty) {
// //       _showToast(
// //         'Please enter at least one "To No" before closing',
// //         isError: true,
// //       );
// //       return;
// //     }

// //     // Validate To No >= From No for every entered row.
// //     for (final r in itemsToClose) {
// //       if (r.toNo < r.item.fromNo) {
// //         _showToast(
// //           '"To No" for ${r.item.vazhivadItem} cannot be less than From No (${r.item.fromNo})',
// //           isError: true,
// //         );
// //         return;
// //       }
// //     }

// //     final confirmed = await _confirmCloseDialog(itemsToClose.length);
// //     if (confirmed != true) return;

// //     setState(() => _isSaving = true);

// //     final items = itemsToClose
// //         .map((r) => {
// //               "book_issue_id": r.item.bookIssueId,
// //               "leaf_used_to": r.toNo,
// //             })
// //         .toList();

// //     final ticketProvider = context.read<TicketProvidetr>();
// //     await ticketProvider.closeBook(
// //       date: _apiDateFmt(_selectedDate),
// //       counterId: counter!.id!,
// //       items: items,
// //       onSuccess: (model) {
// //         if (!mounted) return;
// //         setState(() => _isSaving = false);
// //         _showToast(
// //           model.message.isNotEmpty
// //               ? model.message
// //               : 'Book closed for ${counter.name ?? ''}',
// //         );
// //         // Refresh so the table reflects updated opening/closing counts.
// //         _fetchVazhivadEntries();
// //       },
// //       onFailure: (error) {
// //         if (!mounted) return;
// //         setState(() => _isSaving = false);
// //         _showToast(error, isError: true);
// //       },
// //     );

// //     // Safety net in case neither callback fires for some reason.
// //     if (mounted && _isSaving) {
// //       setState(() => _isSaving = false);
// //     }
// //   }

// //   Future<bool?> _confirmCloseDialog(int count) {
// //     return showDialog<bool>(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: Text(
// //           'Close Book?',
// //           style: GoogleFonts.poppins(
// //             fontWeight: FontWeight.w800,
// //             color: _labelColor,
// //           ),
// //         ),
// //         content: Text(
// //           'This will settle $count item${count == 1 ? '' : 's'} for '
// //           '${_selectedCounter?.name ?? ''}. This action cannot be undone.',
// //           style: GoogleFonts.poppins(color: _labelColor, fontSize: 13.sp),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx, false),
// //             child: Text(
// //               'Cancel',
// //               style: GoogleFonts.poppins(
// //                 color: _hintColor,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ),
// //           ElevatedButton(
// //             onPressed: () => Navigator.pop(ctx, true),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: _primary,
// //               foregroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(10)),
// //             ),
// //             child: Text(
// //               'Confirm',
// //               style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void _showToast(String message, {bool isError = false}) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         behavior: SnackBarBehavior.floating,
// //         backgroundColor: isError ? Colors.redAccent : _primary,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //         content: Text(
// //           message,
// //           style: GoogleFonts.poppins(
// //             color: Colors.white,
// //             fontSize: 14.sp,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Totals ────────────────────────────────────────────────────────────────
// //   int get _totalNos => _rows.fold(0, (s, r) => s + r.nos);
// //   double get _totalAmount => _rows.fold(0.0, (s, r) => s + r.amount);
// //   int get _totalOpening => _rows.fold(0, (s, r) => s + r.item.fromNo);
// //   int get _totalClosing => _rows.fold(0, (s, r) => s + r.toNo);

// //   // ── API date formatter (yyyy-MM-dd) ─────────────────────────────────────
// //   String _apiDateFmt(DateTime d) =>
// //       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// //   // ─────────────────────────────────────────────────────────────────────────
// //   // BUILD
// //   // ─────────────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: _bg,
// //       appBar: AppBar(
// //         toolbarHeight: 0,
// //         elevation: 0,
// //         systemOverlayStyle: const SystemUiOverlayStyle(
// //           statusBarColor: _primary,
// //           statusBarIconBrightness: Brightness.light,
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           _buildHeader(),
// //           Expanded(
// //             child: SingleChildScrollView(
// //               physics: const BouncingScrollPhysics(),
// //               padding: EdgeInsets.fromLTRB(14.w, 20.h, 14.w, 32.h),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // ── Date + Temple row ──────────────────────────────────
// //                   Row(
// //                     children: [
// //                       Expanded(child: _buildDatePicker()),
// //                       SizedBox(width: 10.w),
// //                       Expanded(child: _buildTempleDropdown()),
// //                     ],
// //                   ),
// //                   SizedBox(height: 22.h),

// //                   // ── Table ─────────────────────────────────────────────
// //                   if (_selectedCounter == null)
// //                     _buildEmptyPrompt()
// //                   else if (_isLoadingRows)
// //                     _buildLoadingState()
// //                   else if (_rows.isEmpty)
// //                     _buildNoEntriesState()
// //                   else ...[
// //                     _sectionLabel('Entries'),
// //                     SizedBox(height: 10.h),
// //                     _buildTable(),
// //                     SizedBox(height: 24.h),
// //                     _buildSaveButton(),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Header ───────────────────────────────────────────────────────────────
// //   Widget _buildHeader() {
// //     return Container(
// //       width: double.infinity,
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [Color(0xFFE77F75), Color(0xFFF1907A), Color(0xFFE77F75)],
// //         ),
// //         borderRadius: BorderRadius.only(
// //           bottomLeft: Radius.circular(24),
// //           bottomRight: Radius.circular(24),
// //         ),
// //       ),
// //       child: SafeArea(
// //         bottom: false,
// //         child: Padding(
// //           padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 22.h),
// //           child: Row(
// //             children: [
// //               GestureDetector(
// //                 onTap: () => Navigator.pop(context),
// //                 child: Container(
// //                   width: 38.w,
// //                   height: 38.h,
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(0.15),
// //                     borderRadius: BorderRadius.circular(10),
// //                     border: Border.all(color: Colors.white.withOpacity(0.25)),
// //                   ),
// //                   child: const Icon(
// //                     Icons.arrow_back_ios_new_rounded,
// //                     color: Colors.white,
// //                     size: 16,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(width: 14.w),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Ticket Entry',
// //                     style: GoogleFonts.poppins(
// //                       color: Colors.white.withOpacity(0.6),
// //                       fontSize: 11.sp,
// //                       fontWeight: FontWeight.w600,
// //                       letterSpacing: 2.5,
// //                     ),
// //                   ),
// //                   Text(
// //                     'Close & Settle Book',
// //                     style: GoogleFonts.poppins(
// //                       color: Colors.white,
// //                       fontSize: 20.sp,
// //                       fontWeight: FontWeight.w800,
// //                       height: 1.2,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Section label ─────────────────────────────────────────────────────────
// //   Widget _sectionLabel(String text) => Row(
// //         children: [
// //           Container(
// //             width: 3.w,
// //             height: 14.h,
// //             decoration: BoxDecoration(
// //               color: _saffron,
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //           SizedBox(width: 8.w),
// //           Text(
// //             text.toUpperCase(),
// //             style: GoogleFonts.poppins(
// //               color: _labelColor,
// //               fontSize: 11.sp,
// //               fontWeight: FontWeight.w700,
// //               letterSpacing: 1.8,
// //             ),
// //           ),
// //         ],
// //       );

// //   // ── Date picker tile ──────────────────────────────────────────────────────
// //   Widget _buildDatePicker() {
// //     final label =
// //         '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
// //     return GestureDetector(
// //       onTap: _pickDate,
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(color: const Color(0xFFEADDD8)),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.04),
// //               blurRadius: 8,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 32.w,
// //               height: 32.w,
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF9E8E8),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: const Icon(
// //                 Icons.calendar_today_rounded,
// //                 color: _primary,
// //                 size: 15,
// //               ),
// //             ),
// //             SizedBox(width: 8.w),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'DATE',
// //                     style: GoogleFonts.poppins(
// //                       color: _hintColor,
// //                       fontSize: 9.sp,
// //                       fontWeight: FontWeight.w700,
// //                       letterSpacing: 1.4,
// //                     ),
// //                   ),
// //                   Text(
// //                     label,
// //                     style: GoogleFonts.poppins(
// //                       color: _labelColor,
// //                       fontSize: 13.sp,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const Icon(
// //               Icons.keyboard_arrow_down_rounded,
// //               color: _primary,
// //               size: 18,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Temple dropdown ───────────────────────────────────────────────────────
// //   Widget _buildTempleDropdown() {
// //     final counterList = context.watch<HomeProvider>().counterdata ?? [];
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: const Color(0xFFEADDD8)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: DropdownButtonHideUnderline(
// //         child: DropdownButton<Datum>(
// //           value: _selectedCounter,
// //           isExpanded: true,
// //           isDense: true,
// //           icon: const Icon(
// //             Icons.keyboard_arrow_down_rounded,
// //             color: _primary,
// //             size: 18,
// //           ),
// //           hint: Text(
// //             'Counter',
// //             style: GoogleFonts.poppins(
// //               color: _hintColor,
// //               fontSize: 12.sp,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           style: GoogleFonts.poppins(
// //             color: _labelColor,
// //             fontSize: 13.sp,
// //             fontWeight: FontWeight.w600,
// //           ),
// //           dropdownColor: Colors.white,
// //           borderRadius: BorderRadius.circular(14),
// //           items: counterList
// //               .map(
// //                 (t) => DropdownMenuItem<Datum>(
// //                   value: t,
// //                   child: Text(t.name ?? '', overflow: TextOverflow.ellipsis),
// //                 ),
// //               )
// //               .toList(),
// //           onChanged: _onCounterChanged,
// //         ),
// //       ),
// //     );
// //   }

// //   // ── TABLE ─────────────────────────────────────────────────────────────────
// //   Widget _buildTable() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: const Color(0xFFEADDD8)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: const Offset(0, 3),
// //           ),
// //         ],
// //       ),
// //       clipBehavior: Clip.hardEdge,
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.horizontal,
// //         child: ConstrainedBox(
// //           constraints: BoxConstraints(
// //             minWidth: MediaQuery.of(context).size.width - 28.w,
// //           ),
// //           child: Column(
// //             children: [
// //               _buildTableHeader(),
// //               ...List.generate(
// //                 _rows.length,
// //                 (i) => _buildTableRow(_rows[i], i),
// //               ),
// //               _buildTotalRow(),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   static const _cols = [
// //     'Sl\nNo',
// //     'Item',
// //     'From\nNo',
// //     'To No',
// //     'Nos',
// //     'Amount\n(₹)',
// //     'Opening\nTicket',
// //     'Closing\nTickets',
// //   ];
// //   static const _colWidths = [38.0, 120.0, 58.0, 72.0, 44.0, 72.0, 68.0, 68.0];

// //   Widget _buildTableHeader() {
// //     return Container(
// //       color: _primary,
// //       child: Row(
// //         children: List.generate(_cols.length, (i) {
// //           return SizedBox(
// //             width: _colWidths[i].w,
// //             child: Padding(
// //               padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
// //               child: Text(
// //                 _cols[i],
// //                 textAlign: TextAlign.center,
// //                 style: GoogleFonts.poppins(
// //                   color: Colors.white,
// //                   fontSize: 10.sp,
// //                   fontWeight: FontWeight.w700,
// //                   letterSpacing: 0.5,
// //                   height: 1.3,
// //                 ),
// //               ),
// //             ),
// //           );
// //         }),
// //       ),
// //     );
// //   }

// //   Widget _buildTableRow(_PoojaRow row, int index) {
// //     final isEven = index.isEven;
// //     final nosVal = row.nos;
// //     final amtVal = row.amount;

// //     return Container(
// //       color: isEven ? const Color(0xFFFDF8F5) : Colors.white,
// //       child: Row(
// //         children: [
// //           // Sl No
// //           _cell(row.item.slno.toString(), _colWidths[0], center: true),
// //           // Vazhivad
// //           _cell(row.item.vazhivadItem, _colWidths[1], isLeft: true),
// //           // From No
// //           _cell(row.item.fromNo.toString(), _colWidths[2], center: true),
// //           // To No — editable
// //           SizedBox(
// //             width: _colWidths[3].w,
// //             child: Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
// //               child: Container(
// //                 height: 34.h,
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFF9E8E8),
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(color: _primary.withOpacity(0.3)),
// //                 ),
// //                 child: TextFormField(
// //                   controller: row.toNoCtrl,
// //                   keyboardType: TextInputType.number,
// //                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //                   textAlign: TextAlign.center,
// //                   style: GoogleFonts.poppins(
// //                     color: _primary,
// //                     fontSize: 13.sp,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                   decoration: InputDecoration(
// //                     border: InputBorder.none,
// //                     hintText: '—',
// //                     hintStyle: GoogleFonts.poppins(
// //                       color: _hintColor,
// //                       fontSize: 12.sp,
// //                     ),
// //                     contentPadding: EdgeInsets.symmetric(vertical: 8.h),
// //                     isDense: true,
// //                   ),
// //                   onChanged: (_) => setState(() {}),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           // Nos
// //           _cell(
// //             nosVal > 0 ? nosVal.toString() : '0',
// //             _colWidths[4],
// //             center: true,
// //             bold: nosVal > 0,
// //             color: nosVal > 0 ? _saffron : _hintColor,
// //           ),
// //           // Amount
// //           _cell(
// //             amtVal > 0 ? amtVal.toStringAsFixed(0) : '0',
// //             _colWidths[5],
// //             center: true,
// //             bold: amtVal > 0,
// //             color: amtVal > 0 ? _saffron : _hintColor,
// //           ),
// //           // Opening ticket (From No)
// //           _cell(
// //             row.item.fromNo.toString(),
// //             _colWidths[6],
// //             center: true,
// //             color: const Color(0xFF6D1A1A),
// //             bold: true,
// //           ),
// //           // Closing tickets (To No)
// //           _cell(
// //             row.toNo > 0 ? row.toNo.toString() : '0',
// //             _colWidths[7],
// //             center: true,
// //             color: row.toNo > 0 ? const Color(0xFF2E6B4F) : _hintColor,
// //             bold: true,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildTotalRow() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: const Color(0xFF6D1A1A).withOpacity(0.06),
// //         border: Border(
// //           top: BorderSide(color: _primary.withOpacity(0.2), width: 1.5),
// //         ),
// //       ),
// //       child: Row(
// //         children: [
// //           _cell('', _colWidths[0]),
// //           _cell(
// //             'Total',
// //             _colWidths[1],
// //             isLeft: true,
// //             bold: true,
// //             color: _primary,
// //           ),
// //           _cell('', _colWidths[2]),
// //           _cell('', _colWidths[3]),
// //           _cell(
// //             _totalNos.toString(),
// //             _colWidths[4],
// //             center: true,
// //             bold: true,
// //             color: _saffron,
// //           ),
// //           _cell(
// //             _totalAmount.toStringAsFixed(0),
// //             _colWidths[5],
// //             center: true,
// //             bold: true,
// //             color: _saffron,
// //           ),
// //           _cell(
// //             _totalOpening.toString(),
// //             _colWidths[6],
// //             center: true,
// //             bold: true,
// //             color: _primary,
// //           ),
// //           _cell(
// //             _totalClosing.toString(),
// //             _colWidths[7],
// //             center: true,
// //             bold: true,
// //             color: const Color(0xFF2E6B4F),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _cell(
// //     String text,
// //     double width, {
// //     bool center = false,
// //     bool isLeft = false,
// //     bool bold = false,
// //     Color? color,
// //   }) {
// //     return SizedBox(
// //       width: width.w,
// //       child: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
// //         child: Text(
// //           text,
// //           textAlign: isLeft
// //               ? TextAlign.left
// //               : (center ? TextAlign.center : TextAlign.right),
// //           style: GoogleFonts.poppins(
// //             color: color ?? _labelColor,
// //             fontSize: 12.sp,
// //             fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Empty prompt (no counter selected yet) ─────────────────────────────────
// //   Widget _buildEmptyPrompt() {
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: const Color(0xFFEADDD8)),
// //       ),
// //       child: Column(
// //         children: [
// //           Icon(Icons.temple_hindu_outlined, color: _hintColor, size: 36),
// //           SizedBox(height: 12.h),
// //           Text(
// //             'Select a date and temple\nto load entries',
// //             textAlign: TextAlign.center,
// //             style: GoogleFonts.poppins(
// //               color: _hintColor,
// //               fontSize: 13.sp,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Loading state ────────────────────────────────────────────────────────
// //   Widget _buildLoadingState() {
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.symmetric(vertical: 48.h),
// //       alignment: Alignment.center,
// //       child: const CircularProgressIndicator(color: _primary),
// //     );
// //   }

// //   // ── No entries state (counter+date chosen, nothing to close) ───────────────
// //   Widget _buildNoEntriesState() {
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: const Color(0xFFEADDD8)),
// //       ),
// //       child: Column(
// //         children: [
// //           Icon(Icons.inbox_outlined, color: _hintColor, size: 36),
// //           SizedBox(height: 12.h),
// //           Text(
// //             'No issued books found for\n${_selectedCounter?.name ?? ''} on this date',
// //             textAlign: TextAlign.center,
// //             style: GoogleFonts.poppins(
// //               color: _hintColor,
// //               fontSize: 13.sp,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Save button ───────────────────────────────────────────────────────────
// //   Widget _buildSaveButton() {
// //     final canSave = !_isSaving && _selectedCounter != null && _totalNos > 0;
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 52.h,
// //       child: ElevatedButton.icon(
// //         onPressed: canSave ? _onSave : null,
// //         icon: _isSaving
// //             ? SizedBox(
// //                 width: 18.w,
// //                 height: 18.w,
// //                 child: const CircularProgressIndicator(
// //                   strokeWidth: 2.2,
// //                   color: Colors.white,
// //                 ),
// //               )
// //             : const Icon(Icons.lock_outline_rounded, size: 20),
// //         label: Text(
// //           _isSaving ? 'Closing...' : 'Ticket Register',
// //           style: GoogleFonts.poppins(
// //             fontSize: 17.sp,
// //             fontWeight: FontWeight.w700,
// //           ),
// //         ),
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: _primary,
// //           foregroundColor: Colors.white,
// //           disabledBackgroundColor: _primary.withOpacity(0.4),
// //           elevation: 3,
// //           shadowColor: _primary.withOpacity(0.4),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(14),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }






// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:punnyam/models/counters_model.dart';
// import 'package:punnyam/providers/home_provider.dart';
// import 'package:punnyam/providers/ticket_providetr.dart';

// // ─────────────────────────────────────────────────────────────────────────────
// // MODELS
// // ─────────────────────────────────────────────────────────────────────────────
// class _PoojaItem {
//   final int slno;
//   final int bookIssueId; // needed by the close-book API
//   final String vazhivadItem;
//   final int fromNo;
//   final double ratePerTicket;
//   final int openingTicket;

//   const _PoojaItem({
//     required this.slno,
//     required this.bookIssueId,
//     required this.vazhivadItem,
//     required this.fromNo,
//     required this.ratePerTicket,
//     required this.openingTicket,
//   });
// }

// class _PoojaRow {
//   final _PoojaItem item;
//   final TextEditingController toNoCtrl;

//   _PoojaRow({required this.item}) : toNoCtrl = TextEditingController();

//   int get toNo => int.tryParse(toNoCtrl.text.trim()) ?? 0;
//   int get nos => toNo > item.fromNo ? (toNo - item.fromNo + 1) : 0;
//   double get amount => nos * item.ratePerTicket;
//   int get closingTickets => item.openingTicket - nos;

//   void dispose() => toNoCtrl.dispose();
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // SCREEN
// // ─────────────────────────────────────────────────────────────────────────────
// class BookClosingTableScreen extends StatefulWidget {
//   const BookClosingTableScreen({super.key});

//   @override
//   State<BookClosingTableScreen> createState() => _BookClosingTableScreenState();
// }

// class _BookClosingTableScreenState extends State<BookClosingTableScreen> {
//   static const _primary = Color(0xFFE77F75);
//   static const _saffron = Color(0xFFE77F75);
//   static const _bg = Color(0xFFF8F4F0);
//   static const _labelColor = Color(0xFF4A3728);
//   static const _hintColor = Color.fromARGB(255, 3, 3, 3);

//   Datum? _selectedCounter;
//   DateTime _selectedDate = DateTime.now();
//   List<_PoojaRow> _rows = [];
//   bool _isLoadingRows = false;
//   bool _isSaving = false;

//   // ── Lifecycle ─────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final homeProvider = context.read<HomeProvider>();
//       if (homeProvider.counterdata == null ||
//           homeProvider.counterdata!.isEmpty) {
//         homeProvider.getCounter();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     for (final r in _rows) r.dispose();
//     super.dispose();
//   }

//   // ── Data fetch ───────────────────────────────────────────────────────────
//   Future<void> _fetchVazhivadEntries() async {
//     final counter = _selectedCounter;
//     if (counter?.id == null) return;

//     setState(() => _isLoadingRows = true);

//     final homeProvider = context.read<TicketProvidetr>();
//     await homeProvider.bookIssueAvailable(
//       counterId: counter!.id!,
//       date: _apiDateFmt(_selectedDate),
//     );

//     if (!mounted) return;

//     for (final r in _rows) {
//       r.dispose();
//     }

//     final fetched = homeProvider.bookIssueAvailableList;
//     setState(() {
//       _rows = List.generate(fetched.length, (i) {
//         final entry = fetched[i];
//         return _PoojaRow(
//           item: _PoojaItem(
//             slno: i + 1,
//             bookIssueId: entry.id ?? 0,
//             vazhivadItem: entry.poojaName,
//             fromNo: entry.nextleaffrom ?? entry.leafFrom,
//             ratePerTicket: entry.ratePerTicket,
//             openingTicket: entry.openingTicket,
//           ),
//         );
//       });
//       _isLoadingRows = false;
//     });
//   }

//   void _onCounterChanged(Datum? counter) {
//     setState(() => _selectedCounter = counter);
//     if (counter != null) _fetchVazhivadEntries();
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: _primary,
//             onPrimary: Colors.white,
//             surface: Colors.white,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       setState(() => _selectedDate = picked);
//       if (_selectedCounter != null) _fetchVazhivadEntries();
//     }
//   }

//   // ── Save / Close book ───────────────────────────────────────────────────
//   /// [completeClose] = false  -> "Close": only rows where you manually typed a "To No" get closed.
//   /// [completeClose] = true   -> "Completely Close": every row gets closed; any blank "To No"
//   ///                              is auto-filled with the last leaf number of that book
//   ///                              (fromNo + openingTicket - 1).
//   Future<void> _onSave({required bool completeClose}) async {
//     final counter = _selectedCounter;
//     if (counter?.id == null) return;

//     List<_PoojaRow> itemsToClose;

//     if (completeClose) {
//       for (final r in _rows) {
//         if (r.toNoCtrl.text.trim().isEmpty) {
//           final lastLeaf = r.item.fromNo + r.item.openingTicket - 1;
//           r.toNoCtrl.text = lastLeaf.toString();
//         }
//       }
//       itemsToClose = _rows;
//     } else {
//       // Only close rows where a "To No" was actually entered.
//       itemsToClose =
//           _rows.where((r) => r.toNoCtrl.text.trim().isNotEmpty).toList();
//     }

//     if (itemsToClose.isEmpty) {
//       _showToast(
//         'Please enter at least one "To No" before closing',
//         isError: true,
//       );
//       return;
//     }

//     // Validate To No >= From No for every entered row.
//     for (final r in itemsToClose) {
//       if (r.toNo < r.item.fromNo) {
//         _showToast(
//           '"To No" for ${r.item.vazhivadItem} cannot be less than From No (${r.item.fromNo})',
//           isError: true,
//         );
//         return;
//       }
//     }

//     final confirmed = await _confirmCloseDialog(
//       itemsToClose.length,
//       completeClose: completeClose,
//     );
//     if (confirmed != true) return;

//     setState(() => _isSaving = true);

//     final items = itemsToClose
//         .map((r) => {
//               "book_issue_id": r.item.bookIssueId,
//               "leaf_used_to": r.toNo,
//               "type": completeClose ? "complete" : "partial",
//             })
//         .toList();

//     final ticketProvider = context.read<TicketProvidetr>();
//     await ticketProvider.closeBook(
//       date: _apiDateFmt(_selectedDate),
//       counterId: counter!.id!,
//       items: items,
//       onSuccess: (model) {
//         if (!mounted) return;
//         setState(() => _isSaving = false);
//         _showToast(
//           model.message.isNotEmpty
//               ? model.message
//               : 'Book closed for ${counter.name ?? ''}',
//         );
//         // Refresh so the table reflects updated opening/closing counts.
//         _fetchVazhivadEntries();
//       },
//       onFailure: (error) {
//         if (!mounted) return;
//         setState(() => _isSaving = false);
//         _showToast(error, isError: true);
//       },
//     );

//     // Safety net in case neither callback fires for some reason.
//     if (mounted && _isSaving) {
//       setState(() => _isSaving = false);
//     }
//   }

//   Future<bool?> _confirmCloseDialog(int count, {required bool completeClose}) {
//     return showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           completeClose ? 'Completely Close Book?' : 'Close Book?',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w800,
//             color: _labelColor,
//           ),
//         ),
//         content: Text(
//           completeClose
//               ? 'This will settle all $count item${count == 1 ? '' : 's'} for '
//                   '${_selectedCounter?.name ?? ''}, using the full ticket range '
//                   'for any items you didn\'t manually enter. This action cannot be undone.'
//               : 'This will settle $count item${count == 1 ? '' : 's'} for '
//                   '${_selectedCounter?.name ?? ''}. This action cannot be undone.',
//           style: GoogleFonts.poppins(color: _labelColor, fontSize: 13.sp),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.poppins(
//                 color: _hintColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _primary,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: Text(
//               'Confirm',
//               style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showToast(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: isError ? Colors.redAccent : _primary,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         content: Text(
//           message,
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Totals ────────────────────────────────────────────────────────────────
//   int get _totalNos => _rows.fold(0, (s, r) => s + r.nos);
//   double get _totalAmount => _rows.fold(0.0, (s, r) => s + r.amount);
//   int get _totalOpening => _rows.fold(0, (s, r) => s + r.item.fromNo);
//   int get _totalClosing => _rows.fold(0, (s, r) => s + r.toNo);

//   // ── API date formatter (yyyy-MM-dd) ─────────────────────────────────────
//   String _apiDateFmt(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: AppBar(
//         toolbarHeight: 0,
//         elevation: 0,
//         systemOverlayStyle: const SystemUiOverlayStyle(
//           statusBarColor: _primary,
//           statusBarIconBrightness: Brightness.light,
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildHeader(),
//           Expanded(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               padding: EdgeInsets.fromLTRB(14.w, 20.h, 14.w, 32.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Date + Temple row ──────────────────────────────────
//                   Row(
//                     children: [
//                       Expanded(child: _buildDatePicker()),
//                       SizedBox(width: 10.w),
//                       Expanded(child: _buildTempleDropdown()),
//                     ],
//                   ),
//                   SizedBox(height: 22.h),

//                   // ── Table ─────────────────────────────────────────────
//                   if (_selectedCounter == null)
//                     _buildEmptyPrompt()
//                   else if (_isLoadingRows)
//                     _buildLoadingState()
//                   else if (_rows.isEmpty)
//                     _buildNoEntriesState()
//                   else ...[
//                     _sectionLabel('Entries'),
//                     SizedBox(height: 10.h),
//                     _buildTable(),
//                     SizedBox(height: 24.h),
//                     _buildSaveButton(),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Header ───────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFFE77F75), Color(0xFFF1907A), Color(0xFFE77F75)],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 22.h),
//           child: Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 38.w,
//                   height: 38.h,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.white.withOpacity(0.25)),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 14.w),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Ticket Entry',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white.withOpacity(0.6),
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 2.5,
//                     ),
//                   ),
//                   Text(
//                     'Close & Settle Book',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.w800,
//                       height: 1.2,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Section label ─────────────────────────────────────────────────────────
//   Widget _sectionLabel(String text) => Row(
//         children: [
//           Container(
//             width: 3.w,
//             height: 14.h,
//             decoration: BoxDecoration(
//               color: _saffron,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           SizedBox(width: 8.w),
//           Text(
//             text.toUpperCase(),
//             style: GoogleFonts.poppins(
//               color: _labelColor,
//               fontSize: 11.sp,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.8,
//             ),
//           ),
//         ],
//       );

//   // ── Date picker tile ──────────────────────────────────────────────────────
//   Widget _buildDatePicker() {
//     final label =
//         '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
//     return GestureDetector(
//       onTap: _pickDate,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: const Color(0xFFEADDD8)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 32.w,
//               height: 32.w,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF9E8E8),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.calendar_today_rounded,
//                 color: _primary,
//                 size: 15,
//               ),
//             ),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'DATE',
//                     style: GoogleFonts.poppins(
//                       color: _hintColor,
//                       fontSize: 9.sp,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1.4,
//                     ),
//                   ),
//                   Text(
//                     label,
//                     style: GoogleFonts.poppins(
//                       color: _labelColor,
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               color: _primary,
//               size: 18,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Temple dropdown ───────────────────────────────────────────────────────
//   Widget _buildTempleDropdown() {
//     final counterList = context.watch<HomeProvider>().counterdata ?? [];
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFEADDD8)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<Datum>(
//           value: _selectedCounter,
//           isExpanded: true,
//           isDense: true,
//           icon: const Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: _primary,
//             size: 18,
//           ),
//           hint: Text(
//             'Counter',
//             style: GoogleFonts.poppins(
//               color: _hintColor,
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           style: GoogleFonts.poppins(
//             color: _labelColor,
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w600,
//           ),
//           dropdownColor: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           items: counterList
//               .map(
//                 (t) => DropdownMenuItem<Datum>(
//                   value: t,
//                   child: Text(t.name ?? '', overflow: TextOverflow.ellipsis),
//                 ),
//               )
//               .toList(),
//           onChanged: _onCounterChanged,
//         ),
//       ),
//     );
//   }

//   // ── TABLE ─────────────────────────────────────────────────────────────────
//   Widget _buildTable() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFEADDD8)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.hardEdge,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             minWidth: MediaQuery.of(context).size.width - 28.w,
//           ),
//           child: Column(
//             children: [
//               _buildTableHeader(),
//               ...List.generate(
//                 _rows.length,
//                 (i) => _buildTableRow(_rows[i], i),
//               ),
//               _buildTotalRow(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   static const _cols = [
//     'Sl\nNo',
//     'Item',
//     'From\nNo',
//     'To No',
//     'Nos',
//     'Amount\n(₹)',
//     'Opening\nTicket',
//     'Closing\nTickets',
//   ];
//   static const _colWidths = [38.0, 120.0, 58.0, 72.0, 44.0, 72.0, 68.0, 68.0];

//   Widget _buildTableHeader() {
//     return Container(
//       color: _primary,
//       child: Row(
//         children: List.generate(_cols.length, (i) {
//           return SizedBox(
//             width: _colWidths[i].w,
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
//               child: Text(
//                 _cols[i],
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 10.sp,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.5,
//                   height: 1.3,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildTableRow(_PoojaRow row, int index) {
//     final isEven = index.isEven;
//     final nosVal = row.nos;
//     final amtVal = row.amount;

//     return Container(
//       color: isEven ? const Color(0xFFFDF8F5) : Colors.white,
//       child: Row(
//         children: [
//           // Sl No
//           _cell(row.item.slno.toString(), _colWidths[0], center: true),
//           // Vazhivad
//           _cell(row.item.vazhivadItem, _colWidths[1], isLeft: true),
//           // From No
//           _cell(row.item.fromNo.toString(), _colWidths[2], center: true),
//           // To No — editable
//           SizedBox(
//             width: _colWidths[3].w,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
//               child: Container(
//                 height: 34.h,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF9E8E8),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: _primary.withOpacity(0.3)),
//                 ),
//                 child: TextFormField(
//                   controller: row.toNoCtrl,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     color: _primary,
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: '—',
//                     hintStyle: GoogleFonts.poppins(
//                       color: _hintColor,
//                       fontSize: 12.sp,
//                     ),
//                     contentPadding: EdgeInsets.symmetric(vertical: 8.h),
//                     isDense: true,
//                   ),
//                   onChanged: (_) => setState(() {}),
//                 ),
//               ),
//             ),
//           ),
//           // Nos
//           _cell(
//             nosVal > 0 ? nosVal.toString() : '0',
//             _colWidths[4],
//             center: true,
//             bold: nosVal > 0,
//             color: nosVal > 0 ? _saffron : _hintColor,
//           ),
//           // Amount
//           _cell(
//             amtVal > 0 ? amtVal.toStringAsFixed(0) : '0',
//             _colWidths[5],
//             center: true,
//             bold: amtVal > 0,
//             color: amtVal > 0 ? _saffron : _hintColor,
//           ),
//           // Opening ticket (From No)
//           _cell(
//             row.item.fromNo.toString(),
//             _colWidths[6],
//             center: true,
//             color: const Color(0xFF6D1A1A),
//             bold: true,
//           ),
//           // Closing tickets (To No)
//           _cell(
//             row.toNo > 0 ? row.toNo.toString() : '0',
//             _colWidths[7],
//             center: true,
//             color: row.toNo > 0 ? const Color(0xFF2E6B4F) : _hintColor,
//             bold: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotalRow() {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF6D1A1A).withOpacity(0.06),
//         border: Border(
//           top: BorderSide(color: _primary.withOpacity(0.2), width: 1.5),
//         ),
//       ),
//       child: Row(
//         children: [
//           _cell('', _colWidths[0]),
//           _cell(
//             'Total',
//             _colWidths[1],
//             isLeft: true,
//             bold: true,
//             color: _primary,
//           ),
//           _cell('', _colWidths[2]),
//           _cell('', _colWidths[3]),
//           _cell(
//             _totalNos.toString(),
//             _colWidths[4],
//             center: true,
//             bold: true,
//             color: _saffron,
//           ),
//           _cell(
//             _totalAmount.toStringAsFixed(0),
//             _colWidths[5],
//             center: true,
//             bold: true,
//             color: _saffron,
//           ),
//           _cell(
//             _totalOpening.toString(),
//             _colWidths[6],
//             center: true,
//             bold: true,
//             color: _primary,
//           ),
//           _cell(
//             _totalClosing.toString(),
//             _colWidths[7],
//             center: true,
//             bold: true,
//             color: const Color(0xFF2E6B4F),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _cell(
//     String text,
//     double width, {
//     bool center = false,
//     bool isLeft = false,
//     bool bold = false,
//     Color? color,
//   }) {
//     return SizedBox(
//       width: width.w,
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
//         child: Text(
//           text,
//           textAlign: isLeft
//               ? TextAlign.left
//               : (center ? TextAlign.center : TextAlign.right),
//           style: GoogleFonts.poppins(
//             color: color ?? _labelColor,
//             fontSize: 12.sp,
//             fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Empty prompt (no counter selected yet) ─────────────────────────────────
//   Widget _buildEmptyPrompt() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFEADDD8)),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.temple_hindu_outlined, color: _hintColor, size: 36),
//           SizedBox(height: 12.h),
//           Text(
//             'Select a date and temple\nto load entries',
//             textAlign: TextAlign.center,
//             style: GoogleFonts.poppins(
//               color: _hintColor,
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Loading state ────────────────────────────────────────────────────────
//   Widget _buildLoadingState() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(vertical: 48.h),
//       alignment: Alignment.center,
//       child: const CircularProgressIndicator(color: _primary),
//     );
//   }

//   // ── No entries state (counter+date chosen, nothing to close) ───────────────
//   Widget _buildNoEntriesState() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFEADDD8)),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.inbox_outlined, color: _hintColor, size: 36),
//           SizedBox(height: 12.h),
//           Text(
//             'No issued books found for\n${_selectedCounter?.name ?? ''} on this date',
//             textAlign: TextAlign.center,
//             style: GoogleFonts.poppins(
//               color: _hintColor,
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Save buttons (Close / Completely Close) ────────────────────────────────
//   Widget _buildSaveButton() {
//     final hasCounter = _selectedCounter != null;
//     final canClose = !_isSaving && hasCounter && _totalNos > 0;
//     final canCompleteClose = !_isSaving && hasCounter && _rows.isNotEmpty;

//     return Row(
//       children: [
//         // ── Close (only rows with a manually entered "To No") ──────────
//         Expanded(
//           child: SizedBox(
//             height: 52.h,
//             child: OutlinedButton.icon(
//               onPressed:
//                   canClose ? () => _onSave(completeClose: false) : null,
//               icon: _isSaving
//                   ? SizedBox(
//                       width: 18.w,
//                       height: 18.w,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 2.2,
//                         color: _primary,
//                       ),
//                     )
//                   : const Icon(Icons.lock_outline_rounded, size: 20),
//               label: Text(
//                 'Close',
//                 style: GoogleFonts.poppins(
//                   fontSize: 15.sp,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: _primary,
//                 side: const BorderSide(color: _primary, width: 1.5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: 10.w),
//         // ── Completely Close (auto-fills blank rows with full range) ───
//         Expanded(
//           child: SizedBox(
//             height: 52.h,
//             child: ElevatedButton.icon(
//               onPressed: canCompleteClose
//                   ? () => _onSave(completeClose: true)
//                   : null,
//               icon: _isSaving
//                   ? SizedBox(
//                       width: 18.w,
//                       height: 18.w,
//                       child: const CircularProgressIndicator(
//                         strokeWidth: 2.2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Icon(Icons.lock_rounded, size: 20),
//               label: Text(
//                 _isSaving ? 'Closing...' : 'Completely Close',
//                 style: GoogleFonts.poppins(
//                   fontSize: 15.sp,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _primary,
//                 foregroundColor: Colors.white,
//                 disabledBackgroundColor: _primary.withOpacity(0.4),
//                 elevation: 3,
//                 shadowColor: _primary.withOpacity(0.4),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/models/counters_model.dart';
import 'package:punnyam/providers/home_provider.dart';
import 'package:punnyam/providers/ticket_providetr.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _PoojaItem {
  final int slno;
  final int bookIssueId; // needed by the close-book API
  final String vazhivadItem;
  final int fromNo;
  final double ratePerTicket;
  final int openingTicket;

  const _PoojaItem({
    required this.slno,
    required this.bookIssueId,
    required this.vazhivadItem,
    required this.fromNo,
    required this.ratePerTicket,
    required this.openingTicket,
  });
}

class _PoojaRow {
  final _PoojaItem item;
  final TextEditingController toNoCtrl;
  bool isSelected;

  _PoojaRow({required this.item, this.isSelected = false})
      : toNoCtrl = TextEditingController();

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

  Datum? _selectedCounter;
  DateTime _selectedDate = DateTime.now();
  List<_PoojaRow> _rows = [];
  bool _isLoadingRows = false;
  bool _isSaving = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
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

  @override
  void dispose() {
    for (final r in _rows) r.dispose();
    super.dispose();
  }

  // ── Data fetch ───────────────────────────────────────────────────────────
  Future<void> _fetchVazhivadEntries() async {
    final counter = _selectedCounter;
    if (counter?.id == null) return;

    setState(() => _isLoadingRows = true);

    final homeProvider = context.read<TicketProvidetr>();
    await homeProvider.bookIssueAvailable(
      counterId: counter!.id!,
      date: _apiDateFmt(_selectedDate),
    );

    if (!mounted) return;

    for (final r in _rows) {
      r.dispose();
    }

    final fetched = homeProvider.bookIssueAvailableList;
    setState(() {
      _rows = List.generate(fetched.length, (i) {
        final entry = fetched[i];
        return _PoojaRow(
          item: _PoojaItem(
            slno: i + 1,
            bookIssueId: entry.id ?? 0,
            vazhivadItem: entry.poojaName,
            fromNo: entry.nextleaffrom ?? entry.leafFrom,
            ratePerTicket: entry.ratePerTicket,
            openingTicket: entry.openingTicket,
          ),
        );
      });
      _isLoadingRows = false;
    });
  }

  void _onCounterChanged(Datum? counter) {
    setState(() => _selectedCounter = counter);
    if (counter != null) _fetchVazhivadEntries();
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
    if (picked != null) {
      setState(() => _selectedDate = picked);
      if (_selectedCounter != null) _fetchVazhivadEntries();
    }
  }

  // ── Selection helpers ────────────────────────────────────────────────────
  int get _selectedCount => _rows.where((r) => r.isSelected).length;

  bool get _allSelected =>
      _rows.isNotEmpty && _rows.every((r) => r.isSelected);

  bool get _someSelected => _rows.any((r) => r.isSelected);

  void _toggleSelectAll(bool? value) {
    setState(() {
      for (final r in _rows) {
        r.isSelected = value ?? false;
      }
    });
  }

  void _toggleRow(_PoojaRow row, bool? value) {
    setState(() => row.isSelected = value ?? false);
  }

  // ── Save / Close book ───────────────────────────────────────────────────
  /// [completeClose] = false  -> "Close": only SELECTED rows where you manually
  ///                              typed a "To No" get closed.
  /// [completeClose] = true   -> "Completely Close": every SELECTED row gets
  ///                              closed; any blank "To No" among selected rows
  ///                              is auto-filled with the last leaf number of
  ///                              that book (fromNo + openingTicket - 1).
  Future<void> _onSave({required bool completeClose}) async {
    final counter = _selectedCounter;
    if (counter?.id == null) return;

    final selectedRows = _rows.where((r) => r.isSelected).toList();

    if (selectedRows.isEmpty) {
      _showToast(
        'Please select at least one item to close',
        isError: true,
      );
      return;
    }

    List<_PoojaRow> itemsToClose;

    if (completeClose) {
      for (final r in selectedRows) {
        if (r.toNoCtrl.text.trim().isEmpty) {
          final lastLeaf = r.item.fromNo + r.item.openingTicket - 1;
          r.toNoCtrl.text = lastLeaf.toString();
        }
      }
      itemsToClose = selectedRows;
    } else {
      // Only close selected rows where a "To No" was actually entered.
      itemsToClose =
          selectedRows.where((r) => r.toNoCtrl.text.trim().isNotEmpty).toList();
    }

    if (itemsToClose.isEmpty) {
      _showToast(
        'Please enter a "To No" for the selected item(s) before closing',
        isError: true,
      );
      return;
    }

    // Validate To No >= From No for every entered row.
    for (final r in itemsToClose) {
      if (r.toNo < r.item.fromNo) {
        _showToast(
          '"To No" for ${r.item.vazhivadItem} cannot be less than From No (${r.item.fromNo})',
          isError: true,
        );
        return;
      }
    }

    final confirmed = await _confirmCloseDialog(
      itemsToClose.length,
      completeClose: completeClose,
    );
    if (confirmed != true) return;

    setState(() => _isSaving = true);

    final items = itemsToClose
        .map((r) => {
              "book_issue_id": r.item.bookIssueId,
              "leaf_used_to": r.toNo,
              "type": completeClose ? "complete" : "partial",
            })
        .toList();

    final ticketProvider = context.read<TicketProvidetr>();
    await ticketProvider.closeBook(
      date: _apiDateFmt(_selectedDate),
      counterId: counter!.id!,
      items: items,
      onSuccess: (model) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        _showToast(
          model.message.isNotEmpty
              ? model.message
              : 'Book closed for ${counter.name ?? ''}',
        );
        // Refresh so the table reflects updated opening/closing counts.
        _fetchVazhivadEntries();
      },
      onFailure: (error) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        _showToast(error, isError: true);
      },
    );

    // Safety net in case neither callback fires for some reason.
    if (mounted && _isSaving) {
      setState(() => _isSaving = false);
    }
  }

  Future<bool?> _confirmCloseDialog(int count, {required bool completeClose}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          completeClose ? 'Completely Close Book?' : 'Close Book?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            color: _labelColor,
          ),
        ),
        content: Text(
          completeClose
              ? 'This will settle the selected $count item${count == 1 ? '' : 's'} for '
                  '${_selectedCounter?.name ?? ''}, using the full ticket range '
                  'for any of them you didn\'t manually enter. This action cannot be undone.'
              : 'This will settle the selected $count item${count == 1 ? '' : 's'} for '
                  '${_selectedCounter?.name ?? ''}. This action cannot be undone.',
          style: GoogleFonts.poppins(color: _labelColor, fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: _hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : _primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Totals ────────────────────────────────────────────────────────────────
  int get _totalNos => _rows.fold(0, (s, r) => s + r.nos);
  double get _totalAmount => _rows.fold(0.0, (s, r) => s + r.amount);
  int get _totalOpening => _rows.fold(0, (s, r) => s + r.item.fromNo);
  int get _totalClosing => _rows.fold(0, (s, r) => s + r.toNo);

  // ── API date formatter (yyyy-MM-dd) ─────────────────────────────────────
  String _apiDateFmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

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
                  if (_selectedCounter == null)
                    _buildEmptyPrompt()
                  else if (_isLoadingRows)
                    _buildLoadingState()
                  else if (_rows.isEmpty)
                    _buildNoEntriesState()
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionLabel('Entries'),
                        if (_someSelected)
                          Text(
                            '$_selectedCount selected',
                            style: GoogleFonts.poppins(
                              color: _primary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    _buildTable(),
                    SizedBox(height: 24.h),
                    _buildSaveButton(),
                  ],
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
    final counterList = context.watch<HomeProvider>().counterdata ?? [];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Datum>(
          value: _selectedCounter,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _primary,
            size: 18,
          ),
          hint: Text(
            'Counter',
            style: GoogleFonts.poppins(
              color: _hintColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: GoogleFonts.poppins(
            color: _labelColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          items: counterList
              .map(
                (t) => DropdownMenuItem<Datum>(
                  value: t,
                  child: Text(t.name ?? '', overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: _onCounterChanged,
        ),
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

  // First column is now the checkbox column ('' header holds the select-all box).
  static const _cols = [
    '',
    'Sl\nNo',
    'Item',
    'From\nNo',
    'To No',
    'Nos',
    'Amount\n(₹)',
    // 'Opening\nTicket',
    // 'Closing\nTickets',
  ];
  static const _colWidths = [
    34.0, // checkbox
    34.0, // sl no
    112.0, // item
    56.0, // from no
    72.0, // to no
    42.0, // nos
    70.0, // amount
    // 66.0, // opening
    // 66.0, // closing
  ];

  Widget _buildTableHeader() {
    return Container(
      color: _primary,
      child: Row(
        children: List.generate(_cols.length, (i) {
          // Checkbox / select-all column
          if (i == 0) {
            return SizedBox(
              width: _colWidths[i].w,
              child: Center(
                child: Transform.scale(
                  scale: 0.85,
                  child: Checkbox(
                    value: _allSelected,
                    tristate: !_allSelected && _someSelected,
                    onChanged: _rows.isEmpty ? null : _toggleSelectAll,
                    fillColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.white,
                    ),
                    checkColor: _primary,
                    side: const BorderSide(color: Colors.white, width: 1.4),
                  ),
                ),
              ),
            );
          }
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
      color: row.isSelected
          ? _primary.withOpacity(0.08)
          : (isEven ? const Color(0xFFFDF8F5) : Colors.white),
      child: Row(
        children: [
          // Row checkbox
          SizedBox(
            width: _colWidths[0].w,
            child: Center(
              child: Transform.scale(
                scale: 0.85,
                child: Checkbox(
                  value: row.isSelected,
                  onChanged: (v) => _toggleRow(row, v),
                  activeColor: _primary,
                  side: BorderSide(color: _primary.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          // Sl No
          _cell(row.item.slno.toString(), _colWidths[1], center: true),
          // Vazhivad
          _cell(row.item.vazhivadItem, _colWidths[2], isLeft: true),
          // From No
          _cell(row.item.fromNo.toString(), _colWidths[3], center: true),
          // To No — editable
          SizedBox(
            width: _colWidths[4].w,
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
                  onChanged: (value) {
                    setState(() {
                      // Auto-select the row once the user starts typing a To No,
                      // so they don't have to tap the checkbox separately.
                      if (value.trim().isNotEmpty) row.isSelected = true;
                    });
                  },
                ),
              ),
            ),
          ),
          // Nos
          _cell(
            nosVal > 0 ? nosVal.toString() : '0',
            _colWidths[5],
            center: true,
            bold: nosVal > 0,
            color: nosVal > 0 ? _saffron : _hintColor,
          ),
          // Amount
          _cell(
            amtVal > 0 ? amtVal.toStringAsFixed(0) : '0',
            _colWidths[6],
            center: true,
            bold: amtVal > 0,
            color: amtVal > 0 ? _saffron : _hintColor,
          ),
          // Opening ticket (From No)
          // _cell(
          //   row.item.fromNo.toString(),
          //   _colWidths[7],
          //   center: true,
          //   color: const Color(0xFF6D1A1A),
          //   bold: true,
          // ),
          // // Closing tickets (To No)
          // _cell(
          //   row.toNo > 0 ? row.toNo.toString() : '0',
          //   _colWidths[8],
          //   center: true,
          //   color: row.toNo > 0 ? const Color(0xFF2E6B4F) : _hintColor,
          //   bold: true,
          // ),
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
          _cell('', _colWidths[1]),
          _cell(
            'Total',
            _colWidths[2],
            isLeft: true,
            bold: true,
            color: _primary,
          ),
          _cell('', _colWidths[3]),
          _cell('', _colWidths[4]),
          _cell(
            _totalNos.toString(),
            _colWidths[5],
            center: true,
            bold: true,
            color: _saffron,
          ),
          _cell(
            _totalAmount.toStringAsFixed(0),
            _colWidths[6],
            center: true,
            bold: true,
            color: _saffron,
          ),
          // _cell(
          //   _totalOpening.toString(),
          //   _colWidths[7],
          //   center: true,
          //   bold: true,
          //   color: _primary,
          // ),
          // _cell(
          //   _totalClosing.toString(),
          //   _colWidths[8],
          //   center: true,
          //   bold: true,
          //   color: const Color(0xFF2E6B4F),
          // ),
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

  // ── Empty prompt (no counter selected yet) ─────────────────────────────────
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
            'Select a date and counter\nto load entries',
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

  // ── Loading state ────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: _primary),
    );
  }

  // ── No entries state (counter+date chosen, nothing to close) ───────────────
  Widget _buildNoEntriesState() {
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
          Icon(Icons.inbox_outlined, color: _hintColor, size: 36),
          SizedBox(height: 12.h),
          Text(
            'No issued books found for\n${_selectedCounter?.name ?? ''} on this date',
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

  // ── Save buttons (Close / Completely Close) ────────────────────────────────
  // Both now act only on the rows the user has checked.
  Widget _buildSaveButton() {
    final hasCounter = _selectedCounter != null;
    final hasSelection = _someSelected;
    final canClose = !_isSaving && hasCounter && hasSelection;
    final canCompleteClose = !_isSaving && hasCounter && hasSelection;

    return Row(
      children: [
        // ── Close (only SELECTED rows with a manually entered "To No") ──
        Expanded(
          child: SizedBox(
            height: 52.h,
            child: OutlinedButton.icon(
              onPressed:
                  canClose ? () => _onSave(completeClose: false) : null,
              icon: _isSaving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: _primary,
                      ),
                    )
                  : const Icon(Icons.lock_outline_rounded, size: 20),
              label: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        // ── Completely Close (auto-fills blank rows among SELECTED) ─────
        Expanded(
          child: SizedBox(
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: canCompleteClose
                  ? () => _onSave(completeClose: true)
                  : null,
              icon: _isSaving
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_rounded, size: 20),
              label: Text(
                _isSaving ? 'Closing...' : 'Completely Close',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
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
          ),
        ),
      ],
    );
  }
}