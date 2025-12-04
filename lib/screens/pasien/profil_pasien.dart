import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kajjafisioapp/screens/login_page.dart';
import 'package:kajjafisioapp/utils/app_colors.dart';
import 'package:kajjafisioapp/utils/header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePasienPage extends StatefulWidget {
  const ProfilePasienPage({super.key});

  @override
  State<ProfilePasienPage> createState() => _ProfilePasienPageState();
}

class _ProfilePasienPageState extends State<ProfilePasienPage> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isUploadingImage = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _profileImage;
  Uint8List? _webImage;
  String? _photoURL;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserProfile();
  }

  void _setupAnimations() {
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
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc('pasien')
            .collection('datapasien')
            .doc(user.uid)
            .get();
        final data = doc.data();
        setState(() {
          _nameController.text = data?['displayName'] ?? (user.displayName ?? user.email!.split('@').first);
          _emailController.text = user.email ?? '';
          _photoURL = data?['photoURL'] ?? user.photoURL;
        });
      } catch (e) {
        setState(() {
          _nameController.text = user.displayName ?? user.email!.split('@').first;
          _emailController.text = user.email ?? '';
          _photoURL = user.photoURL;
        });
      }
    }
  }

  Future<String?> _uploadImageToSupabase({File? file, Uint8List? bytes}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final storage = Supabase.instance.client.storage;
    const bucket = 'profile-pictures';
    String fileExt = '.jpg';
    String fileName = '${user.uid}_pasien_${DateTime.now().millisecondsSinceEpoch}$fileExt';

    try {
      if (kIsWeb && bytes != null) {
        await storage.from(bucket).uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));
      } else if (file != null) {
        await storage.from(bucket).upload(fileName, file, fileOptions: const FileOptions(upsert: true));
      } else {
        throw Exception('Tidak ada data gambar');
      }
      final publicUrl = storage.from(bucket).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    if (_isUploadingImage) return;
    setState(() => _isUploadingImage = true);
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      String? url;
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _webImage = bytes);
          url = await _uploadImageToSupabase(bytes: bytes);
        } else {
          final file = File(pickedFile.path);
          setState(() => _profileImage = file);
          url = await _uploadImageToSupabase(file: file);
        }
        if (url != null) {
          await _savePhotoUrlToFirestore(url);
          setState(() {
            _photoURL = url;
            _profileImage = null;
            _webImage = null;
          });
          _showSnackBar('Foto profil berhasil diperbarui!', isError: false);
        } else {
          _showSnackBar('Upload gagal!', isError: true);
        }
      }
    } catch (e) {
      _showSnackBar('Gagal memilih gambar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _savePhotoUrlToFirestore(String url) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc('pasien')
          .collection('datapasien')
          .doc(user.uid)
          .set({
            'photoURL': url,
            'userId': user.uid,
            'email': user.email,
            'displayName': _nameController.text,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    }
  }

  void _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('Nama tidak boleh kosong', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        await FirebaseFirestore.instance
            .collection('users')
            .doc('pasien')
            .collection('datapasien')
            .doc(user.uid)
            .set({
              'displayName': name,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
        _showSnackBar('Profil berhasil disimpan!', isError: false);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Gagal menyimpan: ${e.message}', isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(
              'Keluar dari Akun?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar? Anda harus login lagi untuk mengakses layanan.',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Keluar'),
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
        margin: EdgeInsets.only(bottom: 70, left: 16, right: 16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 70,
            backgroundColor: AppColors.accentColor.withOpacity(0.3),
            backgroundImage: _getImageProvider(),
            child: _getImageProvider() == null
                ? Icon(Icons.person, size: 70, color: Colors.grey.shade600)
                : null,
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: _isUploadingImage ? null : _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: _isUploadingImage
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _getImageProvider() {
    if (kIsWeb && _webImage != null) {
      return MemoryImage(_webImage!);
    } else if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_photoURL != null) {
      return NetworkImage(_photoURL!);
    }
    return null;
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Container(
                margin: EdgeInsets.all(12),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20),
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
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
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: 'Profil Saya',
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                            )
                          : Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 110),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(child: _buildProfileImage()),
                              SizedBox(height: 16),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      _nameController.text.isNotEmpty ? _nameController.text : 'Pengguna',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _emailController.text,
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32),
                              _buildStyledTextField(
                                controller: _nameController,
                                label: 'Nama Lengkap',
                                hintText: 'Masukkan nama lengkap Anda',
                                icon: Icons.person_outline,
                              ),
                              SizedBox(height: 24),
                              _buildStyledTextField(
                                controller: _emailController,
                                label: 'Email',
                                hintText: 'Email Anda',
                                icon: Icons.email_outlined,
                                readOnly: true,
                              ),
                              SizedBox(height: 24),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green.shade100),
                                ),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 28),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Butuh Bantuan?',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.green[900],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          GestureDetector(
                                            onTap: () async {
                                              final url = Uri.parse('https://wa.me/62');
                                              try {
                                                await launchUrl(url, mode: LaunchMode.externalApplication);
                                              } catch (e) {
                                                _showSnackBar('Gagal membuka WhatsApp', isError: true);
                                              }
                                            },
                                            child: Text(
                                              '+62',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.green[800],
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _logout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade400,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    elevation: 3,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.logout, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Keluar dari Akun',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}