import 'package:flutter/material.dart'; // Mengimpor library Flutter untuk membuat aplikasi mobile.
import 'package:http/http.dart'
    as http; // Mengimpor package http untuk melakukan permintaan HTTP.
import 'dart:convert'; // Mengimpor package untuk mengkonversi JSON.
import 'package:provider/provider.dart'; // Mengimpor package provider untuk manajemen state.

void main() {
  runApp(MyApp()); // Memulai aplikasi dengan menjalankan widget MyApp.
}

// Membuat class untuk merepresentasikan objek Universitas.
class University {
  final String name; // Nama universitas.
  final String website; // Website universitas.

  University(
      {required this.name, required this.website}); // Konstruktor universitas.

  // Factory method untuk membuat objek University dari JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Ambil nama universitas dari JSON.
      website: json['web_pages'][0], // Ambil website universitas dari JSON.
    );
  }
}

// Class untuk menyimpan daftar universitas dengan mengimplementasikan ChangeNotifier.
class UniversityList extends ChangeNotifier {
  late Future<List<University>>
      futureUniversity; // Future untuk daftar universitas.
  late String country; // Negara untuk mencari universitas.

  // Konstruktor UniversitasList dengan default country "Indonesia".
  UniversityList({this.country = "Indonesia"}) {
    futureUniversity =
        fetchUniversity(country); // Mengambil daftar universitas.
  }

  // Fungsi untuk mengambil daftar universitas dari API.
  Future<List<University>> fetchUniversity(String country) async {
    final response = await http.get(Uri.parse(
        "http://universities.hipolabs.com/search?country=$country")); // Permintaan HTTP untuk mendapatkan daftar universitas berdasarkan negara.

    if (response.statusCode == 200) {
      List<University> universities =
          []; // List untuk menyimpan objek Universitas.
      List<dynamic> jsonData =
          jsonDecode(response.body); // Konversi respons ke JSON.
      jsonData.forEach((university) {
        universities.add(University.fromJson(
            university)); // Tambahkan universitas ke dalam list.
      });
      return universities; // Kembalikan daftar universitas.
    } else {
      throw Exception('Gagal memuat data'); // Jika gagal, lemparkan error.
    }
  }

  // Fungsi untuk memperbarui daftar universitas berdasarkan negara yang dipilih.
  void updateUniversityList(String country) {
    this.country = country; // Perbarui negara.
    futureUniversity =
        fetchUniversity(country); // Ambil daftar universitas baru.
    notifyListeners(); // Beritahu listener bahwa ada perubahan.
  }
}

// Widget utama aplikasi.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas ASEAN', // Judul aplikasi.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema aplikasi.
      ),
      home: ChangeNotifierProvider(
        // Menggunakan ChangeNotifierProvider untuk memberikan state UniversitasList.
        create: (context) =>
            UniversityList(), // Membuat instance dari UniversityList.
        child: UniversityPage(), // Menampilkan halaman UniversityPage.
      ),
    );
  }
}

// Halaman utama yang menampilkan daftar universitas.
class UniversityPage extends StatelessWidget {
  final List<String> aseanCountries = [
    // Daftar negara ASEAN.
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Thailand',
    'Vietnam',
    'Philippines',
    'Brunei',
    'Myanmar',
    'Cambodia',
    'Laos'
  ];

  @override
  Widget build(BuildContext context) {
    var universityList = Provider.of<UniversityList>(
        context); // Mendapatkan state UniversitasList.
    return Scaffold(
      // Scaffold untuk menyusun struktur halaman.
      appBar: AppBar(
        title: Text(
          'Daftar Universitas ASEAN', // Judul AppBar.
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue, // Warna latar belakang AppBar.
        iconTheme: IconThemeData(color: Colors.white), // Tema ikon AppBar.
      ),
      drawer: Drawer(
        // Drawer untuk menampilkan menu samping.
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.lightBlue, Colors.grey[300]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Pilih Negara', // Judul Drawer.
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            for (String country
                in aseanCountries) // Menampilkan daftar negara ASEAN sebagai pilihan di Drawer.
              ListTile(
                title: Text(country), // Menampilkan nama negara.
                onTap: () {
                  universityList.updateUniversityList(
                      country); // Memperbarui daftar universitas berdasarkan negara yang dipilih.
                  Navigator.pop(
                      context); // Menutup Drawer setelah memilih negara.
                },
              ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FutureBuilder<List<University>>(
              future: universityList
                  .futureUniversity, // Membangun daftar universitas yang akan datang.
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Menampilkan loading indicator jika sedang memuat data.
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        'Error: ${snapshot.error}'), // Menampilkan pesan error jika terjadi kesalahan.
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!
                        .length, // Menampilkan jumlah universitas yang diterima.
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.lightBlue, Colors.grey[300]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.school,
                                color: Colors.white,
                              ),
                              title: Text(
                                snapshot.data![index]
                                    .name, // Menampilkan nama universitas.
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                snapshot.data![index]
                                    .website, // Menampilkan website universitas.
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                          'Detail Universitas'), // Judul dialog.
                                      content: Text(snapshot.data![index]
                                          .name), // Menampilkan nama universitas di dalam dialog.
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Menutup dialog saat tombol ditutup ditekan.
                                          },
                                          child: Text(
                                              'Tutup'), // Menampilkan tombol tutup.
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                        'Tidak ada data'), // Menampilkan pesan jika tidak ada data yang ditemukan.
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
