import 'package:flutter/material.dart'; // Memuat library untuk mengembangkan aplikasi Flutter.
import 'package:flutter_bloc/flutter_bloc.dart'; // Menggunakan Flutter Bloc untuk manajemen state.
import 'package:http/http.dart'
    as http; // Library untuk melakukan HTTP request.
import 'dart:convert'; // Untuk mengubah data JSON menjadi objek Dart.
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka URL di aplikasi.

void main() {
  runApp(MyApp()); // Memulai aplikasi Flutter.
}

// Representasi event ketika negara berubah.
class CountryEvent {}

// Event ketika negara yang dipilih berubah.
class CountryChanged extends CountryEvent {
  final String selectedCountry; // Negara yang dipilih.
  CountryChanged(this.selectedCountry); // Konstruktor untuk event.
}

// Representasi state aplikasi berdasarkan negara yang dipilih.
class CountryState {
  final String selectedCountry; // Negara yang dipilih.
  CountryState(this.selectedCountry); // Konstruktor untuk state.
}

// Bloc untuk mengelola perubahan negara.
class CountryBloc extends Bloc<CountryEvent, CountryState> {
  CountryBloc() : super(CountryState('Indonesia')); // State awal 'Indonesia'.

  @override
  Stream<CountryState> mapEventToState(CountryEvent event) async* {
    if (event is CountryChanged) {
      yield CountryState(
          event.selectedCountry); // Mengubah state berdasarkan event.
    }
  }
}

// Widget utama aplikasi.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas di ASEAN', // Judul aplikasi.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema utama aplikasi.
      ),
      home: BlocProvider(
        create: (context) => CountryBloc(), // Menginisialisasi Bloc.
        child: Scaffold(
          appBar: AppBar(
            title: Text('Daftar Universitas di ASEAN'), // Judul halaman.
          ),
          body: Column(
            children: [
              CountrySelector(), // Widget untuk memilih negara.
              Expanded(
                child:
                    UniversitiesList(), // Widget untuk menampilkan daftar universitas.
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget untuk memilih negara.
class CountrySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountryBloc, CountryState>(
      builder: (context, state) {
        return DropdownButton<String>(
          value: state.selectedCountry, // Nilai terpilih dari dropdown.
          onChanged: (String? newValue) {
            if (newValue != null) {
              context.read<CountryBloc>().add(
                  CountryChanged(newValue)); // Memperbarui negara yang dipilih.
            }
          },
          items: <String>[
            'Indonesia',
            'Singapore',
            'Malaysia',
            'Thailand',
            'Vietnam',
            'Philippines',
            'Brunei Darussalam',
            'Myanmar',
            'Cambodia',
            'Laos'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value, // Nilai dari dropdown.
              child: Text(value), // Teks yang ditampilkan.
            );
          }).toList(),
        );
      },
    );
  }
}

// Widget untuk menampilkan daftar universitas.
class UniversitiesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountryBloc, CountryState>(
      builder: (context, state) {
        return FutureBuilder<List<dynamic>>(
          future: _fetchUniversities(
              state.selectedCountry), // Mengambil data universitas.
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // Menampilkan loading spinner.
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Error: ${snapshot.error}')); // Menampilkan pesan error.
            } else {
              List<dynamic> universities =
                  snapshot.data ?? []; // Data universitas.
              return ListView.builder(
                itemCount: universities.length, // Jumlah item dalam daftar.
                itemBuilder: (BuildContext context, int index) {
                  final university =
                      universities[index]; // Universitas saat ini.
                  return GestureDetector(
                    onTap: () {
                      _launchURL(university['web_pages']
                          [0]); // Membuka URL universitas.
                    },
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          university['name'], // Nama universitas.
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            university['web_pages'][0]), // URL universitas.
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  // Fungsi untuk mengambil data universitas dari server.
  Future<List<dynamic>> _fetchUniversities(String country) async {
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); // Endpoint untuk mengambil data.
    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Mengembalikan data universitas.
    } else {
      throw Exception(
          'Failed to load universities'); // Melemparkan error jika gagal mengambil data.
    }
  }

  // Fungsi untuk membuka URL universitas.
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url); // Membuka URL jika bisa dilakukan.
    } else {
      throw 'Could not launch $url'; // Melemparkan error jika gagal membuka URL.
    }
  }
}
