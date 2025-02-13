import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  final int nilai;
  const ResultPage({super.key, required this.nilai});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Future<void> _resetSessionAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus semua data sesi

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/trophy.png", width: 150),
            SizedBox(
              height: 20,
            ),
            Text("Selamat !!! Nilai Kamu ${widget.nilai}",
                style:
                    GoogleFonts.montserrat(fontSize: 18, color: Colors.white)),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _resetSessionAndGoHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Kembali ke Halaman Utama",
                style:
                    GoogleFonts.montserrat(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
