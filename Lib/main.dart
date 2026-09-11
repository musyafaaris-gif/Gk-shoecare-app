import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const GKShoecareApp());
}

const String firestoreProjectId = 'gk-shoecare';
const String firestoreBase =
    'https://firestore.googleapis.com/v1/projects/$firestoreProjectId/databases/(default)/documents';
const String cloudName = 'dw0xiznv';
const String uploadPreset = 'gk_shoecare_upload';
const String nomorAdminWa = '6282123562903';

class GKShoecareApp extends StatelessWidget {
  const GKShoecareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GK Shoecare',
      theme: ThemeData(useMaterial3: true),
      home: const SplashPage(),
    );
  }
}

String formatRupiah(int angka) {
  final s = angka.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return 'Rp$buffer';
}

String formatTanggal(DateTime d) {
  const bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  return '${d.day} ${bulan[d.month]} ${d.year}';
}

Color warnaStatus(String status) {
  switch (status) {
    case 'Dikerjakan':
      return Colors.orange[700]!;
    case 'Sudah Selesai':
      return Colors.green[700]!;
    default:
      return Colors.blueGrey;
  }
}

String? validasiNoWa(String input) {
  String bersih = input.replaceAll(RegExp(r'[\s\-]'), '');
  if (bersih.startsWith('+')) bersih = bersih.substring(1);
  if (bersih.length < 10 || !RegExp(r'^\d+$').hasMatch(bersih)) {
    return null;
  }
  return bersih;
}

