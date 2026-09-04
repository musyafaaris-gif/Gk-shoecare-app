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
              title: Text(
                nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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

class TreatmentPage extends StatelessWidget {
  final String jenisBarang;
  const TreatmentPage({super.key, required this.jenisBarang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treatment untuk $jenisBarang'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Kamu pilih: $jenisBarang\n(halaman treatment nyusul)'),
      ),
    );
  }
}
