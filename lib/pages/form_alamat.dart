import 'package:flutter/material.dart';
import 'package:carilaundry2/widgets/custom_field.dart';
import 'package:carilaundry2/pages/form_informasi.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormAlamatPage extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String deskripsi;

  const FormAlamatPage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.deskripsi,
  });

  @override
  _AlamatState createState() => _AlamatState();
}

class _AlamatState extends State<FormAlamatPage> {
  TextEditingController jalanController = TextEditingController();
  
  // Untuk dropdown
  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> regencies = [];
  List<Map<String, dynamic>> districts = [];
  
  String? selectedProvinceId;
  String? selectedRegencyId;
  String? selectedDistrictId;
  
  String? selectedProvinceName;
  String? selectedRegencyName;
  String? selectedDistrictName;
  
  bool isLoadingProvinces = false;
  bool isLoadingRegencies = false;
  bool isLoadingDistricts = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() => isLoadingProvinces = true);
    try {
      final response = await http.get(
        Uri.parse('https://emsifa.github.io/api-wilayah-indonesia/api/provinces.json')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          provinces = data.map((province) => {
            'id': province['id'].toString(),
            'name': province['name']
          }).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat provinsi: $e')),
      );
    } finally {
      setState(() => isLoadingProvinces = false);
    }
  }

  Future<void> _loadRegencies(String provinceId) async {
    setState(() {
      selectedRegencyId = null;
      selectedRegencyName = null;
      regencies = [];
      isLoadingRegencies = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://emsifa.github.io/api-wilayah-indonesia/api/regencies/$provinceId.json')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          regencies = data.map((regency) => {
            'id': regency['id'].toString(),
            'name': regency['name']
          }).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kabupaten/kota: $e')),
      );
    } finally {
      setState(() => isLoadingRegencies = false);
    }
  }

  Future<void> _loadDistricts(String regencyId) async {
    setState(() {
      selectedDistrictId = null;
      selectedDistrictName = null;
      districts = [];
      isLoadingDistricts = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://emsifa.github.io/api-wilayah-indonesia/api/districts/$regencyId.json')
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          districts = data.map((district) => {
            'id': district['id'].toString(),
            'name': district['name']
          }).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kecamatan: $e')),
      );
    } finally {
      setState(() => isLoadingDistricts = false);
    }
  }

  String? _validateAddressField(String value, String fieldName) {
    if (value.isEmpty) {
      return "$fieldName wajib diisi";
    }
    if (value.length > 255) {
      return "$fieldName maksimal 255 karakter";
    }
    return null;
  }

  void _goToNextPage() {
    final String jalan = jalanController.text;

    // Validate all fields
    String? jalanError = _validateAddressField(jalan, "Alamat jalan");
    String? provinsiError = selectedProvinceId == null ? "Provinsi wajib dipilih" : null;
    String? kabupatenError = selectedRegencyId == null ? "Kabupaten/Kota wajib dipilih" : null;
    String? kecamatanError = selectedDistrictId == null ? "Kecamatan wajib dipilih" : null;

    // Check if there are any validation errors
    if (jalanError != null || provinsiError != null || 
        kabupatenError != null || kecamatanError != null) {
      String errorMessage = jalanError ?? provinsiError ?? 
                          kabupatenError ?? kecamatanError ?? "Validasi gagal";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    // If validation passes, navigate to FormInformasiPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormInformasiPage(
          name: widget.name,
          phone: widget.phone,
          email: widget.email,
          deskripsi: widget.deskripsi,
          jalan: jalan,
          kecamatan: selectedDistrictName!,
          kabupaten: selectedRegencyName!,
          provinsi: selectedProvinceName!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Formulir Alamat Toko",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Silahkan isi alamat toko laundry Anda dengan lengkap dan benar.",
                style: TextStyle(
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "* Menunjukkan kolom yang wajib diisi",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              
              // Alamat Jalan
              const Text(
                "Alamat Jalan *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              CustomField(
                label: "*Alamat Jalan",
                controller: jalanController,
                isPassword: false,
                textInputType: TextInputType.streetAddress,
                radius: 12,
              ),
              const SizedBox(height: 20),
              
              // Dropdown Provinsi
              const Text(
                "Provinsi *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Pilih Provinsi"),
                    value: selectedProvinceId,
                    items: provinces.map((province) {
                      return DropdownMenuItem<String>(
                        value: province['id'],
                        child: Text(province['name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProvinceId = newValue;
                        selectedProvinceName = provinces.firstWhere(
                          (province) => province['id'] == newValue)['name'];
                        _loadRegencies(newValue!);
                      });
                    },
                  ),
                ),
              ),
              if (isLoadingProvinces) const LinearProgressIndicator(),
              const SizedBox(height: 20),
              
              // Dropdown Kabupaten/Kota
              const Text(
                "Kabupaten/Kota *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Pilih Kabupaten/Kota"),
                    value: selectedRegencyId,
                    items: regencies.map((regency) {
                      return DropdownMenuItem<String>(
                        value: regency['id'],
                        child: Text(regency['name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRegencyId = newValue;
                        selectedRegencyName = regencies.firstWhere(
                          (regency) => regency['id'] == newValue)['name'];
                        _loadDistricts(newValue!);
                      });
                    },
                  ),
                ),
              ),
              if (isLoadingRegencies) const LinearProgressIndicator(),
              const SizedBox(height: 20),
              
              // Dropdown Kecamatan
              const Text(
                "Kecamatan *",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Pilih Kecamatan"),
                    value: selectedDistrictId,
                    items: districts.map((district) {
                      return DropdownMenuItem<String>(
                        value: district['id'],
                        child: Text(district['name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDistrictId = newValue;
                        selectedDistrictName = districts.firstWhere(
                          (district) => district['id'] == newValue)['name'];
                      });
                    },
                  ),
                ),
              ),
              if (isLoadingDistricts) const LinearProgressIndicator(),
              const SizedBox(height: 20),
              
              // Tombol Selanjutnya
              ElevatedButton(
                onPressed: _goToNextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  foregroundColor: Colors.green,
                  elevation: 0,
                ),
                child: const Text(
                  "Selanjutnya",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}