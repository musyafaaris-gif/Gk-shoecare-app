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

class TreatmentOption {
  final String nama;
  final int harga;
  const TreatmentOption(this.nama, this.harga);
}

const List<TreatmentOption> daftarTreatment = [
  TreatmentOption('Fast Cleaning', 25000),
  TreatmentOption('Deep Cleaning', 35000),
  TreatmentOption('Heels/Flat Shoes/Sandal/Kid Shoes', 25000),
  TreatmentOption('Leather Shoes Care', 40000),
  TreatmentOption('Suede Shoes Care', 40000),
  TreatmentOption('Unyellowing', 40000),
  TreatmentOption('Unyellowing + Deep Cleaning', 70000),
  TreatmentOption('Express', 70000),
  TreatmentOption('Carrier', 60000),
  TreatmentOption('Hat Repaint (1 warna)', 90000),
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
                  MaterialPageRoute(
                    builder: (context) => TreatmentPage(jenisBarang: nama),
                  ),
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
                final total = t.harga + tambahan;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(t.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(formatRupiah(total), style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dipilih: ${t.nama} - ${formatRupiah(total)}')),
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
