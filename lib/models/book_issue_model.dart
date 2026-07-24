// To parse this JSON data, do
//
//     final bookIssueModel = bookIssueModelFromJson(jsonString);

import 'dart:convert';

BookIssueModel bookIssueModelFromJson(String str) =>
    BookIssueModel.fromJson(json.decode(str));

String bookIssueModelToJson(BookIssueModel data) => json.encode(data.toJson());

class BookIssueModel {
  bool status;
  List<BookIssue> data;
  String message;

  BookIssueModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory BookIssueModel.fromJson(Map<String, dynamic> json) => BookIssueModel(
        status: json["status"],
        data: List<BookIssue>.from(
            json["data"].map((x) => BookIssue.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class BookIssue {
  int bookId;
  int counterId;
  DateTime issueDate;
  int leafFrom;
  dynamic leafTo;
  String status;
  int issuedBy;
  DateTime createdAt;
  int id;

  BookIssue({
    required this.bookId,
    required this.counterId,
    required this.issueDate,
    required this.leafFrom,
    required this.leafTo,
    required this.status,
    required this.issuedBy,
    required this.createdAt,
    required this.id,
  });

  factory BookIssue.fromJson(Map<String, dynamic> json) => BookIssue(
        bookId: json["book_id"],
        counterId: json["counter_id"],
        issueDate: DateTime.parse(json["issue_date"]),
        leafFrom: json["leaf_from"],
        leafTo: json["leaf_to"],
        status: json["status"],
        issuedBy: json["issued_by"],
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "counter_id": counterId,
        "issue_date":
            "${issueDate.year.toString().padLeft(4, '0')}-${issueDate.month.toString().padLeft(2, '0')}-${issueDate.day.toString().padLeft(2, '0')}",
        "leaf_from": leafFrom,
        "leaf_to": leafTo,
        "status": status,
        "issued_by": issuedBy,
        "created_at": createdAt.toIso8601String(),
        "id": id,
      };
}
