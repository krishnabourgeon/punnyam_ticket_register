// To parse this JSON data, do
//
//     final reportsModel = reportsModelFromJson(jsonString);

import 'dart:convert';

ReportsModel reportsModelFromJson(String str) => ReportsModel.fromJson(json.decode(str));

String reportsModelToJson(ReportsModel data) => json.encode(data.toJson());

class ReportsModel {
    bool status;
    Data data;
    Meta meta;
    dynamic message;

    ReportsModel({
        required this.status,
        required this.data,
        required this.meta,
        required this.message,
    });

    factory ReportsModel.fromJson(Map<String, dynamic> json) => ReportsModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
        meta: Meta.fromJson(json["meta"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "meta": meta.toJson(),
        "message": message,
    };
}

class Data {
    Counter counter;
    DateTime fromDate;
    DateTime toDate;
    Totals totals;
    List<PoojaWise> poojaWise;
    List<Issue> issues;

    Data({
        required this.counter,
        required this.fromDate,
        required this.toDate,
        required this.totals,
        required this.poojaWise,
        required this.issues,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        counter: Counter.fromJson(json["counter"]),
        fromDate: DateTime.parse(json["from_date"]),
        toDate: DateTime.parse(json["to_date"]),
        totals: Totals.fromJson(json["totals"]),
        poojaWise: List<PoojaWise>.from(json["pooja_wise"].map((x) => PoojaWise.fromJson(x))),
        issues: List<Issue>.from(json["issues"].map((x) => Issue.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "counter": counter.toJson(),
        "from_date": "${fromDate.year.toString().padLeft(4, '0')}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
        "to_date": "${toDate.year.toString().padLeft(4, '0')}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
        "totals": totals.toJson(),
        "pooja_wise": List<dynamic>.from(poojaWise.map((x) => x.toJson())),
        "issues": List<dynamic>.from(issues.map((x) => x.toJson())),
    };
}

class Counter {
    int id;
    String name;

    Counter({
        required this.id,
        required this.name,
    });

    factory Counter.fromJson(Map<String, dynamic> json) => Counter(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}

class Issue {
    int bookIssueId;
    int poojaId;
    String poojaName;
    int bookNo;
    DateTime issueDate;
    int leafFrom;
    int leafTo;
    String status;
    int leafUsedTo;
    int noOfLeafsUsed;

    Issue({
        required this.bookIssueId,
        required this.poojaId,
        required this.poojaName,
        required this.bookNo,
        required this.issueDate,
        required this.leafFrom,
        required this.leafTo,
        required this.status,
        required this.leafUsedTo,
        required this.noOfLeafsUsed,
    });

    factory Issue.fromJson(Map<String, dynamic> json) => Issue(
        bookIssueId: json["book_issue_id"],
        poojaId: json["pooja_id"],
        poojaName: json["pooja_name"],
        bookNo: json["book_no"],
        issueDate: DateTime.parse(json["issue_date"]),
        leafFrom: json["leaf_from"],
        leafTo: json["leaf_to"],
        status: json["status"],
        leafUsedTo: json["leaf_used_to"],
        noOfLeafsUsed: json["no_of_leafs_used"],
    );

    Map<String, dynamic> toJson() => {
        "book_issue_id": bookIssueId,
        "pooja_id": poojaId,
        "pooja_name": poojaName,
        "book_no": bookNo,
        "issue_date": "${issueDate.year.toString().padLeft(4, '0')}-${issueDate.month.toString().padLeft(2, '0')}-${issueDate.day.toString().padLeft(2, '0')}",
        "leaf_from": leafFrom,
        "leaf_to": leafTo,
        "status": status,
        "leaf_used_to": leafUsedTo,
        "no_of_leafs_used": noOfLeafsUsed,
    };
}

class PoojaWise {
    int poojaId;
    String poojaName;
    int booksIssued;
    int booksOpen;
    int booksSettled;
    int leavesUsed;

    PoojaWise({
        required this.poojaId,
        required this.poojaName,
        required this.booksIssued,
        required this.booksOpen,
        required this.booksSettled,
        required this.leavesUsed,
    });

    factory PoojaWise.fromJson(Map<String, dynamic> json) => PoojaWise(
        poojaId: json["pooja_id"],
        poojaName: json["pooja_name"],
        booksIssued: json["books_issued"],
        booksOpen: json["books_open"],
        booksSettled: json["books_settled"],
        leavesUsed: json["leaves_used"],
    );

    Map<String, dynamic> toJson() => {
        "pooja_id": poojaId,
        "pooja_name": poojaName,
        "books_issued": booksIssued,
        "books_open": booksOpen,
        "books_settled": booksSettled,
        "leaves_used": leavesUsed,
    };
}

class Totals {
    int booksIssued;
    int booksOpen;
    int booksSettled;
    int leavesUsed;

    Totals({
        required this.booksIssued,
        required this.booksOpen,
        required this.booksSettled,
        required this.leavesUsed,
    });

    factory Totals.fromJson(Map<String, dynamic> json) => Totals(
        booksIssued: json["books_issued"],
        booksOpen: json["books_open"],
        booksSettled: json["books_settled"],
        leavesUsed: json["leaves_used"],
    );

    Map<String, dynamic> toJson() => {
        "books_issued": booksIssued,
        "books_open": booksOpen,
        "books_settled": booksSettled,
        "leaves_used": leavesUsed,
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
        total: json["total"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
        lastPage: json["last_page"],
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "per_page": perPage,
        "current_page": currentPage,
        "last_page": lastPage,
    };
}
