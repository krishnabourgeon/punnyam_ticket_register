// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:provider/provider.dart';
// // import 'package:punnyam/common/common_functions.dart';
// // import 'package:punnyam/models/book_register_model.dart';
// // import 'package:punnyam/models/pooja_response_model.dart';
// // import 'package:punnyam/providers/billing_provider.dart';
// // import 'package:punnyam/providers/ticket_providetr.dart';

// // class NewBookScreen extends StatefulWidget {
// //   const NewBookScreen({super.key});
// //   @override
// //   State<NewBookScreen> createState() => _NewBookScreenState();
// // }

// // class _BookRow {
// //   PoojaData? selectedPooja;
// //   // final fromCtrl = TextEditingController();
// //   // final toCtrl = TextEditingController();
// //   // final leavesCtrl =
// //   //     TextEditingController(); // leaves per book, entered manually
// //   TextEditingController fromCtrl = TextEditingController();
// //   TextEditingController toCtrl = TextEditingController();
// //   TextEditingController leavesCtrl = TextEditingController();
// //   DateTime date = DateTime.now();
// //   BookRegisterModel? bookRegisterModel;

// //   double? noOfBooks;

// //   bool get hasFractionalBooks => noOfBooks != null && noOfBooks! % 1 != 0;

// //   void dispose() {
// //     fromCtrl.dispose();
// //     toCtrl.dispose();
// //     leavesCtrl.dispose();
// //   }
// // }

// // class _NewBookScreenState extends State<NewBookScreen> {
// //   // ── Colors ──────────────────────────────────────────────────────────────────
// //   static const _primary = Color(0xFFE77F75);
// //   static const _saffron = Color(0xFFE77F75);
// //   static const _bg = Color(0xFFF8F4F0);
// //   static const _cardBg = Colors.white;
// //   static const _labelColor = Color(0xFF4A3728);
// //   static const _hintColor = Color.fromARGB(255, 8, 8, 8);
// //   static const _border = Color(0xFFEADDD8);

// //   final _formKey = GlobalKey<FormState>();

// //   // ── Rows ─────────────────────────────────────────────────────────────────────
// //   final List<_BookRow> _rows = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _rows.add(_newRow());
// //     CommonFunctions.afterInit(() {
// //       final billingProvider = context.read<BillingProvider>();
// //       if (billingProvider.poojaDataList.isEmpty) {
// //         billingProvider.getPoojas();
// //       }
// //     });
// //   }

// //   _BookRow _newRow() {
// //     final row = _BookRow();
// //     // Recalculate No of Books whenever From/To/Leaves changes for this row.
// //     row.fromCtrl.addListener(() => _recalcBooks(row));
// //     row.toCtrl.addListener(() => _recalcBooks(row));
// //     row.leavesCtrl.addListener(() => _recalcBooks(row));
// //     return row;
// //   }

// //   void _recalcBooks(_BookRow row) {
// //     final from = int.tryParse(row.fromCtrl.text.trim());
// //     final to = int.tryParse(row.toCtrl.text.trim());
// //     final leavesPerBook = double.tryParse(row.leavesCtrl.text.trim());

// //     double? result;
// //     if (from != null &&
// //         to != null &&
// //         to >= from &&
// //         leavesPerBook != null &&
// //         leavesPerBook > 0) {
// //       final totalLeaves = to - from + 1;
// //       result = totalLeaves / leavesPerBook;
// //     }
// //     setState(() => row.noOfBooks = result);
// //   }

// //   @override
// //   void dispose() {
// //     for (final row in _rows) {
// //       row.dispose();
// //     }
// //     super.dispose();
// //   }

// //   void _addRow() {
// //     setState(() {
// //       _rows.add(_newRow());
// //     });
// //   }

// //   void _deleteRow(int index) {
// //     if (_rows.length == 1) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           behavior: SnackBarBehavior.floating,
// //           backgroundColor: Colors.grey.shade700,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           content: Text(
// //             'At least one Receipt row is required',
// //             style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp),
// //           ),
// //         ),
// //       );
// //       return;
// //     }
// //     setState(() {
// //       _rows[index].dispose();
// //       _rows.removeAt(index);
// //     });
// //   }

// //   void _onPoojaSelected(_BookRow row, PoojaData? value) {
// //     setState(() => row.selectedPooja = value);
// //   }

// //   Future<void> _pickDate(_BookRow row) async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: row.date,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       builder: (context, child) {
// //         return Theme(
// //           data: Theme.of(
// //             context,
// //           ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
// //           child: child!,
// //         );
// //       },
// //     );
// //     if (picked != null) {
// //       setState(() => row.date = picked);
// //     }
// //   }

// //     String _formatDate(DateTime date) {
// //     return '${date.year.toString().padLeft(4, '0')}-'
// //         '${date.month.toString().padLeft(2, '0')}-'
// //         '${date.day.toString().padLeft(2, '0')}';
// //   }

// //    _onSubmit(BookRegisterModel? bookRegisterModel) async {
// //     if (!_formKey.currentState!.validate()) return;

