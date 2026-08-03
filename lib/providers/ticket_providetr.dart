import 'package:flutter/foundation.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/models/available_book_model.dart';
import 'package:punnyam/models/book_close_model.dart';
import 'package:punnyam/models/book_issue_available.dart';
import 'package:punnyam/models/book_issue_model.dart';
import 'package:punnyam/models/book_register_model.dart';
import 'package:punnyam/models/error_response_model.dart';
import 'package:punnyam/models/reports_model.dart';
import 'package:punnyam/models/settings_model.dart';
import 'package:punnyam/services/provider_helper_class.dart';

class TicketProvidetr extends ChangeNotifier with ProviderHelperClass {
  AvailableBookModel? availableBookModel;
  List<AvailableBook> availablebookList = [];
  List<AvailableBook> allAvailableBookList = [];

  BookIssueAvailable? bookIssueAvailableModel;
  List<BookIssueAvailableItem> bookIssueAvailableList = [];
  List<BookIssueAvailableItem> allBookIssueAvailableList = [];

  ReportsModel? reportsModel;
  bool isLoadingReport = false;

  int? defaultLeafsPerBook;
  bool bookRegisterSettingsLoaded = false;

  // BookIssueAvailable? bookIssueAvailableModel;
  // List<dynamic> bookIssueAvailableList = [];
  // List<dynamic> allBookIssueAvailableList = [];