double? angkaField(Map<String, dynamic> fields, String key) {
  final f = fields[key];
  if (f == null) return null;
  if (f['doubleValue'] != null) return (f['doubleValue'] as num).toDouble();
  if (f['integerValue'] != null) return double.tryParse(f['integerValue'].toString());
  return null;
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<void> mulai(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('nama_customer');
    if (!context.mounted) return;
    if (nama == null || nama.isEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DaftarProfilPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PilihJenisBarangPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
          Align(
            alignment: const Alignment(0, 0.3),
            child: SizedBox(
              width: 220,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: const Color(0xFFF5B315),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                onPressed: () => mulai(context),
                child: const Text(
                  'MULAI TREATMENT',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DaftarProfilPage extends StatefulWidget {
  const DaftarProfilPage({super.key});

  @override
  State<DaftarProfilPage> createState() => _DaftarProfilPageState();
}

class _DaftarProfilPageState extends State<DaftarProfilPage> {
  final namaController = TextEditingController();
  final noWaController = TextEditingController();

  Future<void> simpanDanLanjut() async {
    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama wajib diisi')));
      return;
    }
    final noWaBersih = validasiNoWa(noWaController.text);
    if (noWaBersih == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nomor WA tidak valid (minimal 10 digit angka)')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_customer', namaController.text.trim());
    await prefs.setString('no_wa_customer', noWaBersih);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PilihJenisBarangPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Data Diri'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Isi data diri kamu dulu ya (cuma sekali)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 24),
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nama',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noWaController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nomor WhatsApp',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                  onPressed: simpanDanLanjut,
                  child: const Text('Simpan & Lanjut'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TreatmentOption {
  final String nama;
  final int harga;
  final int estimasiHari;
  const TreatmentOption(this.nama, this.harga, this.estimasiHari);
}

class CartItem {
  final String jenisBarang;
  final TreatmentOption treatment;
  final bool warnaPutih;
  final int jumlah;
  final int hargaSatuan;
  final DateTime tanggalSelesai;
  final File foto;

  CartItem({
    required this.jenisBarang,
    required this.treatment,
    required this.warnaPutih,
    required this.jumlah,
    required this.hargaSatuan,
    required this.tanggalSelesai,
    required this.foto,
  });

  int get subtotal => hargaSatuan * jumlah;
}

class Keranjang {
  static final List<CartItem> items = [];
  static int get totalHarga => items.fold(0, (sum, item) => sum + item.subtotal);
}

class PilihJenisBarangPage extends StatefulWidget {
  const PilihJenisBarangPage({super.key});

  @override
  State<PilihJenisBarangPage> createState() => _PilihJenisBarangPageState();
}

class _PilihJenisBarangPageState extends State<PilihJenisBarangPage> {
  List<String> daftarJenis = [];
  bool sedangMemuat = true;
  String? error;

  @override
  void initState() {
    super.initState();
    muatJenisBarang();
  }

  Future<void> muatJenisBarang() async {
    setState(() {
      sedangMemuat = true;
      error = null;
    });
    try {
      final uri = Uri.parse('$firestoreBase/jenisBarang');
      final response = await http.get(uri);
      if (response.statusCode != 200) throw Exception('Gagal memuat (${response.statusCode})');
      final data = jsonDecode(response.body);
      final docs = (data['documents'] as List?) ?? [];
      final hasil = docs.map((doc) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        return fields['nama']?['stringValue'] as String? ?? '';
      }).where((s) => s.isNotEmpty).toList();
      hasil.sort();
      setState(() {
        daftarJenis = hasil;
        sedangMemuat = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memuat jenis barang: $e';
        sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('GK. SHOECARE'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Status Pesanan',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StatusPesananPage()));
            },
          ),
          IconButton(
            icon: Badge(
              label: Text('${Keranjang.items.length}'),
              isLabelVisible: Keranjang.items.isNotEmpty,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const KeranjangPage()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: sedangMemuat
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!)))
                : RefreshIndicator(
                    onRefresh: muatJenisBarang,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: daftarJenis.length,
                      itemBuilder: (context, index) {
                        final nama = daftarJenis[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => TreatmentPage(jenisBarang: nama)));
                            },
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final namaController = TextEditingController();
  final noWaController = TextEditingController();
  bool sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    muatProfil();
  }

  Future<void> muatProfil() async {
    final prefs = await SharedPreferences.getInstance();
    namaController.text = prefs.getString('nama_customer') ?? '';
    noWaController.text = prefs.getString('no_wa_customer') ?? '';
    setState(() => sedangMemuat = false);
  }

  Future<void> simpanPerubahan() async {
    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama wajib diisi')));
      return;
    }
    final noWaBersih = validasiNoWa(noWaController.text);
    if (noWaBersih == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nomor WA tidak valid (minimal 10 digit angka)')));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_customer', namaController.text.trim());
    await prefs.setString('no_wa_customer', noWaBersih);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil disimpan')));
  }

  Future<void> logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Data nama & nomor WA di HP ini akan dihapus. Yakin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Logout')),
        ],
      ),
    );
    if (konfirmasi != true) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nama_customer');
    await prefs.remove('no_wa_customer');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Nama',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noWaController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Nomor WhatsApp',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16)),
                        onPressed: simpanPerubahan,
                        child: const Text('Simpan Perubahan'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.all(16)),
                        onPressed: logout,
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class TreatmentPage extends StatefulWidget {
  final String jenisBarang;
  const TreatmentPage({super.key, required this.jenisBarang});

  @override
  State<TreatmentPage> createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  bool warnaPutih = false;
  List<TreatmentOption> daftarTreatment = [];
  bool sedangMemuat = true;
  String? error;

  @override
  void initState() {
    super.initState();
    muatTreatment();
  }

  Future<void> muatTreatment() async {
    setState(() {
      sedangMemuat = true;
      error = null;
    });
    try {
      final uri = Uri.parse('$firestoreBase:runQuery');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'structuredQuery': {
            'from': [
              {'collectionId': 'treatments'}
            ],
            'where': {
              'fieldFilter': {
                'field': {'fieldPath': 'jenisBarang'},
                'op': 'EQUAL',
                'value': {'stringValue': widget.jenisBarang}
              }
            }
          }
        }),
      );
      if (response.statusCode != 200) throw Exception('Gagal memuat (${response.statusCode})');
      final List data = jsonDecode(response.body);
      final hasil = data.where((item) => item['document'] != null).map((item) {
        final fields = item['document']['fields'] as Map<String, dynamic>;
        String getString(String key) => fields[key]?['stringValue'] ?? '';
        int getInt(String key) => int.tryParse(fields[key]?['integerValue']?.toString() ?? '0') ?? 0;
        return TreatmentOption(getString('nama'), getInt('harga'), getInt('estimasiHari'));
      }).toList();
      hasil.sort((a, b) => a.nama.compareTo(b.nama));
      setState(() {
        daftarTreatment = hasil;
        sedangMemuat = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memuat treatment: $e';
        sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tambahan = warnaPutih ? 5000 : 0;
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: Text(widget.jenisBarang),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SwitchListTile(
              tileColor: Colors.white,
              title: const Text('Barang warna putih?'),
              subtitle: const Text('Tambahan +Rp5.000'),
              value: warnaPutih,
              onChanged: (val) => setState(() => warnaPutih = val),
            ),
            const Divider(height: 1),
            Expanded(
              child: sedangMemuat
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!)))
                      : daftarTreatment.isEmpty
                          ? const Center(child: Text('Belum ada treatment untuk kategori ini'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: daftarTreatment.length,
                              itemBuilder: (context, index) {
                                final t = daftarTreatment[index];
                                final hargaSatuan = t.harga + tambahan;
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    title: Text(t.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    trailing: Text(formatRupiah(hargaSatuan),
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UploadFotoPage(
                                            jenisBarang: widget.jenisBarang,
                                            treatment: t,
                                            warnaPutih: warnaPutih,
                                            hargaSatuan: hargaSatuan,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadFotoPage extends StatefulWidget {
  final String jenisBarang;
  final TreatmentOption treatment;
  final bool warnaPutih;
  final int hargaSatuan;

  const UploadFotoPage({
    super.key,
    required this.jenisBarang,
    required this.treatment,
    required this.warnaPutih,
    required this.hargaSatuan,
  });

  @override
  State<UploadFotoPage> createState() => _UploadFotoPageState();
}

class _UploadFotoPageState extends State<UploadFotoPage> {
  File? fotoTerpilih;

  Future<void> pilihFoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? hasil = await picker.pickImage(source: source, imageQuality: 70);
    if (hasil != null) {
      setState(() => fotoTerpilih = File(hasil.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Upload Foto Barang'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('${widget.jenisBarang} - ${widget.treatment.nama}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              if (fotoTerpilih != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(fotoTerpilih!, height: 250, width: double.infinity, fit: BoxFit.cover),
                )
              else
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Icon(Icons.image_outlined, size: 64, color: Colors.grey)),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pilihFoto(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Kamera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pilihFoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galeri'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                  onPressed: fotoTerpilih == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JumlahBarangPage(
                                jenisBarang: widget.jenisBarang,
                                treatment: widget.treatment,
                                warnaPutih: widget.warnaPutih,
                                hargaSatuan: widget.hargaSatuan,
                                foto: fotoTerpilih!,
                              ),
                            ),
                          );
                        },
                  child: const Text('Lanjut'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JumlahBarangPage extends StatefulWidget {
  final String jenisBarang;
  final TreatmentOption treatment;
  final bool warnaPutih;
  final int hargaSatuan;
  final File foto;

  const JumlahBarangPage({
    super.key,
    required this.jenisBarang,
    required this.treatment,
    required this.warnaPutih,
    required this.hargaSatuan,
    required this.foto,
  });

  @override
  State<JumlahBarangPage> createState() => _JumlahBarangPageState();
}

class _JumlahBarangPageState extends State<JumlahBarangPage> {
  int jumlah = 1;

  @override
  Widget build(BuildContext context) {
    final totalHarga = widget.hargaSatuan * jumlah;
    final tanggalSelesai = DateTime.now().add(Duration(days: widget.treatment.estimasiHari));

    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Jumlah Barang'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.jenisBarang, style: const TextStyle(fontSize: 16)),
              Text(widget.treatment.nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: jumlah > 1 ? () => setState(() => jumlah--) : null,
                          ),
                          Text('$jumlah', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => jumlah++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Harga'),
                          Text(formatRupiah(totalHarga),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimasi Selesai'),
                          Text(formatTanggal(tanggalSelesai), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                  onPressed: () {
                    Keranjang.items.add(CartItem(
                      jenisBarang: widget.jenisBarang,
                      treatment: widget.treatment,
                      warnaPutih: widget.warnaPutih,
                      jumlah: jumlah,
                      hargaSatuan: widget.hargaSatuan,
                      tanggalSelesai: tanggalSelesai,
                      foto: widget.foto,
                    ));
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const KeranjangPage()));
                  },
                  child: const Text('Tambah ke Keranjang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  void editJumlah(int index) {
    final item = Keranjang.items[index];
    int jumlahBaru = item.jumlah;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${item.jenisBarang} - ${item.treatment.nama}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: jumlahBaru > 1 ? () => setSheetState(() => jumlahBaru--) : null,
                      ),
                      Text('$jumlahBaru', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setSheetState(() => jumlahBaru++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      onPressed: () {
                        setState(() {
                          Keranjang.items[index] = CartItem(
                            jenisBarang: item.jenisBarang,
                            treatment: item.treatment,
                            warnaPutih: item.warnaPutih,
                            jumlah: jumlahBaru,
                            hargaSatuan: item.hargaSatuan,
                            tanggalSelesai: item.tanggalSelesai,
                            foto: item.foto,
                          );
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> konfirmasiHapus(int index) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus item?'),
        content: const Text('Item ini akan dihapus dari keranjang. Yakin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Hapus')),
        ],
      ),
    );
    if (konfirmasi == true) {
      setState(() => Keranjang.items.removeAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = Keranjang.items;
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? const Center(child: Text('Keranjang masih kosong'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(item.foto, width: 48, height: 48, fit: BoxFit.cover),
                    ),
                    title: Text('${item.jenisBarang} - ${item.treatment.nama}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${item.jumlah}x${item.warnaPutih ? ' (putih)' : ''} - Selesai: ${formatTanggal(item.tanggalSelesai)}'),
                    onTap: () => editJumlah(index),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatRupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => konfirmasiHapus(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18)),
                  Text(formatRupiah(Keranjang.totalHarga), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                      child: const Text('Tambah Item Lain'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      onPressed: items.isEmpty
                          ? null
                          : () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MetodePesanPage()));
                            },
                      child: const Text('Bayar'),
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
}

class MetodePesanPage extends StatelessWidget {
  const MetodePesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Pilih Metode Pesan'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inbox),
                  title: const Text('Loker Self-Service', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Taruh barang di loker toko'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LokerPage()));
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('Antar Langsung ke Toko', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Serahkan barang langsung ke toko'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PaymentPage(lokerNomor: '-', metodePesan: 'Toko Langsung', ongkir: 0),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delivery_dining),
                  title: const Text('Pesan Online', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Dijemput & diantar, ada biaya ongkir'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HitungOngkirPage()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HitungOngkirPage extends StatefulWidget {
  const HitungOngkirPage({super.key});

  @override
  State<HitungOngkirPage> createState() => _HitungOngkirPageState();
}

class _HitungOngkirPageState extends State<HitungOngkirPage> {
  bool sedangProses = true;
  String? error;
  int? ongkirDihitung;
  double? jarakKm;

  @override
  void initState() {
    super.initState();
    hitungOngkir();
  }

  Future<void> hitungOngkir() async {
    setState(() {
      sedangProses = true;
      error = null;
    });
    try {
      bool layananAktif = await Geolocator.isLocationServiceEnabled();
      if (!layananAktif) {
        throw Exception('Aktifkan GPS/Lokasi HP kamu dulu');
      }
      LocationPermission izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
        if (izin == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }
      if (izin == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diblokir permanen, aktifkan lewat Settings HP');
      }

      final posisi = await Geolocator.getCurrentPosition();

      final resToko = await http.get(Uri.parse('$firestoreBase/pengaturan/toko'));
      if (resToko.statusCode != 200) throw Exception('Lokasi toko belum diatur admin');
      final dataToko = jsonDecode(resToko.body);
      final fieldsToko = dataToko['fields'] as Map<String, dynamic>? ?? {};
      final latToko = angkaField(fieldsToko, 'lat');
      final lngToko = angkaField(fieldsToko, 'lng');
      if (latToko == null || lngToko == null) throw Exception('Lokasi toko belum diatur admin');

      final jarakMeter = Geolocator.distanceBetween(posisi.latitude, posisi.longitude, latToko, lngToko);
      final jarak = jarakMeter / 1000;

      final resTier = await http.get(Uri.parse('$firestoreBase/ongkirTiers'));
      final dataTier = jsonDecode(resTier.body);
      final docsTier = (dataTier['documents'] as List?) ?? [];
      int tarifDitemukan = -1;
      for (final doc in docsTier) {
        final f = doc['fields'] as Map<String, dynamic>? ?? {};
        final min = angkaField(f, 'jarakMin') ?? 0;
        final max = angkaField(f, 'jarakMax') ?? 0;
        final tarif = int.tryParse(f['tarif']?['integerValue']?.toString() ?? '0') ?? 0;
        if (jarak >= min && jarak <= max) {
          tarifDitemukan = tarif;
          break;
        }
      }
      if (tarifDitemukan == -1) {
        throw Exception('Jarak kamu (${jarak.toStringAsFixed(1)} km) di luar jangkauan layanan online');
      }

      setState(() {
        jarakKm = jarak;
        ongkirDihitung = tarifDitemukan;
        sedangProses = false;
      });
    } catch (e) {
      setState(() {
        error = '$e'.replaceFirst('Exception: ', '');
        sedangProses = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Hitung Ongkir'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: sedangProses
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Menghitung jarak & ongkir...'),
                    ],
                  )
                : error != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: hitungOngkir, child: const Text('Coba Lagi')),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Jarak ke toko: ${jarakKm!.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Ongkir: ${formatRupiah(ongkirDihitung!)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(16)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      lokerNomor: '-',
                                      metodePesan: 'Online (Dijemput & Diantar)',
                                      ongkir: ongkirDihitung!,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Lanjut ke Pembayaran'),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class LokerPage extends StatefulWidget {
  const LokerPage({super.key});

  @override
  State<LokerPage> createState() => _LokerPageState();
}

class _LokerPageState extends State<LokerPage> {
  Map<String, bool> statusLoker = {};
  bool sedangMemuat = true;
  String? error;

  @override
  void initState() {
    super.initState();
    muatLoker();
  }

  Future<void> muatLoker() async {
    setState(() {
      sedangMemuat = true;
      error = null;
    });
    try {
      final uri = Uri.parse('$firestoreBase/lokers');
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      final docs = (data['documents'] as List?) ?? [];
      final hasil = <String, bool>{};
      for (final doc in docs) {
        final fields = doc['fields'] as Map<String, dynamic>? ?? {};
        final name = doc['name'] as String;
        final nomor = name.split('/').last;
        hasil[nomor] = fields['terisi']?['booleanValue'] ?? false;
      }
      setState(() {
        statusLoker = hasil;
        sedangMemuat = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memuat data loker: $e';
        sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Pilih Nomor Loker'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: muatLoker)],
      ),
      body: SafeArea(
        child: sedangMemuat
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!)))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 15,
                      itemBuilder: (context, index) {
                        final nomor = (index + 1).toString();
                        final terisi = statusLoker[nomor] ?? false;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: terisi ? Colors.grey[400] : Colors.black,
                            foregroundColor: terisi ? Colors.grey[700] : const Color(0xFFF5B315),
                          ),
                          onPressed: terisi
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PaymentPage(lokerNomor: nomor, metodePesan: 'Loker', ongkir: 0),
                                    ),
                                  );
                                },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(nomor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              if (terisi) const Icon(Icons.lock, size: 14),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _PilihLokerSheet extends StatefulWidget {
  const _PilihLokerSheet();

  @override
  State<_PilihLokerSheet> createState() => _PilihLokerSheetState();
}

class _PilihLokerSheetState extends State<_PilihLokerSheet> {
  Map<String, bool> statusLoker = {};
  bool sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    muat();
  }

  Future<void> muat() async {
    final response = await http.get(Uri.parse('$firestoreBase/lokers'));
    final data = jsonDecode(response.body);
    final docs = (data['documents'] as List?) ?? [];
    final hasil = <String, bool>{};
    for (final doc in docs) {
      final fields = doc['fields'] as Map<String, dynamic>? ?? {};
      final name = doc['name'] as String;
      hasil[name.split('/').last] = fields['terisi']?['booleanValue'] ?? false;
    }
    setState(() {
      statusLoker = hasil;
      sedangMemuat = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: sedangMemuat
          ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pilih Nomor Loker Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    final nomor = (index + 1).toString();
                    final terisi = statusLoker[nomor] ?? false;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: terisi ? Colors.grey[400] : Colors.black,
                        foregroundColor: terisi ? Colors.grey[700] : const Color(0xFFF5B315),
                      ),
                      onPressed: terisi ? null : () => Navigator.pop(context, nomor),
                      child: Text(nomor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final String lokerNomor;
  final String metodePesan;
  final int ongkir;
  const PaymentPage({super.key, required this.lokerNomor, required this.metodePesan, required this.ongkir});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool sedangKirim = false;
  bool sudahTerkirim = false;
  String pesanWa = '';
  late String lokerTerpilih;

  @override
  void initState() {
    super.initState();
    lokerTerpilih = widget.lokerNomor;
  }

  Future<void> ubahLoker() async {
    final terpilihBaru = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _PilihLokerSheet(),
    );
    if (terpilihBaru != null) {
      setState(() => lokerTerpilih = terpilihBaru);
    }
  }

  void salin(String teks, String label) {
    Clipboard.setData(ClipboardData(text: teks));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label disalin')));
  }

  Future<String> uploadFotoKeCloudinary(File foto) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', foto.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Upload foto gagal: $body');
    }
    final data = jsonDecode(body);
    return data['secure_url'] as String;
  }

  Future<void> simpanPesananKeFirestore(
      CartItem item, String fotoUrl, String namaCustomer, String noWaCustomer) async {
    final uri = Uri.parse('$firestoreBase/pesanan');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fields': {
          'namaCustomer': {'stringValue': namaCustomer},
          'noWaCustomer': {'stringValue': noWaCustomer},
          'jenisBarang': {'stringValue': item.jenisBarang},
          'treatment': {'stringValue': item.treatment.nama},
          'warnaPutih': {'booleanValue': item.warnaPutih},
          'jumlah': {'integerValue': item.jumlah.toString()},
          'hargaSatuan': {'integerValue': item.hargaSatuan.toString()},
          'subtotal': {'integerValue': item.subtotal.toString()},
          'tanggalSelesai': {'stringValue': formatTanggal(item.tanggalSelesai)},
          'fotoUrl': {'stringValue': fotoUrl},
          'status': {'stringValue': 'Sudah Diambil'},
          'lokerNomor': {'stringValue': lokerTerpilih},
          'metodePesan': {'stringValue': widget.metodePesan},
          'ongkir': {'integerValue': widget.ongkir.toString()},
          'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
        }
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Simpan pesanan gagal: ${response.body}');
    }
  }

  Future<void> kunciLoker(String namaCustomer) async {
    if (widget.metodePesan != 'Loker') return;
    final uri = Uri.parse('$firestoreBase/lokers/$lokerTerpilih').replace(queryParameters: {
      'updateMask.fieldPaths': ['terisi', 'namaCustomer'],
    });
    await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fields': {
          'terisi': {'booleanValue': true},
          'namaCustomer': {'stringValue': namaCustomer},
        }
      }),
    );
  }

  Future<void> kirimSemuaPesanan() async {
    setState(() => sedangKirim = true);
    final items = List<CartItem>.from(Keranjang.items);
    final total = Keranjang.totalHarga + widget.ongkir;
    try {
      final prefs = await SharedPreferences.getInstance();
      final namaCustomer = prefs.getString('nama_customer') ?? '';
      final noWaCustomer = prefs.getString('no_wa_customer') ?? '';

      for (final item in items) {
        final fotoUrl = await uploadFotoKeCloudinary(item.foto);
        await simpanPesananKeFirestore(item, fotoUrl, namaCustomer, noWaCustomer);
      }
      await kunciLoker(namaCustomer);

      final buffer = StringBuffer();
      buffer.writeln('Halo, saya $namaCustomer mau konfirmasi pesanan:');
      for (final item in items) {
        buffer.writeln(
            '- ${item.jenisBarang} - ${item.treatment.nama} (${item.jumlah}x): ${formatRupiah(item.subtotal)}');
      }
      buffer.writeln('Metode: ${widget.metodePesan}');
      if (widget.metodePesan == 'Loker') buffer.writeln('Nomor Loker: $lokerTerpilih');
      if (widget.ongkir > 0) buffer.writeln('Ongkir: ${formatRupiah(widget.ongkir)}');
      buffer.writeln('Total: ${formatRupiah(total)}');
      buffer.writeln('Bukti transfer menyusul di chat ini ya.');

      Keranjang.items.clear();

      if (!mounted) return;
      setState(() {
        sudahTerkirim = true;
        pesanWa = buffer.toString();
        sedangKirim = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesanan, coba lagi. ($e)')),
      );
      setState(() => sedangKirim = false);
    }
  }

  Future<void> bukaWhatsApp() async {
    final uri = Uri.parse('https://wa.me/$nomorAdminWa?text=${Uri.encodeComponent(pesanWa)}');
    final berhasil = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!berhasil && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka WhatsApp, pastikan WhatsApp terinstall')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sudahTerkirim) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5B315),
        appBar: AppBar(
          title: const Text('Pesanan Diterima'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                const Text('Pesanan kamu sudah tersimpan!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                if (widget.metodePesan == 'Loker')
                  Text('Taruh barang di Loker No. $lokerTerpilih',
                      style: const TextStyle(fontSize: 16), textAlign: TextAlign.center)
                else
                  Text(widget.metodePesan, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16)),
                    onPressed: () async {
                      await bukaWhatsApp();
                      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Kirim ke WhatsApp'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final items = Keranjang.items;
    final total = Keranjang.totalHarga + widget.ongkir;

    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: items
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('${item.jenisBarang} - ${item.treatment.nama} (${item.jumlah}x)')),
                                Text(formatRupiah(item.subtotal)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Metode Pesan'),
                trailing: Text(widget.metodePesan, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (widget.metodePesan == 'Loker')
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inbox),
                  title: const Text('Nomor Loker'),
                  trailing: Text(lokerTerpilih, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  onTap: ubahLoker,
                ),
              ),
            if (widget.metodePesan == 'Loker')
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: TextButton.icon(
                  onPressed: ubahLoker,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Ubah Nomor Loker'),
                ),
              ),
            if (widget.ongkir > 0)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delivery_dining),
                  title: const Text('Ongkir'),
                  trailing: Text(formatRupiah(widget.ongkir), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 8),
            Card(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Bayar', style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text(formatRupiah(total),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('Transfer Bank BCA'),
                subtitle: const Text('6042769068 a.n. Azmi Alimudin'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => salin('6042769068', 'Nomor rekening'),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('E-Wallet'),
                subtitle: const Text('+62 821-2875-4716 a.n. Azmi Alimudin'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => salin('082128754716', 'Nomor e-wallet'),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text('QRIS', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('file_000000001344820880218e311f8ddb40.png', width: 220),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                onPressed: sedangKirim ? null : kirimSemuaPesanan,
                child: sedangKirim
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Saya Sudah Transfer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RiwayatPesanan {
  final String jenisBarang;
  final String treatment;
  final int subtotal;
  final String tanggalSelesai;
  final String status;
  final String fotoUrl;
  final String lokerNomor;
  final String metodePesan;
  final DateTime createdAt;

  RiwayatPesanan({
    required this.jenisBarang,
    required this.treatment,
    required this.subtotal,
    required this.tanggalSelesai,
    required this.status,
    required this.fotoUrl,
    required this.lokerNomor,
    required this.metodePesan,
    required this.createdAt,
  });

  factory RiwayatPesanan.fromFirestore(Map<String, dynamic> fields) {
    String getString(String key) => fields[key]?['stringValue'] ?? '';
    int getInt(String key) => int.tryParse(fields[key]?['integerValue']?.toString() ?? '0') ?? 0;
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(fields['createdAt']?['timestampValue'] ?? '');
    } catch (_) {
      createdAt = DateTime.now();
    }
    final statusMentah = getString('status');
    return RiwayatPesanan(
      jenisBarang: getString('jenisBarang'),
      treatment: getString('treatment'),
      subtotal: getInt('subtotal'),
      tanggalSelesai: getString('tanggalSelesai'),
      status: statusMentah.isEmpty ? 'Sudah Diambil' : statusMentah,
      fotoUrl: getString('fotoUrl'),
      lokerNomor: getString('lokerNomor'),
      metodePesan: getString('metodePesan'),
      createdAt: createdAt,
    );
  }
}

class StatusPesananPage extends StatefulWidget {
  const StatusPesananPage({super.key});

  @override
  State<StatusPesananPage> createState() => _StatusPesananPageState();
}

class _StatusPesananPageState extends State<StatusPesananPage> {
  List<RiwayatPesanan> daftar = [];
  bool sedangMemuat = true;
  String? error;

  @override
  void initState() {
    super.initState();
    muatData();
  }

  Future<void> muatData() async {
    setState(() {
      sedangMemuat = true;
      error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final noWa = prefs.getString('no_wa_customer') ?? '';
      final uri = Uri.parse('$firestoreBase:runQuery');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'structuredQuery': {
            'from': [
              {'collectionId': 'pesanan'}
            ],
            'where': {
              'fieldFilter': {
                'field': {'fieldPath': 'noWaCustomer'},
                'op': 'EQUAL',
                'value': {'stringValue': noWa}
              }
            }
          }
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Gagal memuat (${response.statusCode})');
      }
      final List data = jsonDecode(response.body);
      final hasil = data
          .where((item) => item['document'] != null)
          .map((item) => RiwayatPesanan.fromFirestore(item['document']['fields'] as Map<String, dynamic>))
          .toList();
      hasil.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        daftar = hasil;
        sedangMemuat = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memuat: $e';
        sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Status Pesanan Saya'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: muatData)],
      ),
      body: SafeArea(
        child: sedangMemuat
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!)))
                : daftar.isEmpty
                    ? const Center(child: Text('Belum ada pesanan'))
                    : RefreshIndicator(
                        onRefresh: muatData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: daftar.length,
                          itemBuilder: (context, index) {
                            final p = daftar[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        p.fotoUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) =>
                                            Container(width: 60, height: 60, color: Colors.grey[300]),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${p.jenisBarang} - ${p.treatment}',
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text('${formatRupiah(p.subtotal)} • ${p.metodePesan}',
                                              style: const TextStyle(fontSize: 12)),
                                          if (p.lokerNomor.isNotEmpty && p.lokerNomor != '-')
                                            Text('Loker ${p.lokerNomor}', style: const TextStyle(fontSize: 12)),
                                          Text('Estimasi: ${p.tanggalSelesai}', style: const TextStyle(fontSize: 12)),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: warnaStatus(p.status), borderRadius: BorderRadius.circular(20)),
                                            child: Text(p.status,
                                                style: const TextStyle(
                                                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
