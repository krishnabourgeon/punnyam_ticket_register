import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:punnyam/common/common_functions.dart';
import 'package:punnyam/models/dieties_response_model.dart';
import 'package:punnyam/models/gothra_response.dart';
import 'package:punnyam/models/payment_mode_response.dart';
import 'package:punnyam/models/pooja_response_model.dart';
import 'package:punnyam/models/quickbill_datamodel.dart';
import 'package:punnyam/models/rashi_datamodel.dart';
import 'package:punnyam/models/save_bill_body.dart';
import 'package:punnyam/models/save_bill_response.dart';
import 'package:punnyam/models/savequickbillresponse_datamodel.dart';
import 'package:punnyam/models/special_star_response.dart';
import 'package:punnyam/models/starts_response_model.dart';
import 'package:punnyam/models/version_datamodel.dart';
import 'package:punnyam/screens/billing/preview_bill.dart';
import 'package:punnyam/services/app_config.dart';
import 'package:punnyam/services/helpers.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'package:punnyam/services/validation_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../models/preview_bill_response.dart';
import '../screens/billing/widgets/preview_bill_btn.dart';

class BillingProvider extends ChangeNotifier with ProviderHelperClass {
// printer
  String printerErrorMessage = '';
  int? sunmiPrinter;
  bool isConnected = false;
  static bool ratefield = false;
// print close

  // checkPrinter() async {
  //   try {
  //     isConnected = await SunmiPrinter.initPrinter() ?? false;

  //     notifyListeners();
  //   } catch (err) {
  //     printerErrorMessage = err.toString();
  //     notifyListeners();
  //   }
  // }

  DeitiesResponse? deitiesResponse;
  SavequickbillDatamodel? savequickbills;

  List<DeitiesData> deitiesList = [];
  List<DeitiesData> allDeitiesList = [];
  StarsResponse? starsResponse;
  GothraDatamodel? gothraResponse;
  RashiDatamodel? rashiResponse;
  List<StartsData> starsList = [];
  List<StartsData> allStarsList = [];
  PoojaResponse? poojaResponse;
  List<PoojaDetails> poojaDetailsList = [];
  List<PoojaData> poojaDataList = [];
  List<PoojaData> allPoojaDataList = [];
  SaveBillResponse? saveBillResponse;
  SpecialStarResponse? specialStarResponse;
  List<SpecialStar> specialStarList = [];
  List<SpecialStar> allSpecialStarList = [];
  PaymentModeResponse? paymentModeResponse;

  List<PaymentModeDataList> paymentModeDataList = [];
  List<String> scheduleTypesList = const [
    "Daily",
    "Weekly",
    "Monthly",
    "Other"
  ];

  List<String> prasadamList = const [
    "Yes",
    "No",
  ];

