import 'package:flutter/material.dart'; // Mengimpor modul dasar dari Flutter
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor modul Flutter Bloc untuk manajemen state
import 'package:http/http.dart'
    as http; // Mengimpor modul http untuk melakukan permintaan HTTP
import 'dart:convert'; // Mengimpor modul untuk mengonversi JSON

// Fungsi utama yang akan dijalankan pertama kali
void main() {
  runApp(MyApp()); // Menjalankan aplikasi Flutter
}

// Kelas untuk merepresentasikan data universitas
class University {
  final String name; // Nama universitas
  final String website; // Situs web universitas

  // Konstruktor untuk membuat objek University
  University({required this.name, required this.website});

  // Metode factory untuk membuat objek University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Mendapatkan nama universitas dari JSON
      website: json['web_pages']
          [0], // Mendapatkan situs web universitas dari JSON
    );
  }
}

// Kelas untuk manajemen state universitas
class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit() : super([]); // Konstruktor untuk menginisialisasi state

  // Metode untuk memperbarui daftar universitas berdasarkan negara
  void updateUniversityList(String country) async {
    final universities = await fetchUniversity(
        country); // Mendapatkan daftar universitas dari server
    emit(universities); // Memperbarui state dengan daftar universitas yang baru
  }

  // Metode untuk mengambil data universitas dari server
  Future<List<University>> fetchUniversity(String country) async {
    final response = await http.get(// Mengirim permintaan GET ke server
        Uri.parse("http://universities.hipolabs.com/search?country=$country"));

    if (response.statusCode == 200) {
      // Jika permintaan berhasil
      List<University> universities = []; // Inisialisasi daftar universitas
      List<dynamic> jsonData =
          jsonDecode(response.body); // Mendekode respons JSON
      jsonData.forEach((university) {
        universities.add(University.fromJson(
            university)); // Menambahkan universitas ke daftar
      });
      return universities; // Mengembalikan daftar universitas
    } else {
      throw Exception(
          'Gagal memuat data'); // Melempar pengecualian jika gagal memuat data
    }
  }
}

// Kelas utama aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas ASEAN', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Warna tema utama aplikasi
      ),
      home: BlocProvider(
        // Membungkus halaman dengan BlocProvider untuk manajemen state
        create: (context) =>
            UniversityCubit(), // Membuat instans UniversityCubit
        child: UniversityPage(), // Menampilkan halaman UniversityPage
      ),
    );
  }
}

// Halaman untuk menampilkan daftar universitas
class UniversityPage extends StatelessWidget {
  final List<String> aseanCountries = [
    // Daftar negara ASEAN
    'Indonesia',
    'Malaysia',
    'Singapura',
    'Thailand',
    'Vietnam',
    'Filipina',
    'Brunei',
    'Myanmar',
    'Kamboja',
    'Laos'
  ];

  @override
  Widget build(BuildContext context) {
    final universityCubit = BlocProvider.of<UniversityCubit>(
        context); // Mendapatkan akses ke UniversityCubit
    return Scaffold(
      // Membuat tata letak dasar aplikasi
      appBar: AppBar(
        // Menampilkan bilah aplikasi di bagian atas
        title: Text(
          'Daftar Universitas ASEAN', // Judul bilah aplikasi
          style: TextStyle(
            color: Colors.white, // Warna teks
            fontWeight: FontWeight.bold, // Ketebalan teks
          ),
        ),
        backgroundColor: Colors.lightBlue, // Warna latar belakang
        iconTheme: IconThemeData(color: Colors.white), // Tema ikon
      ),
      drawer: Drawer(
        // Menampilkan bilah samping
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlue,
                    Colors.grey[300]!
                  ], // Warna gradien latar belakang
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Pilih Negara', // Judul bilah samping
                    style: TextStyle(
                      color: Colors.white, // Warna teks
                      fontSize: 24, // Ukuran teks
                      fontWeight: FontWeight.bold, // Ketebalan teks
                    ),
                  ),
                ],
              ),
            ),
            for (String country in aseanCountries)
              ListTile(
                title:
                    Text(country), // Menampilkan nama negara di bilah samping
                onTap: () {
                  universityCubit.updateUniversityList(
                      country); // Memperbarui daftar universitas saat negara dipilih
                  Navigator.pop(
                      context); // Menutup bilah samping setelah memilih negara
                },
              ),
          ],
        ),
      ),
      body: BlocBuilder<UniversityCubit, List<University>>(
        builder: (context, universities) {
          if (universities.isEmpty) {
            // Jika daftar universitas kosong
            return Center(
                child:
                    CircularProgressIndicator()); // Menampilkan indikator loading di tengah layar
          } else {
            return ListView.builder(
              itemCount: universities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.lightBlue,
                            Colors.grey[300]!
                          ], // Warna gradien latar belakang
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.school, // Ikon universitas
                          color: Colors.white, // Warna ikon
                        ),
                        title: Text(
                          universities[index].name, // Nama universitas
                          style: TextStyle(
                            color: Colors.white, // Warna teks
                            fontWeight: FontWeight.bold, // Ketebalan teks
                          ),
                        ),
                        subtitle: Text(
                          universities[index].website, // Situs web universitas
                          style: TextStyle(color: Colors.white), // Warna teks
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title:
                                    Text('Detail Universitas'), // Judul dialog
                                content: Text(universities[index]
                                    .name), // Isi dialog dengan nama universitas
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Menutup dialog
                                    },
                                    child: Text(
                                        'Tutup'), // Tombol untuk menutup dialog
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
          }
        },
      ),
    );
  }
}
