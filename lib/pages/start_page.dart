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

  void getAllData(String username, String url) async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await http.get(Uri.parse(url));
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
      backgroundColor: const Color(0x00848484),
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Quiz App",
                  style:
                      GoogleFonts.montserrat(fontSize: 40, color: Colors.black),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: 
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Username",
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Username wajib diisi!";
                      }
                      return null;
                    },
                  ),
                ),
                isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black), // Mengubah warna menjadi putih
                        semanticsLabel: 'Loading...',
                        semanticsValue: 'Loading...',
                      )
                    // Loading indicator
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                getAllData(usernameController.text, widget.url); 
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 15, 71, 154),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text("Mulai", style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white),),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
