import 'package:flutter/material.dart';

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
      home: const PilihJenisBarangPage(),
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

const List<TreatmentOption> daftarTreatment = [
  TreatmentOption('Fast Cleaning', 25000, 2),
  TreatmentOption('Deep Cleaning', 35000, 4),
  TreatmentOption('Heels/Flat Shoes/Sandal/Kid Shoes', 25000, 3),
  TreatmentOption('Leather Shoes Care', 40000, 4),
  TreatmentOption('Suede Shoes Care', 40000, 3),
  TreatmentOption('Unyellowing', 40000, 5),
  TreatmentOption('Unyellowing + Deep Cleaning', 70000, 5),
  TreatmentOption('Express', 70000, 1),
  TreatmentOption('Carrier', 60000, 5),
  TreatmentOption('Hat Repaint (1 warna)', 90000, 5),
];

class PilihJenisBarangPage extends StatelessWidget {
  const PilihJenisBarangPage({super.key});

  static const List<String> jenisBarang = [
    'Sepatu Dewasa',
    'Sepatu Anak',
    'Sandal (Wanita/Gunung/Flat Shoes)',
    'Topi',
    'Tas Wanita',
    'Backpack/Carrier/Tas Olahraga',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5B315),
      appBar: AppBar(
        title: const Text('GK. SHOECARE'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jenisBarang.length,
        itemBuilder: (context, index) {
          final nama = jenisBarang[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TreatmentPage(jenisBarang: nama)),
                );
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
                          builder: (context) => JumlahBarangPage(
                            jenisBarang: widget.jenisBarang,
                            treatment: t,
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

class JumlahBarangPage extends StatefulWidget {
  final String jenisBarang;
  final TreatmentOption treatment;
  final int hargaSatuan;

  const JumlahBarangPage({
    super.key,
    required this.jenisBarang,
    required this.treatment,
    required this.hargaSatuan,
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman pembayaran nyusul')),
                  );
                },
                child: const Text('Lanjut ke Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
