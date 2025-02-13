import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/pages/test_page.dart';
import 'package:http/http.dart' as http;

class StartPage extends StatefulWidget {
  final String url;
  const StartPage({super.key, required this.url});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late QuestionModel questions;
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  bool isLoading = false;

  void getAllData(String username) async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.get(Uri.parse(widget.url));
      var data = json.decode(response.body) as Map<String, dynamic>?;
      if (data != null) {
        questions = QuestionModel.fromJson(data);
      } else {
        throw Exception("Gagal mengambil data soal!");
      }

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TestPage(
            questionModel: questions,
            username: username,
          ),
        ));
      }
    } catch (err) {
      print('ERROR $err');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Quiz App",
                  style:
                      GoogleFonts.montserrat(fontSize: 26, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Username",
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Username wajib diisi!";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),
                isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white), // Mengubah warna menjadi putih
                        semanticsLabel: 'Loading...',
                        semanticsValue: 'Loading...',
                      )
                    // Loading indicator
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            getAllData(usernameController.text);
                          }
                        },
                        child: Text("Mulai"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
