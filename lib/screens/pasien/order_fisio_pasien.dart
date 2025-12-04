import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';

// Komponen header baru
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final double height;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: height,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      automaticallyImplyLeading: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class OrderFisioPasienPage extends StatefulWidget {
  final VoidCallback? onGoToPesananSaya;
  const OrderFisioPasienPage({Key? key, this.onGoToPesananSaya}) : super(key: key);

  @override
  State<OrderFisioPasienPage> createState() => _OrderFisioPasienPageState();
}

class _OrderFisioPasienPageState extends State<OrderFisioPasienPage> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  List<String> _bookedTimes = [];
  bool _isLoadingTimes = false;
  Set<DateTime> _fullyBookedDates = {};

  // Available time slots
  final List<String> _availableTimeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
    _phoneController.text = '+62';
    _loadFullyBookedDates();
  }

  Future<void> _loadFullyBookedDates() async {
    try {
      // Get bookings for the next 365 days
      DateTime now = DateTime.now();
      DateTime endDate = now.add(const Duration(days: 365));
      
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ordersfisio')
          .doc('pasien')
          .collection('orders')
          .where('requestedDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('requestedDate', isLessThan: Timestamp.fromDate(endDate))
          .where('status', whereIn: ['proses', 'disetujui', 'selesai'])
          .get();

      Map<String, Set<String>> dateTimeMap = {};
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp? requestedDateTimestamp = data['requestedDate'];
        String? selectedTime = data['selectedTime'];
        
        if (requestedDateTimestamp != null && selectedTime != null) {
          DateTime date = requestedDateTimestamp.toDate();
          String dateKey = DateFormat('yyyy-MM-dd').format(date);
          
          if (!dateTimeMap.containsKey(dateKey)) {
            dateTimeMap[dateKey] = <String>{};
          }
          dateTimeMap[dateKey]!.add(selectedTime);
        }
      }

      Set<DateTime> fullyBooked = {};
      for (String dateKey in dateTimeMap.keys) {
        if (dateTimeMap[dateKey]!.length >= _availableTimeSlots.length) {
          DateTime date = DateTime.parse(dateKey);
          fullyBooked.add(DateTime(date.year, date.month, date.day));
        }
      }

      setState(() {
        _fullyBookedDates = fullyBooked;
      });
    } catch (e) {
      print('Error loading fully booked dates: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CustomDatePickerDialog(
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          fullyBookedDates: _fullyBookedDates,
          onDateSelected: (DateTime date) {
            DateTime selectedDate = DateTime(date.year, date.month, date.day);
            bool isFullyBooked = _fullyBookedDates.contains(selectedDate);
            
            if (isFullyBooked) {
              _showSnackBar('Tanggal ini sudah penuh. Silakan pilih tanggal lain.', isError: true);
              return;
            }
            
            setState(() {
              _selectedDate = date;
              _dateController.text = DateFormat('dd MMMM yyyy').format(date);
              _selectedTime = null; // Reset selected time when date changes
            });
            _checkBookedTimes();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _checkBookedTimes() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoadingTimes = true;
    });

    try {
      // Format tanggal untuk query
      DateTime startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ordersfisio')
          .doc('pasien')
          .collection('orders')
          .where('requestedDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('requestedDate', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: ['proses', 'disetujui', 'selesai'])
          .get();

      List<String> bookedTimes = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String? time = data['selectedTime'] as String?;
        if (time != null) {
          bookedTimes.add(time);
        }
      }

      setState(() {
        _bookedTimes = bookedTimes;
        _isLoadingTimes = false;
      });
    } catch (e) {
      print('Error checking booked times: $e');
      setState(() {
        _isLoadingTimes = false;
      });
    }
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Mohon lengkapi semua data!', isError: true);
      return;
    }
    if (_selectedDate == null) {
      _showSnackBar('Pilih tanggal terapi.', isError: true);
      return;
    }
    if (_selectedTime == null) {
      _showSnackBar('Pilih jam terapi.', isError: true);
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Anda belum login.', isError: true);
      return;
    }
    int? age = int.tryParse(_ageController.text);
    if (age == null || age <= 0 || age > 90) {
      _showSnackBar('Masukkan umur valid (1-90).', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Double check if the time slot is still available
      await _checkBookedTimes();
      if (_bookedTimes.contains(_selectedTime)) {
        _showSnackBar('Jam tersebut sudah dibooking oleh pasien lain. Silakan pilih jam lain.', isError: true);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('ordersfisio')
          .doc('pasien')
          .collection('orders')
          .add({
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
        'age': age,
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'complaint': _complaintController.text.trim(),
        'requestedDate': Timestamp.fromDate(_selectedDate!),
        'selectedTime': _selectedTime,
        'status': 'proses',
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal menyimpan order: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryColor, size: 32),
            const SizedBox(width: 8),
            const Text('Berhasil!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Pesanan Anda telah kami terima.\nTim kami akan segera menghubungi Anda via WhatsApp untuk konfirmasi.',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onGoToPesananSaya != null) {
                widget.onGoToPesananSaya!();
              }
              // Jika callback tidak ada, tidak melakukan push.
              // Navigasi akan otomatis lewat parent (HomePasienPage) mengganti tab.
            },
            child: Text(
              'Lihat Pesanan',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : Colors.green,
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primaryColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Pengisian Form',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pastikan alamat lengkap dan nomor WhatsApp aktif agar terapis bisa menghubungi Anda.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    if (_selectedDate == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Pilih tanggal terlebih dahulu',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.access_time, color: AppColors.primaryColor, size: 20),
              ),
              const Text(
                'Pilih Jam Terapi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingTimes)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _availableTimeSlots.length,
                itemBuilder: (context, index) {
                  String timeSlot = _availableTimeSlots[index];
                  bool isBooked = _bookedTimes.contains(timeSlot);
                  bool isSelected = _selectedTime == timeSlot;

                  return GestureDetector(
                    onTap: isBooked ? null : () {
                      setState(() {
                        _selectedTime = timeSlot;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isBooked 
                            ? Colors.red.withOpacity(0.1)
                            : isSelected
                                ? AppColors.primaryColor
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isBooked 
                              ? Colors.red
                              : isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey[400]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              timeSlot,
                              style: TextStyle(
                                color: isBooked 
                                    ? Colors.red
                                    : isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            if (isBooked) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Booked',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              const Text('Tersedia', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              const Text('Dipilih', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              const Text('Sudah Dibooking', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 20),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildStyledDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          hintText: 'Pilih Jenis Kelamin',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: AppColors.primaryColor, size: 20),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        items: <String>['Pria', 'Wanita'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Pilih jenis kelamin';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppHeader(title: "Order Fisioterapi"),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildStyledTextField(
                        controller: _nameController,
                        hintText: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
                          return null;
                        },
                      ),
                      _buildStyledDropdown(),
                      _buildStyledTextField(
                        controller: _ageController,
                        hintText: 'Umur',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Umur harus diisi';
                          if (int.tryParse(value) == null) return 'Masukkan angka';
                          return null;
                        },
                      ),
                      _buildStyledTextField(
                        controller: _addressController,
                        hintText: 'Alamat Lengkap',
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Alamat tidak boleh kosong';
                          return null;
                        },
                      ),
                      _buildStyledTextField(
                        controller: _phoneController,
                        hintText: 'Nomor WhatsApp (+62)',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            String text = newValue.text;
                            if (!text.startsWith('+62')) {
                              text = '+62${text.replaceAll(RegExp(r'\D'), '')}';
                            }
                            String digits = text.length > 3 ? text.substring(3).replaceAll(RegExp(r'\D'), '') : '';
                            if (digits.length > 13) digits = digits.substring(0, 13);
                            String formatted = '+62$digits';
                            if (formatted.length < 3) formatted = '+62';
                            return TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty || value == '+62') {
                            return 'Nomor WhatsApp tidak valid';
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.calendar_today_outlined, color: AppColors.primaryColor, size: 20),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Reservasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tanggal dengan latar merah = sudah penuh',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStyledTextField(
                        controller: _dateController,
                        hintText: 'Pilih Tanggal Reservasi',
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Pilih tanggal reservasi';
                          return null;
                        },
                      ),
                      _buildTimeSelection(),
                      _buildStyledTextField(
                        controller: _complaintController,
                        hintText: 'Keluhan atau kondisi kesehatan',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Jelaskan keluhan Anda';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Buat Pesanan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _complaintController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

class _CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Set<DateTime> fullyBookedDates;
  final Function(DateTime) onDateSelected;

  const _CustomDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.fullyBookedDates,
    required this.onDateSelected,
  });

  @override
  _CustomDatePickerDialogState createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<_CustomDatePickerDialog> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  Widget _buildCalendar() {
    List<Widget> days = [];
    
    // Add month header
    days.add(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_currentMonth),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );

    // Add day headers
    days.add(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
              .map((day) => Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ))
              .toList(),
        ),
      ),
    );

    // Calculate days in month
    DateTime firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    DateTime lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    int daysInMonth = lastDayOfMonth.day;
    int firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    List<Widget> dayWidgets = [];
    
    // Add empty cells for days before the first day of month
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      
      bool isToday = normalizedDate == DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      bool isSelected = normalizedDate == DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      bool isFullyBooked = widget.fullyBookedDates.contains(normalizedDate);
      bool isInPast = normalizedDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
      bool isInRange = !normalizedDate.isBefore(widget.firstDate) && !normalizedDate.isAfter(widget.lastDate);

      Color backgroundColor = Colors.transparent;
      Color textColor = Colors.black87;
      
      if (isInPast || !isInRange) {
        backgroundColor = Colors.transparent;
        textColor = Colors.grey[400]!;
      } else if (isFullyBooked) {
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red[700]!;
      } else if (isSelected) {
        backgroundColor = AppColors.primaryColor;
        textColor = Colors.white;
      } else if (isToday) {
        backgroundColor = AppColors.primaryColor.withOpacity(0.2);
        textColor = AppColors.primaryColor;
      }

      dayWidgets.add(
        GestureDetector(
          onTap: (isInPast || !isInRange) ? null : () {
            widget.onDateSelected(date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: isFullyBooked ? Border.all(color: Colors.red, width: 1) : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isFullyBooked)
                    Text(
                      'Penuh',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Add days grid
    days.add(
      Container(
        height: 250,
        child: GridView.count(
          crossAxisCount: 7,
          children: dayWidgets,
        ),
      ),
    );

    return Column(children: days);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Tanggal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildCalendar(),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.transparent, Colors.black87, 'Tersedia'),
                _buildLegendItem(AppColors.primaryColor, Colors.white, 'Dipilih'),
                _buildLegendItem(Colors.red.withOpacity(0.2), Colors.red[700]!, 'Penuh'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color backgroundColor, Color textColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: backgroundColor == Colors.transparent 
                ? Border.all(color: Colors.grey[400]!) 
                : backgroundColor == Colors.red.withOpacity(0.2)
                    ? Border.all(color: Colors.red)
                    : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
}