import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;


import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/auth_controller.dart';
import 'package:mobile_app/controller/locality_controller.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/model/citizen/bill/bill_info.dart';
import 'package:mobile_app/model/citizen/localization/language.dart';
import 'package:mobile_app/model/citizen/payments/payment.dart';
import 'package:mobile_app/model/citizen/properties_tax/my_properties.dart';
import 'package:mobile_app/model/employee/emp_mdms_model/emp_mdms_model.dart';
import 'package:mobile_app/model/employee/emp_pt_model/emp_pt_model.dart';
import 'package:mobile_app/model/request/emp_property_action_request/emp_property_action_request_model.dart';
import 'package:mobile_app/model/request/emp_property_request/property_request_model.dart';
import 'package:mobile_app/repository/core_repository.dart';
import 'package:mobile_app/repository/inbox_repository.dart';
import 'package:mobile_app/repository/payment_repository.dart';
import 'package:mobile_app/repository/propertytax_repository.dart';
import 'package:mobile_app/services/mdms_service.dart';
import 'package:mobile_app/services/secure_storage_service.dart';
import 'package:mobile_app/utils/enums/app_enums.dart';
import 'package:mobile_app/utils/enums/emp_enums.dart';
import 'package:mobile_app/utils/errors/error_handler.dart';
import 'package:mobile_app/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

class PropertiesTaxController extends GetxController {
  var streamCtrl = StreamController.broadcast();
  var streamCtrlPt = StreamController.broadcast();
  final mutationPropertyCtrl = BehaviorSubject();
  late String token;

  PtMyProperties? myProperties, myProp;
  Payment? myPayments;
  BillInfo? billInfo;
  late EmpPtModel empPtModel;
  late Property property;
  PropertyActionRequest? propertyActionRequest;
  EmpMdmsResModel? empMdmsResModel;

  RxInt length = 0.obs;
  int limit = 10, offset = 0;
  RxBool isLoading = false.obs;
  String assigneeUuid = '';

  @override
  void onClose() {
    super.onClose();
    streamCtrl.close();
    streamCtrlPt.close();
    mutationPropertyCtrl.close();
  }

