import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/auth_controller.dart';
import 'package:mobile_app/controller/language_controller.dart';
import 'package:mobile_app/controller/locality_controller.dart';
import 'package:mobile_app/controller/properties_tax_controller.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/model/request/emp_property_request/property_request_model.dart';
import 'package:mobile_app/repository/propertytax_repository.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_registration_success_screen.dart';
import 'package:mobile_app/utils/loaders.dart';
import 'package:mobile_app/utils/utils.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class PropertySummaryScreen extends StatefulWidget {
  const PropertySummaryScreen({super.key});

  @override
  State<PropertySummaryScreen> createState() => _PropertySummaryScreenState();
}

class _PropertySummaryScreenState extends State<PropertySummaryScreen> {
  final _authController = Get.find<AuthController>();
  final _ptController = Get.find<PropertiesTaxController>();
  late final PropertyRegistrationController _propertyController;

  @override
  void initState() {
    super.initState();
    // Try to find existing controller first, if not found create new one
    try {
      _propertyController = Get.find<PropertyRegistrationController>();
    } catch (e) {
      _propertyController = Get.put(PropertyRegistrationController());
    }
  }

  String _getTenantIdFromCity() {
    // Get tenant ID from user's selected city via MDMS
    final languageController = Get.find<LanguageController>();
    final pincode = _propertyController.pincode.value;
    
    if (pincode.isNotEmpty) {
      final code = int.tryParse(pincode);
      if (code != null) {
        final tenant = languageController.mdmsResTenant.tenants
            ?.firstWhereOrNull((tenant) => tenant.pincode?.contains(code) ?? false);
        if (tenant?.code != null) {
          return tenant!.code!;
        }
      }
    }
    
    // Fallback to default tenant
    return 'pg.citya';
  }

  String _getLocalityCode() {
    // Get actual locality code from controller
    final localityController = Get.find<LocalityController>();
    final boundaries = localityController.locality.value?.tenantBoundary;
    
    if (boundaries != null && boundaries.isNotEmpty) {
      final pincode = _propertyController.pincode.value;
      final code = int.tryParse(pincode);
      
      if (code != null) {
        final boundary = boundaries.first.boundary
            ?.firstWhereOrNull((b) => b.pinCode?.contains(code) ?? false);
        if (boundary?.code != null) {
          return boundary!.code!;
        }
      }
    }
    
    // Fallback to locality name
    return _propertyController.locality.value;
  }

  String _getOwnershipCategory() {
    final ownershipType = _propertyController.ownershipType.value.toLowerCase();
    switch (ownershipType) {
      case 'single':
        return 'INDIVIDUAL.SINGLEOWNER';
      case 'multiple':
        return 'INDIVIDUAL.MULTIPLEOWNERS';
      case 'government':
        return 'INSTITUTIONAL.GOVERNMENT';
      case 'private':
        return 'INSTITUTIONAL.PRIVATE';
      default:
        return 'INDIVIDUAL.SINGLEOWNER';
    }
  }

  String _getOwnerType() {
    final specialCategory = _propertyController.specialCategory.value;
    if (specialCategory == 'Not Applicable') return 'NONE';
    
    switch (specialCategory) {
      case 'Below Poverty Line':
        return 'BPL';
      case 'Defense Personnel':
        return 'DEFENCE';
      case 'Freedom Fighter':
        return 'FREEDOMFIGHTER';
      case 'Handicapped/ Disabled':
        return 'HANDICAPPED';
      case 'Widow':
        return 'WIDOW';
      default:
        return 'NONE';
    }
  }

  String _getRelationship() {
    final relationship = _propertyController.relationship.value.toLowerCase();
    switch (relationship) {
      case 'husband':
        return 'HUSBAND';
      case 'father':
        return 'FATHER';
      default:
        return 'FATHER';
    }
  }

  String _getOccupancyType() {
    final occupancy = _propertyController.occupancy.value.toLowerCase();
    switch (occupancy) {
      case 'self_occupied':
      case 'self-occupied':
        return 'SELFOCCUPIED';
      case 'rented':
        return 'RENTED';
      case 'vacant':
        return 'VACANT';
      default:
        return 'SELFOCCUPIED';
    }
  }

  String _getPropertyType() {
    final propertyType = _propertyController.propertyType.value.toLowerCase();
    if (propertyType.contains('independent')) {
      return 'BUILTUP.INDEPENDENTPROPERTY';
    } else if (propertyType.contains('flat') || propertyType.contains('part of building')) {
      return 'BUILTUP.SHAREDPROPERTY';
    }
    return 'BUILTUP.INDEPENDENTPROPERTY';
  }

