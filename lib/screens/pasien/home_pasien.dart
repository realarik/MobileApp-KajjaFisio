import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kajjafisioapp/screens/pasien/order_fisio_pasien.dart';
import 'package:kajjafisioapp/screens/pasien/my_orders_pasien.dart';
import 'package:kajjafisioapp/screens/pasien/profil_pasien.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';
import 'package:kajjafisioapp/utils/app_styles.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- IMPORT DITAMBAHKAN DI SINI

class HomePasienPage extends StatefulWidget {
  const HomePasienPage({super.key});

  @override
  State<HomePasienPage> createState() => _HomePasienPageState();
}

class _HomePasienPageState extends State<HomePasienPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _userName = 'User';
  late PageController _pageController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _pageController = PageController(initialPage: _selectedIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _navigateToOrderPage() {
    _onItemTapped(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _HomeContent(
            userName: _userName,
            onNavigateToOrder: _navigateToOrderPage,
          ),
          OrderFisioPasienPage(
            onGoToPesananSaya: () => _onItemTapped(2),
          ),
          const MyOrdersPasienPage(),
          const ProfilePasienPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          elevation: 0,
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final String userName;
  final VoidCallback onNavigateToOrder;

  const _HomeContent({
    this.userName = 'User',
    required this.onNavigateToOrder,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _isLayananExpanded = false;
  bool _isCaraPesanExpanded = false;
  bool _isBiayaExpanded = false;
  bool _isInfoTerapisExpanded = false;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorColor : AppColors.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          pinned: true,
          automaticallyImplyLeading: false,
          expandedHeight: kToolbarHeight + 16,
          flexibleSpace: SafeArea(
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Home',
                        style: AppStyles.headlineStyle.copyWith(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor.withOpacity(0.05),
                        AppColors.accentColor.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
                        style: AppStyles.bodyTextStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.userName,
                        style: AppStyles.headlineStyle.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selamat datang di layanan fisioterapi KajjaFisio',
                        style: AppStyles.bodyTextStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/fisiopic.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fisioterapi Profesional',
                                  style: AppStyles.headlineStyle.copyWith(
                                    color: AppColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Layanan terbaik untuk Fisio Home Terapi',
                                  style: AppStyles.bodyTextStyle.copyWith(
                                    color: AppColors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildExpandableSection(
                  title: 'Layanan Kami',
                  isExpanded: _isLayananExpanded,
                  onTap: () {
                    setState(() {
                      _isLayananExpanded = !_isLayananExpanded;
                    });
                  },
                  content: _buildLayananContent(),
                ),
                _buildExpandableSection(
                  title: 'Cara Memesan Fisiohome terapi',
                  isExpanded: _isCaraPesanExpanded,
                  onTap: () {
                    setState(() {
                      _isCaraPesanExpanded = !_isCaraPesanExpanded;
                    });
                  },
                  content: _buildCaraPesanContent(),
                ),
                _buildExpandableSection(
                  title: 'Biaya Fisiohome terapi',
                  isExpanded: _isBiayaExpanded,
                  onTap: () {
                    setState(() {
                      _isBiayaExpanded = !_isBiayaExpanded;
                    });
                  },
                  content: _buildBiayaContent(),
                ),
                _buildExpandableSection(
                  title: 'Info Terapis',
                  isExpanded: _isInfoTerapisExpanded,
                  onTap: () {
                    setState(() {
                      _isInfoTerapisExpanded = !_isInfoTerapisExpanded;
                    });
                  },
                  content: _buildInfoTerapisContent(),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kami hadir memberikan penanganan fisioterapi profesional untuk:',
                        style: AppStyles.bodyTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCheckListItem('✓ Pemulihan Pasca Stroke & Pasca Operasi'),
                      _buildCheckListItem('✓ Mengatasi Nyeri dari Cedera Olahraga'),
                      _buildCheckListItem('✓ Permasalahan Fisik pada Anak & Lansia'),
                      const SizedBox(height: 12),
                      Text(
                        'KajjaFisio melayani panggilan terapi ke rumah untuk wilayah Bekasi Utara dan sekitarnya. Menangani berbagai masalah seperti Pemulihan Stroke, Nyeri Pinggang/Punggung, Cedera Olahraga, dan terapi untuk Lansia.',
                        style: AppStyles.bodyTextStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kami menawarkan kemudahan, kenyamanan, dan pelayanan profesional. Konsultasi gratis untuk mengetahui kondisi dan kebutuhan terapi Anda',
                        style: AppStyles.bodyTextStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Dapatkan perawatan fisioterapi terbaik dengan terapis profesional',
                        textAlign: TextAlign.center,
                        style: AppStyles.bodyTextStyle.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: widget.onNavigateToOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Order Fisioterapi',
                              style: AppStyles.headlineStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppStyles.headlineStyle.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: isExpanded ? content : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Layanan fisioterapi yang disediakan oleh KajjaFisio meliputi berbagai jenis perawatan fisioterapi, seperti perawatan fisioterapi pada kondisi tulang belakang, kaki, tangan, dan pergelangan tangan. KajjaFisio juga menyediakan layanan perawatan fisioterapi pada kondisi medis tertentu, seperti stroke, asam urat, kekuatan mobil, dan cedera olahraga.',
        style: AppStyles.bodyTextStyle.copyWith(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCaraPesanContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Cara ke-1', style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Mengisi Formulir Data, lalu Terapis akan menghubungi Anda via WhatsApp', style: AppStyles.bodyTextStyle.copyWith(fontSize: 13, color: Colors.grey[700], height: 1.4)),
          const SizedBox(height: 12),
          Text('• Cara ke-2', style: AppStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Langsung Menghubungi Kontak Terapis via WhatsApp Untuk Melakukan Konsultasi ataupun Membuat Janji Terapi', style: AppStyles.bodyTextStyle.copyWith(fontSize: 13, color: Colors.grey[700], height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildBiayaContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• Fisiohome Terapi hanya Rp 200.000/sesi! Nikmati terapi profesional & berpengalaman selama 45-60 menit dengan peralatan lengkap (Infrared, Ultra Sound, TENS) sesuai kebutuhan Anda, langsung di rumah!', style: AppStyles.bodyTextStyle.copyWith(fontSize: 14, color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 12),
          Text('• Pembayaran dilakukan setelah selesai melakukan terapi & Pembayaran bisa melalui uang tunai(cash) atau transfer bank', style: AppStyles.bodyTextStyle.copyWith(fontSize: 14, color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildInfoTerapisContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text('Sertifikat tidak tersedia', style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Terapis kami memiliki sertifikat resmi, berpendidikan dengan IPK dan data pribadi yang terverifikasi, sehingga kami bisa percaya sepenuhnya bahwa perawatan yang diberikan aman, profesional, dan sesuai standar nasional.',
            style: AppStyles.bodyTextStyle.copyWith(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone, color: const Color(0xFF049231), size: 20),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('');
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    _showSnackBar('Gagal membuka WhatsApp', isError: true);
                  }
                },
                child: Text(
                  '+62',
                  style: AppStyles.bodyTextStyle.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF049231),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF049231),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppStyles.bodyTextStyle.copyWith(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}