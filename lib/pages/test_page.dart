import 'dart:convert';

import 'package:countdown_progress_indicator/countdown_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/pages/result.dart';
import 'package:http/http.dart' as http;
// import 'package:dio/dio.dart';

class TestPage extends StatefulWidget {
  final QuestionModel questionModel;
  final String username;
  const TestPage(
      {super.key, required this.questionModel, required this.username});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _controller = CountDownController();
  int index = 0;
  int result = 0;

  void navigate(String optionChar) {
    setState(() {
      if (optionChar == widget.questionModel.data[index].correctOption) {
        result++;
      }
      if (index + 1 < widget.questionModel.data.length) {
        index++; // Tambahkan index hanya jika masih dalam batas
      } else {
        int nilai = hitungNilai();
        sendDataToSheet(widget.username, nilai);
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => ResultPage(nilai: nilai)))
            .then((value) {
          setState(() {
            index = 0; // Reset index jika kembali ke halaman utama
          });
        });
      }
    });
  }

  int hitungNilai() {
    int jumlahBenar = result;
    int totalSoal = widget.questionModel.data.length;

    if (totalSoal == 0) return 0; // Hindari error pembagian dengan nol

    double nilaiPerSoal = 100 / totalSoal; // Hasil dalam double
    int nilai = (jumlahBenar * nilaiPerSoal).round(); // Dibulatkan

    return nilai;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
          child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${index + 1} / ${widget.questionModel.data.length}",
                  style: GoogleFonts.montserrat(
                      fontSize: 18, color: Colors.white)),
              Text(widget.username,
                  style:
                      GoogleFonts.montserrat(fontSize: 18, color: Colors.white))
            ],
          ),
        ),
        SizedBox(
          height: 150,
          width: 150,
          child: CountDownProgressIndicator(
            controller: _controller,
            valueColor: Colors.red,
            backgroundColor: Colors.white,
            initialPosition: 0,
            duration: 10,
            text: 'detik',
            timeTextStyle: TextStyle(
              color: Colors.white,
            ),
            labelTextStyle: TextStyle(
              color: Colors.white,
            ),
            onComplete: () async {
              await Future.delayed(Duration(milliseconds: 500));
              int nilai = hitungNilai();
              sendDataToSheet(widget.username, nilai);
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => ResultPage(
                            nilai: nilai,
                          )))
                  .then((value) {
                setState(() {});
              });
            },
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.questionModel.data[index].question,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 22, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        GestureDetector(
          onTap: () {
            navigate("a");
            // Navigator.of(context)
            //     .push(MaterialPageRoute(builder: (context) => ResultPage()));
          },
          child: OptionWidget(
              color: Colors.red,
              optionChar: "A",
              optionDetail: widget.questionModel.data[index].optionA),
        ),
        GestureDetector(
          onTap: () {
            navigate("b");
          },
          child: OptionWidget(
              color: Colors.yellow,
              optionChar: "B",
              optionDetail: widget.questionModel.data[index].optionB),
        ),
        GestureDetector(
          onTap: () {
            navigate("c");
          },
          child: OptionWidget(
              color: Colors.green,
              optionChar: "C",
              optionDetail: widget.questionModel.data[index].optionC),
        ),
        GestureDetector(
          onTap: () {
            navigate("d");
          },
          child: OptionWidget(
              color: Colors.blue,
              optionChar: "D",
              optionDetail: widget.questionModel.data[index].optionD),
        ),
      ])),
    );
  }
}

class OptionWidget extends StatelessWidget {
  final String optionChar;
  final String optionDetail;
  final Color color;
  const OptionWidget({
    super.key,
    required this.optionChar,
    required this.optionDetail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(color: color),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(optionChar,
                  style: GoogleFonts.montserrat(
                      fontSize: 18, color: Colors.white)),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Text(optionDetail,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(
                        fontSize: 18, color: Colors.white)),
              )
            ],
          ),
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
        "nilai": nilai.toString(), // Pastikan nilai dikirim dengan benar
      }),
    );

    print("nama: " + nama);
    print("nilai: " + nilai.toString());

    if (response.statusCode == 302) {
      String? redirectUrl = response.headers['location'];
      if (redirectUrl != null) {
        print("Redirecting to: $redirectUrl");

        // Kirim ulang data ke URL baru setelah redirect
        final redirectedResponse = await http.post(
          Uri.parse(redirectUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "nama": nama,
            "nilai": nilai.toString(),
          }),
        );

        print(
            "Data berhasil dikirim setelah redirect: ${redirectedResponse.body}");
      } else {
        print("Redirect 302 tetapi tidak ada lokasi tujuan.");
      }
    } else if (response.statusCode == 200) {
      print("Data berhasil dikirim: ${response.body}");
    } else {
      print("Gagal mengirim data: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