  Future<void> _submitApplication() async {
    try {
      Loaders.showLoadingDialog(context, label: 'Submitting...');

      // Use the new buildPropertyPayload method from PropertiesTaxController
      final tenantId = _getTenantIdFromCity();
      final property = _ptController.buildPropertyPayload(
        controller: _propertyController,
        tenantId: tenantId,
      );

      final res = await _ptController.createNewPTApplicationCitizen(
        token: _authController.token!.accessToken!,
        property: property,
      );

      Navigator.of(context).pop();

      if (res != null) {
        Get.off(
          () => PropertyRegistrationSuccessScreen(
            applicationNo: res.acknowledgementNumber ?? '',
            mainTitle: 'Property Tax Registration',
            appIdName: 'Application Number',
            message: 'Your property tax registration has been submitted successfully. You will receive updates on your registered mobile number.',
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit application. Please try again.',
          backgroundColor: BaseConfig.redColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      Get.snackbar(
        'Error',
        'Failed to submit application: ${e.toString()}',
        backgroundColor: BaseConfig.redColor,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: BaseConfig.borderColor),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: BaseConfig.appThemeColor1,
            ),
          ),
          SizedBox(height: 12.h),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    item['label']!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: BaseConfig.textColor2,
                    ),
                  ),
                ),
                Text(
                  ': ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BaseConfig.textColor2,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    item['value']!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: BaseConfig.textColor,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderTop(
        titleWidget: const Text('Property Tax Registration'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registration Summary',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please review all the information before submitting your application.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: BaseConfig.textColor2,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Obx(() => _buildSectionCard(
                    title: 'Property Details',
                    items: [
                      {'label': 'Property Type', 'value': _propertyController.propertyType.value.isNotEmpty ? _propertyController.propertyType.value : 'Not specified'},
                      {'label': 'Structure Type', 'value': _propertyController.structureType.value.isNotEmpty ? _propertyController.structureType.value : 'Not specified'},
                      {'label': 'Property Age', 'value': _propertyController.propertyAge.value.isNotEmpty ? _propertyController.propertyAge.value : 'Not specified'},
                      {'label': 'Electricity Number', 'value': _propertyController.electricityNumber.value.isNotEmpty ? _propertyController.electricityNumber.value : 'Not specified'},
                      {'label': 'Unique ID', 'value': _propertyController.uniqueId.value.isNotEmpty ? _propertyController.uniqueId.value : 'Not specified'},
                      {'label': 'Area (sqft)', 'value': _propertyController.areaSqft.value.isNotEmpty ? _propertyController.areaSqft.value : 'Not specified'},
                    ],
                  )),
                  Obx(() => _buildSectionCard(
                    title: 'Floor Details',
                    items: [
                      {'label': 'Basement', 'value': _propertyController.basement.value.isNotEmpty ? _propertyController.basement.value : 'Not specified'},
                      {'label': 'Floors', 'value': _propertyController.floors.value.isNotEmpty ? _propertyController.floors.value : 'Not specified'},
                      {'label': 'Ground Floor', 'value': _propertyController.groundFloor.value.isNotEmpty ? _propertyController.groundFloor.value : 'Not specified'},
                      {'label': 'Unit Usage Type', 'value': _propertyController.unitUsageType.value.isNotEmpty ? _propertyController.unitUsageType.value : 'Not specified'},
                      {'label': 'Sub Usage Type', 'value': _propertyController.subUsageType.value.isNotEmpty ? _propertyController.subUsageType.value : 'Not specified'},
                      {'label': 'Occupancy', 'value': _propertyController.occupancy.value.isNotEmpty ? _propertyController.occupancy.value : 'Not specified'},
                      {'label': 'Built-up Area (sqft)', 'value': _propertyController.builtUpArea.value.isNotEmpty ? _propertyController.builtUpArea.value : 'Not specified'},
                    ],
                  )),
                  Obx(() => _buildSectionCard(
                    title: 'Address Details',
                    items: [
                      {'label': 'Pincode', 'value': _propertyController.pincode.value.isNotEmpty ? _propertyController.pincode.value : 'Not specified'},
                      {'label': 'City', 'value': _propertyController.city.value.isNotEmpty ? _propertyController.city.value : 'Not specified'},
                      {'label': 'Locality', 'value': _propertyController.locality.value.isNotEmpty ? _propertyController.locality.value : 'Not specified'},
                      {'label': 'Street Name', 'value': _propertyController.streetName.value.isNotEmpty ? _propertyController.streetName.value : 'Not specified'},
                      {'label': 'House No', 'value': _propertyController.houseNo.value.isNotEmpty ? _propertyController.houseNo.value : 'Not specified'},
                      {'label': 'Landmark', 'value': _propertyController.landmark.value.isNotEmpty ? _propertyController.landmark.value : 'Not specified'},
                      {'label': 'Latitude', 'value': _propertyController.latitude.value.isNotEmpty ? _propertyController.latitude.value : 'Not specified'},
                      {'label': 'Longitude', 'value': _propertyController.longitude.value.isNotEmpty ? _propertyController.longitude.value : 'Not specified'},
                    ],
                  )),
                  Obx(() {
                    // Build owner details for multiple owners
                    List<Map<String, String>> ownerItems = [];
                    ownerItems.add({'label': 'Ownership Type', 'value': _propertyController.ownershipType.value.isNotEmpty ? _propertyController.ownershipType.value : 'Not specified'});
                    
                    // Add all owners from allOwners list
                    if (_propertyController.allOwners.isNotEmpty) {
                      for (int i = 0; i < _propertyController.allOwners.length; i++) {
                        final owner = _propertyController.allOwners[i];
                        final ownerPrefix = _propertyController.allOwners.length > 1 ? 'Owner ${i + 1} - ' : '';
                        
                        ownerItems.addAll([
                          {'label': '${ownerPrefix}Name', 'value': owner['name']?.toString() ?? 'Not specified'},
                          {'label': '${ownerPrefix}Gender', 'value': owner['gender']?.toString() ?? 'Not specified'},
                          {'label': '${ownerPrefix}Mobile', 'value': owner['mobileNumber']?.toString().isNotEmpty == true ? '+91 ${owner['mobileNumber']}' : 'Not specified'},
                          {'label': '${ownerPrefix}Guardian', 'value': owner['guardian']?.toString() ?? 'Not specified'},
                          {'label': '${ownerPrefix}Relationship', 'value': owner['relationship']?.toString() ?? 'Not specified'},
                          {'label': '${ownerPrefix}Email', 'value': owner['email']?.toString().isNotEmpty == true ? owner['email'].toString() : 'Not specified'},
                          if (owner['permanentAddress']?.toString().isNotEmpty == true)
                            {'label': '${ownerPrefix}Address', 'value': owner['permanentAddress'].toString()},
                        ]);
                        
                        // Add separator between owners
                        if (i < _propertyController.allOwners.length - 1) {
                          ownerItems.add({'label': '---', 'value': '---'});
                        }
                      }
                    } else {
                      // Fallback to single owner data
                      ownerItems.addAll([
                        {'label': 'Owner Name', 'value': _propertyController.ownerName.value.isNotEmpty ? _propertyController.ownerName.value : 'Not specified'},
                        {'label': 'Gender', 'value': _propertyController.gender.value.isNotEmpty ? _propertyController.gender.value : 'Not specified'},
                        {'label': 'Mobile Number', 'value': _propertyController.mobileNumber.value.isNotEmpty ? '+91 ${_propertyController.mobileNumber.value}' : 'Not specified'},
                        {'label': 'Guardian', 'value': _propertyController.guardian.value.isNotEmpty ? _propertyController.guardian.value : 'Not specified'},
                        {'label': 'Relationship', 'value': _propertyController.relationship.value.isNotEmpty ? _propertyController.relationship.value : 'Not specified'},
                        {'label': 'Email ID', 'value': _propertyController.email.value.isNotEmpty ? _propertyController.email.value : 'Not specified'},
                      ]);
                    }
                    
                    return _buildSectionCard(
                      title: 'Owner Details',
                      items: ownerItems,
                    );
                  }),
                  Obx(() => _buildSectionCard(
                    title: 'Special Category',
                    items: [
                      {'label': 'Category', 'value': _propertyController.specialCategory.value.isNotEmpty ? _propertyController.specialCategory.value : 'Not specified'},
                    ],
                  )),
                  Obx(() => _buildSectionCard(
                    title: 'Documents',
                    items: [
                      {'label': 'Proof of Identity', 'value': _propertyController.identityDocType.value.isNotEmpty ? _propertyController.identityDocType.value : 'Not specified'},
                      {'label': 'Identity Document', 'value': _propertyController.identityFile.value != null ? _propertyController.identityFile.value!.path.split('/').last : 'Not uploaded'},
                      {'label': 'Proof of Address', 'value': _propertyController.addressDocType.value.isNotEmpty ? _propertyController.addressDocType.value : 'Not specified'},
                      {'label': 'Address Document', 'value': _propertyController.addressFile.value != null ? _propertyController.addressFile.value!.path.split('/').last : 'Not uploaded'},
                    ],
                  )),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: BaseConfig.appThemeColor1),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: BaseConfig.appThemeColor1,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BaseConfig.appThemeColor1,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}