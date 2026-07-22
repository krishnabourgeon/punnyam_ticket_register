import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:punnyam/screens/home/ticket_register/book_closing_screen.dart';
import 'package:punnyam/screens/home/ticket_register/issue_book_screen.dart';
import 'package:punnyam/screens/home/ticket_register/new_book_screen.dart';
import 'package:punnyam/screens/home/ticket_register/report_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CARD DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _CardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Function() onTap;

  const _CardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class TicketRegisterScreen extends StatefulWidget {
  const TicketRegisterScreen({super.key});

  @override
  State<TicketRegisterScreen> createState() => _TicketRegisterScreenState();
}

class _TicketRegisterScreenState extends State<TicketRegisterScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animController;

  final _drawerController = ZoomDrawerController();

  late final List<_CardItem> _cardItems = [
    _CardItem(
      title: "Double Receipt",
      subtitle: "Register ticket book",
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF6D1A1A),
      bgColor: const Color(0xFFF9E8E8),
      onTap: () async {
        final saved = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewBookScreen()),
        );
        if (saved is String && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF6D1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Text(
                saved,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
      },
    ),
    // _CardItem(
    //   title: "List of Books",
    //   subtitle: "View all books",
    //   icon: Icons.library_books_outlined,
    //   color: const Color(0xFFC17D26),
    //   bgColor: const Color(0xFFFFF8E7),
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //        MaterialPageRoute(
    //         builder: (_) => const ListOfBooksScreen(),
    //       ),
    //     );
    //   },
    // ),
    _CardItem(
      title: "Double Issue",
      subtitle: "Issue to counter",
      icon: Icons.assignment_outlined,
      color: Color(0xFF2E6B4F),
      bgColor: Color(0xFFE8F5EE),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IssueBookScreen()),
        );
      },
    ),
    _CardItem(
      title: "Ticket Register",
      subtitle: "Close & settle book",
      icon: Icons.lock_outline_rounded,
      color: Color(0xFF1A4A7A),
      bgColor: Color(0xFFE6EEF8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookClosingTableScreen()),
        );
      },
    ),
    _CardItem(
      title: "Double Lock Register",
      subtitle: "Sales & summaries",
      icon: Icons.bar_chart_outlined,
      color: Color(0xFF5C3A8A),
      bgColor: Color(0xFFF1ECF8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoubleLockRegisterScreen()),
        );
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF6D1A1A),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      //     body: ZoomDrawer(
      //       controller: _drawerController,
      //       style: DrawerStyle.defaultStyle,
      //       menuScreen: _buildDrawerMenu(),
      //       mainScreen: _buildMainScreen(),
      //       borderRadius: 28.0,
      //       showShadow: true,
      //       angle: -10.0,
      //       drawerShadowsBackgroundColor: Colors.grey.shade300,
      //       slideWidth: MediaQuery.of(context).size.width * .65,
      //       openCurve: Curves.fastOutSlowIn,
      //       closeCurve: Curves.bounceIn,
      //     ),
      body: _buildMainScreen(),
    );
  }

  // ─── DRAWER MENU ───────────────────────────────────────────────────────────
  Widget _buildDrawerMenu() {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3A683), Color(0xFFF1907A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 30.h),
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 36,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "User",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "● Online",
              style: GoogleFonts.poppins(
                color: const Color(0xFFFAC5A4),
                fontSize: 12.sp,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 30.h),
            Divider(
              color: Colors.white.withOpacity(0.15),
              indent: 20,
              endIndent: 20,
            ),
            SizedBox(height: 10.h),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                // TODO: handle logout
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── MAIN SCREEN ───────────────────────────────────────────────────────────
  Widget _buildMainScreen() {
    return Container(
      color: const Color.fromRGBO(248, 244, 240, 1),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildDashboard()),
        ],
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE77F75), Color(0xFFF1907A), Color(0xFFE77F75)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GestureDetector(
              //   onTap: () => _drawerController.open!(),
              //   child: Container(
              //     width: 40.w,
              //     height: 40.h,
              //     decoration: BoxDecoration(
              //       color: Colors.white.withOpacity(0.15),
              //       borderRadius: BorderRadius.circular(10),
              //       border: Border.all(
              //         color: Colors.white.withOpacity(0.25),
              //         width: 1,
              //       ),
              //     ),
              //     child: const Icon(
              //       Icons.menu_rounded,
              //       color: Colors.white,
              //       size: 20,
              //     ),
              //   ),
              // ),
              // SizedBox(height: 20.h),
              // Text(
              //   "DASHBOARD",
              //   style: GoogleFonts.poppins(
              //     color: Colors.white.withOpacity(0.65),
              //     fontSize: 13.sp,
              //     fontWeight: FontWeight.w600,
              //     letterSpacing: 3,
              //   ),
              // ),
              SizedBox(height: 80.h),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: 50,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.3)),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Text(
                "Temple Ticket Manager",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Devotee Ticket Registration System",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DASHBOARD ─────────────────────────────────────────────────────────────
  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Container(
          //       width: 3.w,
          //       height: 18.h,
          //       decoration: BoxDecoration(
          //         color: const Color(0xFF6D1A1A),
          //         borderRadius: BorderRadius.circular(2),
          //       ),
          //     ),
          //     SizedBox(width: 10.w),
          //     Text(
          //       "QUICK ACTIONS",
          //       style: GoogleFonts.poppins(
          //         color: Colors.black54,
          //         fontSize: 12.sp,
          //         fontWeight: FontWeight.w700,
          //         letterSpacing: 2.5,
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 20.h),
          _buildCardGrid(),
          SizedBox(height: 24.h),
          //_buildInfoStrip(),
        ],
      ),
    );
  }

  // ─── 5-CARD LAYOUT (2 + 2 + 1 centered) ───────────────────────────────────
  Widget _buildCardGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _animatedCard(0)),
            SizedBox(width: 14.w),
            Expanded(child: _animatedCard(1)),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(child: _animatedCard(2)),
            SizedBox(width: 14.w),
            Expanded(child: _animatedCard(3)),
          ],
        ),
        // SizedBox(height: 14.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     SizedBox(
        //       width: (MediaQuery.of(context).size.width - 32.w - 14.w) / 2,
        //       child: _animatedCard(4),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _animatedCard(int index) {
    final ctrl = _animController;
    if (ctrl == null) return _buildDashCard(_cardItems[index]);

    final delay = index * 0.08;
    final animation = CurvedAnimation(
      parent: ctrl,
      curve: Interval(
        delay.clamp(0.0, 1.0),
        (delay + 0.5).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: _buildDashCard(_cardItems[index]),
    );
  }

  // ─── DASHBOARD CARD ────────────────────────────────────────────────────────
  Widget _buildDashCard(_CardItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: item.color.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Positioned(
              //   top: -16,
              //   right: -16,
              //   child: Container(
              //     width: 70,
              //     height: 70,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color: item.color.withOpacity(0.06),
              //     ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(item.icon, color: item.color, size: 22),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1A1A2E),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.subtitle,
                                style: GoogleFonts.poppins(
                                  color: Colors.black38,
                                  fontSize: 11.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: item.bgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: item.color,
                                size: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── INFO STRIP ────────────────────────────────────────────────────────────
  Widget _buildInfoStrip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF9E8E8), width: 1),
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
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF9E8E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.temple_hindu_outlined,
              color: Color(0xFF6D1A1A),
              size: 20,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Temple Ticket Manager",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1A1A2E),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Manage devotee ticket books with ease",
                  style: GoogleFonts.poppins(
                    color: Colors.black38,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