  List<String> weekDayList = const [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  List<PoojaPersons> person = [];
  Temple? temple;
  Summary? summary;
  Uint8List? imageData;
  String deityId = '1';
  String poojaId = '';
  String? scheduleTypes;
  String? starId = '';
  String? gothraId = '';
  String? rashiId = '';
  String? starId1 = '';
  int? specialStarId;
  String? fromDate;
  String? date;
  String? scheduledType;
  String? weekDays;
  String? poojaName;
  String? deityname;
  String? starName = '';
  String? starName1 = '';
  String? specialStarName;
  String? nameErrorMessage;
  String? qtyErrorMessage;
  String? rateErrorMessage;
  String? paidAmountErrorMessage;
  String? totalRateErrorMessage;
  String? mobileErrorMessage;
  String? errorMessage;
  String? paymentMode = 'COD';
  String? gothraName = '';
  String? rashiName = '';
  int? numberOfDays;
  int? numberOfMonths;
  int? numberOfWeeks;
  int? paymentModeId;
  int currentDropDownIndex = -1;
  double? poojaRate;
  double paidAmount = 0;
  double billAmount = 0;
  String? transid;

  bool isBillingFormValidated = false;
  bool isPreviewBillingFormValidated = false;
  bool? isPrasadhamIncluded;
  bool isDeityUpdated = false;
  bool isScheduled = false;
  bool isSearching = false;
  static bool address = false;

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController noOfMonthsController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();
  TextEditingController noOfWeeksController = TextEditingController();
  TextEditingController totalRateController = TextEditingController();
  TextEditingController noOfDaysController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nameController2 = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  int? poojacountrow;
  List<PoojaDetails> previewDetailsList = [];
  PreviewBillResponse? previewBillResponse;
  double totalAmount = 0;
  getInitialDataList() async {
    await clearValues();
    await getDeities();
    await getStars();
    await getStarIdFromName("Nodata");
    getSpecialStars();
    await getPoojas();
    updateFromDate(DateFormat('y-MM-dd').format(DateTime.now()));
    mobileNumberController.text = AppConfig.customerNumber ?? '';
    nameController.text = AppConfig.customerName ?? '';
    await updateBillingFormState();
  }

  Future<void> getPaymentModes(BuildContext context,
      {Function? onFailure}) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      updateLoadState(LoaderState.loading);
      try {
        var res = await serviceConfig.getPaymentModes();
        if (res.isValue) {
          paymentModeResponse = res.asValue!.value;
          updatePaymentModeList(paymentModeResponse);
        } else {
          updateLoadState(LoaderState.loaded);
          if (onFailure != null) onFailure();
        }
      } catch (e) {
        debugPrint('exception in deities: $e');
        updateLoadState(LoaderState.loaded);
      }
      notifyListeners();
    }
  }

  VersionDatamodel? version;
  Future<void> getversion(BuildContext context, {Function? onFailure}) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      updateLoadState(LoaderState.loading);
      try {
        var res = await serviceConfig.getversion();
        if (res.isValue) {
          version = res.asValue!.value;
        } else {
          updateLoadState(LoaderState.loaded);
          if (onFailure != null) onFailure();
        }
      } catch (e) {
        debugPrint('exception in deities: $e');
        updateLoadState(LoaderState.loaded);
      }
      notifyListeners();
    }
  }

  Future<void> getPreviewBill(BuildContext context,
      {Function? onSuccess, Function? onFailure}) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      updateLoadState(LoaderState.loading);
      SaveBillBody previewBillBody = SaveBillBody(
        counterId: int.parse(AppConfig.counterID ?? '0'),
        customerId: AppConfig.customerId ?? 0,
        poojaDetails: poojaDetailsList,
      );
      try {
        var res = await serviceConfig.getPreviewBill(previewBillBody);

        if (res.isValue) {
          previewBillResponse = res.asValue!.value;
          updatePoojaDetailsLength(previewBillResponse);
          print(previewBillResponse?.data?.billimage);
          String? imageUrl = previewBillResponse?.data?.billimage == null ||
                  previewBillResponse?.data?.billimage == ''
              ? null
              : "${previewBillResponse?.data?.billimage}";

          imageData = imageUrl == null ? null : await getImageData(imageUrl);
          if (imageData == null) {
            imageData = null;
          }
          if (onSuccess != null) onSuccess();
        } else {
          if (onFailure != null) onFailure();
          updateLoadState(LoaderState.loaded);
        }
      } catch (e) {
        debugPrint('exception in preview bill: $e');
        updateLoadState(LoaderState.loaded);
      }
      notifyListeners();
    }
  }

  Future<void> savequickbill(
      {Function? onSuccess,
      Function? onFailure,
      bool enableLoaderState = false,
      int? modeid,
      String? amt,
      List? poojalist}) async {
    if (enableLoaderState) updateBtnLoader(true);
    if (!enableLoaderState) updateLoadState(LoaderState.loading);
    // SaveBillBody saveBillBody = SaveBillBody(
    //     billAmount: double.parse(totalRateController.text.trim()),
    //     // counterId: int.parse(AppConfig.counterID ?? '0'),
    //     customerId: AppConfig.customerId ?? 1,
    //     paidAmount: double.parse(paidAmountController.text.trim()),
    //     paymentMode: paymentModeId ?? 0,
    //     // transactionid: transid == null || transid == '' ? null : transid,
    //     poojaDetails: previewBillResponse?.data?.poojaDetails);
    try {
      var res = await serviceConfig.savequickbill(
          amt: amt, modeid: modeid, poojalist: poojalist);
      if (res.isValue) {
        savequickbills = res.asValue!.value;
        String? imageUrl =
            savequickbills?.billImage == null || savequickbills?.billImage == ''
                ? null
                : "${savequickbills?.billImage}";

        imageData = imageUrl == null ? null : await getImageData(imageUrl);
        if (onSuccess != null) onSuccess();
        if (enableLoaderState) updateBtnLoader(false);
        if (!enableLoaderState) updateLoadState(LoaderState.loaded);
      } else {
        errorMessage = 'Oops...! Something went wrong';
        if (onFailure != null) onFailure();
        if (enableLoaderState) updateBtnLoader(false);
        if (!enableLoaderState) updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('exception in save quick bill: $e');
      if (enableLoaderState) updateBtnLoader(false);
      if (!enableLoaderState) updateLoadState(LoaderState.loaded);
      Helpers.successToast('Internal Server Error...');
    }
    updateStarId('');
  }

  updatePoojaDetailsLength(PreviewBillResponse? previewBillResponse) {
    poojaDetailsList.clear();
    previewDetailsList = previewBillResponse?.data?.poojaDetails ?? [];
    poojaDetailsList = [...previewDetailsList];

    updatePreviewRate();
    if (previewDetailsList.isNotEmpty) {
      updateLoadState(LoaderState.loaded);
    } else {
      updateLoadState(LoaderState.noData);
    }
    notifyListeners();
  }

  removeFromPoojaList(int index) {
    previewDetailsList.removeAt(index);
    updatePreviewRate();
    if (previewDetailsList.isEmpty) {
      updateLoadState(LoaderState.noData);
    }
    notifyListeners();
  }

  updatePreviewRate() {
    totalAmount = 0;
    if (previewDetailsList.isNotEmpty) {
      for (var element in previewDetailsList) {
        totalAmount = totalAmount + element.rate;
      }
    }
    totalRateController.text = totalAmount.toStringAsFixed(0);
    paidAmountController.text = totalAmount.toStringAsFixed(0);
    notifyListeners();
  }

  Future<Uint8List?> getImageData(String imageUrl) async {
    try {
      final network = await CommonFunctions.checkInternetConnection();

      if (!network) {
        return null;
      }

      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      print("Image load failed: ${response.statusCode}");
      return null;
    } catch (e) {
      print("Image exception: $e");
      return null;
    }
  }

  Future<void> saveBill(
      {Function? onSuccess,
      Function? onFailure,
      bool enableLoaderState = false}) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      if (enableLoaderState) updateBtnLoader(true);
      if (!enableLoaderState) updateLoadState(LoaderState.loading);
      SaveBillBody saveBillBody = SaveBillBody(
          billAmount: double.parse(totalRateController.text.trim()),
          counterId: int.parse(AppConfig.counterID ?? '0'),
          customerId: AppConfig.customerId ?? 1,
          paidAmount: double.parse(paidAmountController.text.trim()),
          paymentMode: paymentModeId ?? 0,
          transactionid: transid == null || transid == '' ? null : transid,
          poojaDetails: previewBillResponse?.data?.poojaDetails);
      try {
        var res = await serviceConfig.saveBill(saveBillBody);
        if (res.isValue) {
          saveBillResponse = res.asValue!.value;

          List<Details> details = saveBillResponse?.details ?? [];

          person.clear();
          for (int i = 0; i < details.length; i++) {
            person.add(PoojaPersons(
                id: (i + 1).toString(),
                date: details[i].date.toString(),
                dietyName: details[i].deity.toString(),
                // gothra: details[i].gothra?.nameEng,
                // rashi: details[i].rashi?.nameEng,
                name: details[i].name ?? 'Customer'.toString(),
                address: details[i].address ?? ''.toString(),
                poojaName: details[i].pooja.toString(),
                rate: "${details[i].qty}/${details[i].rate}",
                star: details[i].star.toString()));
          }

          if (onSuccess != null) onSuccess();
          if (enableLoaderState) updateBtnLoader(false);
          if (!enableLoaderState) updateLoadState(LoaderState.loaded);
        } else {
          errorMessage = 'Oops...! Something went wrong';
          if (onFailure != null) onFailure();
          if (enableLoaderState) updateBtnLoader(false);
          if (!enableLoaderState) updateLoadState(LoaderState.loaded);
        }
      } catch (e) {
        debugPrint('exception in save bill: $e');
        if (enableLoaderState) updateBtnLoader(false);
        if (!enableLoaderState) updateLoadState(LoaderState.loaded);
        Helpers.successToast('Internal Server Error...');
      }
    }
  }

  Future<void> getDeities() async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      updateLoadState(LoaderState.loading);
      try {
        var res = await serviceConfig.getDeities();
        if (res.isValue) {
          deitiesResponse = res.asValue!.value;
          if (deitiesResponse != null) {
            updateDeitiesList(deitiesResponse);
          }
          // updateLoadState(LoaderState.loaded);
        } else {
          updateLoadState(LoaderState.loaded);
        }
      } catch (e) {
        debugPrint('exception in deities: $e');
        updateLoadState(LoaderState.loaded);
      }
    }
  }

  Future<void> getStars() async {
    // updateLoadState(LoaderState.loading);
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      try {
        var res = await serviceConfig.getStarts();
        if (res.isValue) {
          starsResponse = res.asValue!.value;
          if (starsResponse != null) {
            updateStarsList(starsResponse);
          }
          //updateLoadState(LoaderState.loaded);
        } else {
          updateLoadState(LoaderState.loaded);
        }
      } catch (e) {
        debugPrint('exception in stars: $e');
        updateLoadState(LoaderState.loaded);
      }
    }
  }

  Future<void> getgothra() async {
    // updateLoadState(LoaderState.loading);
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      try {
        var res = await serviceConfig.getgothra();
        if (res.isValue) {
          gothraResponse = res.asValue!.value;
          // if (starsResponse != null) {
          //   updateStarsList(starsResponse);
          // }
          //updateLoadState(LoaderState.loaded);
        } else {
          // updateLoadState(LoaderState.loaded);
        }
      } catch (e) {
        debugPrint('exception in stars: $e');
        // updateLoadState(LoaderState.loaded);
      }
    }
  }

  Future<void> getrashi() async {
    // updateLoadState(LoaderState.loading);
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      try {
        var res = await serviceConfig.getrashi();
        if (res.isValue) {
          rashiResponse = res.asValue!.value;
          // if (starsResponse != null) {
          //   updateStarsList(starsResponse);
          // }
          //updateLoadState(LoaderState.loaded);
        } else {
          // updateLoadState(LoaderState.loaded);
        }
      } catch (e) {
        debugPrint('exception in stars: $e');
        // updateLoadState(LoaderState.loaded);
      }
    }
  }

  Future<void> getSpecialStars() async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      try {
        var res = await serviceConfig.getSpecialStars();
        if (res.isValue) {
          specialStarResponse = res.asValue!.value;
          if (specialStarResponse != null) {
            updateSpecialStarsList(specialStarResponse);
          } else {
            updateLoadState(LoaderState.loaded);
          }
        }
      } catch (e) {
        debugPrint('exception in special stars: $e');
        updateLoadState(LoaderState.loaded);
      }
    }
  }

  Future<void> getPoojas({bool isEnableBtnLoader = false}) async {
    final network = await CommonFunctions.checkInternetConnection();
    if (network) {
      if (isEnableBtnLoader) updateBtnLoader(true);
      try {
        var res = await serviceConfig.getPoojas(deityId);
        if (res.isValue) {
          poojaResponse = res.asValue!.value;
          if (poojaResponse != null) {
            updatePoojasList(poojaResponse);
          }
          updateBtnLoader(false);
          updateLoadState(LoaderState.loaded);
        } else {
          updateBtnLoader(false);
          updateLoadState(LoaderState.loaded);
        }
      } catch (e) {
        debugPrint('exception in poojas: $e');
        updateLoadState(LoaderState.loaded);
      }
    }
  }

  updateDeitiesList(DeitiesResponse? deitiesResponse) {
    deitiesList = deitiesResponse?.data ?? [];
    allDeitiesList = deitiesResponse?.data ?? [];
    // updateDeityId('${deitiesList[0].id}');  // cleared
    notifyListeners();
  }

  searchDeity(String value) {
    isSearching = true;

    deitiesList = allDeitiesList
        .where((element) =>
            (element.name ?? '').toLowerCase().contains(value.toLowerCase()))
        .toList();

    isSearching = false;
    debugPrint('length ${deitiesList.length}');
    notifyListeners();
  }

  updateStarsList(StarsResponse? starsResponse) {
    starsList = starsResponse?.data ?? [];
    allStarsList = starsList;
    notifyListeners();
  }

  searchStar(String value) {
    starsList = allStarsList
        .where((element) =>
            (element.nameEng ?? '').toLowerCase().contains(value.toLowerCase()))
        .toList();

    notifyListeners();
  }

  updateSpecialStarsList(SpecialStarResponse? specialStarResponse) {
    specialStarList = specialStarResponse?.data ?? [];
    allSpecialStarList = specialStarList;
    notifyListeners();
  }

  searchSpecialStar(String value) {
    specialStarList = allSpecialStarList
        .where((element) => (element.otherDetail ?? '')
            .toLowerCase()
            .contains(value.toLowerCase()))
        .toList();

    notifyListeners();
  }

  updatePoojasList(PoojaResponse? poojaResponse) {
    poojaDataList.clear();
    poojaDataList = poojaResponse?.data ?? [];
    // print(poojaResponse?.data![0].name);
    allPoojaDataList = poojaDataList;
    notifyListeners();
  }

  searchPooja(String value) {
    poojaDataList = allPoojaDataList
        .where((element) =>
            (element.name ?? '').toLowerCase().contains(value.toLowerCase()))
        .toList();

    notifyListeners();
  }

  removeElementFromPoojaList(int index, {Function? onSuccess}) {
    poojaDetailsList.removeAt(index);
    if (onSuccess != null) onSuccess();
    notifyListeners();
  }

  updateDeityId(String id) {
    deityId = id;
    notifyListeners();
  }

  ayyapanpooja(String? name) {
    if (deityname == name) {
      getPoojaIdFromName('ARI PARA');
    }
    notifyListeners();
  }

  getDeityIdFromName(String name) async {
    deityname = name;

    updateIsDeityUpdated(true);
    for (var element in deitiesList) {
      if (name == element.name) {
        deityId = '${element.id}';
      }
      if (name == "DONATION") {
        ratefield = true;
      } else {
        ratefield = false;
      }
    }
    // ayyapanpooja(deityname); for default pooja selection
    notifyListeners();
  }

  updatePoojaId(String id) {
    poojaId = id;
    notifyListeners();
  }

  getPoojaIdFromName(String name) {
    poojaName = name;
    updateIsDeityUpdated(true);
    for (var element in poojaDataList) {
      if (name == element.name) {
        poojaId = '${element.poojaId}';

        poojacountrow = element.rowcount;
        qtyController.text = '1';
        // print(rateController.text);
        poojaRate = double.parse(element.rate ?? '0');
        updateRate();
      }
    }

    notifyListeners();
  }

  String? name;
  String getPoojanamefromid(int id, QuickbillDatamodel? quickdata) {
    for (var element in quickdata!.data!) {
      if (id == element.id) {
        name = '${element.name}';
      } else {}
    }

    notifyListeners();
    return name ?? '';
  }

  updateRate() {
    if (qtyController.text.isNotEmpty) {
      var totalRate = (poojaRate ?? 0) * (int.parse(qtyController.text));
      rateController.text = totalRate == 0 ? '' : totalRate.toStringAsFixed(0);
    } else {
      rateController.text = '';
    }
    notifyListeners();
  }

  updateStarId(String id) {
    starId = id;
    notifyListeners();
  }

