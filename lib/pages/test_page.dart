import 'dart:convert';

import 'package:countdown_progress_indicator/countdown_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/pages/result.dart';
import 'package:http/http.dart' as http;

class TestPage extends StatefulWidget {
  final QuestionModel questionModel;
  final String username;
  const TestPage({
    super.key,
    required this.questionModel,
    required this.username,
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _controller = CountDownController();
  int index = 0;
  int result = 0;
  String? selectedOption; // Menyimpan opsi yang dipilih

  void navigate(String optionChar) {
    setState(() {
      selectedOption = optionChar;
    });
  }

  void submitAnswer() {
    if (selectedOption == widget.questionModel.data[index].correctOption) {
      result++;
    }

    if (index + 1 < widget.questionModel.data.length) {
      setState(() {
        index++;
        selectedOption = null; // Reset pilihan untuk soal berikutnya
      });
    } else {
      int nilai = hitungNilai();
      sendDataToSheet(widget.username, nilai);
      Navigator.of(context)
          .push(
              MaterialPageRoute(builder: (context) => ResultPage(nilai: nilai)))
          .then((value) {
        setState(() {
          index = 0; // Reset index jika kembali ke halaman utama
        });
      });
    }
  }

  int hitungNilai() {
    int jumlahBenar = result;
    int totalSoal = widget.questionModel.data.length;
    if (totalSoal == 0) return 0;
    double nilaiPerSoal = 100 / totalSoal;
    return (jumlahBenar * nilaiPerSoal).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${index + 1}/${widget.questionModel.data.length}",
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.username,
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              width: 100,
              child: CountDownProgressIndicator(
                controller: _controller,
                valueColor: const Color.fromRGBO(187, 222, 251, 1),
                backgroundColor: const Color.fromRGBO(13, 71, 161, 1),
                initialPosition: 0,
                duration: 100,
                timeTextStyle: TextStyle(color: Colors.black),
                onComplete: () async {
                  await Future.delayed(Duration(milliseconds: 500));
                  int nilai = hitungNilai();
                  sendDataToSheet(widget.username, nilai);
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => ResultPage(nilai: nilai)))
                      .then((value) {
                    setState(() {});
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                height: 120,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Text(
                  widget.questionModel.data[index].question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Pilihan Jawaban
            _buildOption("a", widget.questionModel.data[index].optionA),
            _buildOption("b", widget.questionModel.data[index].optionB),
            _buildOption("c", widget.questionModel.data[index].optionC),
            _buildOption("d", widget.questionModel.data[index].optionD),
            SizedBox(height: 10),
            // Tombol Next
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: selectedOption != null ? submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String option, String text) {
    bool isSelected = selectedOption == option;

    return GestureDetector(
      onTap: () {
        navigate(option);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: const TextStyle(fontSize: 18)),
            Radio<String>(
              value: option,
              groupValue: selectedOption,
              onChanged: (value) {
                navigate(value!);
              },
              activeColor: Colors.blue[900],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> sendDataToSheet(String nama, int nilai) async {
  final String url =
      "https://script.google.com/macros/s/AKfycbxX7lp0gZA5Kk5sU3Afn9eJI-KgP_og-zSheQFFpxUP6XDUSX9XhfFxaFqJQOYKkASi/exec";

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nama": nama,
        "nilai": nilai.toString(),
      }),
    );

    print("Data dikirim: Nama: $nama, Nilai: $nilai");

    if (response.statusCode == 302) {
      String? redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        final redirectedResponse = await http.post(
          Uri.parse(redirectUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"nama": nama, "nilai": nilai.toString()}),
        );
        print(
            "Data berhasil dikirim setelah redirect: ${redirectedResponse.body}");
      }
    } else if (response.statusCode == 200) {
      print("Data berhasil dikirim: ${response.body}");
    } else {
      print("Gagal mengirim data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
