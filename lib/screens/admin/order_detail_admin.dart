import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';

class OrderDetailAdminPage extends StatefulWidget {
  final Map<String, dynamic>? orderData;
  final String orderId;

  const OrderDetailAdminPage({
    super.key,
    required this.orderData,
    required this.orderId,
  });

  @override
  State<OrderDetailAdminPage> createState() => _OrderDetailAdminPageState();
}

class _OrderDetailAdminPageState extends State<OrderDetailAdminPage> {
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  // Memuat data pesanan dari Firestore jika tidak ada data yang diterima
  Future<void> _loadOrderData() async {
    if (widget.orderData != null) {
      setState(() {
        _orderData = widget.orderData;
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('ordersfisio')
          .doc('pasien')
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (!doc.exists) {
        throw Exception('Pesanan tidak ditemukan');
      }

      setState(() {
        _orderData = doc.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pesanan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading indicator
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Detail Pesanan - Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // Dapatkan orderId dari widget
    final orderId = widget.orderId;

    // Tampilkan pesan error jika ada
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Detail Pesanan - Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadOrderData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Pastikan data tersedia
    if (_orderData == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Detail Pesanan - Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('Data pesanan tidak tersedia')),
      );
    }

    // Ambil data dari _orderData
    final String name = _orderData!['name'] ?? 'N/A';
    final String gender = _orderData!['gender'] ?? 'N/A';
    final int age = _orderData!['age'] ?? 0;
    final String address = _orderData!['address'] ?? 'N/A';
    final String phone = _orderData!['phone'] ?? 'N/A';
    final String complaint = _orderData!['complaint'] ?? 'N/A';
    final String status = _orderData!['status'] ?? 'N/A';
    final String? selectedTime = _orderData!['selectedTime'] as String?;
    final String? userId = _orderData!['userId'] as String?;

    // Format tanggal dibuat (createdAt)
    String createdAtFormatted = 'N/A';
    if (_orderData!['createdAt'] != null && _orderData!['createdAt'] is Timestamp) {
      final dt = (_orderData!['createdAt'] as Timestamp).toDate();
      createdAtFormatted = DateFormat('dd MMMM yyyy, HH:mm').format(dt);
    }

    // Format tanggal diminta (requestedDate)
    String requestedDateFormatted = 'N/A';
    if (_orderData!['requestedDate'] != null && _orderData!['requestedDate'] is Timestamp) {
      final dt = (_orderData!['requestedDate'] as Timestamp).toDate();
      requestedDateFormatted = DateFormat('dd MMMM yyyy').format(dt);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pesanan - Admin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _loadOrderData();
            },
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  _buildStatusBadge(status),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Order ID & Admin Info
            _buildSectionCard(
              context,
              'Informasi Pesanan',
              Icons.receipt_long,
              [
                _buildInfoItem(Icons.tag, 'Order ID', orderId),
                _buildInfoItem(Icons.info, 'Status Pesanan', status.toUpperCase()),
                if (userId != null)
                  _buildInfoItem(Icons.fingerprint, 'User ID', userId),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Informasi Pasien
            _buildSectionCard(
              context,
              'Informasi Pasien',
              Icons.person,
              [
                _buildInfoItem(Icons.account_circle, 'Nama Pasien', name),
                _buildInfoItem(Icons.wc, 'Jenis Kelamin', gender),
                _buildInfoItem(Icons.cake, 'Umur', '$age tahun'),
                _buildInfoItem(Icons.location_on, 'Alamat', address),
                _buildInfoItem(Icons.phone, 'No WhatsApp', phone),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Informasi Reservasi
            _buildSectionCard(
              context,
              'Informasi Reservasi',
              Icons.calendar_today,
              [
                _buildInfoItem(Icons.event, 'Tanggal Reservasi Fisioterapi', requestedDateFormatted),
                _buildTimeInfoItem(selectedTime),
                const SizedBox(height: 8),
                _buildInfoItem(Icons.access_time, 'Pesanan Dibuat pada', createdAtFormatted),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Keluhan
            _buildComplaintCard(context, complaint),
            
            const SizedBox(height: 24),
            
            // Admin Action Buttons
            _buildAdminActions(context, status),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Tombol "Pesanan Selesai" jika status masih proses
          if (status.toLowerCase() == 'proses')
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Pesanan Selesai',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onPressed: () => _confirmCompleteOrder(context),
              ),
            ),
          
          // Tombol Hapus
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Hapus Pesanan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              onPressed: () => _confirmDeleteOrder(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    Color textColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'proses':
        statusColor = Colors.white;
        textColor = AppColors.primaryColor;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'selesai':
        statusColor = Colors.green;
        textColor = Colors.white;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        textColor = Colors.white;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
        border: status.toLowerCase() == 'proses' 
            ? Border.all(color: Colors.white, width: 2) 
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget khusus untuk menampilkan informasi jam dengan styling yang sama seperti halaman pasien
  Widget _buildTimeInfoItem(String? selectedTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jam Reservasi Fisioterapi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                selectedTime != null 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedTime,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text(
                              'Perlu Dijadwalkan Admin',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, String complaint) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_services, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Keluhan Pasien',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              complaint,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCompleteOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Konfirmasi Selesai'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menandai pesanan ini sebagai selesai?\n\nPesanan yang sudah selesai tidak dapat diubah kembali ke status proses.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ya, Selesaikan',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        await FirebaseFirestore.instance
            .collection('ordersfisio')
            .doc('pasien')
            .collection('orders')
            .doc(widget.orderId)
            .update({
              'status': 'selesai',
              'completedAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

        if (context.mounted) {
          Navigator.pop(context); // Close loading
          Navigator.pop(context); // Go back to previous page
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil ditandai sebagai selesai'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui pesanan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Text('Hapus Pesanan'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pesanan ini secara permanen?\n\nTindakan ini tidak dapat dibatalkan dan semua data pesanan akan hilang.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ya, Hapus Permanen',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        await FirebaseFirestore.instance
            .collection('ordersfisio')
            .doc('pasien')
            .collection('orders')
            .doc(widget.orderId)
            .delete();

        if (context.mounted) {
          Navigator.pop(context); // Close loading
          Navigator.pop(context); // Go back to previous page
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dihapus secara permanen'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus pesanan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}