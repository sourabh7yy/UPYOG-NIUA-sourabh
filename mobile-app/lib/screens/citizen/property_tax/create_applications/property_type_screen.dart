import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/config/base_config.dart';
import 'package:mobile_app/controller/properties_tax_controller.dart';
import 'package:mobile_app/controller/property_registration_controller.dart';
import 'package:mobile_app/screens/citizen/property_tax/create_applications/electricity_number_screen.dart';
import 'package:mobile_app/widgets/header_widgets.dart';

class PropertyTypeScreen extends StatefulWidget {
  const PropertyTypeScreen({super.key});

  @override
  State<PropertyTypeScreen> createState() => _PropertyTypeScreenState();
}

class _PropertyTypeScreenState extends State<PropertyTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPropertyType;
  String? selectedStructureType;
  String? selectedAgeOfProperty;

  final _propertiesTaxController = Get.find<PropertiesTaxController>();
  late final PropertyRegistrationController _propertyController;
  List<String> propertyTypes = [];

  final List<Map<String, String>> structureTypes = [
    {'code': 'permanent', 'name': 'Permanent'},
    {'code': 'temporary', 'name': 'Temporary'},
    {'code': 'semi permanent', 'name': 'Semi Permanent'},
    {'code': 'RCC', 'name': 'RCC'},
  ];

  final List<Map<String, String>> ageOfPropertyOptions = [
    {'code': '10', 'name': 'greater than 10 years'},
    {'code': '15', 'name': 'greater than 15 years'},
    {'code': '25', 'name': 'greater than 24 years'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize PropertyRegistrationController
    _propertyController = Get.put(PropertyRegistrationController());
    _loadPropertyTypes();
  }
   // Asynchronous method to fetch property types from the MDMS and update the state
  Future<void> _loadPropertyTypes() async {
      // Fetch MDMS property tax form data using the controller
    await _propertiesTaxController.getEmpMdmsPTForm();
    setState(() {
          // Update the property types list with the fetched data

      propertyTypes = _getPropertyTypes();
    });
  }
// Helper method to extract property types from the MDMS response
  List<String> _getPropertyTypes() {
    final mdmsTypes = _propertiesTaxController.empMdmsResModel?.mdmsResEmp?.propertyTax?.propertyType
        ?.map((e) => e.name ?? e.code ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    
    return mdmsTypes ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderTop(
        titleWidget: const Text('PropertRegistration'),
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
                      'Type Of Property',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Obx(() => _propertiesTaxController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: propertyTypes.map((type) => _buildPropertyTypeOption(type)).toList(),
                          )),
                    if (selectedPropertyType != null)
                      SizedBox(height: 32.h),
                    if (selectedPropertyType != null)
                      Text(
                        'Structure Type *',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (selectedPropertyType != null)
                      SizedBox(height: 8.h),
                    if (selectedPropertyType != null)
                      DropdownButtonFormField<String>(
                        value: selectedStructureType,
                        decoration: InputDecoration(
                          hintText: 'Select structure type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        items: structureTypes.map((type) {
                          return DropdownMenuItem(
                            value: type['code'],
                            child: Text(type['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStructureType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Structure type is required';
                          }
                          return null;
                        },
                      ),
                    if (selectedPropertyType != null)
                      SizedBox(height: 24.h),
                    if (selectedPropertyType != null)
                      Text(
                        'Age of Property *',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (selectedPropertyType != null)
                      SizedBox(height: 8.h),
                    if (selectedPropertyType != null)
                      DropdownButtonFormField<String>(
                        value: selectedAgeOfProperty,
                        decoration: InputDecoration(
                          hintText: 'Select age of property',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                        items: ageOfPropertyOptions.map((age) {
                          return DropdownMenuItem(
                            value: age['code'],
                            child: Text(age['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAgeOfProperty = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Age of property is required';
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
                onPressed: selectedPropertyType != null ? () {
                  if (_formKey.currentState!.validate()) {
                    // Save data to controller
                    _propertyController.propertyType.value = selectedPropertyType!;
                    _propertyController.structureType.value = selectedStructureType ?? '';
                    _propertyController.propertyAge.value = selectedAgeOfProperty ?? '';
                    
                    Get.to(() => ElectricityNumberScreen(
                      selectedPropertyType: selectedPropertyType!,
                    ));
                  }
                } : null,
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

  Widget _buildPropertyTypeOption(String type) {
    final isSelected = selectedPropertyType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPropertyType = type;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? BaseConfig.appThemeColor1 : BaseConfig.borderColor,
            width: isSelected ? 2.w : 1.w,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: isSelected ? BaseConfig.appThemeColor1.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? BaseConfig.appThemeColor1 : Colors.grey,
                  width: 2.w,
                ),
                color: isSelected ? BaseConfig.appThemeColor1 : Colors.white,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: 16.w),
            Text(
              type,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? BaseConfig.appThemeColor1 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}