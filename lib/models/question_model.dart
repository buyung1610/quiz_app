// To parse this JSON data, do
//
//     final questionModel = questionModelFromJson(jsonString);

import 'dart:convert';

QuestionModel questionModelFromJson(String str) => QuestionModel.fromJson(json.decode(str));

String questionModelToJson(QuestionModel data) => json.encode(data.toJson());

class QuestionModel {
    List<Datum> data;

    QuestionModel({
        required this.data,
    });

    factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int id;
    String question;
    String optionA;
    String optionB;
    String optionC;
    String optionD;
    String answer;
    String correctOption;

    Datum({
        required this.id,
        required this.question,
        required this.optionA,
        required this.optionB,
        required this.optionC,
        required this.optionD,
        required this.answer,
        required this.correctOption,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        question: json["question"],
        optionA: json["option_a"],
        optionB: json["option_b"],
        optionC: json["option_c"],
        optionD: json["option_d"],
        answer: json["answer"],
        correctOption: json["correct_option"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "option_a": optionA,
        "option_b": optionB,
        "option_c": optionC,
        "option_d": optionD,
        "answer": answer,
        "correct_option": correctOption,
    };
}