// //     final ticketProvider = context.read<TicketProvidetr>();
// //     for (final rows in _rows) {
// //       final poojaId = rows.selectedPooja?.poojaId;
// //       final date = rows.date;
// //       final leafFrom = int.tryParse(rows.fromCtrl.text.trim());
// //       final leafTo = int.tryParse(rows.toCtrl.text.trim());
// //       final leafsPerBook = int.tryParse(rows.leavesCtrl.text.trim());
// //       final noofBooks = rows.noOfBooks ?? 0.0;
// //       if (poojaId == null || leafFrom == null || leafTo == null || leafsPerBook == null) {
// //     continue; // or collect this row index to show the user what's missing
// //   }
// //       await ticketProvider.bookRegister(
// //       poojaId: poojaId,
// //       date: _formatDate(date),
// //       leafFrom: leafFrom,
// //       leafTo: leafTo,
// //       leafsPerBook: leafsPerBook,
// //       );
// //     }

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         behavior: SnackBarBehavior.floating,
// //         backgroundColor: _primary,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //         content: Text(
// //           bookRegisterModel?.message ?? 'OOps...!, Something went wrong',
// //           style: GoogleFonts.poppins(
// //             color: Colors.white,
// //             fontSize: 14.sp,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ─── BUILD ──────────────────────────────────────────────────────────────────
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
// //           statusBarBrightness: Brightness.dark,
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           _buildHeader(),
// //           Expanded(
// //             child: Form(
// //               key: _formKey,
// //               child: SingleChildScrollView(
// //                 physics: const BouncingScrollPhysics(),
// //                 padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     for (int i = 0; i < _rows.length; i++) ...[
// //                       _buildBookCard(i),
// //                       SizedBox(height: 14.h),
// //                     ],
// //                     _buildAddRowButton(),
// //                     SizedBox(height: 28.h),
// //                     _buildSubmitButton(),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ─── HEADER ─────────────────────────────────────────────────────────────────
// //   Widget _buildHeader() {
// //     return Container(
// //       height: 100,
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
// //                     border: Border.all(
// //                       color: Colors.white.withOpacity(0.25),
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: const Icon(
// //                     Icons.arrow_back_ios_new_rounded,
// //                     color: Colors.white,
// //                     size: 16,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(width: 14.w),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Text(
// //                       'Double Lock Receipt',
// //                       overflow: TextOverflow.ellipsis,
// //                       style: GoogleFonts.poppins(
// //                         color: Colors.white.withOpacity(0.6),
// //                         fontSize: 11.sp,
// //                         fontWeight: FontWeight.w600,
// //                         letterSpacing: 2.5,
// //                       ),
// //                     ),
// //                     Text(
// //                       'Register Ticket Receipt',
// //                       overflow: TextOverflow.ellipsis,
// //                       style: GoogleFonts.poppins(
// //                         color: Colors.white,
// //                         fontSize: 20.sp,
// //                         fontWeight: FontWeight.w800,
// //                         height: 1.2,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(width: 8.w),
// //               Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white.withOpacity(0.15),
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Text(
// //                   '${_rows.length} ${_rows.length > 1 ? "Receipts" : "Receipt"}',
// //                   style: GoogleFonts.poppins(
// //                     color: Colors.white,
// //                     fontSize: 12.sp,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ─── SECTION LABEL ──────────────────────────────────────────────────────────
// //   Widget _sectionLabel(String text) {
// //     return Row(
// //       children: [
// //         Container(
// //           width: 3.w,
// //           height: 14.h,
// //           decoration: BoxDecoration(
// //             color: _saffron,
// //             borderRadius: BorderRadius.circular(2),
// //           ),
// //         ),
// //         SizedBox(width: 8.w),
// //         Text(
// //           text.toUpperCase(),
// //           style: GoogleFonts.poppins(
// //             color: _labelColor,
// //             fontSize: 11.sp,
// //             fontWeight: FontWeight.w700,
// //             letterSpacing: 1.8,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ─── BOOK CARD (one row of the form) ────────────────────────────────────────
// //   Widget _buildBookCard(int index) {
// //     final row = _rows[index];
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _cardBg,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: _border, width: 1),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Row header: "Receipt N" + delete icon
// //           Row(
// //             children: [
// //               Container(
// //                 width: 26.w,
// //                 height: 26.w,
// //                 decoration: BoxDecoration(
// //                   color: _primary.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 alignment: Alignment.center,
// //                 child: Text(
// //                   '${index + 1}',
// //                   style: GoogleFonts.poppins(
// //                     color: _primary,
// //                     fontSize: 13.sp,
// //                     fontWeight: FontWeight.w800,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(width: 10.w),
// //               Text(
// //                 'Receipt ${index + 1}',
// //                 style: GoogleFonts.poppins(
// //                   color: _labelColor,
// //                   fontSize: 14.sp,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //               const Spacer(),
// //               InkWell(
// //                 borderRadius: BorderRadius.circular(8),
// //                 onTap: () => _deleteRow(index),
// //                 child: Container(
// //                   padding: EdgeInsets.all(6.w),
// //                   decoration: BoxDecoration(
// //                     color: Colors.red.withOpacity(0.08),
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Icon(
// //                     Icons.delete_outline_rounded,
// //                     color: Colors.red.shade400,
// //                     size: 18,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 14.h),

// //           _sectionLabel('Date'),
// //           SizedBox(height: 8.h),
// //           _buildDateField(row),
// //           SizedBox(height: 14.h),

// //           _sectionLabel('Pooja Item'),
// //           SizedBox(height: 8.h),
// //           _buildPoojaDropdown(row),
// //           SizedBox(height: 14.h),

// //           _sectionLabel('Leaf Range'),
// //           SizedBox(height: 8.h),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: _buildTextField(
// //                   controller: row.fromCtrl,
// //                   label: 'From No',
// //                   hint: 'e.g. 1',
// //                   icon: Icons.first_page_rounded,
// //                   keyboardType: TextInputType.number,
// //                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //                   validator: (v) =>
// //                       (v == null || v.trim().isEmpty) ? 'Required' : null,
// //                 ),
// //               ),
// //               SizedBox(width: 10.w),
// //               Expanded(
// //                 child: _buildTextField(
// //                   controller: row.toCtrl,
// //                   label: 'To No',
// //                   hint: 'e.g. 100',
// //                   icon: Icons.last_page_rounded,
// //                   keyboardType: TextInputType.number,
// //                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //                   validator: (v) =>
// //                       (v == null || v.trim().isEmpty) ? 'Required' : null,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 12.h),

// //           // Leaves per Book (entered manually) + No of Books (derived)
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: _buildTextField(
// //                   controller: row.leavesCtrl,
// //                   label: 'Leaves / Book',
// //                   hint: 'e.g. 50',
// //                   icon: Icons.layers_outlined,
// //                   keyboardType: TextInputType.number,
// //                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //                   validator: (v) =>
// //                       (v == null || v.trim().isEmpty) ? 'Required' : null,
// //                 ),
// //               ),
// //               SizedBox(width: 10.w),
// //               Expanded(child: _buildBooksField(row)),
// //             ],
// //           ),
// //           if (row.hasFractionalBooks) ...[
// //             SizedBox(height: 8.h),
// //             Row(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Icon(
// //                   Icons.error_outline_rounded,
// //                   color: Colors.red.shade400,
// //                   size: 14,
// //                 ),
// //                 SizedBox(width: 6.w),
// //                 Expanded(
// //                   child: Text(
// //                     'Leaf range doesn\'t divide evenly into whole Receipts. Adjust From/To.',
// //                     style: GoogleFonts.poppins(
// //                       color: Colors.red.shade400,
// //                       fontSize: 11.sp,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }

// //   // ─── DATE FIELD ─────────────────────────────────────────────────────────────
// //   Widget _buildDateField(_BookRow row) {
// //     final dateStr =
// //         '${row.date.month.toString().padLeft(2, '0')}/${row.date.day.toString().padLeft(2, '0')}/${row.date.year}';
// //     return InkWell(
// //       onTap: () => _pickDate(row),
// //       borderRadius: BorderRadius.circular(14),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: _cardBg,
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(color: _border, width: 1),
// //         ),
// //         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 32.w,
// //               height: 32.w,
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF9E8E8),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               alignment: Alignment.center,
// //               child: const Icon(
// //                 Icons.calendar_today_rounded,
// //                 color: _primary,
// //                 size: 15,
// //               ),
// //             ),
// //             SizedBox(width: 12.w),
// //             Text(
// //               dateStr,
// //               style: GoogleFonts.poppins(
// //                 color: _labelColor,
// //                 fontSize: 15.sp,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //             const Spacer(),
// //             const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ─── DROPDOWN (static local list, no API) ──────────────────────────────────
// //   Widget _buildPoojaDropdown(_BookRow row) {
// //     final poojaList = context.watch<BillingProvider>().poojaDataList;
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _cardBg,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: _border, width: 1),
// //       ),
// //       child: DropdownButtonFormField<PoojaData>(
// //         value: row.selectedPooja,
// //         isExpanded: true,
// //         decoration: InputDecoration(
// //           prefixIcon: Padding(
// //             padding: EdgeInsets.all(10.w),
// //             child: Container(
// //               width: 30.w,
// //               height: 30.w,
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF9E8E8),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: const Icon(
// //                 Icons.temple_hindu_outlined,
// //                 color: _primary,
// //                 size: 15,
// //               ),
// //             ),
// //           ),
// //           labelText: 'Select Pooja',
// //           labelStyle: GoogleFonts.poppins(
// //             color: _hintColor,
// //             fontSize: 12.sp,
// //             fontWeight: FontWeight.w500,
// //           ),
// //           border: InputBorder.none,
// //           contentPadding: EdgeInsets.symmetric(
// //             horizontal: 14.w,
// //             vertical: 12.h,
// //           ),
// //           errorStyle: GoogleFonts.poppins(
// //             color: Colors.red.shade400,
// //             fontSize: 10.sp,
// //           ),
// //         ),
// //         style: GoogleFonts.poppins(
// //           color: _labelColor,
// //           fontSize: 14.sp,
// //           fontWeight: FontWeight.w600,
// //         ),
// //         dropdownColor: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //         icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
// //         items: poojaList
// //             .map(
// //               (e) => DropdownMenuItem<PoojaData>(
// //                 value: e,
// //                 child: Text(e.name ?? "", overflow: TextOverflow.ellipsis),
// //               ),
// //             )
// //             .toList(),
// //         onChanged: (value) => _onPoojaSelected(row, value),
// //         validator: (v) => v == null ? 'Required' : null,
// //       ),
// //     );
// //   }

// //   // ─── TEXT FIELD ─────────────────────────────────────────────────────────────
// //   Widget _buildTextField({
// //     required TextEditingController controller,
// //     required String label,
// //     required String hint,
// //     required IconData icon,
// //     TextInputType keyboardType = TextInputType.text,
// //     List<TextInputFormatter>? inputFormatters,
// //     String? Function(String?)? validator,
// //   }) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _cardBg,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: _border, width: 1),
// //       ),
// //       child: TextFormField(
// //         controller: controller,
// //         keyboardType: keyboardType,
// //         inputFormatters: inputFormatters,
// //         style: GoogleFonts.poppins(
// //           color: _labelColor,
// //           fontSize: 14.sp,
// //           fontWeight: FontWeight.w600,
// //         ),
// //         decoration: InputDecoration(
// //           prefixIcon: Padding(
// //             padding: EdgeInsets.all(10.w),
// //             child: Container(
// //               width: 30.w,
// //               height: 30.w,
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF9E8E8),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Icon(icon, color: _primary, size: 15),
// //             ),
// //           ),
// //           labelText: label,
// //           hintText: hint,
// //           labelStyle: GoogleFonts.poppins(
// //             color: _hintColor,
// //             fontSize: 12.sp,
// //             fontWeight: FontWeight.w500,
// //           ),
// //           hintStyle: GoogleFonts.poppins(color: _hintColor, fontSize: 12.sp),
// //           border: InputBorder.none,
// //           contentPadding: EdgeInsets.symmetric(
// //             horizontal: 14.w,
// //             vertical: 12.h,
// //           ),
// //           errorStyle: GoogleFonts.poppins(
// //             color: Colors.red.shade400,
// //             fontSize: 10.sp,
// //           ),
// //         ),
// //         validator: validator,
// //       ),
// //     );
// //   }

