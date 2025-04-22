import 'package:carilaundry2/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carilaundry2/models/userProfile.dart';
import 'package:carilaundry2/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:carilaundry2/main.dart';
// import 'package:app_settings/app_settings.dart';
import 'package:carilaundry2/core/apiConstant.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfile?> userProfileFuture;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isEditing = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userProfileFuture = _checkLoginAndFetchProfile();
  }

  Future<UserProfile?> _checkLoginAndFetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      print('token: $token');

      if (token.isEmpty) {
        print('Token is empty, user not logged in');
        return null;
      }

      return await fetchUserProfile();
    } catch (e) {
      print('Error checking login status: $e');
      return null;
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    // Clear any existing SnackBars
    rootScaffoldMessengerKey.currentState?.clearSnackBars();

    // Show the new SnackBar with fixed behavior
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // Upload the image
        await uploadProfileImage();
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Error memilih gambar: $e', Colors.red);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                    Icon(Icons.photo_camera, color: Constants.primaryColor),
                title: Text('Ambil Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: Constants.primaryColor),
                title: Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadProfileImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_imageFile == null) {
        _showSnackBar('Silakan pilih gambar terlebih dahulu', Colors.orange);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _showSnackBar(
            'Anda belum login. Silakan login terlebih dahulu', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Upload image directly to Laravel backend
      print('Starting image upload to Laravel backend...');
      String? imageUrl = await _uploadToLaravelServer(token);

      if (imageUrl == null || imageUrl.isEmpty) {
        _showSnackBar('Gagal mengupload gambar', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('Image successfully uploaded to Laravel server. URL: $imageUrl');

      // Update UI
      setState(() {
        _isLoading = false;
        // Refresh profile data to show updated image
        userProfileFuture = fetchUserProfile();
      });

      _showSnackBar('Foto profil berhasil diperbarui', Colors.green);
    } catch (e) {
      print('Error uploading profile image: $e');
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _uploadToLaravelServer(String token) async {
    try {
      print('Preparing to upload image to Laravel server...');

      // Create a multipart request

      var request = http.MultipartRequest(
          'POST', Uri.parse('${Apiconstant.BASE_URL}/upload-profile-image'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add file to upload
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image', // Use the form field name expected by your Laravel API
        _imageFile!.path,
      ));

      print('Sending request to Laravel server...');

      // Send the request with timeout
      final response = await request.send().timeout(Duration(seconds: 30));
      final responseData = await response.stream.bytesToString();

      print('Laravel server response status: ${response.statusCode}');
      print('Laravel server response: $responseData');

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseData);
        if (jsonData['status'] == 'success' && jsonData['image_url'] != null) {
          print(
              'Image successfully uploaded to Laravel: ${jsonData['image_url']}');
          return jsonData['image_url'];
        } else {
          print('Failed to get URL from Laravel response: $responseData');
          return null;
        }
      } else {
        print(
            'Failed to upload to Laravel: ${response.statusCode}, $responseData');
        return null;
      }
    } catch (e) {
      print('Error uploading to Laravel: $e');
      return null;
    }
  }

  // Helper method to calculate HMAC-SHA1
  List<int> hmacSha1(List<int> key, List<int> message) {
    final hmac = Hmac(sha1, key);
    hmac.convert(message);
    return hmac.convert(message).bytes;
  }

  Future<UserProfile> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      print('token: $token');

      if (token.isEmpty) {
        throw Exception('Anda belum Login.');
      }

      final response = await http.get(
        Uri.parse('${Apiconstant.BASE_URL}/user-profil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          UserProfile userProfile = UserProfile.fromJson(data['data']);
          emailController.text = userProfile.email;
          phoneController.text = userProfile.phoneNumber;
          return userProfile;
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat profil');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token tidak valid. Silakan login ulang.');
      } else {
        throw Exception('Gagal memuat profil: ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Gagal memuat profil: $e');
    }
  }

  Future<void> updateProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) {
        throw Exception('Anda belum Login.');
      }

      print(
          'Updating profile with email: ${emailController.text} and phone: ${phoneController.text}');

      final response = await http.post(
        Uri.parse('${Apiconstant.BASE_URL}/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': emailController.text,
          'noTelp': phoneController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showSnackBar('Profil berhasil diperbarui', Constants.primaryColor);
          setState(() {
            isEditing = false;
            userProfileFuture = fetchUserProfile();
          });
        } else {
          throw Exception(data['message'] ?? 'Gagal memperbarui profil');
        }
      } else if (response.statusCode == 422) {
        // Validation error
        final data = json.decode(response.body);
        String errorMsg = 'Validasi gagal: ';
        if (data['errors'] != null) {
          data['errors'].forEach((key, value) {
            errorMsg += value[0] + ' ';
          });
        }
        throw Exception(errorMsg);
      } else {
        throw Exception('Gagal memperbarui profil: ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: Text("Akun Saya", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<UserProfile?>(
        future: userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Constants.primaryColor),
              ),
            );
          } else if (snapshot.hasError) {
            return _buildErrorState(context, '${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data != null) {
            final user = snapshot.data!;
            return Container(
              color: Color.fromARGB(255, 253, 253, 253),
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                children: [
                  _buildProfileCard(user),
                  SizedBox(height: 16),
                  _buildInfoCard(),
                  SizedBox(height: 16),
                  _buildMenuItems(context),
                  SizedBox(height: 24),
                  _buildRegisterStoreCard(),
                  SizedBox(height: 24),
                ],
              ),
            );
          } else {
            return _buildNotLoggedInState(context);
          }
        },
      ),
    );
  }

  Widget _buildNotLoggedInState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Anda Belum Login',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Silakan login terlebih dahulu untuk mengakses profil Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/login", (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Oops! Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userProfileFuture = fetchUserProfile();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProfile user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: _showImagePicker,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _getProfileImage(user),
                    child: (_imageFile == null &&
                            (user.profileImage.isEmpty ||
                                user.profileImage == ""))
                        ? Icon(Icons.person,
                            size: 30, color: Constants.primaryColor)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Constants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get profile image
  ImageProvider? _getProfileImage(UserProfile user) {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (user.profileImage.isNotEmpty && user.profileImage != "") {
      try {
        // Use a reliable placeholder service or a local asset
        if (user.profileImage.contains('placeholder.com')) {
          // Return a local asset or a more reliable placeholder service
          return AssetImage('assets/images/dp.png');
        }
        return NetworkImage(user.profileImage);
      } catch (e) {
        print('Error loading network image: $e');
        return AssetImage('assets/images/dp.png');
      }
    }
    return null;
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                isEditing
                    ? Container(
                        width: 200,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Constants.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Text(
                            emailController.text,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isEditing = true;
                              });
                            },
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: Constants.primaryColor,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
            SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  "Nomor HP",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                isEditing
                    ? Container(
                        width: 200,
                        child: TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Constants.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      )
                    : Row(
                        children: [
                          Text(
                            phoneController.text,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isEditing = true;
                              });
                            },
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: Constants.primaryColor,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
            if (isEditing)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                          // Reset to original values
                          userProfileFuture = fetchUserProfile();
                        });
                      },
                      child: Text("Batal"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.primaryColor,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Simpan"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            title: "Riwayat Transaksi",
            onTap: () {
              // Navigate to transaction history
            },
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            icon: Icons.store,
            title: "Toko Anda",
            onTap: () {
              // Navigate to store page
              Navigator.pushNamed(context, "/tes-approve");
            },
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildMenuItem(
            icon: Icons.logout,
            title: "Keluar dari Akun",
            isLogout: true,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isLogout ? Colors.red.shade700 : Constants.primaryColor,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red.shade700 : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterStoreCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Punya usaha laundry?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Daftarkan toko Anda sekarang untuk menarik pelanggan lebih banyak lagi.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/register-toko");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Daftarkan Toko Kamu",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Keluar Akun ?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          "Apakah kamu ingin keluar dari akunmu sekarang ?",
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tidak",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/dashboard", (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              "Iya, Keluar",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 24),
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}
