import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const GKShoecareApp());
}

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

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
          Align(
            alignment: const Alignment(0, 0.05),
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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const PilihJenisBarangPage()),
                  );
                },
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

class TreatmentOption {
  final String nama;
  final int harga;
  final int estimasiHari;
  const TreatmentOption(this.nama, this.harga, this.estimasiHari);
}

const List<String> jenisBarangList = [
  'Sepatu Dewasa',
  'Sepatu Anak',
  'Sandal (Wanita/Gunung/Flat Shoes)',
  'Topi',
  'Tas Wanita',
  'Backpack/Carrier/Tas Olahraga',
];

const Map<String, List<TreatmentOption>> treatmentPerJenis = {
  'Sepatu Dewasa': [
    TreatmentOption('Fast Cleaning', 25000, 2),
    TreatmentOption('Deep Cleaning', 35000, 4),
    TreatmentOption('Leather Shoes Care', 40000, 4),
    TreatmentOption('Suede Shoes Care', 40000, 3),
    TreatmentOption('Unyellowing', 40000, 5),
    TreatmentOption('Unyellowing + Deep Cleaning', 70000, 5),
    TreatmentOption('Express', 70000, 1),
  ],
  'Sepatu Anak': [
    TreatmentOption('Cuci Sepatu Anak', 25000, 3),
  ],
  'Sandal (Wanita/Gunung/Flat Shoes)': [
    TreatmentOption('Cuci Sandal', 25000, 3),
  ],
  'Topi': [
    TreatmentOption('Wash', 35000, 4),
    TreatmentOption('Hat Repaint (1 warna)', 90000, 5),
  ],
  'Tas Wanita': [
    TreatmentOption('Wash', 35000, 4),
  ],
  'Backpack/Carrier/Tas Olahraga': [
    TreatmentOption('Backpack', 45000, 5),
    TreatmentOption('Carrier', 60000, 5),
    TreatmentOption('Tas Olahraga', 40000, 5),
  ],
};

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

class PilihJenisBarangPage extends StatelessWidget {
  const PilihJenisBarangPage({super.key});

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jenisBarangList.length,
        itemBuilder: (context, index) {
          final nama = jenisBarangList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TreatmentPage(jenisBarang: nama)));
              },
            ),
          );
        },
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

  @override
  Widget build(BuildContext context) {
    final tambahan = warnaPutih ? 5000 : 0;
    final daftarTreatment = treatmentPerJenis[widget.jenisBarang] ?? [];
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: Text(widget.jenisBarang),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: daftarTreatment.length,
              itemBuilder: (context, index) {
                final t = daftarTreatment[index];
                final hargaSatuan = t.harga + tambahan;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(t.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(formatRupiah(hargaSatuan), style: const TextStyle(fontWeight: FontWeight.bold)),
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
      body: Padding(
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
      body: Padding(
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
                        Text(formatRupiah(totalHarga), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
    );
  }
}

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatRupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() => items.removeAt(index)),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentPage()));
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

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  void salin(BuildContext context, String teks, String label) {
    Clipboard.setData(ClipboardData(text: teks));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label disalin')));
  }

  @override
  Widget build(BuildContext context) {
    final items = Keranjang.items;
    final total = Keranjang.totalHarga;

    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
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
                              Expanded(
                                  child: Text('${item.jenisBarang} - ${item.treatment.nama} (${item.jumlah}x)')),
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
                onPressed: () => salin(context, '6042769068', 'Nomor rekening'),
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
                onPressed: () => salin(context, '082128754716', 'Nomor e-wallet'),
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pesanan Diterima'),
                    content: const Text(
                        'Silakan transfer sesuai total, lalu kirim bukti transfer ke WhatsApp admin GK Shoecare: +62821-2356-2903'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Keranjang.items.clear();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Saya Sudah Transfer'),
            ),
          ),
        ],
      ),
    );
  }
}
