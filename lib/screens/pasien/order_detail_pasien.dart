import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';

class OrderDetailPasienPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const OrderDetailPasienPage({
    super.key,
    required this.orderData,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil data dari orderData
    final String name = orderData['name'] ?? 'N/A';
    final String gender = orderData['gender'] ?? 'N/A';
    final int age = orderData['age'] ?? 0;
    final String address = orderData['address'] ?? 'N/A';
    final String phone = orderData['phone'] ?? 'N/A';
    final String complaint = orderData['complaint'] ?? 'N/A';
    final String status = orderData['status'] ?? 'N/A';
    final String? selectedTime = orderData['selectedTime'] as String?;

    // Format tanggal dibuat (createdAt)
    String createdAtFormatted = 'N/A';
    if (orderData['createdAt'] != null && orderData['createdAt'] is Timestamp) {
      final dt = (orderData['createdAt'] as Timestamp).toDate();
      createdAtFormatted = DateFormat('dd MMMM yyyy, HH:mm').format(dt);
    }

    // Format tanggal diminta (requestedDate)
    String requestedDateFormatted = 'N/A';
    if (orderData['requestedDate'] != null && orderData['requestedDate'] is Timestamp) {
      final dt = (orderData['requestedDate'] as Timestamp).toDate();
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
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
                  const Text(
                    'KajjaFisio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
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
                _buildInfoItem(Icons.access_time, 'Dibuat pada Tanggal', createdAtFormatted),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Keluhan
            _buildComplaintCard(context, complaint),
            
            const SizedBox(height: 32),
          ],
        ),
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

  // Widget khusus untuk menampilkan informasi jam dengan styling yang berbeda
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
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Belum ditentukan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
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
}