  //ticket booking
  Future<void> bookRegister({
    required int poojaId,
    required String date,
    required int leafFrom,
    required int leafTo,
    required int leafsPerBook,
    // required int noofBooks,
    Function(BookRegisterModel)? onSuccess,
    Function(String)? onFailure,
  }) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (!network) {
      if (onFailure != null) onFailure('No internet connection');
      return;
    }
    updateLoadState(LoaderState.loading);
    try {
      var res = await serviceConfig.bookRegister(
          poojaId: poojaId,
          date: date,
          leafFrom: leafFrom,
          leafTo: leafTo,
          leafsPerBook: leafsPerBook);
      if (res.isValue) {
        BookRegisterModel bookRegisterModel = res.asValue!.value;
        //Helpers.successToast("Book Registered Successfully");
        if (onSuccess != null) onSuccess(bookRegisterModel);
      } else {
        String errorMessage = 'Failed to register book';
        final error = res.asError!.error;
        if (error is BookRegisterModel) {
          errorMessage = error.message;
        } else if (error is ErrorResponseModel) {
          errorMessage = error.errorMessage ?? errorMessage;
        }
        if (onFailure != null) onFailure(errorMessage);
      }
      updateLoadState(LoaderState.loaded);
    } catch (e) {
      debugPrint('exception in bookRegister: $e');
      updateLoadState(LoaderState.loaded);
      if (onFailure != null) onFailure("Failed to register book");
    }
  }

  Future<void> availableBooks({required int poojaId}) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      updateLoadState(LoaderState.loading);
      try {
        var res = await serviceConfig.availableBook(poojaId: poojaId);
        if (res.isValue) {
          availableBookModel = res.asValue!.value;
          if (availableBookModel != null) {
            updateAvailableBook(availableBookModel);
          }
        }
        updateLoadState(LoaderState.loaded);
      } catch (e) {
        debugPrint('exception in availableBooks: $e');
        updateLoadState(LoaderState.loaded);
      }
    }
  }

  Future<void> issueBook({
    required String date,
    required int counterId,
    required List<Map<String, dynamic>> items,
    Function(BookIssueModel)? onSuccess,
    Function(String)? onFailure,
  }) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (!network) {
      if (onFailure != null) onFailure("No internet connection");
      return;
    }
    updateLoadState(LoaderState.loading);
    try {
      var res = await serviceConfig.issueBook(
          date: date, counterId: counterId, items: items);
      if (res.isValue) {
        BookIssueModel bookIssueModel = res.asValue!.value;
        if (onSuccess != null) onSuccess(bookIssueModel);
      } else {
        String errorMessage = "Failed to Issue Book";
        final error = res.asError!.error;
        if (error is BookIssueModel) {
          errorMessage = error.message;
        } else if (error is ErrorResponseModel) {
          errorMessage = error.errorMessage ?? errorMessage;
        }
        if (onFailure != null) onFailure(errorMessage);
      }
    } catch (e) {
      debugPrint("exception in issueBook: $e");
      updateLoadState(LoaderState.loaded);
      if (onFailure != null) onFailure("Failed to Issue Book");
    }
  }

  Future<void> bookIssueAvailable({
    required int counterId,
    required String date,
  }) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      updateLoadState(LoaderState.loading);
      try {
        var res = await serviceConfig.issueBookAvailable(
          counterId: counterId,
          date: date,
        );
        if (res.isValue) {
          bookIssueAvailableModel = res.asValue!.value;
          if (bookIssueAvailableModel != null) {
            updateBookIssueAvailable(bookIssueAvailableModel);
          }
        } else {
          // Request came back but marked as an error — clear stale rows so
          // the UI doesn't show entries for the wrong counter/date.
          bookIssueAvailableList = [];
          allBookIssueAvailableList = [];
          notifyListeners();
        }
        updateLoadState(LoaderState.loaded);
      } catch (e) {
        debugPrint('exception in bookIssueAvailable: $e');
        updateLoadState(LoaderState.loaded);
      }
    }
  }

  Future<void> closeBook({
    required String date,
    required int counterId,
    required List<Map<String, dynamic>> items,
    Function(BookCloseModel)? onSuccess,
    Function(String)? onFailure,
  }) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (!network) {
      if (onFailure != null) onFailure("No internet connection");
      return;
    }
    updateLoadState(LoaderState.loading);
    try {
      var res = await serviceConfig.closeBook(
          date: date, counterId: counterId, items: items);
      if (res.isValue) {
        BookCloseModel bookCloseModel = res.asValue!.value;
        if (onSuccess != null) onSuccess(bookCloseModel);
      } else {
        String errorMessage = "Failed to close Book";
        final error = res.asError!.error;
        if (error is BookCloseModel) {
          errorMessage = error.message;
        } else if (error is ErrorResponseModel) {
          errorMessage = error.errorMessage ?? errorMessage;
        }
        if (onFailure != null) onFailure(errorMessage);
      }
    } catch (e) {
      debugPrint("exception in closeBook: $e");
      updateLoadState(LoaderState.loaded);
      if (onFailure != null) onFailure("Failed to close Book");
    }
  }


  

  Future<void> getReports({
    required String fromDate,
    required String toDate,
    required int counterId,
  }) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (!network) {
      return;
    }
    isLoadingReport = true;
    notifyListeners();
    try {
      var res = await serviceConfig.getReports(
        fromDate: fromDate,
        toDate: toDate,
        counterId: '$counterId',
      );
      if (res.isValue) {
        reportsModel = res.asValue!.value;
      } else {
        reportsModel = null;
      }
    } catch (e) {
      debugPrint('exception in getReports: $e');
      reportsModel = null;
    }
    isLoadingReport = false;
    notifyListeners();
  }

  Future<void> getBookRegisterSettings() async {
    try {
      var res = await serviceConfig.settings();
      if (res.isValue) {
        SettingsModel settingsModel = res.asValue!.value;
        defaultLeafsPerBook = settingsModel.data.defaultLeafsPerBook;
      } else {
        defaultLeafsPerBook = null;
      }
    } catch (e) {
      debugPrint('exception in getBookRegisterSettings: $e');
      defaultLeafsPerBook = null;
    }
    bookRegisterSettingsLoaded = true;
    notifyListeners();
  }

  void updateBookIssueAvailable(BookIssueAvailable? bookIssueAvailable) {
    bookIssueAvailableList = bookIssueAvailable?.data ?? [];
    allBookIssueAvailableList = bookIssueAvailable?.data ?? [];
    notifyListeners();
  }

  updateAvailableBook(AvailableBookModel? availableBookModel) {
    availablebookList = availableBookModel?.data ?? [];
    allAvailableBookList = availableBookModel?.data ?? [];
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }
}