// //   // ─── BOOKS FIELD (derived, read-only) ──────────────────────────────────────
// //   String _formatBooks(double value) {
// //     if (value % 1 == 0) return value.toInt().toString();
// //     // Trim trailing zeros but keep decimal precision readable, e.g. 2.4
// //     return value
// //         .toStringAsFixed(2)
// //         .replaceFirst(RegExp(r'0+$'), '')
// //         .replaceFirst(RegExp(r'\.$'), '');
// //   }

// //   Widget _buildBooksField(_BookRow row) {
// //     final value = row.noOfBooks;
// //     final hasValue = value != null;
// //     final isFractional = row.hasFractionalBooks;

// //     final accentColor = isFractional ? Colors.red.shade400 : _saffron;
// //     final textColor = !hasValue
// //         ? _hintColor
// //         : (isFractional ? Colors.red.shade400 : _primary);

// //     return Container(
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [
// //             (isFractional ? Colors.red : _primary).withOpacity(0.06),
// //             accentColor.withOpacity(0.06),
// //           ],
// //         ),
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(
// //           color: hasValue ? accentColor.withOpacity(0.4) : _border,
// //           width: 1,
// //         ),
// //       ),
// //       child: TextFormField(
// //         readOnly: true,
// //         initialValue: hasValue ? _formatBooks(value) : '',
// //         key: ValueKey('books-${hasValue ? value : "empty"}'),
// //         style: GoogleFonts.poppins(
// //           color: textColor,
// //           fontSize: 15.sp,
// //           fontWeight: FontWeight.w800,
// //         ),
// //         decoration: InputDecoration(
// //           prefixIcon: Padding(
// //             padding: EdgeInsets.all(10.w),
// //             child: Container(
// //               width: 30.w,
// //               height: 30.w,
// //               decoration: BoxDecoration(
// //                 color: hasValue
// //                     ? accentColor.withOpacity(0.15)
// //                     : const Color(0xFFF9E8E8),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Icon(
// //                 Icons.menu_book_outlined,
// //                 color: hasValue ? accentColor : _hintColor,
// //                 size: 15,
// //               ),
// //             ),
// //           ),
// //           suffixIcon: hasValue
// //               ? Padding(
// //                   padding: EdgeInsets.only(right: 10.w),
// //                   child: Align(
// //                     alignment: Alignment.center,
// //                     widthFactor: 1,
// //                     child: Container(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: 8.w,
// //                         vertical: 3.h,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: accentColor.withOpacity(0.12),
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Text(
// //                         isFractional ? '!' : 'Auto',
// //                         style: GoogleFonts.poppins(
// //                           color: accentColor,
// //                           fontSize: 9.sp,
// //                           fontWeight: FontWeight.w700,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 )
// //               : null,
// //           labelText: 'No of Books',
// //           hintText: '—',
// //           labelStyle: GoogleFonts.poppins(
// //             color: _hintColor,
// //             fontSize: 12.sp,
// //             fontWeight: FontWeight.w500,
// //           ),
// //           border: InputBorder.none,
// //           contentPadding: EdgeInsets.symmetric(
// //             horizontal: 14.w,
// //             vertical: 12.h,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ─── ADD ROW BUTTON ─────────────────────────────────────────────────────────
// //   Widget _buildAddRowButton() {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: OutlinedButton.icon(
// //         onPressed: _addRow,
// //         icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
// //         label: Text(
// //           'Add Another Receipt',
// //           style: GoogleFonts.poppins(
// //             fontSize: 14.sp,
// //             fontWeight: FontWeight.w700,
// //           ),
// //         ),
// //         style: OutlinedButton.styleFrom(
// //           foregroundColor: _primary,
// //           side: BorderSide(color: _primary.withOpacity(0.4), width: 1.2),
// //           padding: EdgeInsets.symmetric(vertical: 13.h),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(14),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ─── SUBMIT BUTTON ──────────────────────────────────────────────────────────
// //   Widget _buildSubmitButton() {
// //     return SizedBox(
// //       width: double.infinity,
// //       height: 52.h,
// //       child: ElevatedButton.icon(
// //         onPressed: () => _onSubmit(null),
// //         icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
// //         label: Text(
// //           'Submit Data',
// //           style: GoogleFonts.poppins(
// //             fontSize: 17.sp,
// //             fontWeight: FontWeight.w700,
// //             letterSpacing: 0.5,
// //           ),
// //         ),
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: _primary,
// //           foregroundColor: Colors.white,
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
// import 'package:punnyam/common/common_functions.dart';
// import 'package:punnyam/models/book_register_model.dart';
// import 'package:punnyam/models/pooja_response_model.dart';
// import 'package:punnyam/providers/billing_provider.dart';
// import 'package:punnyam/providers/ticket_providetr.dart';

// class NewBookScreen extends StatefulWidget {
//   const NewBookScreen({super.key});
//   @override
//   State<NewBookScreen> createState() => _NewBookScreenState();
// }

// class _BookRow {
//   PoojaData? selectedPooja;
//   TextEditingController fromCtrl = TextEditingController();
//   TextEditingController toCtrl = TextEditingController();
//   TextEditingController leavesCtrl = TextEditingController();
//   DateTime date = DateTime.now();
//   BookRegisterModel? bookRegisterModel;

//   double? noOfBooks;

//   // Total leaves in the range, auto-calculated from From/To.
//   int? get totalLeaves {
//     final from = int.tryParse(fromCtrl.text.trim());
//     final to = int.tryParse(toCtrl.text.trim());
//     if (from != null && to != null && to >= from) {
//       return to - from + 1;
//     }
//     return null;
//   }

//   bool get hasFractionalBooks => noOfBooks != null && noOfBooks! % 1 != 0;

//   void dispose() {
//     fromCtrl.dispose();
//     toCtrl.dispose();
//     leavesCtrl.dispose();
//   }
// }

// class _NewBookScreenState extends State<NewBookScreen> {
//   // ── Colors ──────────────────────────────────────────────────────────────────
//   static const _primary = Color(0xFFE77F75);
//   static const _saffron = Color(0xFFE77F75);
//   static const _bg = Color(0xFFF8F4F0);
//   static const _cardBg = Colors.white;
//   static const _labelColor = Color(0xFF4A3728);
//   static const _hintColor = Color.fromARGB(255, 8, 8, 8);
//   static const _border = Color(0xFFEADDD8);

//   final _formKey = GlobalKey<FormState>();

//   // ── Rows ─────────────────────────────────────────────────────────────────────
//   final List<_BookRow> _rows = [];

//   @override
//   void initState() {
//     super.initState();
//     _rows.add(_newRow());
//     CommonFunctions.afterInit(() {
//       final billingProvider = context.read<BillingProvider>();
//       if (billingProvider.poojaDataList.isEmpty) {
//         billingProvider.getPoojas();
//       }
//     });
//   }

//   _BookRow _newRow() {
//     final row = _BookRow();
//     // Recalculate No of Leaves / No of Books whenever From/To/Leaves changes.
//     row.fromCtrl.addListener(() => _recalcBooks(row));
//     row.toCtrl.addListener(() => _recalcBooks(row));
//     row.leavesCtrl.addListener(() => _recalcBooks(row));
//     return row;
//   }

//   void _recalcBooks(_BookRow row) {
//     final leavesPerBook = double.tryParse(row.leavesCtrl.text.trim());
//     final totalLeaves = row.totalLeaves;

//     double? result;
//     if (totalLeaves != null && leavesPerBook != null && leavesPerBook > 0) {
//       result = totalLeaves / leavesPerBook;
//     }
//     setState(() => row.noOfBooks = result);
//   }

//   @override
//   void dispose() {
//     for (final row in _rows) {
//       row.dispose();
//     }
//     super.dispose();
//   }

//   void _addRow() {
//     setState(() {
//       _rows.add(_newRow());
//     });
//   }

//   void _deleteRow(int index) {
//     if (_rows.length == 1) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.grey.shade700,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           content: Text(
//             'At least one Receipt row is required',
//             style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp),
//           ),
//         ),
//       );
//       return;
//     }
//     setState(() {
//       _rows[index].dispose();
//       _rows.removeAt(index);
//     });
//   }

//   void _onPoojaSelected(_BookRow row, PoojaData? value) {
//     setState(() {
//       row.selectedPooja = value;
//       // Auto-fill "Leaves / Book" from the selected pooja's leaf count.
//       // NOTE: assumes PoojaData has a `rate` field for leaves-per-book —
//       // update this to the correct field name if it's called something else.
//       if (value != null) {
//         row.leavesCtrl.text = value.rate?.toString() ?? '';
//       } else {
//         row.leavesCtrl.clear();
//       }
//     });
//     // leavesCtrl's listener already triggers _recalcBooks on text change,
//     // but call it directly too in case the value didn't actually change
//     // (e.g. re-selecting the same pooja) so No of Books stays in sync.
//     _recalcBooks(row);
//   }

//   Future<void> _pickDate(_BookRow row) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: row.date,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(
//             context,
//           ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() => row.date = picked);
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.year.toString().padLeft(4, '0')}-'
//         '${date.month.toString().padLeft(2, '0')}-'
//         '${date.day.toString().padLeft(2, '0')}';
//   }

//   Future<void> _onSubmit() async {
//     if (!_formKey.currentState!.validate()) return;

//     final ticketProvider = context.read<TicketProvidetr>();
//     for (final row in _rows) {
//       final poojaId = row.selectedPooja?.poojaId;
//       final date = row.date;
//       final leafFrom = int.tryParse(row.fromCtrl.text.trim());
//       final leafTo = int.tryParse(row.toCtrl.text.trim());
//       final leafsPerBook = int.tryParse(row.leavesCtrl.text.trim());

//       if (poojaId == null ||
//           leafFrom == null ||
//           leafTo == null ||
//           leafsPerBook == null) {
//         continue; // or collect this row index to show the user what's missing
//       }

//       await ticketProvider.bookRegister(
//         poojaId: poojaId,
//         date: _formatDate(date),
//         leafFrom: leafFrom,
//         leafTo: leafTo,
//         leafsPerBook: leafsPerBook,
//       );
//     }

//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: _primary,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         content: Text(
//           'Receipt${_rows.length > 1 ? 's' : ''} saved successfully!',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── BUILD ──────────────────────────────────────────────────────────────────
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
//           statusBarBrightness: Brightness.dark,
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildHeader(),
//           Expanded(
//             child: Form(
//               key: _formKey,
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     for (int i = 0; i < _rows.length; i++) ...[
//                       _buildBookCard(i),
//                       SizedBox(height: 14.h),
//                     ],
//                     _buildAddRowButton(),
//                     SizedBox(height: 28.h),
//                     _buildSubmitButton(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─── HEADER ─────────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       height: 100,
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
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.25),
//                       width: 1,
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 14.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Double Lock Receipt',
//                       overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.poppins(
//                         color: Colors.white.withOpacity(0.6),
//                         fontSize: 11.sp,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 2.5,
//                       ),
//                     ),
//                     Text(
//                       'Register Ticket Receipt',
//                       overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 20.sp,
//                         fontWeight: FontWeight.w800,
//                         height: 1.2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   '${_rows.length} ${_rows.length > 1 ? "Receipts" : "Receipt"}',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── SECTION LABEL ──────────────────────────────────────────────────────────
//   Widget _sectionLabel(String text) {
//     return Row(
//       children: [
//         Container(
//           width: 3.w,
//           height: 14.h,
//           decoration: BoxDecoration(
//             color: _saffron,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         SizedBox(width: 8.w),
//         Text(
//           text.toUpperCase(),
//           style: GoogleFonts.poppins(
//             color: _labelColor,
//             fontSize: 11.sp,
//             fontWeight: FontWeight.w700,
//             letterSpacing: 1.8,
//           ),
//         ),
//       ],
//     );
//   }

//   // ─── BOOK CARD (one row of the form) ────────────────────────────────────────
//   Widget _buildBookCard(int index) {
//     final row = _rows[index];
//     return Container(
//       decoration: BoxDecoration(
//         color: _cardBg,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _border, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Row header: "Receipt N" + delete icon
//           Row(
//             children: [
//               Container(
//                 width: 26.w,
//                 height: 26.w,
//                 decoration: BoxDecoration(
//                   color: _primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   '${index + 1}',
//                   style: GoogleFonts.poppins(
//                     color: _primary,
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Text(
//                 'Receipt ${index + 1}',
//                 style: GoogleFonts.poppins(
//                   color: _labelColor,
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const Spacer(),
//               InkWell(
//                 borderRadius: BorderRadius.circular(8),
//                 onTap: () => _deleteRow(index),
//                 child: Container(
//                   padding: EdgeInsets.all(6.w),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.delete_outline_rounded,
//                     color: Colors.red.shade400,
//                     size: 18,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 14.h),

//           _sectionLabel('Date'),
//           SizedBox(height: 8.h),
//           _buildDateField(row),
//           SizedBox(height: 14.h),

//           _sectionLabel('Pooja Item'),
//           SizedBox(height: 8.h),
//           _buildPoojaDropdown(row),
//           SizedBox(height: 14.h),

//           _sectionLabel('Leaf Range'),
//           SizedBox(height: 8.h),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTextField(
//                   controller: row.fromCtrl,
//                   label: 'From No',
//                   hint: 'e.g. 1',
//                   icon: Icons.first_page_rounded,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   validator: (v) =>
//                       (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: _buildTextField(
//                   controller: row.toCtrl,
//                   label: 'To No',
//                   hint: 'e.g. 100',
//                   icon: Icons.last_page_rounded,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   validator: (v) =>
//                       (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),

//           // No of Leaves (auto-calculated from From/To) + Leaves per Book (manual)
//           Row(
//             children: [
//               Expanded(child: _buildLeavesField(row)),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: _buildTextField(
//                   controller: row.leavesCtrl,
//                   label: 'Leaves / Book',
//                   hint: 'e.g. 50',
//                   icon: Icons.layers_outlined,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   validator: (v) =>
//                       (v == null || v.trim().isEmpty) ? 'Required' : null,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),

//           // No of Books (auto-calculated from Leaves / Leaves-per-Book)
//           _buildBooksField(row),

//           if (row.hasFractionalBooks) ...[
//             SizedBox(height: 8.h),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(
//                   Icons.error_outline_rounded,
//                   color: Colors.red.shade400,
//                   size: 14,
//                 ),
//                 SizedBox(width: 6.w),
//                 Expanded(
//                   child: Text(
//                     'Leaf range doesn\'t divide evenly into whole Receipts. Adjust From/To.',
//                     style: GoogleFonts.poppins(
//                       color: Colors.red.shade400,
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // ─── DATE FIELD ─────────────────────────────────────────────────────────────
//   Widget _buildDateField(_BookRow row) {
//     final dateStr =
//         '${row.date.month.toString().padLeft(2, '0')}/${row.date.day.toString().padLeft(2, '0')}/${row.date.year}';
//     return InkWell(
//       onTap: () => _pickDate(row),
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         decoration: BoxDecoration(
//           color: _cardBg,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: _border, width: 1),
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
//         child: Row(
//           children: [
//             Container(
//               width: 32.w,
//               height: 32.w,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF9E8E8),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               alignment: Alignment.center,
//               child: const Icon(
//                 Icons.calendar_today_rounded,
//                 color: _primary,
//                 size: 15,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Text(
//               dateStr,
//               style: GoogleFonts.poppins(
//                 color: _labelColor,
//                 fontSize: 15.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const Spacer(),
//             const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─── DROPDOWN (backed by BillingProvider.poojaDataList) ────────────────────
//   Widget _buildPoojaDropdown(_BookRow row) {
//     final poojaList = context.watch<BillingProvider>().poojaDataList;
//     return Container(
//       decoration: BoxDecoration(
//         color: _cardBg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _border, width: 1),
//       ),
//       child: DropdownButtonFormField<PoojaData>(
//         value: row.selectedPooja,
//         isExpanded: true,
//         decoration: InputDecoration(
//           prefixIcon: Padding(
//             padding: EdgeInsets.all(10.w),
//             child: Container(
//               width: 30.w,
//               height: 30.w,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF9E8E8),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.temple_hindu_outlined,
//                 color: _primary,
//                 size: 15,
//               ),
//             ),
//           ),
//           labelText: 'Select Pooja',
//           labelStyle: GoogleFonts.poppins(
//             color: _hintColor,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w500,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 14.w,
//             vertical: 12.h,
//           ),
//           errorStyle: GoogleFonts.poppins(
//             color: Colors.red.shade400,
//             fontSize: 10.sp,
//           ),
//         ),
//         style: GoogleFonts.poppins(
//           color: _labelColor,
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w600,
//         ),
//         dropdownColor: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
//         items: poojaList
//             .map(
//               (e) => DropdownMenuItem<PoojaData>(
//                 value: e,
//                 child: Text(e.name ?? "", overflow: TextOverflow.ellipsis),
//               ),
//             )
//             .toList(),
//         onChanged: (value) => _onPoojaSelected(row, value),
//         validator: (v) => v == null ? 'Required' : null,
//       ),
//     );
//   }

//   // ─── TEXT FIELD ─────────────────────────────────────────────────────────────
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     List<TextInputFormatter>? inputFormatters,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _cardBg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _border, width: 1),
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         inputFormatters: inputFormatters,
//         style: GoogleFonts.poppins(
//           color: _labelColor,
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w600,
//         ),
//         decoration: InputDecoration(
//           prefixIcon: Padding(
//             padding: EdgeInsets.all(10.w),
//             child: Container(
//               width: 30.w,
//               height: 30.w,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF9E8E8),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(icon, color: _primary, size: 15),
//             ),
//           ),
//           labelText: label,
//           hintText: hint,
//           labelStyle: GoogleFonts.poppins(
//             color: _hintColor,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w500,
//           ),
//           hintStyle: GoogleFonts.poppins(color: _hintColor, fontSize: 12.sp),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 14.w,
//             vertical: 12.h,
//           ),
//           errorStyle: GoogleFonts.poppins(
//             color: Colors.red.shade400,
//             fontSize: 10.sp,
//           ),
//         ),
//         validator: validator,
//       ),
//     );
//   }

//   // ─── NO OF LEAVES FIELD (auto-calculated from From/To, read-only) ──────────
//   Widget _buildLeavesField(_BookRow row) {
//     final value = row.totalLeaves;
//     final hasValue = value != null;
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [_primary.withOpacity(0.06), _saffron.withOpacity(0.06)],
//         ),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: hasValue ? _saffron.withOpacity(0.4) : _border,
//           width: 1,
//         ),
//       ),
//       child: TextFormField(
//         readOnly: true,
//         initialValue: hasValue ? value.toString() : '',
//         key: ValueKey('leaves-${hasValue ? value : "empty"}'),
//         style: GoogleFonts.poppins(
//           color: hasValue ? _primary : _hintColor,
//           fontSize: 15.sp,
//           fontWeight: FontWeight.w800,
//         ),
//         decoration: InputDecoration(
//           prefixIcon: Padding(
//             padding: EdgeInsets.all(10.w),
//             child: Container(
//               width: 30.w,
//               height: 30.w,
//               decoration: BoxDecoration(
//                 color: hasValue
//                     ? _saffron.withOpacity(0.15)
//                     : const Color(0xFFF9E8E8),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.layers_outlined,
//                 color: hasValue ? _saffron : _hintColor,
//                 size: 15,
//               ),
//             ),
//           ),
//           suffixIcon: hasValue
//               ? Padding(
//                   padding: EdgeInsets.only(right: 10.w),
//                   child: Align(
//                     alignment: Alignment.center,
//                     widthFactor: 1,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 3.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _saffron.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         'Auto',
//                         style: GoogleFonts.poppins(
//                           color: _saffron,
//                           fontSize: 9.sp,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               : null,
//           labelText: 'No of Leaves',
//           hintText: '—',
//           labelStyle: GoogleFonts.poppins(
//             color: _hintColor,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w500,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 14.w,
//             vertical: 12.h,
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── BOOKS FIELD (derived, read-only) ──────────────────────────────────────
//   String _formatBooks(double value) {
//     if (value % 1 == 0) return value.toInt().toString();
//     // Trim trailing zeros but keep decimal precision readable, e.g. 2.4
//     return value
//         .toStringAsFixed(2)
//         .replaceFirst(RegExp(r'0+$'), '')
//         .replaceFirst(RegExp(r'\.$'), '');
//   }

//   Widget _buildBooksField(_BookRow row) {
//     final value = row.noOfBooks;
//     final hasValue = value != null;
//     final isFractional = row.hasFractionalBooks;

//     final accentColor = isFractional ? Colors.red.shade400 : _saffron;
//     final textColor = !hasValue
//         ? _hintColor
//         : (isFractional ? Colors.red.shade400 : _primary);

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             (isFractional ? Colors.red : _primary).withOpacity(0.06),
//             accentColor.withOpacity(0.06),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: hasValue ? accentColor.withOpacity(0.4) : _border,
//           width: 1,
//         ),
//       ),
//       child: TextFormField(
//         readOnly: true,
//         initialValue: hasValue ? _formatBooks(value) : '',
//         key: ValueKey('books-${hasValue ? value : "empty"}'),
//         style: GoogleFonts.poppins(
//           color: textColor,
//           fontSize: 15.sp,
//           fontWeight: FontWeight.w800,
//         ),
//         decoration: InputDecoration(
//           prefixIcon: Padding(
//             padding: EdgeInsets.all(10.w),
//             child: Container(
//               width: 30.w,
//               height: 30.w,
//               decoration: BoxDecoration(
//                 color: hasValue
//                     ? accentColor.withOpacity(0.15)
//                     : const Color(0xFFF9E8E8),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.menu_book_outlined,
//                 color: hasValue ? accentColor : _hintColor,
//                 size: 15,
//               ),
//             ),
//           ),
//           suffixIcon: hasValue
//               ? Padding(
//                   padding: EdgeInsets.only(right: 10.w),
//                   child: Align(
//                     alignment: Alignment.center,
//                     widthFactor: 1,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 3.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: accentColor.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         isFractional ? '!' : 'Auto',
//                         style: GoogleFonts.poppins(
//                           color: accentColor,
//                           fontSize: 9.sp,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               : null,
//           labelText: 'No of Books',
//           hintText: '—',
//           labelStyle: GoogleFonts.poppins(
//             color: _hintColor,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w500,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 14.w,
//             vertical: 12.h,
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── ADD ROW BUTTON ─────────────────────────────────────────────────────────
//   Widget _buildAddRowButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: OutlinedButton.icon(
//         onPressed: _addRow,
//         icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
//         label: Text(
//           'Add Another Receipt',
//           style: GoogleFonts.poppins(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: _primary,
//           side: BorderSide(color: _primary.withOpacity(0.4), width: 1.2),
//           padding: EdgeInsets.symmetric(vertical: 13.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── SUBMIT BUTTON ──────────────────────────────────────────────────────────
//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 52.h,
//       child: ElevatedButton.icon(
//         onPressed: _onSubmit,
//         icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
//         label: Text(
//           'Submit Data',
//           style: GoogleFonts.poppins(
//             fontSize: 17.sp,
//             fontWeight: FontWeight.w700,
//             letterSpacing: 0.5,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: _primary,
//           foregroundColor: Colors.white,
//           elevation: 3,
//           shadowColor: _primary.withOpacity(0.4),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/models/book_register_model.dart';
import 'package:punnyam/models/pooja_response_model.dart';
import 'package:punnyam/providers/billing_provider.dart';
import 'package:punnyam/providers/ticket_providetr.dart';

class NewBookScreen extends StatefulWidget {
  const NewBookScreen({super.key});
  @override
  State<NewBookScreen> createState() => _NewBookScreenState();
}

class _BookRow {
  PoojaData? selectedPooja;
  TextEditingController fromCtrl = TextEditingController();
  TextEditingController toCtrl = TextEditingController();
  TextEditingController leavesCtrl = TextEditingController();
  DateTime date = DateTime.now();
  BookRegisterModel? bookRegisterModel;

  double? noOfBooks;

  bool get hasFractionalBooks => noOfBooks != null && noOfBooks! % 1 != 0;

  void dispose() {
    fromCtrl.dispose();
    toCtrl.dispose();
    leavesCtrl.dispose();
  }
}

class _NewBookScreenState extends State<NewBookScreen> {
  // ── Colors ──────────────────────────────────────────────────────────────────
  static const _primary = Color(0xFFE77F75);
  static const _saffron = Color(0xFFE77F75);
  static const _bg = Color(0xFFF8F4F0);
  static const _cardBg = Colors.white;
  static const _labelColor = Color(0xFF4A3728);
  static const _hintColor = Color.fromARGB(255, 8, 8, 8);
  static const _border = Color(0xFFEADDD8);

  final _formKey = GlobalKey<FormState>();

  // ── Rows ─────────────────────────────────────────────────────────────────────
  final List<_BookRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _rows.add(_newRow());
    CommonFunctions.afterInit(() {
      final billingProvider = context.read<BillingProvider>();
      if (billingProvider.poojaDataList.isEmpty) {
        billingProvider.getPoojas();
      }
    });
  }

  _BookRow _newRow() {
    final row = _BookRow();
    // Recalculate No of Leaves / No of Books whenever From/To/Leaves changes.
    row.fromCtrl.addListener(() => _recalcBooks(row));
    row.toCtrl.addListener(() => _recalcBooks(row));
    row.leavesCtrl.addListener(() => _recalcBooks(row));
    return row;
  }

  void _recalcBooks(_BookRow row) {
    final from = int.tryParse(row.fromCtrl.text.trim());
    final to = int.tryParse(row.toCtrl.text.trim());
    final leavesPerBook = double.tryParse(row.leavesCtrl.text.trim());

    double? result;
    if (from != null &&
        to != null &&
        to >= from &&
        leavesPerBook != null &&
        leavesPerBook > 0) {
      final totalLeaves = to - from + 1;
      result = totalLeaves / leavesPerBook;
    }
    setState(() => row.noOfBooks = result);
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(_newRow());
    });
  }

  void _deleteRow(int index) {
    if (_rows.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            'At least one Receipt row is required',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp),
          ),
        ),
      );
      return;
    }
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  void _onPoojaSelected(_BookRow row, PoojaData? value) {
    setState(() => row.selectedPooja = value);
  }

  Future<void> _pickDate(_BookRow row) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: row.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => row.date = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final ticketProvider = context.read<TicketProvidetr>();
    String? successMessage;
    String? errorMessage;
    for (final row in _rows) {
      final poojaId = row.selectedPooja?.poojaId;
      final date = row.date;
      final leafFrom = int.tryParse(row.fromCtrl.text.trim());
      final leafTo = int.tryParse(row.toCtrl.text.trim());
      final leafsPerBook = int.tryParse(row.leavesCtrl.text.trim());

      if (poojaId == null ||
          leafFrom == null ||
          leafTo == null ||
          leafsPerBook == null) {
        continue; // or collect this row index to show the user what's missing
      }

      await ticketProvider.bookRegister(
        poojaId: poojaId,
        date: _formatDate(date),
        leafFrom: leafFrom,
        leafTo: leafTo,
        leafsPerBook: leafsPerBook,
        onSuccess: (model) => successMessage = model.message,
        onFailure: (message) => errorMessage = message,
      );

      if (errorMessage != null) break; // stop on first failure so remaining rows aren't attempted
    }

    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(
            errorMessage!,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      return;
    }

    Navigator.pop(context, successMessage ?? 'Receipt saved successfully!');
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
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
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < _rows.length; i++) ...[
                      _buildBookCard(i),
                      SizedBox(height: 14.h),
                    ],
                    _buildAddRowButton(),
                    SizedBox(height: 28.h),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────────
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Double Lock Receipt',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                      ),
                    ),
                    Text(
                      'Register Ticket Receipt',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_rows.length} ${_rows.length > 1 ? "Receipts" : "Receipt"}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SECTION LABEL ──────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Row(
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
  }

  // ─── BOOK CARD (one row of the form) ────────────────────────────────────────
  Widget _buildBookCard(int index) {
    final row = _rows[index];
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row header: "Receipt N" + delete icon
          Row(
            children: [
              Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                    color: _primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Receipt ${index + 1}',
                style: GoogleFonts.poppins(
                  color: _labelColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _deleteRow(index),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          _sectionLabel('Date'),
          SizedBox(height: 8.h),
          _buildDateField(row),
          SizedBox(height: 14.h),

          _sectionLabel('Pooja Item'),
          SizedBox(height: 8.h),
          _buildPoojaDropdown(row),
          SizedBox(height: 14.h),

          _sectionLabel('No of Leaves'),
          SizedBox(height: 8.h),
          //_buildNoOfLeavesField(),
          _buildLeavesField(row),
          SizedBox(height: 14.h),

          _sectionLabel('Leaf Range'),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: row.fromCtrl,
                  label: 'From No',
                  hint: 'e.g. 1',
                  icon: Icons.first_page_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildTextField(
                  controller: row.toCtrl,
                  label: 'To No',
                  hint: 'e.g. 100',
                  icon: Icons.last_page_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // No of Books (auto-calculated from Leaf Range / No of Leaves per book)
          _buildBooksField(row),

          if (row.hasFractionalBooks) ...[
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade400,
                  size: 14,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'Leaf range doesn\'t divide evenly into whole Receipts. Adjust From/To.',
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade400,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── DATE FIELD ─────────────────────────────────────────────────────────────
  Widget _buildDateField(_BookRow row) {
    final dateStr =
        '${row.date.month.toString().padLeft(2, '0')}/${row.date.day.toString().padLeft(2, '0')}/${row.date.year}';
    return InkWell(
      onTap: () => _pickDate(row),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF9E8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.calendar_today_rounded,
                color: _primary,
                size: 15,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              dateStr,
              style: GoogleFonts.poppins(
                color: _labelColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
          ],
        ),
      ),
    );
  }

  // ─── DROPDOWN (backed by BillingProvider.poojaDataList) ────────────────────
  Widget _buildPoojaDropdown(_BookRow row) {
    final poojaList = context.watch<BillingProvider>().poojaDataList;
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1),
      ),
      child: DropdownButtonFormField<PoojaData>(
        value: row.selectedPooja,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(10.w),
            child: Container(
              width: 30.w,
              height: 30.w,
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
          labelText: 'Select Pooja',
          labelStyle: GoogleFonts.poppins(
            color: _hintColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
          errorStyle: GoogleFonts.poppins(
            color: Colors.red.shade400,
            fontSize: 10.sp,
          ),
        ),
        style: GoogleFonts.poppins(
          color: _labelColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
        items: poojaList
            .map(
              (e) => DropdownMenuItem<PoojaData>(
                value: e,
                child: Text(e.name ?? "", overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (value) => _onPoojaSelected(row, value),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  // ─── TEXT FIELD ─────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.poppins(
          color: _labelColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(10.w),
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF9E8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _primary, size: 15),
            ),
          ),
          labelText: label,
          hintText: hint,
          labelStyle: GoogleFonts.poppins(
            color: _hintColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.poppins(color: _hintColor, fontSize: 12.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
          errorStyle: GoogleFonts.poppins(
            color: Colors.red.shade400,
            fontSize: 10.sp,
          ),
        ),
        validator: validator,
      ),
    );
  }

  // ─── NO OF LEAVES FIELD (leaves per book, entered manually) ─────────────────
  Widget _buildLeavesField(_BookRow row) {
    return _buildTextField(
      controller: row.leavesCtrl,
      label: 'No of Leaves (per book)',
      hint: 'e.g. 50',
      icon: Icons.layers_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }

  // ─── BOOKS FIELD (derived, read-only) ──────────────────────────────────────
  String _formatBooks(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    // Trim trailing zeros but keep decimal precision readable, e.g. 2.4
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  Widget _buildBooksField(_BookRow row) {
    final value = row.noOfBooks;
    final hasValue = value != null;
    final isFractional = row.hasFractionalBooks;

    final accentColor = isFractional ? Colors.red.shade400 : _saffron;
    final textColor = !hasValue
        ? _hintColor
        : (isFractional ? Colors.red.shade400 : _primary);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isFractional ? Colors.red : _primary).withOpacity(0.06),
            accentColor.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasValue ? accentColor.withOpacity(0.4) : _border,
          width: 1,
        ),
      ),
      child: TextFormField(
        readOnly: true,
        initialValue: hasValue ? _formatBooks(value) : '',
        key: ValueKey('books-${hasValue ? value : "empty"}'),
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(10.w),
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: hasValue
                    ? accentColor.withOpacity(0.15)
                    : const Color(0xFFF9E8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                color: hasValue ? accentColor : _hintColor,
                size: 15,
              ),
            ),
          ),
          suffixIcon: hasValue
              ? Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isFractional ? '!' : 'Auto',
                        style: GoogleFonts.poppins(
                          color: accentColor,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          labelText: 'No of Books',
          hintText: '—',
          labelStyle: GoogleFonts.poppins(
            color: _hintColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  // ─── ADD ROW BUTTON ─────────────────────────────────────────────────────────
  Widget _buildAddRowButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addRow,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
        label: Text(
          'Add Another Receipt',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: BorderSide(color: _primary.withOpacity(0.4), width: 1.2),
          padding: EdgeInsets.symmetric(vertical: 13.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ─── SUBMIT BUTTON ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: () => _onSubmit(),
        icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
        label: Text(
          'Submit Data',
          style: GoogleFonts.poppins(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
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
