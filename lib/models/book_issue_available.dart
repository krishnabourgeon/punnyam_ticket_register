// // To parse this JSON data, do
// //
// //     final bookIssueAvailable = bookIssueAvailableFromJson(jsonString);

// import 'dart:convert';

// BookIssueAvailable bookIssueAvailableFromJson(String str) => BookIssueAvailable.fromJson(json.decode(str));

// String bookIssueAvailableToJson(BookIssueAvailable data) => json.encode(data.toJson());

// class BookIssueAvailable {
//     bool status;
//     List<dynamic> data;
//     Meta meta;
//     dynamic message;

//     BookIssueAvailable({
//         required this.status,
//         required this.data,
//         required this.meta,
//         required this.message,
//     });

//     factory BookIssueAvailable.fromJson(Map<String, dynamic> json) => BookIssueAvailable(
//         status: json["status"],
//         data: List<dynamic>.from(json["data"].map((x) => x)),
//         meta: Meta.fromJson(json["meta"]),
//         message: json["message"],
//     );

//     Map<String, dynamic> toJson() => {
//         "status": status,
//         "data": List<dynamic>.from(data.map((x) => x)),
//         "meta": meta.toJson(),
//         "message": message,
//     };
// }

// class Meta {
//     int total;
//     int perPage;
//     int currentPage;
//     int lastPage;

//     Meta({
//         required this.total,
//         required this.perPage,
//         required this.currentPage,
//         required this.lastPage,
//     });

//     factory Meta.fromJson(Map<String, dynamic> json) => Meta(
//         total: json["total"],
//         perPage: json["per_page"],
//         currentPage: json["current_page"],
//         lastPage: json["last_page"],
//     );

//     Map<String, dynamic> toJson() => {
//         "total": total,
//         "per_page": perPage,
//         "current_page": currentPage,
//         "last_page": lastPage,
//     };
// }





// To parse this JSON data, do
//
//     final bookIssueAvailable = bookIssueAvailableFromJson(jsonString);

import 'dart:convert';

BookIssueAvailable bookIssueAvailableFromJson(String str) =>
    BookIssueAvailable.fromJson(json.decode(str));

String bookIssueAvailableToJson(BookIssueAvailable data) =>
    json.encode(data.toJson());

class BookIssueAvailable {
  bool status;
  List<BookIssueAvailableItem> data;
  Meta meta;
  dynamic message;

  BookIssueAvailable({
    required this.status,
    required this.data,
    required this.meta,
    required this.message,
  });

  factory BookIssueAvailable.fromJson(Map<String, dynamic> json) =>
      BookIssueAvailable(
        status: json["status"] ?? false,
        data: List<BookIssueAvailableItem>.from(
          ((json["data"] ?? []) as List)
              .map((x) => BookIssueAvailableItem.fromJson(x)),
        ),
        meta: Meta.fromJson(json["meta"] ?? {}),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "meta": meta.toJson(),
        "message": message,
      };
}


class BookIssueAvailableItem {
  final int? id;
  final int? bookId;
  final int? poojaId;
  final String poojaName;
  final int leafFrom;
  final int leafTo;
  final double ratePerTicket;
  final int counterId;
  final String? issueDate;
  final String? status;

  BookIssueAvailableItem({
    this.id,
    this.bookId,
    this.poojaId,
    required this.poojaName,
    required this.leafFrom,
    required this.leafTo,
    required this.ratePerTicket,
    required this.counterId,
    this.issueDate,
    this.status,
  });

  // Total tickets issued in this book — used as the "Opening Ticket" value
  // in the closing table.
  int get openingTicket => leafTo >= leafFrom ? (leafTo - leafFrom) + 1 : 0;

  factory BookIssueAvailableItem.fromJson(Map<String, dynamic> json) {
    // The real API response nests the actual book/pooja details under
    // `book` and `book.pooja` (e.g. `book.pooja.name`, `book.leaf_to`) —
    // the top-level fields with the same names are often null/absent.
    // Prefer the nested values, falling back to top-level/flatter shapes
    // in case a different endpoint variant returns this flat.
    final book = json['book'] is Map ? json['book'] as Map<String, dynamic> : null;
    final pooja = book?['pooja'] is Map ? book!['pooja'] as Map<String, dynamic> : null;

    return BookIssueAvailableItem(
      id: json['id'] as int?,
      bookId: (json['book_id'] ?? book?['id']) as int?,
      poojaId: (book?['pooja_id'] ?? pooja?['id'] ?? json['pooja_id']) as int?,
      poojaName: (pooja?['name'] ??
              json['pooja_name'] ??
              json['vazhivad_item'] ??
              '')
          .toString(),
      leafFrom:
          int.tryParse('${json['leaf_from'] ?? book?['leaf_from'] ?? 0}') ?? 0,
      leafTo: int.tryParse('${book?['leaf_to'] ?? json['leaf_to'] ?? 0}') ?? 0,
      ratePerTicket: double.tryParse(
            '${pooja?['rate'] ?? json['rate_per_ticket'] ?? json['rate'] ?? json['amount'] ?? 0}',
          ) ??
          0,
      counterId: int.tryParse('${json['counter_id'] ?? 0}') ?? 0,
      issueDate: json['issue_date']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'book_id': bookId,
        'pooja_id': poojaId,
        'pooja_name': poojaName,
        'leaf_from': leafFrom,
        'leaf_to': leafTo,
        'rate_per_ticket': ratePerTicket,
        'counter_id': counterId,
        'issue_date': issueDate,
        'status': status,
      };
}

class Meta {
  int total;
  int perPage;
  int currentPage;
  int lastPage;

  Meta({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        total: json["total"] ?? 0,
        perPage: json["per_page"] ?? 0,
        currentPage: json["current_page"] ?? 1,
        lastPage: json["last_page"] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "per_page": perPage,
        "current_page": currentPage,
        "last_page": lastPage,
      };
}