//? for setting initial star as nodata .........................................

  getStarIdFromName(String name) {
    starName = name;
    print("..star..star..$starName");
    updateIsDeityUpdated(true);
    for (var element in starsList) {
      if (name == element.nameEng) {
        starId = '${element.id}';
      }
    }
    notifyListeners();
  }

  getgothraIdFromName(String name) {
    gothraName = name;
    updateIsDeityUpdated(true);
    for (var element in gothraResponse?.data ?? []) {
      if (name == element.nameEng) {
        gothraId = '${element.id}';
      }
    }
    notifyListeners();
  }

  String? getgothranameFromid(int id) {
    return gothraResponse?.data!.firstWhere((g) => g.id == id).nameEng;
  }

  String? getrashianameFromid(int id) {
    return rashiResponse?.data!
        .firstWhere((element) => element.id == id)
        .nameEng;
  }

  getrashiIdFromName(String name) {
    rashiName = name;
    // updateIsDeityUpdated(true);
    for (var element in rashiResponse?.data ?? []) {
      if (name == element.nameEng) {
        rashiId = '${element.id}';
      }
    }
    notifyListeners();
  }

  getStarIdFromName1(String name) {
    starName1 = name;
    updateIsDeityUpdated(true);
    for (var element in starsList) {
      if (name == element.nameEng) {
        starId1 = '${element.id}';
      }
    }
    notifyListeners();
  }

  getSpecialStarIdFromName(String name) {
    specialStarName = name;
    for (var element in specialStarList) {
      if (name == element.otherDetail) {
        specialStarId = int.parse(element.otherCode ?? '0');
      }
    }
    notifyListeners();
  }

  updateIsDeityUpdated(bool value) {
    isDeityUpdated = value;
    notifyListeners();
  }

  updateSheduleType(String type) {
    scheduleTypes = type;
    updateScheduledType(type);
    notifyListeners();
  }

  updateSwitch(bool val) {
    isScheduled = val;
    notifyListeners();
  }

  updateFromDate(String date) {
    fromDate = date;
    notifyListeners();
  }

  updateDate(String value) {
    date = value;
    notifyListeners();
  }

  updateNumberOfDays(int days) {
    numberOfDays = days;
    notifyListeners();
  }

  updateNumberOfWeeks(int weeks) {
    numberOfWeeks = weeks;
    notifyListeners();
  }

  updateNumberOfMonths(int months) {
    numberOfMonths = months;
    notifyListeners();
  }

  updateIsPrasadhamIncluded(String value) {
    if (value == 'Yes') {
      isPrasadhamIncluded = true;
    } else {
      isPrasadhamIncluded = false;
    }
    notifyListeners();
  }

  updateScheduledType(String value) {
    switch (value) {
      case 'Daily':
        scheduledType = 'D';
        break;
      case 'Weekly':
        scheduledType = 'W';
        break;
      case 'Monthly':
        scheduledType = 'M';
        break;
      case 'Other':
        scheduledType = 'O';
        break;
    }
    notifyListeners();
  }

  updateWeekDays(String value) {
    weekDays = value;
    notifyListeners();
  }

  updateSpecialStarId(int id) {
    specialStarId = id;
    notifyListeners();
  }

  updatePaymentModeList(PaymentModeResponse? paymentModeResponse) {
    paymentModeDataList = paymentModeResponse?.data ?? [];
    paymentMode = paymentModeDataList[0].name ?? '';
    paymentModeId = 1;
    updateLoadState(LoaderState.loaded);
    notifyListeners();
  }

  updatePaymentMode(String value) {
    paymentMode = value;
    notifyListeners();
  }

  updatePaymentModeId() {
    for (var element in paymentModeDataList) {
      if (element.name == paymentMode) {
        paymentModeId = element.id ?? 0;
      }
    }
    notifyListeners();
  }

  updatetransid(String? val) {
    transid = val;
    notifyListeners();
  }

  updateValidationMessage(
      {required ValidationTypes validationTypes,
      required String validationMessage}) {
    switch (validationTypes) {
      case ValidationTypes.name:
        if (validationMessage.isNotEmpty) {
          nameErrorMessage = validationMessage;
        } else {
          nameErrorMessage = null;
        }
        break;
      case ValidationTypes.rate:
        if (validationMessage.isNotEmpty) {
          rateErrorMessage = validationMessage;
        } else {
          rateErrorMessage = null;
        }
        break;
      case ValidationTypes.totalRate:
        if (validationMessage.isNotEmpty) {
          totalRateErrorMessage = validationMessage;
        } else {
          totalRateErrorMessage = null;
        }
        break;
      case ValidationTypes.paidAmount:
        if (validationMessage.isNotEmpty) {
          paidAmountErrorMessage = validationMessage;
        } else {
          paidAmountErrorMessage = null;
        }
        break;
      case ValidationTypes.qty:
        if (validationMessage.isNotEmpty) {
          qtyErrorMessage = validationMessage;
        } else {
          qtyErrorMessage = null;
        }
        break;
      case ValidationTypes.mobileNumber:
        if (validationMessage.isNotEmpty) {
          mobileErrorMessage = validationMessage;
        } else {
          mobileErrorMessage = null;
        }
    }
    updateBillingFormState();
  }

  updateBillingFormState() {
    print("..$gothraId...$gothraName..$rashiId..$rashiName");
    if (!isScheduled) {
      if (deityId.isNotEmpty &&
          poojaId.isNotEmpty &&
          // gothraId != null &&
          // rashiId != null &&
          // gothraId != '' &&
          // rashiId != '' &&
          starId != null &&
          starId != '' &&
          // nameController.text.isNotEmpty &&
          qtyController.text.isNotEmpty &&
          rateController.text.isNotEmpty &&
          fromDate != null &&
          nameErrorMessage == null &&
          qtyErrorMessage == null &&
          rateErrorMessage == null) {
        isBillingFormValidated = true;
      } else {
        isBillingFormValidated = false;
      }
    } else {
      if (deityId.isNotEmpty &&
          poojaId.isNotEmpty &&
          // gothraId != null &&
          // rashiId != null &&
          // gothraId != '' &&
          // rashiId != '' &&
          starId != null &&
          starId != '' &&
          // starId.isNotEmpty &&
          // nameController.text.isNotEmpty &&
          qtyController.text.isNotEmpty &&
          rateController.text.isNotEmpty &&
          // totalRateController.text.isNotEmpty &&
          nameErrorMessage == null &&
          qtyErrorMessage == null &&
          rateErrorMessage == null &&
          paidAmountErrorMessage == null &&
          totalRateErrorMessage == null &&
          scheduledType != null &&
          fromDate != null &&
          (noOfDaysController.text.isNotEmpty ||
              noOfWeeksController.text.isNotEmpty ||
              noOfMonthsController.text.isNotEmpty)) {
        if (scheduledType == 'O') {
          if (specialStarId != null) {
            isBillingFormValidated = true;
          }
        } else {
          isBillingFormValidated = true;
        }
      } else {
        isBillingFormValidated = false;
      }
    }
    notifyListeners();
  }

  updatePreviewBillingFormValidated() {
    if ((AppConfig.customerNumber ?? '').isEmpty) {
      if (mobileNumberController.text.isNotEmpty &&
          mobileErrorMessage == null) {
        isPreviewBillingFormValidated = true;
      } else {
        isPreviewBillingFormValidated = false;
      }
    } else {
      if (paidAmountErrorMessage == null &&
          paidAmountController.text.trim().isNotEmpty) {
        isPreviewBillingFormValidated = true;
      } else {
        isPreviewBillingFormValidated = false;
      }
    }
    notifyListeners();
  }

  updateTemple(Temple? value) {
    temple = value;
    notifyListeners();
  }

  updateSummary(Summary? value) {
    summary = value;
    notifyListeners();
  }

  updatePersonList(List<PoojaPersons> poojaPersons) {
    person = poojaPersons;
    notifyListeners();
  }

  saveAndNextFunction() {
    updateLoadState(LoaderState.loading);
    Future.delayed(const Duration(seconds: 1), () {
      PoojaDetails poojaDetails = PoojaDetails(
          // gothraname: gothraName,
          // rashiname: rashiName,
          // gothra: int.parse(gothraId ?? '0'),
          // rashi: int.parse(rashiId ?? '0'),
          name: nameController.text.isEmpty
              ? 'Customer'
              : nameController.text.trim(),
          address: addressController.text ?? '',
          date: isScheduled ? date : null,
          deityId: int.parse(deityId ?? '1'),
          dwmo: scheduledType,
          fromDate: fromDate,
          isScheduled: isScheduled ? 1 : 0,
          noOfDays: noOfDaysController.text.isNotEmpty
              ? int.parse(noOfDaysController.text.trim())
              : null,
          noOfMonths: noOfMonthsController.text.isNotEmpty
              ? int.parse(noOfMonthsController.text.trim())
              : null,
          noOfWeeks: noOfWeeksController.text.isNotEmpty
              ? int.parse(noOfWeeksController.text.trim())
              : null,
          poojaId: int.parse(poojaId),
          prasadamStatus: (isPrasadhamIncluded ?? false) ? 1 : 0,
          qty: int.parse(qtyController.text.trim()),
          rate: double.parse(rateController.text.trim()),
          starId: starName == null || starId == null
              ? 28
              : int.parse(starId ?? '28'),
          specialStarId: specialStarId,
          monthStar: starName,
          weekDays: weekDays);
      if (paidAmountController.text.isNotEmpty) {
        paidAmount = paidAmount + int.parse(paidAmountController.text.trim());
      }
      if (totalRateController.text.isNotEmpty) {
        billAmount = billAmount + int.parse(totalRateController.text.trim());
      }
      poojaDetailsList.add(poojaDetails);
      if (poojacountrow == 2) {
        PoojaDetails poojaDetails1 = PoojaDetails(
            // gothraname: gothraName,
            // rashiname: rashiName,
            // gothra: int.parse(gothraId ?? '0'),
            // rashi: int.parse(rashiId ?? '0'),
            name: nameController2.text.isEmpty
                ? 'Customer'
                : nameController2.text.trim(),
            address: addressController.text,
            date: isScheduled ? date : null,
            deityId: int.parse(deityId),
            dwmo: scheduledType,
            fromDate: fromDate,
            isScheduled: 0,
            noOfDays: noOfDaysController.text.isNotEmpty
                ? int.parse(noOfDaysController.text.trim())
                : null,
            noOfMonths: noOfMonthsController.text.isNotEmpty
                ? int.parse(noOfMonthsController.text.trim())
                : null,
            noOfWeeks: noOfWeeksController.text.isNotEmpty
                ? int.parse(noOfWeeksController.text.trim())
                : null,
            poojaId: int.parse(poojaId),
            prasadamStatus: (isPrasadhamIncluded ?? false) ? 1 : 0,
            qty: 0,
            rate: 0,
            starId: starName1 == null || starId == null
                ? 28
                : int.parse(starId ?? '28'),
            specialStarId: specialStarId,
            monthStar: starName1,
            weekDays: weekDays);
        poojaDetailsList.add(poojaDetails1);
      }
      clearValues(isClearDate: false);
      updateFromDate(DateFormat('y-MM-dd').format(DateTime.now()));
      getDeityIdFromName(deityname!);
      getPoojaIdFromName(poojaName!);
      updateBillingFormState();
      updateLoadState(LoaderState.loaded);
    });
  }

  saveAndPreviewFunction(BuildContext context) {
    PoojaDetails poojaDetails = PoojaDetails(
        // gothra: int.parse(gothraId ?? '0'),
        // rashi: int.parse(rashiId ?? '0'),
        // gothraname: gothraName,
        // rashiname: rashiName,
        name: nameController.text.isEmpty
            ? 'Customer'
            : nameController.text.trim(),
        address: addressController.text,
        date: !isScheduled ? date : null,
        deityId: int.parse(deityId ?? '1'),
        dwmo: scheduledType,
        fromDate: fromDate,
        isScheduled: isScheduled == true ? 1 : 0,
        noOfDays: noOfDaysController.text.isNotEmpty
            ? int.parse(noOfDaysController.text.trim())
            : null,
        noOfMonths: noOfMonthsController.text.isNotEmpty
            ? int.parse(noOfMonthsController.text.trim())
            : null,
        noOfWeeks: noOfWeeksController.text.isNotEmpty
            ? int.parse(noOfWeeksController.text.trim())
            : null,
        poojaId: int.parse(poojaId),
        prasadamStatus: (isPrasadhamIncluded ?? false) ? 1 : 0,
        qty: int.parse(qtyController.text.trim()),
        rate: double.parse(rateController.text.trim()),
        starId: int.parse(starId ?? '28'),
        specialStarId: specialStarId,
        monthStar: starName,
        weekDays: weekDays);
    if (paidAmountController.text.isNotEmpty) {
      paidAmount = paidAmount + int.parse(paidAmountController.text.trim());
    }
    if (totalRateController.text.isNotEmpty) {
      billAmount = billAmount + int.parse(totalRateController.text.trim());
    }
    poojaDetailsList.add(poojaDetails);
    if (poojacountrow == 2) {
      PoojaDetails poojaDetails1 = PoojaDetails(
          // gothraname: gothraName,
          // rashiname: rashiName,
          // gothra: int.parse(gothraId ?? '0'),
          // rashi: int.parse(rashiId ?? '0'),
          name: nameController2.text.isEmpty
              ? 'Customer'
              : nameController2.text.trim(),
          address: addressController.text ?? '',
          date: isScheduled ? date : null,
          deityId: int.parse(deityId ?? '1'),
          dwmo: scheduledType,
          fromDate: fromDate,
          isScheduled: 0,
          noOfDays: noOfDaysController.text.isNotEmpty
              ? int.parse(noOfDaysController.text.trim())
              : null,
          noOfMonths: noOfMonthsController.text.isNotEmpty
              ? int.parse(noOfMonthsController.text.trim())
              : null,
          noOfWeeks: noOfWeeksController.text.isNotEmpty
              ? int.parse(noOfWeeksController.text.trim())
              : null,
          poojaId: int.parse(poojaId),
          prasadamStatus: (isPrasadhamIncluded ?? false) ? 1 : 0,
          qty: 0,
          rate: 0,
          starId: starName1 == null || starId1 == null || starId == null
              ? 28
              : int.parse(starId ?? '28'),
          specialStarId: specialStarId,
          monthStar: starName1,
          weekDays: weekDays);
      poojaDetailsList.add(poojaDetails1);
    }
    clearValues(isClearPaymentMode: false, isClearDate: false);
    getStarIdFromName("Nodata");
    updateRate();
    navigateToPreviewBill(context);
  }

  navigateToPreviewBill(BuildContext context) {
    if (isBillingFormValidated) {
      // getStarIdFromName("Nodata");
      saveAndPreviewFunction(context);
    } else {
      getStarIdFromName("Nodata");
      getPreviewBill(context,
          onSuccess: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PreviewBillScreen(),
                  )).then((value) {
                totalAmount = 0;
                mobileNumberController.clear();
                updateFromDate(DateFormat('y-MM-dd').format(DateTime.now()));
              }),
          onFailure: () => Helpers.successToast(errorMessage ?? ''));
    }
  }

  launchWhatsAppUri(String text) async {
    String mobileNumber =
        AppConfig.customerNumber ?? mobileNumberController.text.trim();
    final link = WhatsAppUnilink(
      phoneNumber: '91$mobileNumber}',
      text: text,
    );
    // Convert the WhatsAppUnilink instance to a Uri.
    // The "launch" method is part of "url_launcher".
    try {
      await launchUrl(
        link.asUri(),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Exception in whatsapp url $e');
    }
  }

  logoutclear() {
    rateController.clear();
    qtyController.clear();
    deityname = null;
    poojaName = null;
    notifyListeners();
  }

  clearValues({bool isClearPaymentMode = true, bool isClearDate = true}) {
    addressController.clear();
    nameController.clear();
    nameController2.clear();
    gothraId = '';
    rashiId = '';
    starId = '';
    // rateController.clear();
    qtyController = TextEditingController(text: '1');
    totalRateController.clear();
    paidAmountController.clear();
    noOfDaysController.clear();
    noOfWeeksController.clear();
    noOfMonthsController.clear();
    isBillingFormValidated = false;
    transid = null;
    if (isClearDate) fromDate = null;
    starName = null;
    starName1 = null;
    specialStarName = null;
    // deityname = null;
    // poojaName = null;
    if (isClearPaymentMode) paymentMode = 'COD';
    numberOfDays = null;
    numberOfWeeks = null;
    numberOfMonths = null;
    isPrasadhamIncluded = null;
    scheduleTypes = null;
    scheduledType = null;
    isScheduled = false;
    nameErrorMessage = null;
    qtyErrorMessage == null;
    rateErrorMessage = null;
    notifyListeners();
  }

  clearschedule() {
    isScheduled = false;
    notifyListeners();
  }

  clearPaymentValues() {
    billAmount = 0;
    paidAmount = 0;
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }

  @override
  void updateBtnLoader(bool value) {
    btnLoader = value;
    notifyListeners();
  }
}
