import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/property_owner_screen.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class PropertyIntermediateScreen extends StatefulWidget {
  final String selectedPropertyType;
  
  const PropertyIntermediateScreen({
    super.key,
    required this.selectedPropertyType,
  });

  @override
  State<PropertyIntermediateScreen> createState() => _PropertyIntermediateScreenState();
}

class _PropertyIntermediateScreenState extends State<PropertyIntermediateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _builtUpAreaController = TextEditingController();
  String? selectedUnitUsageType;
  String? selectedSubUsageType;
  String? selectedOccupancy;
  String? selectedFloor;
  late final PropertyRegistrationController _propertyController;

  List<Map<String, String>> subUsageTypes = [];

  @override
  void initState() {
    super.initState();
    _propertyController = Get.find<PropertyRegistrationController>();
  }

  bool get isPartOfBuilding {
    print('Property Type: ${widget.selectedPropertyType}');
    return widget.selectedPropertyType.toLowerCase().contains('part of building') || 
           widget.selectedPropertyType.toLowerCase().contains('flat');
  }

  final List<Map<String, String>> floorOptions = [
    {'code': 'ground', 'name': 'Ground Floor'},
    {'code': 'first', 'name': 'First Floor'},
    {'code': 'second', 'name': 'Second Floor'},
    {'code': 'third', 'name': 'Third Floor'},
    {'code': 'basement', 'name': 'Basement'},
  ];

  final List<Map<String, String>> unitUsageTypes = [
    {'code': 'others', 'name': 'Others'},
    {'code': 'institutional', 'name': 'Institutional Consumers'},
    {'code': 'industrial', 'name': 'Industrial Establishments'},
    {'code': 'commercial', 'name': 'Commercial Establishments'},
    {'code': 'residential', 'name': 'Residential/ Domestic Consumers'},
  ];

  final Map<String, List<Map<String, String>>> subUsageTypeMap = {
    'others': [
      {'code': 'cremation_burial', 'name': 'Cremation/ Burial Ground'},
    ],
    'institutional': [
      {'code': 'govt_aided_edu', 'name': 'Govt. Aided Educational Institute'},
      {'code': 'private_edu', 'name': 'Other Private Educational Institute'},
      {'code': 'school', 'name': 'School'},
      {'code': 'community_hall', 'name': 'Community Hall'},
      {'code': 'colleges', 'name': 'Colleges'},
    ],
    'industrial': [
      {'code': 'manufacturing', 'name': 'Manufacturing Facility'},
      {'code': 'godown_warehouse', 'name': 'Godown / Warehouse'},
    ],
    'commercial': [
      {'code': 'other_commercial', 'name': 'Other Commercial Usage'},
      {'code': 'multiplex', 'name': 'Multiplex'},
      {'code': 'malls', 'name': 'Malls'},
      {'code': 'shop_showroom', 'name': 'Shop/Showroom'},
    ],
  };

  final List<Map<String, String>> occupancyTypes = [
    {'code': 'UNOCCUPIED', 'name': 'Vacant'},
    {'code': 'SELFOCCUPIED', 'name': 'Self-Occupied'},
    {'code': 'RENTED', 'name': 'Rented'},
  ];

  void _updateSubUsageTypes(String? usageType) {
    setState(() {
      selectedSubUsageType = null;
      subUsageTypes = usageType != null ? (subUsageTypeMap[usageType] ?? []) : [];
    });
  }

  @override
  void dispose() {
    _builtUpAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderTop(
        titleWidget: const Text('Property Tax Registration'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPartOfBuilding ? 'Floor Details' : 'Ground Floor Details',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isPartOfBuilding 
                          ? 'Select floor and enter built-up area and Usage Type'
                          : 'Enter built-up area on the ground floor and Usage Type',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: BaseConfig.greyColor3,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    if (isPartOfBuilding)
                      Text(
                        'Select Floor *',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (isPartOfBuilding)
                      SizedBox(height: 8.h),
                    if (isPartOfBuilding)
                      DropdownButtonFormField<String>(
                        value: selectedFloor,
                        decoration: InputDecoration(
                          hintText: 'Select floor',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        items: floorOptions.map((floor) {
                          return DropdownMenuItem(
                            value: floor['code'],
                            child: Text(floor['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFloor = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Floor selection is required';
                          }
                          return null;
                        },
                      ),
                    if (isPartOfBuilding)
                      SizedBox(height: 16.h),
                    Text(
                      'Unit Usage Type *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: selectedUnitUsageType,
                      decoration: InputDecoration(
                        hintText: 'Select unit usage type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: unitUsageTypes.map((type) {
                        return DropdownMenuItem(
                          value: type['code'],
                          child: Text(type['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnitUsageType = value;
                        });
                        _updateSubUsageTypes(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unit usage type is required';
                        }
                        return null;
                      },
                    ),
                    if (subUsageTypes.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Text(
                        'Sub Usage Type *',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<String>(
                        value: selectedSubUsageType,
                        decoration: InputDecoration(
                          hintText: 'Select sub usage type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        items: subUsageTypes.map((type) {
                          return DropdownMenuItem(
                            value: type['code'],
                            child: Text(type['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubUsageType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sub usage type is required';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 16.h),
                    Text(
                      'Occupancy *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: selectedOccupancy,
                      decoration: InputDecoration(
                        hintText: 'Select occupancy type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: occupancyTypes.map((type) {
                        return DropdownMenuItem(
                          value: type['code'],
                          child: Text(type['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedOccupancy = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Occupancy is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Built-up Area (In Sq.Ft.) *',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _builtUpAreaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter built-up area in sq.ft.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Built-up area is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save data to controller
                    _propertyController.groundFloor.value = selectedFloor ?? 'ground';
                    _propertyController.unitUsageType.value = selectedUnitUsageType ?? '';
                    _propertyController.subUsageType.value = selectedSubUsageType ?? '';
                    _propertyController.occupancy.value = selectedOccupancy ?? '';
                    _propertyController.builtUpArea.value = _builtUpAreaController.text;
                    
                    Get.to(() => const PropertyOwnerScreen());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BaseConfig.appThemeColor1,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}