  /// Load more my properties
  Future<void> loadMore({
    required String token,
    bool isMyApplication = false,
  }) async {
    try {
      isLoading.value = true;
      offset += limit;
      await getMyPropertiesStream(
        token: token,
        isMyApplication: isMyApplication,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setDefaultLimit() {
    length.value = 0;
    limit = 10;
    offset = 0;
  }

  /// Get my properties
  Future<PtMyProperties?> fetchMyProperties({
    required String token,
    String? propertyIds,
    bool isMyApplication = false,
  }) async {
    isLoading.value = true;
    PtMyProperties? myProperties;
    try {
      Map<String, dynamic> query = {};
      if (propertyIds != null) {
        query = {
          "propertyIds": propertyIds,
        };
      } else {
        final TenantTenant tenantCityId = await getCityTenant();
        
        if (tenantCityId.code?.isEmpty ?? true) {
          throw Exception('Tenant city code is empty');
        }
        
        query = {
          'tenantId': tenantCityId.code ?? '',
          'limit': limit.toString(),
          'sortOrder': 'ASC',
          'sortBy': 'createdTime',
          'offset': offset.toString(),
          'status': isMyApplication ? 'INWORKFLOW' : 'ACTIVE,INACTIVE',
        };
      }

      final res = await PropertyTaxRepository.getMyProperties(
        token: token,
        query: query,
      );

      dPrint('API Response: $res');

      myProperties = PtMyProperties.fromJson(res);

      length.value = myProperties.properties?.length ?? 0;

      isLoading.value = false;
    } catch (e, s) {
      dPrint('getPropertiesError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    } finally {
      isLoading.value = false;
    }
    return myProperties;
  }

  Future<void> getMyPropertiesStream({
    required String token,
    String? propertyIds,
    String? mobileNumber,
    bool isMyApplication = false,
    bool isCertificate = false,
  }) async {
    try {
      Map<String, dynamic> query = {};
      final TenantTenant tenantCityId = await getCityTenant();

      if (isCertificate) {
        query = {
          'tenantId': tenantCityId.code,
          'mobileNumber': mobileNumber,
          'creationReason': 'MUTATION',
          'status': 'ACTIVE',
          'sortOrder': 'DESC',
        };
      } else {
        if (propertyIds != null) {
          query = {
            'tenantId': tenantCityId.code,
            'propertyIds': propertyIds,
            'audit': 'true',
          };
        } else {
          query = {
            'tenantId': tenantCityId.code,
            'limit': limit.toString(),
            'sortOrder': 'ASC',
            'sortBy': 'createdTime',
            'offset': offset.toString(),
            'status': isMyApplication ? 'INWORKFLOW' : 'ACTIVE,INACTIVE',
          };
        }
      }

      final res = await PropertyTaxRepository.getMyProperties(
        token: token,
        query: query,
      );

      myProperties = PtMyProperties.fromJson(res);
      streamCtrl.add(myProperties);
      length.value = myProperties?.properties?.length ?? 0;
    } catch (e, s) {
      streamCtrl.add('getPropertiesError');
      dPrint('getPropertiesError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    }
  }

  Future<void> getMyPropertiesMutation({
    required String token,
    required String tenantId,
    String? propertyIds,
  }) async {
    try {
      var query = {
        'tenantId': tenantId,
        'propertyIds': propertyIds,
        'audit': 'true',
      };

      final res = await PropertyTaxRepository.getMyProperties(
        token: token,
        query: query,
      );

      final myProperties = PtMyProperties.fromJson(res);
      mutationPropertyCtrl.sink.add(myProperties.properties!.first);
    } catch (e, s) {
      mutationPropertyCtrl.add('getPropertiesError');
      dPrint('getPropertiesError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
      return;
    }
  }

  Future<PtMyProperties?> getPropId({
    required String token,
  }) async {
    try {
      final propIdRes = await PropertyTaxRepository.getMyPropertiesWithoutQuery(
        token: token,
      );
      myProp = PtMyProperties.fromJson(propIdRes);
    } catch (e, s) {
      dPrint('getPropertiesError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    }
    return myProp;
  }

  Future<List<Payment>?> getPtMyPayments({
    required String token,
    String? consumerCodes,
  }) async {
    List<Payment> paymentList = [];
    try {
      final paymentRes = await PropertyTaxRepository.getPtMyPayments(
        token: token,
        query: {
          'tenantId': BaseConfig.STATE_TENANT_ID,
          'consumerCodes': consumerCodes,
        },
      );
      dPrint('VerifyPayment Data: ${paymentRes['Payments'][0]}');
      final getPayments = paymentRes['Payments'];
      if (getPayments != []) {
        for (var payment in getPayments) {
          final data = Payment.fromJson(payment);
          paymentList.add(data);
        }
      }
    } catch (e, s) {
      paymentList = [];
      dPrint('GetMyPaymentsError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    }
    return paymentList;
  }

  //Card Count
  Future<int> getPTApplicationCount({
    required String token,
    tenantId,
    bool isMyApplication = false,
  }) async {
    int value = 0;
    try {
      int today = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> query = {
        'tenantId': tenantId,
        'fromDate': '${calculateFromDate(today).millisecondsSinceEpoch}',
        'toDate': today.toString(),
        'isRequestForCount': 'true',
      };
      if (isMyApplication) {
        query['status'] = 'ACTIVE';
      }

      final res = await PropertyTaxRepository.getMyProperties(
        token: token,
        query: query,
      );

      if (res.containsKey('count') && res['count'] is int) {
        value = res['count'];
      }
    } catch (e, s) {
      dPrint('getPropertiesCountError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    }

    return value;
  }

  Future<BillInfo?> getPtMyBills({
    required String tenantId,
    required String token,
    String? mobileNumber,
    required BusinessService businessService,
  }) async {
    try {
      Map<String, String> query;
      if (mobileNumber != null) {
        query = {
          'tenantId': tenantId,
          'mobileNumber': mobileNumber,
          'businessService': businessService.name,
          'limit': limit.toString(),
          'offset': offset.toString(),
        };
      } else {
        query = {
          'tenantId': tenantId,
          'businessService': businessService.name,
          'limit': limit.toString(),
          'offset': offset.toString(),
        };
      }

      final billRes = await PaymentRepository.fetchBill(
        token: token,
        query: query,
      );
      billInfo = BillInfo.fromJson(billRes);
      length.value = billInfo?.bill?.length ?? 0;
    } catch (e, s) {
      dPrint('GetMyPaymentsError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    }
    return billInfo;
  }

  /* -------------------------------------------------------------------------- */
  /*                                For Employee                                */
  /* -------------------------------------------------------------------------- */

  // EMP - PT Form - Mdms service call
  Future<void> getEmpMdmsPTForm() async {
    try {
      const ptStorageKey =
          'Digit.MDMS.${BaseConfig.STATE_TENANT_ID}.PropertyTax';

      final ptTaxLocal = await storage.getString(ptStorageKey);
      final ptDecode = jsonDecode(ptTaxLocal ?? '{}');

      // if (isNotNullOrEmpty(ptDecode['PropertyTax']) == false) {
      //   dPrint('PT1: Delete called');
      //   await storage.delete(ptStorageKey);
      // }

      if (isNotNullOrEmpty(ptDecode)) {
        dPrint('PT1: Local Data');
        empMdmsResModel = EmpMdmsResModel.fromJson(ptDecode);
        return;
      }

      final query = {
        'tenantId': BaseConfig.STATE_TENANT_ID,
      };

      final empRes = await CoreRepository.getMdmsPgrData(
        query: query,
        body: getEmpMdmsBodyPTRegForm(),
      );

      dPrint('PT1: EMP MDMS API');

      empMdmsResModel = EmpMdmsResModel.fromJson(empRes);
      await storage.setString(
        ptStorageKey,
        jsonEncode(empMdmsResModel?.toJson()),
      );
    } catch (e, s) {
      dPrint('getEmpMdmsPTForm Error: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    }
  }

  //Check roles for Field Inspection and Approver Inspection
  // bool checkRolesForPtInspection() {
  //   final roles = Get.find<AuthController>().token?.userRequest?.roles;
  //   if (roles == null) return false;

  //   return roles.any(
  //     (role) =>
  //         role.code == InspectorType.PT_FIELD_INSPECTOR.name ||
  //         role.code == InspectorType.PT_APPROVER_INSPECTOR.name,
  //   );
  // }

  /// Get PT inbox applications for employee
  Future<void> getEmpPtInboxApplications({
    required String token,
    required String tenantId,
    bool isFilter = false,
    List? locality,
    String? applicationNumber,
    String? propertyId,
    String? mobileNumber,
  }) async {
    try {
      final body = getEmpBodyFilter(
        isFilter: isFilter,
        locality: locality,
        limit: limit,
        offset: offset,
        tenantId: tenantId,
        module: ModulesEmp.PT_SERVICES,
        businessServices: [
          BusinessServicesEmp.PT_CREATE,
          BusinessServicesEmp.PT_MUTATION,
          BusinessServicesEmp.PT_UPDATE,
        ],
        applicationNumber: applicationNumber,
        propertyId: propertyId,
        mobileNumber: mobileNumber,
      );

      final empRes = await InboxRepository.getInboxApplications(
        token: token,
        body: body,
      );

      empPtModel = EmpPtModel.fromJson(empRes);

      //Check employee permission for field inspection and approver
      // final inspectorHasPermission = checkRolesForPtInspection();
      dev.log('RAW INBOX COUNT: ${empPtModel.items?.length ?? 0}');




      // empPtModel.items = empPtModel.items?.where((item) {
      //   final state = item.processInstance?.state?.state;
      //   if (state == null) return false;

      //   final isDocVerified = (state == InboxStatus.DOC_VERIFIED.name);

      //   final isMutation = (item.processInstance?.businessService ==
      //           BusinessServicesEmp.PT_MUTATION.name &&
      //       state == 'PAID');

      //   final isPtCreate = (item.processInstance?.businessService ==
      //           BusinessServicesEmp.PT_CREATE.name &&
      //       state == InboxStatus.FIELD_VERIFIED.name);

      //   // return (isDocVerified && inspectorHasPermission) ||
      //   //     (isMutation && inspectorHasPermission) ||
      //   //     (isPtCreate && inspectorHasPermission);
      // }).toList();
      //   dev.log('EMP PT AFTER FILTER: ${empPtModel.items?.length ?? 0}');

      length.value = empPtModel.items?.length ?? 0;
      streamCtrl.add(empPtModel);
      dPrint('EMP PT: ${empPtModel.items?.length}');
    } catch (e, s) {
      dPrint('GetEmpTlInboxError: $e');
      streamCtrl.add('Emp PT Inbox Error');
      ErrorHandler.allExceptionsHandler(e, s);
    }
  }

  /// Get PT new applications form uses for employee
  List<String> getPropertyAssessmentUse() {
    final useTypes = empMdmsResModel?.mdmsResEmp?.propertyTax?.usageCategory
        ?.where(
          (e) => e.code!.split('.').length <= 2 && e.code != "NONRESIDENTIAL",
        )
        .map((owner) {
          List<String> parts = owner.code!.split(".");
          if (parts.length == 2) {
            return parts[1];
          } else {
            return owner.code;
          }
        })
        .toSet()
        .cast<String>()
        .toList();

    return useTypes ?? [];
  }

  String rawUsesTypeEmp(String useType) {
    final useTypes = empMdmsResModel?.mdmsResEmp?.propertyTax?.usageCategory
            ?.where(
              (e) =>
                  (e.code?.split('.').length ?? 0) <= 2 &&
                  e.code != "NONRESIDENTIAL",
            )
            .map((owner) {
              final code = owner.code;
              if (code == null) return null;

              if (code.contains('.')) {
                List<String> parts = code.split('.');
                return (parts.last == useType) ? code : null;
              } else {
                return (code == useType) ? code : null;
              }
            })
            .whereType<String>()
            .toList() ??
        [];

    return useTypes.isNotEmpty ? useTypes.first : '';
  }

  /// Get PT new applications form propertyTypes for employee
  List<String> getPropertyAssessmentType() {
    final propertyTypes = empMdmsResModel?.mdmsResEmp?.propertyTax?.propertyType
        ?.map((e) => e.code as String)
        .map((code) {
      if (code.contains(".")) {
        final parts = code.replaceAll(".", '_');
        return parts.toUpperCase();
      }
      return code;
    }).toList();
    return propertyTypes ?? [];
  }

  /// Get PT new applications form property floors for employee
  List<String> getPropertyAssessmentFloors() {
    final floors = empMdmsResModel?.mdmsResEmp?.propertyTax?.floor
        ?.map((e) => e.code as String)
        .map((code) {
      if (code.contains("-")) {
        final parts = code.replaceAll("-", '_');
        return parts;
      }

      return code;
    }).toList();

    return floors ?? [];
  }

  /// Get PT new applications form unit uses types for employee
  List<String> getPropertyAssessmentUnitUsesTypes({required String useType}) {
    final unitUses = empMdmsResModel?.mdmsResEmp?.propertyTax?.usageCategory
        ?.where((e) => e.code != null)
        .map((e) => e.code!)
        .where((code) {
          final parts = code.split(".");
          if (parts.length > 3) {
            // dPrint('Code: $code');
            return parts[1] == useType;
          }
          return false;
        })
        .map((code) => code.replaceAll('.', '_').toUpperCase())
        .toList();

    return unitUses ?? [];
  }

  /// Get PT new applications form Provide_Ownership_Details for employee
  List<String> getProvideOwnershipDetails() {
    final useTypes = empMdmsResModel?.mdmsResEmp?.propertyTax?.ownerShipCategory
        ?.where(
          (e) => e.code!.split('.').length <= 2,
        )
        .map((owner) {
          List<String> parts = owner.code!.split(".");
          if (parts.length == 2) {
            return parts[1];
          } else {
            return owner.code;
          }
        })
        .toSet()
        .cast<String>()
        .toList();
    return useTypes ?? [];
  }

  String getRawSingleOwner(String selectedOwner) {
    final owners = empMdmsResModel?.mdmsResEmp?.propertyTax?.ownerShipCategory
            ?.where(
              (e) => e.code!.split('.').length <= 2,
            )
            .map((owner) {
              final code = owner.code;
              if (code == null) return null;

              if (code.contains('.')) {
                List<String> parts = code.split('.');
                return (parts.last == selectedOwner) ? code : null;
              } else {
                return (code == selectedOwner) ? code : null;
              }
            })
            .whereType<String>()
            .toList() ??
        [];

    return owners.isNotEmpty ? owners.first : '';
  }

  /// Load more my properties
  Future<void> loadMoreEmp({
    required String token,
    required String tenantId,
    List? locality,
    String? applicationNumber,
    String? propertyId,
    String? mobileNumber,
    bool isFilter = false,
  }) async {
    isLoading.value = true;
    limit = limit + 10;
    await getEmpPtInboxApplications(
      token: token,
      tenantId: tenantId,
      isFilter: isFilter,
      locality: locality,
      applicationNumber: applicationNumber,
      propertyId: propertyId,
      mobileNumber: mobileNumber,
    );
    isLoading.value = false;
  }

  void setDefaultLimitEmp() {
    limit = 10;
    offset = 0;
    length.value = 0;
  }

  Future<void> getMyPropertiesEmp({
    required String token,
    required String propertyId,
    required String tenantId,
  }) async {
    try {
      var query = {
        "propertyIds": propertyId,
        "tenantId": tenantId,
      };

      final res = await PropertyTaxRepository.getMyProperties(
        token: token,
        query: query,
      );

      myProperties = PtMyProperties.fromJson(res);
      property = myProperties!.properties!.first;
      propertyActionRequest =
          PropertyActionRequest.fromJson(res['Properties'][0]);
      dPrint('getMyPropertiesEmp: $res');
    } catch (e, s) {
      dPrint('getPropertiesEmpError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
    }
  }

  // EMP - TL - Action update
  Future<(bool, String?)> empActionUpdate({
    required String token,
    required ModulesEmp module,
  }) async {
    try {
      final body = {
        'Property': propertyActionRequest?.toJson(),
      };
      final empRes = await InboxRepository.actionUpdate(
        token: token,
        body: body,
        type: module,
      );
      myProperties = PtMyProperties.fromJson(empRes);
      dPrint('------Action Update------');
      dPrint(myProperties!.toJson());
      if (myProperties!.responseInfo!.status == 'successful') {
        return (
          true,
          myProperties?.properties?.firstOrNull?.acknowledgementNumber
        );
      }
      return (false, null);
    } catch (e, s) {
      dPrint('PT_UpdateEmpPTActionError: $e');
      ErrorHandler.allExceptionsHandler(e, s);
      return (false, null);
    }
  }

  // EMP - PT Form crate
  Future<Property?> createNewPTApplicationEmp({
    required String token,
    required PropertyRequest property,
  }) async {
    try {
      dPrint('Property: ${property.toJson()}');
      final body = {
        'Property': property.toJson(),
      };
      final res = await PropertyTaxRepository.createProperties(
        token: token,
        body: body,
      );

      final propertyRes = PtMyProperties.fromJson(res).properties?.first;
      return propertyRes;
    } catch (e, s) {
      Get.back();
      dPrint('createNewPTApplicationEmpError: $e');
      await ErrorHandler.allExceptionsHandler(e, s);
    }
    return null;
  }

  // Citizen - PT Form create
  Future<Property?> createNewPTApplicationCitizen({
    required String token,
    required Map<String, dynamic> property,
  }) async {
    try {
      dPrint('Citizen Property: $property');
      final body = {
        'Property': property,
      };
      final res = await PropertyTaxRepository.createProperties(
        token: token,
        body: body,
      );

      final propertyRes = PtMyProperties.fromJson(res).properties?.first;
      return propertyRes;
    } catch (e, s) {
      dPrint('createNewPTApplicationCitizenError: $e');
      await ErrorHandler.allExceptionsHandler(e, s);
      rethrow; // Re-throw to allow caller to handle
    }
  }

  // Build property payload with multiple owners support
  Map<String, dynamic> buildPropertyPayload({
    required PropertyRegistrationController controller,
    required String tenantId,
  }) {
    dPrint('===== BUILD PROPERTY PAYLOAD =====');
    dPrint('Controller values:');
    dPrint('  pincode: ${controller.pincode.value}');
    dPrint('  city: ${controller.city.value}');
    dPrint('  locality: ${controller.locality.value}');
    dPrint('  localityCode: ${controller.localityCode.value}');
    dPrint('  streetName: ${controller.streetName.value}');
    dPrint('  houseNo: ${controller.houseNo.value}');
    dPrint('  landmark: ${controller.landmark.value}');
    
    // Determine ownership category first
    String ownershipCategory = 'INDIVIDUAL';
    bool isInstitutional = false;
    
    if (controller.ownershipType.value == 'multiple') {
      ownershipCategory = 'INDIVIDUAL';
    } else if (controller.ownershipType.value == 'government') {
      ownershipCategory = 'INSTITUTIONALGOVERNMENT';
      isInstitutional = true;
    } else if (controller.ownershipType.value == 'private') {
      ownershipCategory = 'INSTITUTIONALPRIVATE';
      isInstitutional = true;
    }

    // Build owners array from allOwners data
    final owners = controller.allOwners.map((owner) {
      final ownerData = {
        'emailId': owner['email'] ?? '',
        'mobileNumber': owner['mobileNumber'] ?? '',
        'name': owner['name'] ?? '',
        'ownerType': 'NONE',
        'documents': [],
        'isCorrespondenceAddress': true,
      };
      
      // Add fields based on ownership type
      if (isInstitutional) {
        // For institutional: use altContactNumber and designation
        ownerData['altContactNumber'] = owner['telephone']?.toString() ?? '';
        ownerData['designation'] = owner['designation'] ?? '';
        ownerData['correspondenceAddress'] = _buildCorrespondenceAddress(controller);
      } else {
        // For individual: add standard fields
        ownerData['fatherOrHusbandName'] = owner['guardian'] ?? '';
        ownerData['gender'] = (owner['gender'] ?? '').toString().toUpperCase();
        ownerData['permanentAddress'] = owner['permanentAddress'] ?? '';
        ownerData['relationship'] = (owner['relationship'] ?? '').toString().toUpperCase();
      }
      
      ownerData['additionalDetails'] = {
        'ownerSequence': owner['ownerSequence'] ?? 0,
        'ownerName': owner['name'] ?? '',
      };
      
      return ownerData;
    }).toList();

    // Build institution object for institutional ownership
    Map<String, dynamic>? institution;
    if (isInstitutional && controller.allOwners.isNotEmpty) {
      final firstOwner = controller.allOwners.first;
      institution = {
        'designation': firstOwner['designation'] ?? '',
        'name': firstOwner['institutionName'] ?? firstOwner['name'] ?? '',
        'nameOfAuthorizedPerson': firstOwner['name'] ?? '',
        'tenantId': tenantId,
        'type': controller.ownershipType.value == 'government' ? 'GOVERNMENT' : 'PRIVATEBOARD',
      };
    }

    // Map property type to MDMS code
    String propertyTypeCode = _getPropertyTypeCode(controller.propertyType.value);
    
    // Map usage category to MDMS code
    String usageCategoryCode = _getUsageCategoryCode(controller.unitUsageType.value);

    // Build documents array
    final documents = <Map<String, dynamic>>[];
    if (controller.identityFileStoreId.value.isNotEmpty) {
      documents.add({
        'documentType': controller.identityDocType.value,
        'fileStoreId': controller.identityFileStoreId.value,
        'documentUid': controller.identityFileStoreId.value,
      });
    }
    if (controller.addressFileStoreId.value.isNotEmpty) {
      documents.add({
        'documentType': controller.addressDocType.value,
        'fileStoreId': controller.addressFileStoreId.value,
        'documentUid': controller.addressFileStoreId.value,
      });
    }

    final payload = {
      'tenantId': tenantId,
      'address': {
        'pincode': controller.pincode.value,
        'city': controller.city.value,
        'locality': {
          'code': _getLocalityCodeFromController(controller),
          'area': controller.locality.value,
        },
        'street': controller.streetName.value,
        'doorNo': controller.houseNo.value,
        'landmark': controller.landmark.value,
        'documents': [],
      },
      'ownershipCategory': ownershipCategory,
      'owners': owners,
      'institution': institution,
      'documents': documents,
      'units': [
        {
          'usageCategory': usageCategoryCode,
          'unitType': controller.subUsageType.value,
          'occupancyType': _getOccupancyTypeCode(controller.occupancy.value),
          'constructionDetail': {
            'builtUpArea': double.tryParse(controller.builtUpArea.value) ?? 0.0,
          },
          'floorNo': int.tryParse(controller.groundFloor.value) ?? 0,
        }
      ],
      'landArea': double.tryParse(controller.builtUpArea.value) ?? 0.0,
      'propertyType': propertyTypeCode,
      'noOfFloors': int.tryParse(controller.floors.value) ?? 1,
      'superBuiltUpArea': null,
      'usageCategory': usageCategoryCode,
      'additionalDetails': {
        'inflammable': false,
        'heightAbove36Feet': false,
        'propertyType': {
          'i18nKey': 'COMMON_PROPTYPE_$propertyTypeCode',
          'code': propertyTypeCode,
        },
        'owners': owners, // Also include in additionalDetails
      },
      'creationReason': 'CREATE',
      'source': 'MUNICIPAL_RECORDS',
      'channel': 'CITIZEN',
    };
    
    dPrint('Payload: ${jsonEncode(payload)}');
    dPrint('==================================');
    
    return payload;
  }

  // Helper method to get property type MDMS code
  String _getPropertyTypeCode(String displayName) {
    // Map display names to MDMS codes
    final propertyTypeMap = {
      'Independent Building': 'BUILTUP.INDEPENDENTPROPERTY',
      'Flat/Part of the building': 'BUILTUP.SHAREDPROPERTY', 
      'Vacant Land': 'VACANT',
      'Built Up': 'BUILTUP',
    };
    return propertyTypeMap[displayName] ?? displayName;
  }

  // Helper method to get usage category MDMS code  
  String _getUsageCategoryCode(String displayName) {
    // Map display names to MDMS codes
    final usageCategoryMap = {
      'residential': 'RESIDENTIAL',
      'commercial': 'NONRESIDENTIAL.COMMERCIAL',
      'industrial': 'NONRESIDENTIAL.INDUSTRIAL', 
      'institutional': 'NONRESIDENTIAL.INSTITUTIONAL',
      'others': 'NONRESIDENTIAL.OTHERS',
    };
    return usageCategoryMap[displayName] ?? displayName.toUpperCase();
  }

  // Helper method to get occupancy type MDMS code
  String _getOccupancyTypeCode(String displayName) {
    final occupancyTypeMap = {
      'vacant': 'UNOCCUPIED',
      'self_occupied': 'SELFOCCUPIED',
      'rented': 'RENTED',
    };
    return occupancyTypeMap[displayName] ?? displayName.toUpperCase();
  }

  // Helper method to get locality code from LocalityController
  String _getLocalityCodeFromController(PropertyRegistrationController controller) {
    try {
      // First check if controller has localityCode stored
      if (controller.localityCode.value.isNotEmpty) {
        return controller.localityCode.value;
      }
      
      if (!Get.isRegistered<LocalityController>()) {
        dPrint('LocalityController not registered');
        return controller.locality.value.isNotEmpty ? controller.locality.value : 'JLC477';
      }
      
      final localityController = Get.find<LocalityController>();
      final boundaries = localityController.locality.value?.tenantBoundary;
      
      if (boundaries != null && boundaries.isNotEmpty) {
        // Try to find by locality name match
        for (var tenantBoundary in boundaries) {
          final boundary = tenantBoundary.boundary?.firstWhereOrNull(
            (b) => b.name?.toLowerCase() == controller.locality.value.toLowerCase() ||
                   b.label?.toLowerCase() == controller.locality.value.toLowerCase()
          );
          if (boundary?.code != null && boundary!.code!.isNotEmpty) {
            dPrint('Found locality code by name: ${boundary.code}');
            return boundary.code!;
          }
        }
        
        // Try to find by pincode
        final pincode = controller.pincode.value;
        final code = int.tryParse(pincode);
        
        if (code != null) {
          for (var tenantBoundary in boundaries) {
            final boundary = tenantBoundary.boundary?.firstWhereOrNull(
              (b) => b.pinCode?.contains(code) ?? false
            );
            if (boundary?.code != null && boundary!.code!.isNotEmpty) {
              dPrint('Found locality code by pincode: ${boundary.code}');
              return boundary.code!;
            }
          }
        }
      }
    } catch (e) {
      dPrint('Error getting locality code: $e');
    }
    
    dPrint('ERROR: No valid locality code found!');
    dPrint('locality.value: ${controller.locality.value}');
    dPrint('localityCode.value: ${controller.localityCode.value}');
    dPrint('pincode.value: ${controller.pincode.value}');
    throw Exception('Please select a valid locality from the dropdown. Locality code is required.');
  }

  // Helper method to build correspondence address
  String _buildCorrespondenceAddress(PropertyRegistrationController controller) {
    final parts = <String>[
      controller.houseNo.value,
      controller.streetName.value,
      controller.locality.value,
      controller.city.value,
      controller.pincode.value,
    ].where((s) => s.isNotEmpty);
    return parts.join(', ');
  }
}
