import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/pages/start_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String url =
      "https://script.google.com/macros/s/AKfycby6z1Kl5YlJWSmLtlVovDV5xveB1XTelUx1xAcfrITYu0PxSPH4Z0bd1xysXNLorBjlxg/exec";

  Future<List<String>> fetchSheets() async {
    final response = await http.get(Uri.parse("$url?action=getSheets"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return List<String>.from(data['sheets']);
      }
    }
    throw Exception("Gagal mengambil data sheet!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: FutureBuilder<List<String>>(
        future: fetchSheets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Loading indikator
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Tidak ada sheet yang tersedia"));
          }
          List<String> sheets = snapshot.data!;
          return ListView.builder(
            itemCount: sheets.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Text(
                    "Pilihlah Salah Satu Materi Soal Dibawah Ini",
                    style: GoogleFonts.montserrat(
                        fontSize: 18, color: Colors.white),
                  ),
                );
              }
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                child: SizedBox(
                  height:
                      45, // ✅ Atur tinggi button (sesuaikan sesuai kebutuhan)
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            StartPage(url: "$url?sheet=${sheets[index - 1]}"),
                      ));
                      print("Sheet terpilih: ${sheets[index - 1]}");
                    },
                    child: Text(sheets[index - 1],
                        style: GoogleFonts.montserrat(
                            fontSize: 16, color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
